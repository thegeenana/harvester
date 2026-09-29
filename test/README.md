# Test layout

- `fixtures/`: synthetic recipes, Salesforce describe responses, and records
- `integration/`: opt-in scratch org tests with a disposable org alias

M1 tests should prove that preview makes no writes, records preserve lookups, invalid input fails clearly, and a rerun follows the chosen duplicate policy.
