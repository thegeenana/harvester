# Harvester

**Reproducible Salesforce test data for sandboxes and scratch orgs.**

Harvester is an open source tool for generating, previewing, and loading connected test scenarios. A subsequent capability will harvest a selected set of records from one sandbox and recreate their relationships in another. The initial Apex Lead loader is a prototype in a draft PR. It has not been deployed or tested in a live org yet.

## Why

A Salesforce test often needs a believable record graph, not isolated CSV rows. A lead conversion, quote, or order journey depends on related records, target metadata, validation rules, and automation. Rebuilding that state by hand is slow, and copying an entire sandbox is often excessive. Harvester aims to make a small scenario declarative, repeatable, inspectable, and shareable in Git. Read the [motivation](docs/motivation.md), [system design](docs/sdd.md), and [reflective generation model](docs/reflective-generation.md).

## Intended workflow

1. Author a scenario recipe in the repository.
2. Inspect the target org, effective user's permissions, object and field metadata, types, and relationships.
3. Reconcile the scenario against those capabilities; generate compatible data and preview the proposed writes and uncertainties.
4. Confirm the target org and apply the plan.
5. Read back the graph and report desired versus observed state, with IDs, errors, and a run identifier.
6. Run again with an explicit policy for already-created records.

The [Lead dataset and first-load guide](docs/lead-first-load.md) give the first executable path. The [Account–Opportunity recipe](examples/account-opportunity.json) remains a design example.

## Scope and sequence

| Milestone | Outcome |
| --- | --- |
| M0 — design and Lead prototype | Design documents, 30 synthetic Leads, Apex PLAN/APPLY service and tests; org deployment pending |
| M1 — Lead proof | Deploy and test in a disposable org; read back Lead state; establish rerun policy and org guard |\n| M2 — connected generation | Plan and load Account–Contact, then Opportunity and required pricing records |

| M3 — harvesting | Select a bounded source graph; redact sensitive fields; map IDs and load into a target; verify links |
| Later | Large-volume jobs, complex cycles, files, and a UI, guided by real use cases |

Harvester concerns **record data**, not metadata deployments. It complements Salesforce CLI data commands and existing seeding products; its focus is scenario recipes, explainable plans, and reproducible results.

## Repository

- `docs/motivation.md` — problem, audience, and boundaries
- `docs/sdd.md` — architecture, contracts, workflow, and acceptance criteria
- `docs/reflective-generation.md` — org inspection, reconciliation, verification, and researched comparison
- `docs/lead-first-load.md` — Apex Lead proof and run instructions\n- `docs/adr/` — decisions and consequences
- `examples/` — proposed scenario recipes
- `src/` and `test/` — reserved layout for the first implementation

## Safety principles

The initial target is a sandbox or scratch org. The prototype requires an exact org ID for APPLY; its Apex code does not yet enforce non-production org classification. The caller must check the target. Preview is read-only. Credentials and harvested personal data must not be committed. Source data is never written to the target without an explicit field policy. See [ADR 0004](docs/adr/0004-data-safety.md).

## Contributing

Design feedback and concrete test scenarios are welcome. Start with the SDD and ADRs. Record a changed architectural decision in a new ADR rather than silently editing its history. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Status

Apex Lead PLAN/APPLY prototype committed. It has not been compiled, deployed, or executed in an org in this session. Read-back verification and cross-run idempotency remain open.
