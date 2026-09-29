@IsTest
private class HarvesterLeadLoaderTest {
    private static HarvesterLeadLoader.LeadInput row(String key, String email) {
        HarvesterLeadLoader.LeadInput input = new HarvesterLeadLoader.LeadInput();
        input.key = key;
        input.firstName = 'Amara';
        input.lastName = 'Sample';
        input.company = 'Harvester Test';
        input.email = email;
        return input;
    }
    @IsTest static void planHasNoWritesAndApplyCreatesRows() {
        HarvesterLeadLoader.Request request = new HarvesterLeadLoader.Request();
        request.mode = 'PLAN';
        request.rows = new List<HarvesterLeadLoader.LeadInput>{
            row('lead-1', 'lead-1@example.com'), row('lead-2', 'lead-2@example.com')
        };
        Integer beforeRows = Limits.getDmlRows();
        HarvesterLeadLoader.Result planned = HarvesterLeadLoader.execute(request);
        System.assertEquals(false, planned.blocked, String.join(planned.blockers, '; '));
        System.assertEquals(0, planned.created);
        System.assertEquals(beforeRows, Limits.getDmlRows());
        request.mode = 'APPLY';
        request.expectedOrgId = UserInfo.getOrganizationId();
        HarvesterLeadLoader.Result applied = HarvesterLeadLoader.execute(request);
        System.assertEquals(false, applied.blocked, String.join(applied.blockers, '; '));
        System.assertEquals(2, applied.created);
        System.assertEquals('CREATED_UNVERIFIED', applied.rows[0].status);
        System.assertEquals(2, [SELECT COUNT() FROM Lead WHERE Id IN
            :new Set<Id>{applied.rows[0].id, applied.rows[1].id}]);
    }
    @IsTest static void wrongOrgAndInvalidRowsBlockEntireBatch() {
        HarvesterLeadLoader.Request request = new HarvesterLeadLoader.Request();
        request.mode = 'APPLY';
        request.expectedOrgId = 'wrong-org';
        request.rows = new List<HarvesterLeadLoader.LeadInput>{
            row('same', 'duplicate@example.com'), row('same', 'duplicate@example.com')
        };
        Integer beforeRows = Limits.getDmlRows();
        HarvesterLeadLoader.Result result = HarvesterLeadLoader.execute(request);
        System.assertEquals(true, result.blocked);
        System.assertEquals(0, result.created);
        System.assertEquals(beforeRows, Limits.getDmlRows());
    }
    @IsTest static void apiReturnsPlanAndRejectsBadJson() {
        RestRequest http = new RestRequest();
        http.requestUri = '/services/apexrest/harvester/v1/leads/';
        http.httpMethod = 'POST';
        http.requestBody = Blob.valueOf(
            '{"mode":"PLAN","rows":[{"key":"api-1","lastName":"Sample","company":"Example"}]}');
        RestContext.request = http;
        RestContext.response = new RestResponse();
        HarvesterLeadApi.post();
        System.assertEquals(200, RestContext.response.statusCode);
        http.requestBody = Blob.valueOf('{broken');
        RestContext.response = new RestResponse();
        HarvesterLeadApi.post();
        System.assertEquals(400, RestContext.response.statusCode);
    }
}
