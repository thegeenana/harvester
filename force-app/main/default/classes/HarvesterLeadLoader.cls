public with sharing class HarvesterLeadLoader {
    public class LeadInput {
        public String key;
        public String firstName;
        public String lastName;
        public String company;
        public String email;
        public String phone;
        public String city;
        public String description;
    }
    public class Request {
        public String mode;
        public String expectedOrgId;
        public List<LeadInput> rows;
    }
    public class RowOutcome {
        public String key;
        public String status;
        public Id id;
        public List<String> errors = new List<String>();
    }
    public class Result {
        public String orgId;
        public String userId;
        public String mode;
        public Integer requested = 0;
        public Integer created = 0;
        public Boolean blocked = false;
        public List<String> blockers = new List<String>();
        public List<String> warnings = new List<String>();
        public List<RowOutcome> rows = new List<RowOutcome>();
    }

    private static final Integer MAX_ROWS = 200;
    private static final List<String> FIELD_NAMES = new List<String>{
        'FirstName', 'LastName', 'Company', 'Email', 'Phone', 'City', 'Description'
    };

    public static Result execute(Request input) {
        Result output = new Result();
        output.orgId = UserInfo.getOrganizationId();
        output.userId = UserInfo.getUserId();
        output.mode = input == null ? null : input.mode;
        if (input == null || (input.mode != 'PLAN' && input.mode != 'APPLY')) {
            output.blockers.add('mode must be PLAN or APPLY.');
            output.blocked = true;
            return output;
        }
        if (input.rows == null || input.rows.isEmpty() || input.rows.size() > MAX_ROWS) {
            output.blockers.add('Provide 1 to ' + MAX_ROWS + ' Lead rows.');
            output.blocked = true;
            return output;
        }
        output.requested = input.rows.size();
        if (input.mode == 'APPLY' &&
            (String.isBlank(input.expectedOrgId) || input.expectedOrgId != output.orgId)) {
            output.blockers.add('expectedOrgId must match the executing org before APPLY.');
        }

        Schema.DescribeSObjectResult objectInfo = Lead.SObjectType.getDescribe();
        if (!objectInfo.isCreateable()) {
            output.blockers.add('Running user cannot create Lead.');
        }
        Map<String, Schema.SObjectField> fields = objectInfo.fields.getMap();
        for (String fieldName : FIELD_NAMES) {
            Schema.DescribeFieldResult fieldInfo = fields.get(fieldName).getDescribe();
            if (!fieldInfo.isCreateable()) {
                output.blockers.add('Running user cannot create Lead.' + fieldName + '.');
            }
        }
        Set<String> supported = new Set<String>(FIELD_NAMES);
        for (String fieldName : fields.keySet()) {
            Schema.DescribeFieldResult fieldInfo = fields.get(fieldName).getDescribe();
            if (fieldInfo.isCreateable() && !fieldInfo.isNillable() &&
                !fieldInfo.isDefaultedOnCreate() && !fieldInfo.isCalculated() &&
                !supported.contains(fieldName)) {
                output.blockers.add('Required field Lead.' + fieldName +
                    ' needs an explicit generator or default; this slice does not support it.');
            }
        }

        Set<String> keys = new Set<String>();
        Set<String> emails = new Set<String>();
        List<Lead> records = new List<Lead>();
        for (Integer index = 0; index < input.rows.size(); index++) {
            LeadInput row = input.rows[index];
            RowOutcome outcome = new RowOutcome();
            outcome.key = row == null ? null : row.key;
            outcome.status = 'PLANNED';
            output.rows.add(outcome);
            if (row == null) {
                output.blockers.add('Row ' + (index + 1) + ' is null.');
                continue;
            }
            if (String.isBlank(row.key) || keys.contains(row.key)) {
                output.blockers.add('Row ' + (index + 1) + ' has a blank or duplicate key.');
            } else {
                keys.add(row.key);
            }
            if (String.isBlank(row.lastName) || String.isBlank(row.company)) {
                output.blockers.add('Row ' + (index + 1) + ' needs LastName and Company.');
            }
            if (!String.isBlank(row.email) && emails.contains(row.email.toLowerCase())) {
                output.blockers.add('Row ' + (index + 1) + ' has a duplicate email in this request.');
            } else if (!String.isBlank(row.email)) {
                emails.add(row.email.toLowerCase());
            }
            Lead record = new Lead();
            Map<String, String> values = new Map<String, String>{
                'FirstName' => row.firstName, 'LastName' => row.lastName,
                'Company' => row.company, 'Email' => row.email,
                'Phone' => row.phone, 'City' => row.city,
                'Description' => row.description
            };
            for (String fieldName : FIELD_NAMES) {
                String value = values.get(fieldName);
                if (value == null) continue;
                Schema.DescribeFieldResult fieldInfo = fields.get(fieldName).getDescribe();
                if (value.length() > fieldInfo.getLength()) {
                    output.blockers.add('Row ' + (index + 1) + ' exceeds Lead.' +
                        fieldName + ' length ' + fieldInfo.getLength() + '.');
                }
                if (fieldInfo.isCreateable()) record.put(fieldName, value);
            }
            records.add(record);
        }
        output.warnings.add('Validation rules, duplicate rules, flows, triggers and assignment may still reject or alter rows.');
        output.warnings.add('This version does not provide cross-run idempotency or read-back verification.');
        output.blocked = !output.blockers.isEmpty();
        if (output.blocked || input.mode == 'PLAN') return output;

        // User mode enforces CRUD/FLS even if permissions change after the describe checks.
        Database.SaveResult[] saved = Database.insert(records, false, AccessLevel.USER_MODE);
        for (Integer i = 0; i < saved.size(); i++) {
            RowOutcome outcome = output.rows[i];
            if (saved[i].isSuccess()) {
                outcome.status = 'CREATED_UNVERIFIED';
                outcome.id = saved[i].getId();
                output.created++;
            } else {
                outcome.status = 'FAILED';
                for (Database.Error error : saved[i].getErrors()) {
                    outcome.errors.add(String.valueOf(error.getStatusCode()) + ': ' + error.getMessage());
                }
            }
        }
        return output;
    }
}
