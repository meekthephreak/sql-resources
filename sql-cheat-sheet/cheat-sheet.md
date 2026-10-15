# MySQL Cheat Sheet

Load the [sample database](../sample-database/README.md) first. These examples target MySQL 8.0.16+. Run each SQL block separately.

```sql
USE sql_resources_helpdesk_lab;
SELECT ticket_id, category, status FROM tickets ORDER BY ticket_id;
SELECT DISTINCT category FROM tickets ORDER BY category;
SELECT ticket_id FROM tickets ORDER BY opened_date DESC, ticket_id DESC LIMIT 5;
```

## Filtering and operator precedence

AND binds more tightly than OR; use parentheses to make intent explicit. A semicolon ends the statement, so OR and NOT belong inside the same WHERE clause.

```sql
SELECT ticket_id FROM tickets
WHERE (priority='High' OR priority='Critical') AND NOT (status='Resolved');
SELECT ticket_id FROM tickets WHERE priority IN ('High','Critical');
SELECT ticket_id FROM tickets
WHERE opened_date BETWEEN '2026-10-07' AND '2026-10-12';
SELECT hostname FROM assets WHERE hostname LIKE 'SEC-%';
SELECT ticket_id FROM tickets WHERE technician_id IS NULL;
SELECT ticket_id FROM tickets WHERE resolved_date IS NOT NULL;
```

Never compare NULL using `= NULL`. NULL means unknown/absent, not zero or an empty string. For timestamps, use a half-open interval (`>= start AND < next_day`) to include a whole day.

## Aggregates, GROUP BY, and HAVING

WHERE filters rows before grouping; HAVING filters the resulting groups. COUNT(*) counts rows, while COUNT(column) excludes NULL values.

```sql
SELECT category, COUNT(*) AS ticket_count FROM tickets
GROUP BY category HAVING COUNT(*) >= 3 ORDER BY category;
SELECT SUM(minutes_spent) AS total_minutes,
       ROUND(AVG(minutes_spent),2) AS average_minutes,
       MIN(minutes_spent) AS shortest, MAX(minutes_spent) AS longest
FROM work_logs;
```

Select only grouped columns or aggregates when grouping. Do not disable ONLY_FULL_GROUP_BY to hide ambiguous results.

## Join types

```sql
-- INNER: tickets with matching requester records.
SELECT t.ticket_id,e.employee_name FROM tickets t
INNER JOIN employees e ON e.employee_id=t.employee_id;
-- LEFT: retain tickets with no technician.
SELECT t.ticket_id,COALESCE(x.technician_name,'Unassigned') AS technician
FROM tickets t LEFT JOIN technicians x ON x.technician_id=t.technician_id;
-- CROSS: all combinations; here, 4 departments x 4 technicians = 16 rows.
SELECT d.department_name,x.technician_name
FROM departments d CROSS JOIN technicians x;
```

RIGHT JOIN retains all rows on its right side; usually reverse the tables and use LEFT JOIN for readability. MySQL has no native FULL OUTER JOIN. A join to multiple work logs repeats ticket rows; aggregate at the intended grain to avoid inflated ticket counts.

## Subqueries and CASE

```sql
SELECT e.employee_id,e.employee_name FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM tickets t WHERE t.employee_id=e.employee_id);
SELECT ticket_id,
 CASE WHEN resolved_date<=due_date THEN 'On Time' ELSE 'Late' END AS sla_result
FROM tickets WHERE status='Resolved';
```

NOT IN can produce surprising results when its subquery contains NULL; NOT EXISTS is useful for anti-joins.

## Safe INSERT, UPDATE, and DELETE practice

Run the entire block on one connection. The DELETE targets the newly inserted, unreferenced row; deleting a referenced parent may fail due to foreign keys.

```sql
START TRANSACTION;
INSERT INTO departments(department_id,department_name) VALUES(99,'Practice Only');
UPDATE departments SET department_name='Updated Practice' WHERE department_id=99;
SELECT * FROM departments WHERE department_id=99;
DELETE FROM departments WHERE department_id=99;
ROLLBACK;
```

UPDATE or DELETE without WHERE affects every row. Preview the same predicate using SELECT and use primary-key predicates for focused edits. Workbench safe-update mode may reject broad writes; refine the query rather than turning it off globally.

## Table definitions and constraints

```sql
-- Disposable lab example; DDL implicitly commits and is not rolled back.
CREATE TABLE IF NOT EXISTS lab_notes (
 note_id INT PRIMARY KEY,
 ticket_id INT NOT NULL,
 note_text VARCHAR(255) NOT NULL,
 FOREIGN KEY(ticket_id) REFERENCES tickets(ticket_id)
);
```

PRIMARY KEY identifies a row; UNIQUE prevents duplicates; FOREIGN KEY enforces references; NOT NULL requires a value; CHECK restricts valid values. Use DECIMAL for exact financial quantities. ALTER TABLE changes structure; DROP TABLE removes a table and its data. Review definitions before executing either.

See [advanced topics](advanced-topics.md) and [security](security.md) for the next steps.
