# Implementation layout

- `cli/`: user commands, target selection, and confirmation
- `core/`: recipe validation, deterministic generation, graph planning, policies, run state
- `salesforce/`: authentication, describe/query, and write adapters

TypeScript is the design choice in ADR 0002. Runtime files and dependencies will be introduced with the M1 implementation; this directory currently contains no executable tool.
