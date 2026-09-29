# Motivation

## The problem

Salesforce development and testing depend on data shape. A realistic test may need Accounts, Contacts, Opportunities, a Pricebook, Products, and line items whose relationships and business fields are internally consistent. Creating those records by hand takes time. A flat import can leave lookups unresolved. Copying a whole environment can bring too much data, including information that should not travel.

The project began with a practical question: can an engineer define the *scenario needed to prove a behavior*, generate it reliably in a scratch org or sandbox, and later reproduce a selected scenario from one sandbox in another? The name **Harvester** captures the second part, while generation makes the tool useful before source data exists.

## Who it serves

- Salesforce developers building isolated feature and regression tests.
- QA engineers preparing repeatable end-to-end cases.
- Release engineers diagnosing a defect across environments.
- Teachers and students learning Salesforce data relationships, APIs, and safe data movement.

## Product promise

A recipe describes the desired record graph and meaningful variation. Harvester shows what it plans to create, validates target capabilities, applies records in dependency order, and returns evidence of what happened. Harvest mode later selects a bounded source graph, transforms sensitive values, and reconstructs it in a target with new record IDs.

A run must be understandable: which org, which recipe, which objects and fields, how many records, what was transformed, what succeeded, and what needs repair.

## Existing tools and intended difference

Salesforce CLI offers tree import/export for small related datasets and Bulk API commands for larger data. Commercial sandbox seeding tools offer selection, masking, and deployment. Harvester is not premised on these capabilities being absent. Its intended contribution is a Git-friendly **scenario-as-code** workflow with deterministic generation, a useful dry run, explicit data policies, and a teachable architecture.

This is a hypothesis to test with users, not a claim of unique functionality. We should compare actual workflows and narrow the product based on evidence.

## Boundaries

Initial releases support selected objects and bounded graphs. They do not promise an arbitrary copy of every Salesforce object, metadata deployment, production data replication, or bypass of target validation and automation. The first end-to-end proof should be deliberately small, observable, and safe.
