# Lab Instructions, Walkthrough, and Troubleshooting

A guided route through the fictional IT help desk lab. Use this alongside the [standalone practice script](sample-database/MySQL_Workbench_Practice.sql). All examples target MySQL 8.0.16+.

## Contents

1. [Prepare Workbench](#1-prepare-workbench)
2. [Load the database](#2-load-the-database)
3. [Confirm the setup](#3-confirm-the-setup)
4. [Work through the queries](#4-work-through-the-queries)
5. [Practice safe changes](#5-practice-safe-changes)
6. [Explore routines and auditing](#6-explore-routines-and-auditing)
7. [Reset the lab](#7-reset-the-lab)
8. [Troubleshooting](#8-troubleshooting)

## 1. Prepare Workbench

You need MySQL Workbench, a running MySQL server, and an account authorized to create and use a disposable lab schema. Installing Workbench does not install or start a server automatically.

1. Download this repository using GitHub's **Code > Download ZIP**, then extract it.
2. Open Workbench and open your existing server connection. For a new connection, use the **+** beside MySQL Connections and enter the server's actual hostname, port, and account. A local server commonly uses `127.0.0.1` and port `3306`; use your configured values.
3. Choose **Test Connection**, authenticate, and open the SQL editor.
4. Open a new query tab and execute:

```sql
SELECT VERSION() AS server_version, CURRENT_USER() AS authenticated_account;
SHOW VARIABLES LIKE 'default_storage_engine';
```

Confirm MySQL 8.0.16 or newer and InnoDB as the default storage engine. The lab's rollback demonstrations assume transactional InnoDB tables. MariaDB and other SQL engines are not the target for these scripts.

## 2. Load the database

### Recommended: one file

1. Choose **File > Open SQL Script**.
2. Open `sample-database/MySQL_Workbench_Practice.sql`.
3. Clear any text selection. Click the toolbar control whose tooltip says it executes the selected portion or everything if nothing is selected. The other execution control runs only the statement under the cursor.
4. Review **Action Output** for errors. Fix the first error before chasing later errors.
5. Refresh **SCHEMAS** and expand `sql_resources_helpdesk_lab > Tables`.

The loader runs setup and a count query. Exercises and answers are inside comments, so they do not execute during setup. This is intentional.

### Alternative: separate files

Execute [schema.sql](sample-database/schema.sql), then [data.sql](sample-database/data.sql). These load the same database as the standalone file. Choose either approach; running both does not double the seed data.

## 3. Confirm the setup

Open a new query tab on the same connection:

```sql
USE sql_resources_helpdesk_lab;
SHOW TABLES;
SELECT COUNT(*) AS ticket_count FROM tickets;
```

Expect 16 tickets. A fresh lab has these six base tables:

| Table | Rows |
|---|---:|
| departments | 4 |
| employees | 8 |
| technicians | 4 |
| assets | 8 |
| tickets | 16 |
| work_logs | 13 |

An audit table appears later if you run the trigger script.

Open and execute [validate.sql](sql-code/validate.sql). Every column ending in `passed` should show `1`. These are useful baseline checks, not a complete verification of every record. They expect four overdue tickets, three unassigned tickets, seven resolved tickets, and 655 total logged minutes.

## 4. Work through the queries

For each exercise, write your own query in a new tab, execute it, inspect its Result Grid, and then compare with the answer key. Begin your tab with:

```sql
USE sql_resources_helpdesk_lab;
```

To use a supplied answer, copy only its executable SQL into your tab. Do not copy the surrounding `/* ... */` markers or the plain-text expected-result lines.

### A. Filter unresolved priority work

```sql
SELECT ticket_id, priority, status
FROM tickets
WHERE status <> 'Resolved'
  AND priority IN ('High','Critical')
ORDER BY ticket_id;
```

Expected IDs: **5, 6, 10, 14, 16**. Both conditions must hold. Parentheses matter when mixing AND and OR.

### B. Find unassigned tickets

```sql
SELECT ticket_id
FROM tickets
WHERE technician_id IS NULL
ORDER BY ticket_id;
```

Expected IDs: **7, 11, 15**. Use IS NULL instead of = NULL.

### C. Keep unassigned tickets in a join

```sql
SELECT t.ticket_id,
       COALESCE(x.technician_name,'Unassigned') AS technician
FROM tickets t
LEFT JOIN technicians x ON x.technician_id=t.technician_id
ORDER BY t.ticket_id;
```

Expect **16 rows**. Tickets 7, 11, and 15 display Unassigned. Replacing LEFT JOIN with INNER JOIN removes those three tickets.

### D. Report overdue work

```sql
SELECT ticket_id, due_date
FROM tickets
WHERE status <> 'Resolved'
  AND due_date < '2026-10-14'
ORDER BY ticket_id;
```

Expected IDs: **5, 6, 7, 10**. The report uses a fixed date so results remain reproducible. Ticket 16 is due on the reporting date and is not yet overdue under this definition. Using CURDATE() changes the question and expected results.

### E. Aggregate actual work

```sql
SELECT t.ticket_id, COALESCE(SUM(w.minutes_spent),0) AS total_minutes
FROM tickets t
LEFT JOIN work_logs w ON w.ticket_id=t.ticket_id
GROUP BY t.ticket_id
ORDER BY t.ticket_id;
```

Expect **16 rows**. Ticket 1 has **75 minutes**, ticket 9 has **105**, and ticket 7 has **0**. One ticket can have multiple work logs; counting joined rows as tickets can inflate totals.

### Continue independently

| Exercises in standalone file | Focus |
|---|---|
| 1–6 | SELECT, filtering, NULL, sorting, grouping |
| 7–15 | Joins, missing relationships, overdue reports, CASE |
| 16–21 | Date arithmetic, CTEs, window functions, percentages |
| 22 | Assignment change with rollback |

The [queries script](sql-code/queries.sql) contains executable solutions for the 21 read exercises. Use the [advanced guide](sql-cheat-sheet/advanced-topics.md) for explanations.

## 5. Practice safe changes

Run this entire block together on one connection:

```sql
USE sql_resources_helpdesk_lab;
START TRANSACTION;
UPDATE tickets SET technician_id=3 WHERE ticket_id=7;
SELECT ticket_id, technician_id FROM tickets WHERE ticket_id=7;
ROLLBACK;
SELECT ticket_id, technician_id FROM tickets WHERE ticket_id=7;
```

The first result should be **7, 3**; the second should be **7, NULL** on original data. ROLLBACK restores the preceding value, so a previously edited lab may show another value.

Workbench query tabs on the same connection share transaction state. Keep unrelated changes out of that connection while practicing. Stopping script execution does not necessarily end an open transaction; issue ROLLBACK on that connection if you stopped midway.

Do not run CREATE, ALTER, or DROP between START TRANSACTION and ROLLBACK: MySQL DDL can implicitly commit. The routine and trigger scripts create objects before starting their demo transactions.

## 6. Explore routines and auditing

Load each script in order and execute the complete file, including its DELIMITER lines.

| Script | Checkpoint |
|---|---|
| [functions.sql](sql-code/functions.sql) | Resolution-day results: (1,1), (2,1), (3,2), (4,0) |
| [procedures.sql](sql-code/procedures.sql) | Requester 1 has tickets 1, 7, 13; assignment demo rolls back |
| [triggers.sql](sql-code/triggers.sql) | Audit demo shows ticket 7 changing from NULL to 3; audit_rows_restored returns 1 |

DELIMITER is interpreted by the client so semicolons inside a routine do not prematurely end its definition. Copying only part of the definition can cause a syntax error.

The scripts require extra permissions described in [SQL code instructions](sql-code/README.md). Routine or trigger creation can also be restricted by binary-logging configuration. Request authorized lab access rather than changing global server security settings.

The trigger inserts an audit row only when technician assignment changes. Its demo rolls back the ticket update and the audit insert together; no permanent demonstration row should remain. AUTO_INCREMENT IDs can have gaps after rollback.

Run validate.sql again afterward. The baseline should still pass. For more practice, explore [views and indexes](sql-cheat-sheet/advanced-topics.md) and [security](sql-cheat-sheet/security.md).

## 7. Reset the lab

Rerunning the loaders preserves existing rows. It does **not** undo edits, remove added rows, or migrate existing table definitions.

For an intentional fresh start:

1. Save any queries you want to keep.
2. Finish or roll back pending transactions.
3. In SCHEMAS, verify the exact name **sql_resources_helpdesk_lab**.
4. Right-click that lab schema, choose **Drop Schema**, and review the generated statement before confirming. This removes all lab data, routines, triggers, and views.
5. Reload the standalone script, or schema.sql followed by data.sql.
6. Run validate.sql.

Dropping the schema cannot be undone with ROLLBACK. Reset only this disposable lab.

## 8. Troubleshooting

| Symptom | Likely cause | Next step |
|---|---|---|
| Cannot connect / error 2003 | Server stopped, wrong host/port, or connectivity blocked | Confirm the server is running and use its actual connection details; for a remote server, check the approved network path. |
| Access denied / error 1045 | Wrong credentials or account host matching | Confirm the username, password, and allowed connection host with the administrator. |
| Error 1044 or 1142 | Account lacks a schema/object privilege | Ask for the relevant lab permissions; distinguish this from a login failure. |
| No database selected / error 1046 | USE statement was skipped in a new tab | Run USE sql_resources_helpdesk_lab; before the query. |
| Unknown database / error 1049 | Schema creation failed or wrong server connection | Check Action Output and SELECT @@hostname; then rerun schema setup on the intended server. |
| Table does not exist / error 1146 | Setup was partial or schema is wrong | Check SELECT DATABASE(); and SHOW TABLES; run schema.sql before data.sql. |
| Nothing happens when executing an answer | SQL is still inside a block comment | Copy only SQL into a new query tab, without comment markers or expected-results text. |
| Only one setup statement runs | Execute-current-statement was used | Clear selection and use execute-selection-or-everything to run setup in full. |
| Syntax error / error 1064 near a routine | Missing delimiter lines or incomplete selection | Execute the full routine script in Workbench; restore DELIMITER ; afterward. |
| CTE or window syntax fails | Older server or another database engine | Check SELECT VERSION(); and use the documented MySQL version. |
| Safe-update error 1175 | UPDATE/DELETE lacks a usable key predicate | Use the provided primary-key WHERE clause and preview it with SELECT. |
| Foreign-key error 1452 | Child record refers to a missing parent | Check the referenced ID and load the seed in its supplied order; keep checks enabled. |
| Foreign-key error 1451 | A referenced parent is being deleted | Review dependent rows and the intended operation; do not disable checks to force the demo. |
| CHECK violation / error 3819 | Priority, status, or date values violate a rule | Inspect SHOW CREATE TABLE tickets; and supply consistent values. Resolved status requires a valid resolved_date. |
| Routine error 1418 or 1419 | Function characteristics or binary-logging privilege restrictions | Use the supplied definition and consult the administrator; do not weaken global settings. |
| Trigger/routine already exists | Only CREATE was rerun | Execute the complete supplied script, including its named DROP IF EXISTS statement. |
| Duplicate index name | Index exercise was run twice | Inspect SHOW INDEX FROM tickets; and drop only lab_idx_status_due before repeating its CREATE. |
| Query waits or reports a lock timeout | Another transaction holds a needed lock | Finish or roll back the lab transaction in the connection that owns it. |
| Expected answers differ | Earlier edits, different reporting date, or wrong schema | Run the baseline checks and confirm the fixed date; reset the lab if you need original data. |
| ROLLBACK does not restore changes | Earlier COMMIT/DDL, wrong connection, or nontransactional tables | Confirm the connection, transaction sequence, and table engines; reset if changes were already committed. |

### Useful diagnostics

```sql
SELECT VERSION(), DATABASE(), @@hostname, @@port, CURRENT_USER();
SHOW TABLES FROM sql_resources_helpdesk_lab;
SHOW TABLE STATUS FROM sql_resources_helpdesk_lab;
SHOW CREATE TABLE sql_resources_helpdesk_lab.tickets;
SHOW GRANTS;
```

SHOW TABLE STATUS should report InnoDB for tables used in rollback demonstrations. Share the first relevant error code, failing statement, and server version when asking for help; remove credentials, private host details, and personal data.

## Completion checklist

- Database loaded and baseline checks return 1.
- All 22 exercises attempted and compared with expected results.
- Difference between INNER JOIN and LEFT JOIN understood.
- Four overdue tickets identified using the fixed reporting date.
- Assignment rollback verified.
- Optional routine and trigger examples checked on your MySQL server.

The original seed and read-query results were checked locally using SQLite with a DATEDIFF compatibility function. Native MySQL execution was unavailable during authoring; this guide provides checkpoints for verifying behavior on your server.

## Official references

- [Workbench SQL query toolbar](https://dev.mysql.com/doc/workbench/en/wb-sql-editor-toolbar.html)
- [MySQL statements that implicitly commit](https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html)
- [MySQL stored routines](https://dev.mysql.com/doc/refman/8.0/en/create-procedure.html)
