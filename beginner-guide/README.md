# SQL for Complete Beginners

**Start here if SQL is new to you.** You do not need to know what `SELECT *` means. This guide explains the punctuation, builds queries one piece at a time, and provides a glossary you can return to while practicing.

Examples use **MySQL 8.0.16+** and this repository's fictional IT help desk database. SQL is a language; MySQL is one database system that understands it; MySQL Workbench is the application you use to send it commands.

## Find what you need

- [Database vocabulary](#1-database-vocabulary)
- [Your first query](#2-your-first-query)
- [Syntax and punctuation](#3-syntax-and-punctuation)
- [Build a query step by step](#4-build-a-query-step-by-step)
- [Count and summarize](#5-count-and-summarize)
- [Connect tables](#6-connect-tables)
- [Change data safely](#7-change-data-safely)
- [SQL command and syntax glossary](#8-sql-command-and-syntax-glossary)
- [Common beginner mistakes](#9-common-beginner-mistakes)
- [What to practice next](#10-what-to-practice-next)

## 1. Database vocabulary

Imagine a workbook with several connected sheets. This comparison helps you get started, although databases have their own rules and are not simply spreadsheets.

| Word | Plain-language meaning | Example in this lab |
|---|---|---|
| Database / schema | A named collection of related objects. In MySQL these words are often used interchangeably. | `sql_resources_helpdesk_lab` |
| Table | A collection of records with defined columns. | `tickets` |
| Row / record | One item in a table. | One help desk ticket |
| Column / field | One named type of information stored for each row. | `priority` |
| Value | One piece of information in a row and column. | `'High'` |
| Data type | The kind of value a column accepts. | INT for an integer; DATE for a date |
| Query | A request expressed in SQL, often to retrieve data. | List open tickets |
| Statement | A complete SQL instruction. | `SELECT * FROM tickets;` |
| Result set | The rows and columns returned by a query. | The grid below your Workbench editor |
| Primary key | A column or combination of columns that uniquely identifies each row. | `ticket_id` |
| Foreign key | A rule linking a value to a key in another table. | A ticket's `employee_id` references an employee |
| NULL | A missing, unknown, or inapplicable value. | No technician assigned yet |
| Alias | A temporary name used within a query or its results. | `AS ticket_count` |
| Clause | A part of a statement with a particular job. | WHERE filters rows |
| Expression | Something SQL evaluates to a value. | `minutes_spent + 10` |

A small **illustration** of part of a tickets table:

| ticket_id | category | priority | status |
|---:|---|---|---|
| 1 | Network | High | Resolved |
| 5 | Hardware | High | Open |
| 7 | Software | Medium | Open |

The real lab has more columns and 16 ticket rows. A column's position is not its identity, and rows have no guaranteed display order unless you request one.

## 2. Your first query

First load the database using the [Lab Walkthrough](../LAB_README.md). Open a Workbench query tab and run these statements:

```sql
USE sql_resources_helpdesk_lab;

SELECT * FROM tickets;
```

Read the second statement as: **“Show me every column from the tickets table.”**

| Part | Meaning |
|---|---|
| SELECT | Choose the information to return. |
| * | Return all columns from this source. It does not mean multiply here. |
| FROM | Say which table to read. |
| tickets | The table's name. |
| ; | End this statement. |

There is no WHERE filter, so this query returns all ticket rows. On the original lab, that means **16 rows and every tickets column**. It does not change the stored records. Workbench can impose a display/query row limit; large tables may show only the configured limit.

**The star selects columns, not rows.** Compare:

```sql
-- Every column, only the row for ticket 5:
SELECT * FROM tickets WHERE ticket_id = 5;

-- Only these two columns, all ticket rows:
SELECT ticket_id, status FROM tickets;
```

Use explicit columns when you only need a few. They make the output easier to read and avoid retrieving unnecessary data.

The earlier USE statement chooses the database in which MySQL looks for unqualified table names. You can also write a fully qualified name:

```sql
SELECT ticket_id FROM sql_resources_helpdesk_lab.tickets;
```

## 3. Syntax and punctuation

SQL syntax is the set of rules for arranging instructions.

| Item | What it does | Example |
|---|---|---|
| Comma | Separates items such as column names. | `SELECT ticket_id, status FROM tickets;` |
| Single quotes | Surround text and date values. | `status = 'Open'` |
| No quotes around a number | Treats it as a number. | `ticket_id = 5` |
| Backticks | Quote MySQL identifiers when needed. | See the separate example below. |
| Parentheses | Group conditions or enclose function arguments. | `COUNT(*)` |
| Period | Separates a table/alias from a column, or schema from table. | `t.ticket_id` |
| Semicolon | Ends a statement. | `SELECT 1;` |
| -- followed by a space | Starts a comment through the end of the line. | `-- My note` |
| /* ... */ | Surrounds a block comment. | `/* Not executed */` |

Backtick example, shown separately for clarity:

```sql
SELECT `status` FROM tickets;
```

Use single quotes for values and backticks for identifiers. Double-quote behavior depends on SQL mode, so use the conventions above. To include an apostrophe inside text, double it: `'It''s open'`.

Keywords are conventionally uppercase for readability, but `select` and `SELECT` mean the same thing. Database and table name case can behave differently across operating systems and server settings; use the exact names supplied by the lab.

Line breaks and indentation make queries readable. These are equivalent:

```sql
SELECT ticket_id, status FROM tickets;
```

```sql
SELECT
    ticket_id,
    status
FROM tickets;
```

Names such as `column_name` in a generic syntax template are placeholders you must replace. The three dots in `SELECT column1, column2, ...` are explanatory notation, not valid executable SQL.

## 4. Build a query step by step

Run these examples individually after selecting the lab database.

### Choose columns

```sql
SELECT ticket_id, priority, status
FROM tickets;
```

This returns three columns for every ticket.

### Keep only matching rows

```sql
SELECT ticket_id, priority, status
FROM tickets
WHERE status = 'Open';
```

WHERE keeps rows whose condition is true. The equals sign compares values here; it does not change status to Open.

### Require two conditions

```sql
SELECT ticket_id, priority, status
FROM tickets
WHERE status = 'Open'
  AND priority = 'High';
```

Both conditions must be true. The original lab returns tickets **5 and 14**.

### Sort the results

```sql
SELECT ticket_id, priority, status
FROM tickets
WHERE status = 'Open'
  AND priority = 'High'
ORDER BY ticket_id DESC;
```

DESC means largest to smallest here, so ticket 14 appears before 5. ASC means smallest to largest and is the default. Text sorts according to the column's collation; sorting the words High, Low, and Medium does not automatically produce business-priority order.

### Limit how much you return

```sql
SELECT ticket_id, priority, status
FROM tickets
WHERE status = 'Open'
  AND priority = 'High'
ORDER BY ticket_id DESC
LIMIT 1;
```

This returns **one row: ticket 14**. LIMIT controls returned rows; it does not delete other rows.

The usual written order is:

```text
SELECT what_to_return
FROM source_table
WHERE row_condition
GROUP BY grouping_columns
HAVING group_condition
ORDER BY sorting_columns
LIMIT number_of_rows;
```

Only include the clauses you need. To reason about a basic query, think: find sources and joins, filter rows, form groups, filter groups, calculate output, remove duplicates if requested, sort, and limit. This is a learning model, not a guarantee of the optimizer's physical execution order.

## 5. Count and summarize

```sql
SELECT COUNT(*) AS ticket_count
FROM tickets;
```

COUNT(*) counts rows rather than returning all columns. The star has a different role here from SELECT *. AS gives the output column a readable label. Expected result: **16**.

```sql
SELECT status, COUNT(*) AS ticket_count
FROM tickets
GROUP BY status
ORDER BY status;
```

GROUP BY forms groups of rows sharing the same status. COUNT(*) counts within each group:

| status | ticket_count |
|---|---:|
| In Progress | 3 |
| Open | 6 |
| Resolved | 7 |

To keep only groups containing at least four tickets:

```sql
SELECT status, COUNT(*) AS ticket_count
FROM tickets
GROUP BY status
HAVING COUNT(*) >= 4
ORDER BY status;
```

WHERE filters individual rows before grouping; HAVING filters the groups. Select grouped columns or aggregate expressions so the result is unambiguous.

## 6. Connect tables

Tickets store employee IDs. Employees store names. A JOIN combines related rows so you can display both.

```sql
SELECT t.ticket_id, e.employee_name
FROM tickets AS t
INNER JOIN employees AS e
    ON t.employee_id = e.employee_id
ORDER BY t.ticket_id;
```

- `t` and `e` are short aliases for the two tables.
- `t.employee_id` means the employee_id column in tickets.
- ON describes which rows match.
- INNER JOIN keeps combinations with a matching row on both sides.

Use LEFT JOIN when you need to preserve rows without a match:

```sql
SELECT t.ticket_id,
       COALESCE(x.technician_name, 'Unassigned') AS technician
FROM tickets AS t
LEFT JOIN technicians AS x
    ON t.technician_id = x.technician_id
ORDER BY t.ticket_id;
```

All 16 tickets remain. Missing technician matches produce NULL; COALESCE supplies the display label Unassigned. This label does not change the stored value.

A join can produce multiple output rows per ticket if it matches multiple work logs. More rows in the result does not necessarily mean more tickets exist.

## 7. Change data safely

Reading data and changing data are different activities. INSERT adds rows, UPDATE changes values, and DELETE removes rows. Practice only in the disposable lab.

Run this **whole block on one connection**, assuming the original lab has no department 99:

```sql
START TRANSACTION;

INSERT INTO departments (department_id, department_name)
VALUES (99, 'Practice Department');

SELECT * FROM departments WHERE department_id = 99;

UPDATE departments
SET department_name = 'Renamed Practice'
WHERE department_id = 99;

SELECT * FROM departments WHERE department_id = 99;

DELETE FROM departments
WHERE department_id = 99;

ROLLBACK;
```

The first SELECT displays the inserted row. The next displays its changed name. DELETE removes that practice row. ROLLBACK cancels the transaction's changes; the original lab remains unchanged.

For a real transaction you intend to keep, COMMIT saves its changes instead. ROLLBACK cannot undo a completed COMMIT. MySQL normally enables autocommit, so standalone writes can become permanent immediately. START TRANSACTION creates an explicit transaction for this example.

UPDATE or DELETE without a suitable WHERE can affect the whole table. Preview the predicate with SELECT. MySQL CREATE, ALTER, DROP, and TRUNCATE can implicitly commit and cannot be treated as rollback practice. Transaction examples assume InnoDB tables.

## 8. SQL command and syntax glossary

You do not need to memorize every entry. Learn the reading section first, then use the rest as a reference. These tables include statements, clauses, operators, functions, and concepts; they are not all standalone commands. Examples without complete statements are **fragments**, not scripts to execute on their own.

### Reading, filtering, and sorting

| Term | Plain-language meaning | Example |
|---|---|---|
| SELECT | Choose returned columns or expressions. | `SELECT ticket_id FROM tickets;` |
| FROM | Identify the source table. | `FROM tickets` |
| * | All columns in a SELECT list. | `SELECT * FROM tickets;` |
| WHERE | Keep rows matching a condition. | `WHERE status = 'Open'` |
| DISTINCT | Remove duplicate combinations of selected values. | `SELECT DISTINCT category FROM tickets;` |
| AS | Give an output expression or table an alias. | `COUNT(*) AS total` |
| ORDER BY | Sort results. | `ORDER BY ticket_id` |
| ASC / DESC | Ascending / descending sort direction. | `ORDER BY ticket_id DESC` |
| LIMIT | Restrict returned row count. | `LIMIT 5` |
| OFFSET | Skip a number of rows before returning rows. | `LIMIT 5 OFFSET 5` |
| AND | Require both conditions. | `status='Open' AND priority='High'` |
| OR | Accept either condition. | `priority='High' OR priority='Critical'` |
| NOT | Negate a condition. | `NOT (status='Resolved')` |
| = / <> / != | Equal / not equal; <> and != both work in MySQL. | `priority <> 'Low'` |
| > / < / >= / <= | Greater/less than, optionally including equality. | `ticket_id >= 10` |
| BETWEEN | Match an inclusive range. | `ticket_id BETWEEN 1 AND 5` |
| IN | Match any value in a list or subquery. | `priority IN ('High','Critical')` |
| LIKE | Match a text pattern. | `hostname LIKE 'SEC-%'` |
| % / _ in LIKE | Any number of characters / one character. | `'SEC-%'` matches an SEC- prefix |
| IS NULL / IS NOT NULL | Test for missing / present values. | `technician_id IS NULL` |
| <=> | MySQL equality that also handles NULL. | `NULL <=> NULL` returns 1 |
| EXISTS / NOT EXISTS | Test whether a subquery returns any rows. | See employees-without-tickets exercise |
| UNION | Combine compatible query results and remove duplicates. | `SELECT employee_id FROM employees UNION SELECT employee_id FROM tickets;` |
| UNION ALL | Combine compatible results, keeping duplicates. | Replace UNION above with UNION ALL |

AND takes precedence over OR. Parenthesize mixed conditions. LIKE matching can be case-sensitive or insensitive depending on collation. NOT IN with NULL values can give surprising results; consider NOT EXISTS for missing relationships.

### Summaries, expressions, and functions

| Term | Plain-language meaning | Example |
|---|---|---|
| GROUP BY | Form groups to summarize. | `GROUP BY category` |
| HAVING | Filter groups. | `HAVING COUNT(*) > 2` |
| COUNT(*) | Count rows. | `SELECT COUNT(*) FROM tickets;` |
| COUNT(column) | Count non-NULL values in that column. | `COUNT(technician_id)` |
| SUM | Add numeric values. | `SUM(minutes_spent)` |
| AVG | Find the arithmetic mean of non-NULL values. | `AVG(minutes_spent)` |
| MIN / MAX | Find the smallest / largest non-NULL value. | `MAX(opened_date)` |
| ROUND | Round a number to the specified decimal places. | `ROUND(AVG(minutes_spent),2)` |
| CASE | Choose a result based on conditions. | `CASE WHEN priority='Critical' THEN 1 ELSE 0 END` |
| COALESCE | Return the first non-NULL argument. | `COALESCE(technician_id,0)` |
| NULLIF | Return NULL when its two arguments are equal. | `NULLIF(COUNT(*),0)` |
| CONCAT | Join text values together. | `CONCAT('Ticket ',ticket_id)` |
| UPPER / LOWER | Convert text to uppercase / lowercase. | `UPPER(status)` |
| TRIM | Remove surrounding spaces by default. | `TRIM(employee_name)` |
| CHAR_LENGTH | Count text characters. | `CHAR_LENGTH(employee_name)` |
| LENGTH | Count bytes in MySQL, which can differ from characters. | `LENGTH(employee_name)` |
| CAST | Convert a value to another type when possible. | `CAST('123' AS UNSIGNED)` |
| + / - / * / / | Add, subtract, multiply, divide numeric expressions. | `minutes_spent / 60.0` |
| CURDATE() | Today's date according to the server session. | `SELECT CURDATE();` |
| NOW() | Current date and time. | `SELECT NOW();` |
| DATEDIFF | First date minus second date in calendar days. | `DATEDIFF(resolved_date,opened_date)` |
| DATE_ADD / INTERVAL | Add a specified time interval. | `DATE_ADD(opened_date, INTERVAL 7 DAY)` |

Most aggregates ignore NULL. COUNT(*) still counts the row; SUM over no matching rows returns NULL. Replacing NULL with zero changes its meaning, so do that only when zero makes sense for the report.

### Relationships and advanced queries

| Term | Plain-language meaning | Where to learn it |
|---|---|---|
| INNER JOIN | Return matching combinations from both sources. | Section 6 |
| LEFT JOIN | Keep every left-side row, adding matching right-side values. | Section 6 |
| RIGHT JOIN | Keep every right-side row. | Usually express by reversing a LEFT JOIN |
| CROSS JOIN | Produce every left/right row combination. | Cheat sheet |
| ON | Specify how joined rows match. | `ON t.employee_id=e.employee_id` |
| Subquery | A SELECT nested inside another statement. | Advanced exercises |
| WITH / CTE | Name an intermediate query result for one statement. | Advanced guide |
| OVER | Define a window calculation over related rows. | Advanced guide |
| PARTITION BY | Split rows into independent window groups. | `OVER (PARTITION BY employee_id ...)` |
| ROW_NUMBER | Give rows distinct sequence numbers within a window. | Most-recent-ticket exercise |
| RANK / DENSE_RANK | Rank rows with ties; RANK leaves gaps, DENSE_RANK does not. | Technician ranking exercise |
| ROWS BETWEEN | Define which rows contribute to a window calculation. | Running-total exercise |
| VIEW | A stored query definition you can query like a table. | Advanced guide |
| EXPLAIN | Display how MySQL plans a query. | Advanced guide |

MySQL does not provide a native FULL OUTER JOIN. INTERSECT and EXCEPT require MySQL 8.0.31+, so they are not part of this lab's 8.0.16 baseline.

### Adding and changing records

| Term | Plain-language meaning | Example or caution |
|---|---|---|
| INSERT INTO | Add rows to a table. | Section 7 |
| VALUES | Supply values for an INSERT. | `VALUES (99,'Practice Department')` |
| UPDATE | Change existing rows. | Section 7 |
| SET | Assign new column values in UPDATE; also used for variables/settings. | `SET department_name='Renamed Practice'` |
| DELETE FROM | Remove matching rows. | `DELETE FROM departments WHERE department_id=99;` |
| ON DUPLICATE KEY UPDATE | Handle a primary/unique-key conflict by updating the existing row. | The lab seed uses a no-op update to preserve rows |
| START TRANSACTION | Begin a group of changes to commit or roll back together. | Section 7 |
| COMMIT | Make transaction changes permanent. | Does not provide an undo history |
| ROLLBACK | Undo uncommitted changes in a transactional context. | Section 7 |
| SAVEPOINT | Mark an intermediate point in a transaction. | `SAVEPOINT before_change;` |
| ROLLBACK TO SAVEPOINT | Undo changes after a savepoint without ending the transaction. | `ROLLBACK TO SAVEPOINT before_change;` |
| FOR UPDATE | Lock selected rows for a transactional change. | Advanced guide |

### Database structure and rules

| Term | Plain-language meaning | Effect |
|---|---|---|
| USE | Choose the default database. | `USE sql_resources_helpdesk_lab;` |
| CREATE DATABASE | Create a database. | Structure change |
| CREATE TABLE | Define a new table and its columns. | Structure change |
| IF NOT EXISTS | Skip creating an already existing named object where supported. | Does not repair/migrate its definition |
| ALTER TABLE | Change an existing table's structure. | Can change data or constraints |
| DROP TABLE / DROP DATABASE | Remove a table / entire database. | Destructive; not rollback practice |
| TRUNCATE TABLE | Empty a table, subject to engine/foreign-key rules. | No WHERE; implicitly commits in MySQL |
| PRIMARY KEY | Identify each row uniquely; key values cannot be NULL. | One primary key per table, potentially multiple columns |
| FOREIGN KEY / REFERENCES | Require valid referenced parent values. | Protect relationships |
| UNIQUE | Enforce distinct key values. | MySQL permits multiple NULLs in a nullable unique column |
| NOT NULL | Require a non-NULL value. | Does not prohibit an empty text string |
| DEFAULT | Supply a value when omitted from an insert, as defined. | Does not generally replace an explicit NULL |
| CHECK | Require a condition to be true or unknown, rejecting false. | Enforced from MySQL 8.0.16 |
| AUTO_INCREMENT | Generate numeric identifiers. | Gaps are normal; not a row counter |
| INDEX / CREATE INDEX | Add a structure that can speed certain lookups. | Costs storage and write effort |

### Common data types

| Type | Stores | Example |
|---|---|---|
| INT / BIGINT | Whole numbers in different ranges. | Ticket IDs |
| DECIMAL(p,s) | Exact decimal values with defined precision and scale. | DECIMAL(10,2) for an amount |
| FLOAT / DOUBLE | Approximate numbers. | Measurements; avoid for exact money |
| VARCHAR(n) | Variable-length text up to a declared character limit. | VARCHAR(80) for a name |
| CHAR(n) | Fixed-length character data with padding behavior. | Short fixed-format codes |
| TEXT | Larger text. | A detailed note |
| DATE | Calendar date without time. | '2026-10-14' |
| DATETIME | Date and time without TIMESTAMP's automatic session-zone conversion. | A recorded local date/time |
| TIMESTAMP | Date/time with session-time-zone conversion on storage/retrieval. | An audit event timestamp |
| BOOLEAN / BOOL | MySQL synonyms for TINYINT(1). | Conventionally 0 or 1; not limited to those without a rule |
| JSON | Validated JSON documents. | Structured metadata |

### Inspection, routines, and permissions

| Term | Plain-language meaning | Example / next step |
|---|---|---|
| SHOW DATABASES | List databases visible to your account. | `SHOW DATABASES;` |
| SHOW TABLES | List tables/views in the chosen database. | `SHOW TABLES;` |
| DESCRIBE | Inspect table columns. | `DESCRIBE tickets;` |
| SHOW CREATE TABLE | Show the definition, including constraints. | `SHOW CREATE TABLE tickets;` |
| SHOW INDEX | Inspect indexes on a table. | `SHOW INDEX FROM tickets;` |
| SELECT DATABASE() | Show the chosen database. | Returns NULL if none is chosen |
| SELECT VERSION() | Show the server version. | Useful for troubleshooting |
| CREATE FUNCTION | Define a reusable function returning a value. | functions.sql |
| CREATE PROCEDURE / CALL | Define / execute a stored procedure. | procedures.sql |
| CREATE TRIGGER | Define automatic actions responding to table changes. | triggers.sql |
| DELIMITER | Client instruction for routine-script boundaries; not server SQL. | SQL code README |
| SIGNAL | Raise a SQL condition/error in stored code. | Assignment procedure |
| PREPARE / EXECUTE / DEALLOCATE PREPARE | Prepare, run, and release a server-side prepared statement. | Security guide |
| CREATE ROLE / CREATE USER | Create a privilege role / database account. | Administrator tasks |
| GRANT / REVOKE | Give / remove permissions. | Security guide |
| SHOW GRANTS | Inspect privileges granted to an account or role. | `SHOW GRANTS;` |

Parameterize user-supplied values in application queries. Do not build SQL by concatenating input. Permissions and application authorization still matter even when parameterization is correct.

## 9. Common beginner mistakes

| Mistake | Why it fails or surprises you | Better approach |
|---|---|---|
| `SELECT FROM tickets;` | Nothing was selected. | Use * or column names after SELECT. |
| `SELECT ticket_id status FROM tickets;` | The missing comma can make status an alias, not a second selected column. | Separate column names with commas. |
| `WHERE status = Open` | Open is treated as an identifier, not the intended text value. | Write `status = 'Open'`. |
| `WHERE technician_id = NULL` | Ordinary equality with NULL is unknown. | Use IS NULL. |
| Semicolon before WHERE | Ends the SELECT before the filter. | Put the semicolon at the end of the whole statement. |
| Using ORDER BY as a filter | Sorting does not remove rows. | Filter with WHERE. |
| Assuming LIMIT gives newest rows | It limits rows without defining their order. | Add ORDER BY opened_date DESC, ticket_id DESC. |
| WHERE COUNT(*) > 2 | WHERE is for rows before grouping. | Use HAVING COUNT(*) > 2 with GROUP BY. |
| Expecting an empty result to be an error | A valid query can match no rows. | Check your filter and data. |
| “No database selected” | MySQL has no default source database. | Execute USE sql_resources_helpdesk_lab;. |
| Running the full worksheet after adding writes | Several exercises may execute unexpectedly. | Select one answer, or a complete intentional transaction. |
| Rerunning the seed to undo edits | The seed preserves existing records. | Follow the lab reset instructions. |

## 10. What to practice next

1. Load the database using the [Lab Walkthrough](../LAB_README.md).
2. Run SELECT * FROM tickets; and DESCRIBE tickets; to connect rows with column definitions.
3. Attempt exercises 1–6 in [Exercises_Only.sql](../sample-database/Exercises_Only.sql).
4. Continue with joins and grouping before trying CTEs and windows.
5. Use the [cheat sheet](../sql-cheat-sheet/cheat-sheet.md) as a quick reference.
6. Read [advanced topics](../sql-cheat-sheet/advanced-topics.md) and [security](../sql-cheat-sheet/security.md) as you progress.

You are ready to move on when you can explain what a query reads, which columns it returns, which rows it keeps, and whether it changes stored data.

## Official references

This is a practical introduction, not a complete SQL language specification. Syntax and behavior can differ between database products.

- [MySQL tutorial](https://dev.mysql.com/doc/refman/8.0/en/tutorial.html)
- [SELECT reference](https://dev.mysql.com/doc/refman/8.0/en/select.html)
- [MySQL 8.0 reference manual](https://dev.mysql.com/doc/refman/8.0/en/)

Examples and expected counts use the original lab data. Native MySQL execution was unavailable during authoring.
