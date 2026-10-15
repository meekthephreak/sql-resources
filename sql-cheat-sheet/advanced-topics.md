# Advanced MySQL Practice

Requires the help desk sample database and MySQL 8.0.16+. Run blocks individually; expected outputs assume original seed data.

```sql
USE sql_resources_helpdesk_lab;
```

## Common table expressions (CTEs)

A CTE names a query result within one statement. Count work at ticket level before joining other one-to-many tables.

```sql
WITH effort AS (
 SELECT ticket_id,SUM(minutes_spent) AS minutes FROM work_logs GROUP BY ticket_id
)
SELECT t.ticket_id,COALESCE(e.minutes,0) AS minutes
FROM tickets t LEFT JOIN effort e ON e.ticket_id=t.ticket_id
ORDER BY t.ticket_id;
```

There are 16 results, including tickets with zero logged minutes. A CTE is not a persistent table and does not guarantee improved performance.

## Window functions

Window functions calculate across related rows without collapsing them like GROUP BY.

```sql
WITH ranked AS (
 SELECT ticket_id,employee_id,opened_date,
 ROW_NUMBER() OVER(PARTITION BY employee_id
 ORDER BY opened_date DESC,ticket_id DESC) AS rn FROM tickets
)
SELECT employee_id,ticket_id FROM ranked WHERE rn=1 ORDER BY employee_id;
```

Expected employee/ticket pairs: (1,13), (2,14), (3,9), (4,12), (5,15), (6,16). Explicit tie-breaking makes ROW_NUMBER reproducible. RANK leaves gaps after ties; DENSE_RANK does not.

## Transactions and concurrent changes

```sql
START TRANSACTION;
SELECT ticket_id,technician_id FROM tickets WHERE ticket_id=7 FOR UPDATE;
UPDATE tickets SET technician_id=3 WHERE ticket_id=7;
SELECT ticket_id,technician_id FROM tickets WHERE ticket_id=7;
ROLLBACK;
```

FOR UPDATE locks selected rows until the transaction ends. Keep transactions short; another session may wait on that row. InnoDB supports transactional changes, but DDL can implicitly commit. Isolation levels determine which concurrent changes are visible; deadlocks may require retrying the whole application transaction.

## Views

```sql
CREATE OR REPLACE VIEW lab_active_tickets AS
SELECT ticket_id,employee_id,technician_id,priority,due_date
FROM tickets WHERE status<>'Resolved';
SELECT * FROM lab_active_tickets ORDER BY ticket_id;
```

Expected: 9 active tickets. Requires CREATE VIEW and, for replacement, appropriate DROP privileges. A view stores a query definition, not a cached result. View access and SQL SECURITY settings matter; do not assume a view automatically restricts access to underlying data.

## Indexes and query plans

```sql
EXPLAIN SELECT ticket_id FROM tickets
WHERE status='Open' AND due_date<'2026-10-14';
CREATE INDEX lab_idx_status_due ON tickets(status,due_date);
EXPLAIN SELECT ticket_id FROM tickets
WHERE status='Open' AND due_date<'2026-10-14';
-- Optional cleanup after comparison:
DROP INDEX lab_idx_status_due ON tickets;
```

Run the CREATE once, or drop the named index before repeating. Compare `key`, estimated `rows`, and `Extra`. With 16 tickets the optimizer may prefer a full scan; this does not prove the index is useless for larger workloads. Indexes consume space and add write overhead. Composite column order should reflect real filters and ordering. Avoid wrapping indexed columns in functions when an equivalent range predicate is possible.

## Stored routines and triggers

See [functions.sql](../sql-code/functions.sql), [procedures.sql](../sql-code/procedures.sql), and [triggers.sql](../sql-code/triggers.sql). They demonstrate a deterministic date function, parameterized procedure inputs, and an audit trigger. Read [execution instructions](../sql-code/README.md) first. Triggers create implicit side effects and are not a substitute for permissions or a tamper-resistant audit system.

## Practice extensions

1. Report each department's active-ticket count, including zero.
2. Compare requester ticket counts with technician work totals without multiplying rows.
3. Calculate rolling daily ticket totals using an explicit window frame.
4. Explain why a ticket due on October 14 is excluded from the October 14 overdue report.

Reference: [MySQL 8.0 manual](https://dev.mysql.com/doc/refman/8.0/en/).
