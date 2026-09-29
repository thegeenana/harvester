# ADR 0001 — Scenario recipes are the primary unit

Status: Accepted for initial design, 29 September 2026.

## Context

Flat files and broad sandbox copies can be useful, but a developer usually wants the smallest connected set of records that proves a behavior. Generated data and harvested data share the same need to describe a bounded graph and its relationships.

## Decision

A versioned scenario recipe is Harvester's primary input. It names nodes, counts, fields or generators, and explicit relationships. Generation comes first. Harvesting later uses a bounded selection and transformation policy to produce the same conceptual graph. Recipes are suitable for review in Git; target org identity is supplied at execution time.

## Alternatives

- A generic object-by-object CSV loader: simple but weak for repeatable connected scenarios.
- A snapshot of an entire sandbox: useful for broader seeding but too large and sensitive for the first learning and testing workflow.
- A UI-only configuration: easier for some users, less reviewable and harder to reproduce initially.

## Consequences

The recipe schema needs versioning and helpful validation. Some org-specific constraints cannot be represented generically and require target inspection. We will validate its usability with actual Salesforce scenarios before treating the example schema as stable.
