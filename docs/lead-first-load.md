# First Lead load: spreadsheet to Apex

Status: prototype. The [workbook](../examples/Harvester%20Lead%20Generation%20v0.1.xlsx) and [JSON payload](../examples/leads-plan.json) contain 30 synthetic rows generated with seed 1042. Emails use example.com and phone values use UK fictional numbers. The workbook's HarvesterKey is a local correlation key, not a Salesforce field.

## Boundary and responsibilities

- Generator: fixed lists and a seeded 32-bit sequence produce rows. It makes no assumption about target metadata.
- Payload: selects supported Lead fields and carries a stable key. Status and LeadSource are omitted so org defaults may apply. A custom required field blocks the current loader.
- Apex PLAN: inspects running user's Lead create access; seven selected fields' createability and lengths; other required writable fields without create defaults; row keys, required names, and duplicate email values within the request. No DML.
- Apex APPLY: repeats inspection, requires expectedOrgId, inserts at most 200 rows with user-mode DML and allOrNone=false. Reports ID or error for each row.
- Observe: this slice reports CREATED_UNVERIFIED; a subsequent milestone must read back records and evaluate desired state.

Describe cannot predict validation rules, duplicate rules, flows, triggers, or assignment results completely. A PLAN that passes may still have per-row failures. No cross-run duplicate protection exists yet; do **not** repeat APPLY to retry a response without inspecting the first result.

## Run in a disposable sandbox or scratch org

1. Review the target org and deploy `force-app` with `sf project deploy start --source-dir force-app --target-org YOUR_ALIAS`.
2. Run `sf apex run test --tests HarvesterLeadLoaderTest --target-org YOUR_ALIAS --result-format human --wait 10`.
3. Grant the intended user access to the Apex REST class and Lead create/field permissions. Inspect the target org ID with `sf data query --query "SELECT Id, IsSandbox FROM Organization LIMIT 1" --target-org YOUR_ALIAS`.
4. Send the checked-in PLAN body:
   `sf api request rest /services/apexrest/harvester/v1/leads/ --method POST --body @examples/leads-plan.json --target-org YOUR_ALIAS --header "Content-Type: application/json"`
5. Review blockers and the reported org ID. Make a local copy of the payload, set `mode` to `APPLY` and `expectedOrgId` to that exact ID. Confirm it is the intended non-production org, then repeat the request with your local file.
6. Keep the per-row IDs and failures. Do not check locally edited APPLY payloads or results into Git.

No org was connected in this repository-writing session; the deployment and live test remain to be run. The loader cannot itself prevent deployment to production. A production guard and read-back verification are follow-up work.
