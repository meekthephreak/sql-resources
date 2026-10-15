# IT Help Desk Sample Database

All data is fictional. Use MySQL 8.0.16+ and a lab account with schema/table creation and insert privileges.

## Choose a loader

**Single file:** Open `MySQL_Workbench_Practice.sql` in Workbench and execute all. This includes 22 exercises and a commented answer key.

**Separate files:** Execute `schema.sql` first, then `data.sql` in Workbench. This creates the identical base tables and seed records, without the embedded exercises. Execute `../sql-code/queries.sql` next.

In Workbench, use **File > Open SQL Script**. Refresh SCHEMAS after execution. Each script selects `sql_resources_helpdesk_lab`; no manual default-schema selection is needed.

| Table | Fresh row count | Purpose |
|---|---:|---|
| departments | 4 | Business units |
| employees | 8 | Requesters, including two with no tickets |
| technicians | 4 | Support staff, including one with no assignments |
| assets | 8 | Owned and spare devices |
| tickets | 16 | Open, in-progress, and resolved incidents |
| work_logs | 13 | Minutes logged by technicians |

## Relationships

Employees belong to departments. Assets may belong to employees. Tickets belong to requesters and may reference an asset or technician. Work logs reference both a ticket and the technician who performed the work. The worker can differ from the assigned technician, so aggregate those roles separately.

Expected results assume the original seed. The reporting date is `2026-10-14`; unresolved tickets due before that date are overdue, while tickets due that day are not.

## Reloading and resetting

Loaders preserve existing rows by primary key. Rerunning does not restore changed rows or migrate an older table definition. For a fresh reset, deliberately drop **only** `sql_resources_helpdesk_lab` using Workbench's schema menu, then reload. This removes every lab object and change. MySQL DDL can implicitly commit; a rollback will not undo that reset.

## Troubleshooting

- Connection failure: ensure a MySQL server is running; Workbench alone is not a server.
- Access denied: request lab permissions; do not disable server security settings.
- Missing tables: run `schema.sql` before `data.sql`.
- Different answers: check for earlier edits; rerunning the seed will not overwrite them.
- CHECK behavior: enforcement requires MySQL 8.0.16 or newer.
