-- IT HELP DESK SQL PRACTICE | MySQL 8.0+ | All data is fictional.
-- Requires a running MySQL server connection; Workbench is the client.
-- HOW TO LOAD: File > Open SQL Script > select this file.
-- Execute the whole script with the lightning bolt (Execute All).
-- Refresh SCHEMAS, then expand sql_resources_helpdesk_lab.
-- Setup is non-destructive: a second load leaves existing rows unchanged.
-- To restore data after edits, deliberately drop ONLY this lab database,
-- then rerun this script. Never use these instructions on a production DB.
-- Exercises and answers below are comments; they do not run during setup.
-- Select an answer's SQL (without comment markers) to execute it.
-- Fixed reporting date: 2026-10-14. No dependency on today's date.

CREATE DATABASE IF NOT EXISTS sql_resources_helpdesk_lab;
USE sql_resources_helpdesk_lab;

CREATE TABLE IF NOT EXISTS departments (
 department_id INT PRIMARY KEY, department_name VARCHAR(80) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS employees (
 employee_id INT PRIMARY KEY, employee_name VARCHAR(80) NOT NULL,
 department_id INT NOT NULL, email VARCHAR(120) NOT NULL UNIQUE,
 FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
CREATE TABLE IF NOT EXISTS technicians (
 technician_id INT PRIMARY KEY, technician_name VARCHAR(80) NOT NULL
);
CREATE TABLE IF NOT EXISTS assets (
 asset_id INT PRIMARY KEY, hostname VARCHAR(80) NOT NULL UNIQUE,
 asset_type VARCHAR(30) NOT NULL, employee_id INT,
 FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
CREATE TABLE IF NOT EXISTS tickets (
 ticket_id INT PRIMARY KEY, employee_id INT NOT NULL, asset_id INT,
 technician_id INT, category VARCHAR(40) NOT NULL,
 priority VARCHAR(10) NOT NULL, status VARCHAR(20) NOT NULL,
 opened_date DATE NOT NULL, due_date DATE NOT NULL, resolved_date DATE,
 FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
 FOREIGN KEY (asset_id) REFERENCES assets(asset_id),
 FOREIGN KEY (technician_id) REFERENCES technicians(technician_id),
 CHECK (priority IN ('Low','Medium','High','Critical')),
 CHECK (status IN ('Open','In Progress','Resolved')),
 CHECK (due_date >= opened_date),
 CHECK ((status = 'Resolved' AND resolved_date IS NOT NULL AND resolved_date >= opened_date)
     OR (status <> 'Resolved' AND resolved_date IS NULL))
);
CREATE TABLE IF NOT EXISTS work_logs (
 work_log_id INT PRIMARY KEY, ticket_id INT NOT NULL,
 technician_id INT NOT NULL, minutes_spent INT NOT NULL,
 FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
 FOREIGN KEY (technician_id) REFERENCES technicians(technician_id),
 CHECK (minutes_spent > 0)
);

-- Keep original records unchanged when loading again.
INSERT INTO departments VALUES
(1, 'Operations'),
(2, 'Security'),
(3, 'Finance'),
(4, 'Human Resources')
ON DUPLICATE KEY UPDATE department_id = departments.department_id;

INSERT INTO employees VALUES
(1, 'Avery Lane', 1, 'user1@example.com'),
(2, 'Jordan Reed', 2, 'user2@example.com'),
(3, 'Morgan Chen', 3, 'user3@example.com'),
(4, 'Riley Brooks', 4, 'user4@example.com'),
(5, 'Casey Patel', 1, 'user5@example.com'),
(6, 'Taylor Kim', 2, 'user6@example.com'),
(7, 'Drew Ellis', 3, 'user7@example.com'),
(8, 'Sam Rivera', 4, 'user8@example.com')
ON DUPLICATE KEY UPDATE employee_id = employees.employee_id;

INSERT INTO technicians VALUES
(1, 'Alex Carter'),
(2, 'Jamie Morgan'),
(3, 'Skyler Davis'),
(4, 'Robin Lee')
ON DUPLICATE KEY UPDATE technician_id = technicians.technician_id;

INSERT INTO assets VALUES
(1, 'OPS-LT-01', 'Laptop', 1),
(2, 'SEC-LT-01', 'Laptop', 2),
(3, 'FIN-PC-01', 'Desktop', 3),
(4, 'HR-LT-01', 'Laptop', 4),
(5, 'OPS-PC-02', 'Desktop', 5),
(6, 'SEC-LT-02', 'Laptop', 6),
(7, 'SPARE-LT-01', 'Laptop', NULL),
(8, 'SPARE-PC-01', 'Desktop', NULL)
ON DUPLICATE KEY UPDATE asset_id = assets.asset_id;

INSERT INTO tickets VALUES
(1, 1, 1, 1, 'Network', 'High', 'Resolved', '2026-10-01', '2026-10-03', '2026-10-02'),
(2, 2, 2, 2, 'Security', 'Critical', 'Resolved', '2026-10-02', '2026-10-02', '2026-10-03'),
(3, 3, 3, 1, 'Software', 'Medium', 'Resolved', '2026-10-03', '2026-10-07', '2026-10-05'),
(4, 4, 4, 3, 'Account', 'Low', 'Resolved', '2026-10-04', '2026-10-10', '2026-10-04'),
(5, 5, 5, 1, 'Hardware', 'High', 'Open', '2026-10-05', '2026-10-07', NULL),
(6, 6, 6, 2, 'Security', 'Critical', 'In Progress', '2026-10-06', '2026-10-06', NULL),
(7, 1, 1, NULL, 'Software', 'Medium', 'Open', '2026-10-07', '2026-10-12', NULL),
(8, 2, 2, 2, 'Account', 'Medium', 'Resolved', '2026-10-08', '2026-10-12', '2026-10-10'),
(9, 3, 3, 3, 'Hardware', 'High', 'Resolved', '2026-10-09', '2026-10-11', '2026-10-12'),
(10, 5, 5, 1, 'Network', 'High', 'In Progress', '2026-10-10', '2026-10-12', NULL),
(11, 6, 6, NULL, 'Account', 'Low', 'Open', '2026-10-11', '2026-10-18', NULL),
(12, 4, 4, 3, 'Software', 'Medium', 'Open', '2026-10-12', '2026-10-16', NULL),
(13, 1, 1, 1, 'Network', 'Medium', 'Resolved', '2026-10-12', '2026-10-16', '2026-10-13'),
(14, 2, 2, 2, 'Security', 'High', 'Open', '2026-10-13', '2026-10-15', NULL),
(15, 5, 5, NULL, 'Hardware', 'Low', 'Open', '2026-10-14', '2026-10-21', NULL),
(16, 6, 6, 2, 'Security', 'Critical', 'In Progress', '2026-10-14', '2026-10-14', NULL)
ON DUPLICATE KEY UPDATE ticket_id = tickets.ticket_id;

INSERT INTO work_logs VALUES
(1, 1, 1, 30),
(2, 1, 1, 45),
(3, 2, 2, 90),
(4, 3, 1, 60),
(5, 4, 3, 15),
(6, 6, 2, 120),
(7, 8, 2, 25),
(8, 9, 3, 75),
(9, 9, 1, 30),
(10, 10, 1, 45),
(11, 13, 1, 20),
(12, 14, 2, 40),
(13, 16, 2, 60)
ON DUPLICATE KEY UPDATE work_log_id = work_logs.work_log_id;


-- SETUP CHECK: Expected fresh-lab counts: 4, 8, 4, 8, 16, 13.
SELECT
 (SELECT COUNT(*) FROM departments) AS departments_count,
 (SELECT COUNT(*) FROM employees) AS employees_count,
 (SELECT COUNT(*) FROM technicians) AS technicians_count,
 (SELECT COUNT(*) FROM assets) AS assets_count,
 (SELECT COUNT(*) FROM tickets) AS tickets_count,
 (SELECT COUNT(*) FROM work_logs) AS work_logs_count;

/*
RELATIONSHIPS
Departments -> Employees -> Tickets
Employees -> Assets; Technicians -> Tickets
Tickets -> Work Logs <- Technicians
Ticket assignment and logged work can involve different technicians.

EXERCISES (try these before scrolling to the answer key)

01. [Beginner] List all tickets, newest opened_date first; break ties by ticket_id descending.

02. [Beginner] Find unresolved High or Critical tickets.

03. [Beginner] Find tickets with no assigned technician. Use SQL NULL correctly.

04. [Beginner] List the distinct ticket categories alphabetically.

05. [Beginner] Count tickets in each status.

06. [Beginner] Find tickets opened from October 7 through October 12, inclusive.

07. [Intermediate] Show every ticket with its requester and department.

08. [Intermediate] Show every ticket and assigned technician; display Unassigned when absent.

09. [Intermediate] Find employees who have never submitted a ticket.

10. [Intermediate] Find departments with at least five tickets.

11. [Intermediate] Find overdue unresolved tickets as of 2026-10-14. Due today is not overdue.

12. [Intermediate] Count unresolved tickets per technician, including technicians with zero.

13. [Intermediate] Show total logged minutes per ticket, including tickets with no work logs.

14. [Intermediate] Find unassigned assets.

15. [Intermediate] Label resolved tickets On Time or Late according to their due_date.

16. [Advanced] Calculate average calendar days to resolution by category, rounded to two decimals. This is not a business-hours metric.

17. [Advanced] Using a CTE, find tickets with more total logged minutes than the average across ALL tickets, including zero-log tickets.

18. [Advanced] Find the most recent ticket per employee using ROW_NUMBER. Break date ties with the highest ticket_id.

19. [Advanced] Produce daily ticket counts and a running total using a window function.

20. [Advanced] Rank technicians by minutes actually logged, including zero. Use DENSE_RANK and show ties.

21. [Advanced] Calculate the percentage of resolved tickets that met their due date.

22. [Safe writes] Temporarily assign ticket 7 to technician 3, verify the change, and roll back. Run the WHOLE answer block on the same connection.

*/

-- ANSWER KEY: SQL and expected results for the original, unmodified dataset.

/* ANSWER 01: List all tickets, newest opened_date first; break ties by ticket_id descending.

SELECT * FROM tickets ORDER BY opened_date DESC, ticket_id DESC;

Expected rows (columns follow SELECT order):
16 | 6 | 6 | 2 | Security | Critical | In Progress | 2026-10-14 | 2026-10-14 | NULL
15 | 5 | 5 | NULL | Hardware | Low | Open | 2026-10-14 | 2026-10-21 | NULL
14 | 2 | 2 | 2 | Security | High | Open | 2026-10-13 | 2026-10-15 | NULL
13 | 1 | 1 | 1 | Network | Medium | Resolved | 2026-10-12 | 2026-10-16 | 2026-10-13
12 | 4 | 4 | 3 | Software | Medium | Open | 2026-10-12 | 2026-10-16 | NULL
11 | 6 | 6 | NULL | Account | Low | Open | 2026-10-11 | 2026-10-18 | NULL
10 | 5 | 5 | 1 | Network | High | In Progress | 2026-10-10 | 2026-10-12 | NULL
9 | 3 | 3 | 3 | Hardware | High | Resolved | 2026-10-09 | 2026-10-11 | 2026-10-12
8 | 2 | 2 | 2 | Account | Medium | Resolved | 2026-10-08 | 2026-10-12 | 2026-10-10
7 | 1 | 1 | NULL | Software | Medium | Open | 2026-10-07 | 2026-10-12 | NULL
6 | 6 | 6 | 2 | Security | Critical | In Progress | 2026-10-06 | 2026-10-06 | NULL
5 | 5 | 5 | 1 | Hardware | High | Open | 2026-10-05 | 2026-10-07 | NULL
4 | 4 | 4 | 3 | Account | Low | Resolved | 2026-10-04 | 2026-10-10 | 2026-10-04
3 | 3 | 3 | 1 | Software | Medium | Resolved | 2026-10-03 | 2026-10-07 | 2026-10-05
2 | 2 | 2 | 2 | Security | Critical | Resolved | 2026-10-02 | 2026-10-02 | 2026-10-03
1 | 1 | 1 | 1 | Network | High | Resolved | 2026-10-01 | 2026-10-03 | 2026-10-02
*/

/* ANSWER 02: Find unresolved High or Critical tickets.

SELECT ticket_id, priority, status FROM tickets WHERE status <> 'Resolved' AND priority IN ('High','Critical') ORDER BY ticket_id;

Expected rows (columns follow SELECT order):
5 | High | Open
6 | Critical | In Progress
10 | High | In Progress
14 | High | Open
16 | Critical | In Progress
*/

/* ANSWER 03: Find tickets with no assigned technician. Use SQL NULL correctly.

SELECT ticket_id FROM tickets WHERE technician_id IS NULL ORDER BY ticket_id;

Expected rows (columns follow SELECT order):
7
11
15
*/

/* ANSWER 04: List the distinct ticket categories alphabetically.

SELECT DISTINCT category FROM tickets ORDER BY category;

Expected rows (columns follow SELECT order):
Account
Hardware
Network
Security
Software
*/

/* ANSWER 05: Count tickets in each status.

SELECT status, COUNT(*) AS ticket_count FROM tickets GROUP BY status ORDER BY status;

Expected rows (columns follow SELECT order):
In Progress | 3
Open | 6
Resolved | 7
*/

/* ANSWER 06: Find tickets opened from October 7 through October 12, inclusive.

SELECT ticket_id, opened_date FROM tickets WHERE opened_date BETWEEN '2026-10-07' AND '2026-10-12' ORDER BY ticket_id;

Expected rows (columns follow SELECT order):
7 | 2026-10-07
8 | 2026-10-08
9 | 2026-10-09
10 | 2026-10-10
11 | 2026-10-11
12 | 2026-10-12
13 | 2026-10-12
*/

/* ANSWER 07: Show every ticket with its requester and department.

SELECT t.ticket_id, e.employee_name, d.department_name FROM tickets t JOIN employees e ON e.employee_id=t.employee_id JOIN departments d ON d.department_id=e.department_id ORDER BY t.ticket_id;

Expected rows (columns follow SELECT order):
1 | Avery Lane | Operations
2 | Jordan Reed | Security
3 | Morgan Chen | Finance
4 | Riley Brooks | Human Resources
5 | Casey Patel | Operations
6 | Taylor Kim | Security
7 | Avery Lane | Operations
8 | Jordan Reed | Security
9 | Morgan Chen | Finance
10 | Casey Patel | Operations
11 | Taylor Kim | Security
12 | Riley Brooks | Human Resources
13 | Avery Lane | Operations
14 | Jordan Reed | Security
15 | Casey Patel | Operations
16 | Taylor Kim | Security
*/

/* ANSWER 08: Show every ticket and assigned technician; display Unassigned when absent.

SELECT t.ticket_id, COALESCE(x.technician_name,'Unassigned') AS technician FROM tickets t LEFT JOIN technicians x ON x.technician_id=t.technician_id ORDER BY t.ticket_id;

Expected rows (columns follow SELECT order):
1 | Alex Carter
2 | Jamie Morgan
3 | Alex Carter
4 | Skyler Davis
5 | Alex Carter
6 | Jamie Morgan
7 | Unassigned
8 | Jamie Morgan
9 | Skyler Davis
10 | Alex Carter
11 | Unassigned
12 | Skyler Davis
13 | Alex Carter
14 | Jamie Morgan
15 | Unassigned
16 | Jamie Morgan
*/

/* ANSWER 09: Find employees who have never submitted a ticket.

SELECT e.employee_id, e.employee_name FROM employees e WHERE NOT EXISTS (SELECT 1 FROM tickets t WHERE t.employee_id=e.employee_id) ORDER BY e.employee_id;

Expected rows (columns follow SELECT order):
7 | Drew Ellis
8 | Sam Rivera
*/

/* ANSWER 10: Find departments with at least five tickets.

SELECT d.department_name, COUNT(*) AS ticket_count FROM departments d JOIN employees e ON e.department_id=d.department_id JOIN tickets t ON t.employee_id=e.employee_id GROUP BY d.department_id,d.department_name HAVING COUNT(*) >= 5 ORDER BY d.department_name;

Expected rows (columns follow SELECT order):
Operations | 6
Security | 6
*/

/* ANSWER 11: Find overdue unresolved tickets as of 2026-10-14. Due today is not overdue.

SELECT ticket_id, due_date FROM tickets WHERE status <> 'Resolved' AND due_date < '2026-10-14' ORDER BY ticket_id;

Expected rows (columns follow SELECT order):
5 | 2026-10-07
6 | 2026-10-06
7 | 2026-10-12
10 | 2026-10-12
*/

/* ANSWER 12: Count unresolved tickets per technician, including technicians with zero.

SELECT x.technician_name, COUNT(t.ticket_id) AS active_tickets FROM technicians x LEFT JOIN tickets t ON t.technician_id=x.technician_id AND t.status <> 'Resolved' GROUP BY x.technician_id,x.technician_name ORDER BY x.technician_id;

Expected rows (columns follow SELECT order):
Alex Carter | 2
Jamie Morgan | 3
Skyler Davis | 1
Robin Lee | 0
*/

/* ANSWER 13: Show total logged minutes per ticket, including tickets with no work logs.

SELECT t.ticket_id, COALESCE(SUM(w.minutes_spent),0) AS total_minutes FROM tickets t LEFT JOIN work_logs w ON w.ticket_id=t.ticket_id GROUP BY t.ticket_id ORDER BY t.ticket_id;

Expected rows (columns follow SELECT order):
1 | 75
2 | 90
3 | 60
4 | 15
5 | 0
6 | 120
7 | 0
8 | 25
9 | 105
10 | 45
11 | 0
12 | 0
13 | 20
14 | 40
15 | 0
16 | 60
*/

/* ANSWER 14: Find unassigned assets.

SELECT asset_id, hostname FROM assets WHERE employee_id IS NULL ORDER BY asset_id;

Expected rows (columns follow SELECT order):
7 | SPARE-LT-01
8 | SPARE-PC-01
*/

/* ANSWER 15: Label resolved tickets On Time or Late according to their due_date.

SELECT ticket_id, CASE WHEN resolved_date <= due_date THEN 'On Time' ELSE 'Late' END AS sla_result FROM tickets WHERE status='Resolved' ORDER BY ticket_id;

Expected rows (columns follow SELECT order):
1 | On Time
2 | Late
3 | On Time
4 | On Time
8 | On Time
9 | Late
13 | On Time
*/

/* ANSWER 16: Calculate average calendar days to resolution by category, rounded to two decimals. This is not a business-hours metric.

SELECT category, ROUND(AVG(DATEDIFF(resolved_date,opened_date)),2) AS average_days FROM tickets WHERE status='Resolved' GROUP BY category ORDER BY category;

Expected rows (columns follow SELECT order):
Account | 1.0
Hardware | 3.0
Network | 1.0
Security | 1.0
Software | 2.0
*/

/* ANSWER 17: Using a CTE, find tickets with more total logged minutes than the average across ALL tickets, including zero-log tickets.

WITH totals AS (SELECT t.ticket_id, COALESCE(SUM(w.minutes_spent),0) AS total_minutes FROM tickets t LEFT JOIN work_logs w ON w.ticket_id=t.ticket_id GROUP BY t.ticket_id) SELECT ticket_id,total_minutes FROM totals WHERE total_minutes > (SELECT AVG(total_minutes) FROM totals) ORDER BY ticket_id;

Expected rows (columns follow SELECT order):
1 | 75
2 | 90
3 | 60
6 | 120
9 | 105
10 | 45
16 | 60
*/

/* ANSWER 18: Find the most recent ticket per employee using ROW_NUMBER. Break date ties with the highest ticket_id.

WITH ranked AS (SELECT ticket_id,employee_id,opened_date, ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY opened_date DESC,ticket_id DESC) AS rn FROM tickets) SELECT ticket_id,employee_id,opened_date FROM ranked WHERE rn=1 ORDER BY employee_id;

Expected rows (columns follow SELECT order):
13 | 1 | 2026-10-12
14 | 2 | 2026-10-13
9 | 3 | 2026-10-09
12 | 4 | 2026-10-12
15 | 5 | 2026-10-14
16 | 6 | 2026-10-14
*/

/* ANSWER 19: Produce daily ticket counts and a running total using a window function.

WITH daily AS (SELECT opened_date,COUNT(*) AS tickets_opened FROM tickets GROUP BY opened_date) SELECT opened_date,tickets_opened,SUM(tickets_opened) OVER (ORDER BY opened_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM daily ORDER BY opened_date;

Expected rows (columns follow SELECT order):
2026-10-01 | 1 | 1
2026-10-02 | 1 | 2
2026-10-03 | 1 | 3
2026-10-04 | 1 | 4
2026-10-05 | 1 | 5
2026-10-06 | 1 | 6
2026-10-07 | 1 | 7
2026-10-08 | 1 | 8
2026-10-09 | 1 | 9
2026-10-10 | 1 | 10
2026-10-11 | 1 | 11
2026-10-12 | 2 | 13
2026-10-13 | 1 | 14
2026-10-14 | 2 | 16
*/

/* ANSWER 20: Rank technicians by minutes actually logged, including zero. Use DENSE_RANK and show ties.

WITH effort AS (SELECT x.technician_id,x.technician_name,COALESCE(SUM(w.minutes_spent),0) AS total_minutes FROM technicians x LEFT JOIN work_logs w ON w.technician_id=x.technician_id GROUP BY x.technician_id,x.technician_name) SELECT technician_name,total_minutes,DENSE_RANK() OVER (ORDER BY total_minutes DESC) AS effort_rank FROM effort ORDER BY effort_rank,technician_id;

Expected rows (columns follow SELECT order):
Jamie Morgan | 335 | 1
Alex Carter | 230 | 2
Skyler Davis | 90 | 3
Robin Lee | 0 | 4
*/

/* ANSWER 21: Calculate the percentage of resolved tickets that met their due date.

SELECT ROUND(100.0 * SUM(CASE WHEN resolved_date <= due_date THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),2) AS on_time_percent FROM tickets WHERE status='Resolved';

Expected rows (columns follow SELECT order):
71.43
*/

/* ANSWER 22: Temporarily assign ticket 7 to technician 3, verify the change, and roll back. Run the WHOLE answer block on the same connection.

START TRANSACTION;
UPDATE tickets SET technician_id=3 WHERE ticket_id=7;
SELECT ticket_id,technician_id FROM tickets WHERE ticket_id=7;
ROLLBACK;
SELECT ticket_id,technician_id FROM tickets WHERE ticket_id=7;

Expected rows (columns follow SELECT order):
First SELECT: 7 | 3
After ROLLBACK: 7 | NULL
*/
