# SQL Security Practice

Use only fictional lab data. Database permissions, application authorization, and parameterization solve different problems and should be applied together.

## Parameterized application queries

Do not concatenate user input into SQL. With MySQL Connector/Python, pass values separately. This Python example runs in an application, **not** in Workbench. `connection` is an authenticated connector connection; configure it outside source control.

```python
employee_id = 1  # after application authorization checks
cursor = connection.cursor()
cursor.execute(
    "SELECT ticket_id, status FROM tickets WHERE employee_id = %s",
    (employee_id,),
)
rows = cursor.fetchall()
cursor.close()
```

The connector treats the parameter as a value, not SQL syntax. Placeholders cannot represent table names, column names, or sort directions; choose those from an explicit allowlist. Parameterization does not authorize a user to see another employee's records. Stored procedures are not automatically injection-proof if they build dynamic SQL unsafely.

### Server prepared-statement illustration in Workbench

```sql
USE sql_resources_helpdesk_lab;
PREPARE lab_lookup FROM
 'SELECT ticket_id,status FROM tickets WHERE employee_id = ? ORDER BY ticket_id';
SET @lab_employee = 1;
EXECUTE lab_lookup USING @lab_employee;
DEALLOCATE PREPARE lab_lookup;
```

Expected ticket IDs: 1,7,13. This illustrates value binding; applications should use their driver's parameter API.

## Least privilege

In a disposable lab, an authorized administrator can create a reporting role. Run only if the role name is unused, or inspect an existing role before modifying it. This block creates a role but does not create a user or grant it to an account.

```sql
CREATE ROLE IF NOT EXISTS 'sql_lab_reader';
GRANT SELECT ON sql_resources_helpdesk_lab.* TO 'sql_lab_reader';
SHOW GRANTS FOR 'sql_lab_reader';
```

Assign the role to an existing lab user and activate it only through your administrator's approved process. Role activation and account host matching affect effective access. Applications should not connect as root; a reporting account generally needs no CREATE, DROP, or UPDATE privileges. Keep schema migrations separate from runtime application access.

## Safe operational habits

- Preview affected rows before writes, and use focused predicates.
- Use transactions for reversible DML; DDL can implicitly commit.
- Keep credentials out of Git and use protected configuration or a secret manager.
- Avoid logging passwords, tokens, or unnecessary personal information.
- Bound application result sizes and validate inputs even with parameterization.
- An audit table that its owner can modify is not tamper-resistant evidence.

References: [Connector/Python execute](https://dev.mysql.com/doc/connector-python/en/connector-python-api-mysqlcursor-execute.html), [MySQL roles](https://dev.mysql.com/doc/refman/8.0/en/roles.html).
