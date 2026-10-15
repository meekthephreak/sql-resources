# SQL Resources

Hands-on SQL practice using a fictional IT help desk. Examples target **MySQL 8.0.16+**, including enforced CHECK constraints, CTEs, and window functions. MySQL Workbench is the client; you also need a running MySQL server and a connection with permission to create a lab database.

## Quick start in MySQL Workbench

1. Download or clone this repository and connect Workbench to your MySQL server.
2. Choose **File > Open SQL Script** and open [the standalone practice lab](sample-database/MySQL_Workbench_Practice.sql).
3. Execute the entire script using the Execute All lightning button. Read the setup count results and refresh **SCHEMAS**.
4. Expand `sql_resources_helpdesk_lab`. Attempt the 22 commented exercises before using the commented answer key.

The standalone lab contains schema, seed data, exercises, and expected answers. It leaves existing records unchanged when rerun; it does not reset completed edits.

## Learning path

| Step | Material | Purpose |
|---|---|---|
| 1 | [Cheat sheet](sql-cheat-sheet/cheat-sheet.md) | Syntax and common mistakes |
| 2 | [Sample database](sample-database/README.md) | Load and understand the data |
| 3 | [SQL scripts](sql-code/README.md) | Run 21 queries, functions, procedures, and a trigger |
| 4 | [Advanced topics](sql-cheat-sheet/advanced-topics.md) | CTEs, windows, transactions, views, indexes, query plans |
| 5 | [Security](sql-cheat-sheet/security.md) | Parameterization and least privilege |

The modular schema/data scripts and standalone lab are alternative loaders for the same database. Do not expect twice as many records if you execute both.

## Prerequisites and behavior

- Basic query practice requires database/table creation and read/write permissions in this lab schema.
- Stored routines, triggers, and views require additional privileges; see the individual guides.
- Use a disposable lab database. Examples explicitly select `sql_resources_helpdesk_lab`.
- Transaction demos roll back their changes. DDL such as CREATE, DROP, and ALTER can implicitly commit in MySQL; keep DDL outside those demos.
- Dates are fixed to October 2026 so expected results stay reproducible.
- No real accounts, operational data, or credentials are included.

## Validation

The seed relationships and all 21 read queries were checked locally using SQLite with a MySQL DATEDIFF compatibility function. Native MySQL execution was unavailable during authoring. MySQL-specific routines, triggers, privilege examples, and DDL need verification on your MySQL server. The [validation script](sql-code/validate.sql) checks the original seed data and exercises the rollback demos.

## Contributing and license

See [contribution guidelines](CONTRIBUTING.md), the [Code of Conduct](CODE_OF_CONDUCT.md), and the [MIT license](LICENSE).
