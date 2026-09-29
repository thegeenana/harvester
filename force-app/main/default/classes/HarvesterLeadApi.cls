@RestResource(urlMapping='/harvester/v1/leads/*')
global with sharing class HarvesterLeadApi {
    @HttpPost
    global static void post() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        try {
            HarvesterLeadLoader.Request request = (HarvesterLeadLoader.Request)
                JSON.deserialize(RestContext.request.requestBody.toString(),
                    HarvesterLeadLoader.Request.class);
            HarvesterLeadLoader.Result result = HarvesterLeadLoader.execute(request);
            response.statusCode = result.blocked ? 422 : 200;
            response.responseBody = Blob.valueOf(JSON.serialize(result));
        } catch (System.JSONException error) {
            response.statusCode = 400;
            response.responseBody = Blob.valueOf('{"error":"Invalid JSON request."}');
        }
    }
}
