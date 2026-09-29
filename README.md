# Harvester

**Reproducible Salesforce test data for sandboxes and scratch orgs.**

Harvester is an open source tool for generating, previewing, and loading connected test scenarios. A subsequent capability will harvest a selected set of records from one sandbox and recreate their relationships in another. The project is at the design and scaffold stage; **it cannot connect to an org or load records yet**.

## Why

A Salesforce test often needs a believable record graph, not isolated CSV rows. A lead conversion, quote, or order journey depends on related records, target metadata, validation rules, and automation. Rebuilding that state by hand is slow, and copying an entire sandbox is often excessive. Harvester aims to make a small scenario declarative, repeatable, inspectable, and shareable in Git. Read the [motivation](docs/motivation.md) and [system design](docs/sdd.md).

## Intended workflow

1. Author a scenario recipe in the repository.
2. Inspect the target org schema and preview the proposed records and dependencies.
3. Confirm the target org and apply the plan.
4. Receive a manifest with record counts, source-to-target ID mappings where relevant, errors, and a run identifier.
5. Run again with an explicit policy for already-created records.

The [example recipe](examples/account-opportunity.json) illustrates the proposed format. It is a **design example**, not an executable input today.

## Scope and sequence

| Milestone | Outcome |
| --- | --- |
| M0 — design | Motivation, SDD, ADRs, repository layout, and sample recipe |
| M1 — generation | Authenticate to a sandbox or scratch org; describe supported objects; plan and load one connected Account–Contact scenario; verify relationships and rerun behavior |
| M2 — richer scenarios | Opportunity, Product, Pricebook, OpportunityLineItem; deterministic generation; field overrides; error reporting |
| M3 — harvesting | Select a bounded source graph; redact sensitive fields; map IDs and load into a target; verify links |
| Later | Large-volume jobs, complex cycles, files, and a UI, guided by real use cases |

Harvester concerns **record data**, not metadata deployments. It complements Salesforce CLI data commands and existing seeding products; its focus is scenario recipes, explainable plans, and reproducible results.

## Repository

- `docs/motivation.md` — problem, audience, and boundaries
- `docs/sdd.md` — architecture, contracts, workflow, and acceptance criteria
- `docs/adr/` — decisions and consequences
- `examples/` — proposed scenario recipes
- `src/` and `test/` — reserved layout for the first implementation

## Safety principles

The initial target is a sandbox or scratch org. Writes require an explicit target alias and confirmation. Preview is read-only. Credentials and harvested personal data must not be committed. Source data is never written to the target without an explicit field policy. See [ADR 0004](docs/adr/0004-data-safety.md).

## Contributing

Design feedback and concrete test scenarios are welcome. Start with the SDD and ADRs. Record a changed architectural decision in a new ADR rather than silently editing its history. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Status

M0 design scaffold. No Salesforce operations are implemented.
