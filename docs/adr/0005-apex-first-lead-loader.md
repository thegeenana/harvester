# ADR 0005 — Apex first Lead loading slice

Status: Accepted for prototype, 29 September 2026. Extends ADR 0002.

## Context

The first dataset is a spreadsheet of 30 synthetic Leads. We want to learn the target org's runtime field and permission constraints, then prove a real insert before building a general CLI. The prior TypeScript CLI architecture remains an intended orchestration path, but the first write component is Apex.

## Decision

Implement a small Apex Lead loader and authenticated Apex REST endpoint in a Salesforce DX project. The client generates and serializes rows; Apex performs same-user describe checks, a read-only PLAN, and bounded user-mode APPLY with per-row SaveResult. The caller supplies an expected org ID for APPLY. This loader handles only the seven listed Lead fields. It does not silently strip fields, disable automation, or claim a durable desired-state reconciliation.

## Consequences

Deployment of Apex and Apex-class access are prerequisites. The REST endpoint should be exposed only to authorized users in a sandbox or scratch org; this prototype does not itself prove org type. The first result is CREATED_UNVERIFIED because read-back and cross-run idempotency are future work. The service can later become an adapter behind a CLI. Tests require an org whose Lead metadata permits this sample.
