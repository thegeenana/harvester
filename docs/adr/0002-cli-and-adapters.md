# ADR 0002 — Start with a CLI and separated core

Status: Accepted for initial design, 29 September 2026.

## Context

The tool must work in local development and CI, be teachable, and keep Salesforce API details out of graph and policy logic. A hosted service or Kubernetes deployment would add operational work before the basic scenario is proven.

## Decision

Build a standalone TypeScript CLI with a pure core for recipe validation, generation, graph ordering, policy, and planning. Put authentication, org describe/query, and writes behind Salesforce adapters. Use existing Salesforce CLI authentication context where practical; do not invent a credential store. Add a UI only after the CLI workflow has been proven.

## Alternatives

- Salesforce CLI plugin from day one: natural integration, but couples release and command structure to the plugin framework before the core stabilizes.
- Server application: supports shared runs but adds storage, tenancy, and deployment too early.
- Apex-only package: runs close to org data but complicates cross-org orchestration and local recipe workflows.

## Consequences

A CLI can be wrapped as a Salesforce CLI plugin later. Core tests can use synthetic metadata without live credentials. Dependency versions and packaging will be selected with the first implementation rather than guessed in this design scaffold.
