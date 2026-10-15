# Contributing to SQL Resources

Open an issue for errors or suggestions, or fork the repository and submit a focused pull request.

## SQL contribution requirements

1. Target MySQL 8.0.16+ and state any additional version or privilege requirements.
2. Use the fictional help desk dataset or document a new dataset completely.
3. Include executable examples, expected results, and clear instructions.
4. Preview writes and use complete rollback demos where appropriate. Keep DDL outside demo transactions.
5. Explain rerun behavior. Do not include unqualified production-facing destructive commands.
6. Add or update relative documentation links and execution order.
7. Never include real credentials, personal records, or operational data.

## Validation

Load a fresh lab, run the changed scripts, and execute `sql-code/validate.sql`. Every `passed` result should be 1. Run routine/trigger rollback demos in full and confirm both data and audit changes are reverted. Report your exact MySQL version, checks performed, and any checks you could not run; do not label SQLite validation as native MySQL testing.

For a PR, describe the problem, resulting behavior, and validation. Keep changes focused and use descriptive commit messages.

## Community

Follow the [Code of Conduct](CODE_OF_CONDUCT.md). Use GitHub issues for non-sensitive questions. Do not publish secrets or personal information when reporting problems.
