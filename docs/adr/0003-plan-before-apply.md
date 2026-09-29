# ADR 0003 — Plan before apply

Status: Accepted for initial design, 29 September 2026.

## Context

Target orgs differ in schema, required fields, permissions, picklists, and automation. A valid recipe alone cannot guarantee a successful write. A wrong target or silently broken relationship is costly to diagnose.

## Decision

Separate read-only planning from writes. The plan resolves the target org identity, checks metadata and access, orders dependencies, estimates records and operations, describes transformations, and surfaces unresolved conditions. Applying requires an explicit target and confirmation. The writer emits a manifest and a verification report.

## Alternatives

- Write immediately and rely on API errors: fewer components, but failures can leave partial graphs.
- Purely local preview: cannot detect target-specific schema and permission differences.

## Consequences

Planning adds API reads and may become stale before apply; execution rechecks critical assumptions. Automation effects may be unknowable until writes, so preview states uncertainty honestly. Partial success remains possible and must be reported.
