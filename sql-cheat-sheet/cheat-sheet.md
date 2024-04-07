# SQL Cheat Sheet

This cheat sheet provides a quick reference to essential SQL commands and their syntax. It's designed to help both beginners and experienced users recall SQL commands for database operations, querying, and manipulation.

## Disclaimer

*Please note that SQL dialects, such as MySQL, PostgreSQL, SQL Server (T-SQL), Oracle (PL/SQL), and others, may have variations in their syntax, functions, and features. This cheat sheet primarily focuses on standard SQL commands. However, some examples might not work directly or may require modifications to run on different SQL database systems. Always refer to the documentation specific to the SQL dialect you are using to ensure compatibility and understand the nuances of its syntax and capabilities.*

## Basic SQL Commands

### SELECT

```sql
SELECT column1, column2, ...
FROM table_name;
```

Retrieves data from one or more columns in a table.

### INSERT INTO

```sql
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...);
```

Inserts new data into a table.

### UPDATE

```sql
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;
```

Modifies existing data in table

### DELETE

```sql
DELETE FROM table_name
WHERE condition;
```

Removes existing data from a table.

## Working with Conditions and Operators

### WHERE

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

Filters results based on a condition.

### AND, OR, NOT

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition1 AND condition2;
OR condition3;
NOT condition4;
```

Combines multiple conditions in a WHERE clause.

## Managing Databases and Tables

### Create Database

```sql
CREATE DATABASE database_name;
```

Creates a new database

### DROP DATABASE

```sql
DROP DATABASE database_name;
```

Deletes an existing database.

### CREATE TABLE

```sql
CREATE TABLE table_name (
    column1 datatype,
    column2 datatype,
    ...
);
```

Creates a new table in the database.

### DROP TABLE

```sql
DROP TABLE table_name;
```

Deletes an existing table from the database.

## Advanced Operations

### JOINs

```sql
SELECT Orders.OrderID, Customers.CustomerName
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID;
```

Combines rows from two or more tables based on a related column.

### GROUP BY

```sql
SELECT column_name, COUNT(*)
FROM table_name
GROUP BY column_name;
```

Groups rows that have the same values in specified columns into summary rows.

### HAVING

```sql
SELECT column_name, COUNT(*)
FROM table_name
GROUP BY column_name
HAVING COUNT(*) > 1;
```

Used with GROUP BY to filter groups based on a condition.
