# ADR 0004 — Explicit boundaries for org and data safety

Status: Accepted for initial design, 29 September 2026.

## Context

A tool that moves Salesforce records can copy personal or confidential data, target the wrong org, and trigger automation that sends messages or changes downstream systems.

## Decision

Initial writes target sandbox or scratch orgs only, verified by org metadata rather than alias spelling. Production reads are outside the first milestone. Harvest mode requires explicit source selection and field policies; unknown sensitive fields are excluded or block the run until classified. Transform before durable export or target write. Logs and manifests contain IDs, counts, policy names, and errors, but no credentials or raw sensitive values. Local artifacts are ignored by Git and have a documented retention policy before harvest mode ships. Writes require explicit target confirmation; Harvester never disables target automation on its own.

## Alternatives

- Copy every field by default and mask optionally: convenient but risks disclosure.
- Forbid all record copying: safe but removes a central use case.
- Auto-disable triggers and flows: may improve imports but changes the meaning of a test and can leave org state altered.

## Consequences

Harvesting takes more configuration and may refuse a dataset. A safe masking strategy must preserve uniqueness and relationships. We will document unavoidable downstream automation risk and test policies with synthetic data before copying real records.
