-- Run schema.sql then data.sql first. MySQL 8.0.16+.
USE sql_resources_helpdesk_lab;

-- 01. Beginner: List all tickets, newest opened_date first; break ties by ticket_id descending.
-- Expected: 16 rows on the original dataset.
SELECT * FROM tickets ORDER BY opened_date DESC, ticket_id DESC;

-- 02. Beginner: Find unresolved High or Critical tickets.
-- Expected: 5 rows on the original dataset.
SELECT ticket_id, priority, status FROM tickets WHERE status <> 'Resolved' AND priority IN ('High','Critical') ORDER BY ticket_id;

-- 03. Beginner: Find tickets with no assigned technician. Use SQL NULL correctly.
-- Expected: 3 rows on the original dataset.
SELECT ticket_id FROM tickets WHERE technician_id IS NULL ORDER BY ticket_id;

-- 04. Beginner: List the distinct ticket categories alphabetically.
-- Expected: 5 rows on the original dataset.
SELECT DISTINCT category FROM tickets ORDER BY category;

-- 05. Beginner: Count tickets in each status.
-- Expected: 3 rows on the original dataset.
SELECT status, COUNT(*) AS ticket_count FROM tickets GROUP BY status ORDER BY status;

-- 06. Beginner: Find tickets opened from October 7 through October 12, inclusive.
-- Expected: 7 rows on the original dataset.
SELECT ticket_id, opened_date FROM tickets WHERE opened_date BETWEEN '2026-10-07' AND '2026-10-12' ORDER BY ticket_id;

-- 07. Intermediate: Show every ticket with its requester and department.
-- Expected: 16 rows on the original dataset.
SELECT t.ticket_id, e.employee_name, d.department_name FROM tickets t JOIN employees e ON e.employee_id=t.employee_id JOIN departments d ON d.department_id=e.department_id ORDER BY t.ticket_id;

-- 08. Intermediate: Show every ticket and assigned technician; display Unassigned when absent.
-- Expected: 16 rows on the original dataset.
SELECT t.ticket_id, COALESCE(x.technician_name,'Unassigned') AS technician FROM tickets t LEFT JOIN technicians x ON x.technician_id=t.technician_id ORDER BY t.ticket_id;

-- 09. Intermediate: Find employees who have never submitted a ticket.
-- Expected: 2 rows on the original dataset.
SELECT e.employee_id, e.employee_name FROM employees e WHERE NOT EXISTS (SELECT 1 FROM tickets t WHERE t.employee_id=e.employee_id) ORDER BY e.employee_id;

-- 10. Intermediate: Find departments with at least five tickets.
-- Expected: 2 rows on the original dataset.
SELECT d.department_name, COUNT(*) AS ticket_count FROM departments d JOIN employees e ON e.department_id=d.department_id JOIN tickets t ON t.employee_id=e.employee_id GROUP BY d.department_id,d.department_name HAVING COUNT(*) >= 5 ORDER BY d.department_name;

-- 11. Intermediate: Find overdue unresolved tickets as of 2026-10-14. Due today is not overdue.
-- Expected: 4 rows on the original dataset.
SELECT ticket_id, due_date FROM tickets WHERE status <> 'Resolved' AND due_date < '2026-10-14' ORDER BY ticket_id;

-- 12. Intermediate: Count unresolved tickets per technician, including technicians with zero.
-- Expected: 4 rows on the original dataset.
SELECT x.technician_name, COUNT(t.ticket_id) AS active_tickets FROM technicians x LEFT JOIN tickets t ON t.technician_id=x.technician_id AND t.status <> 'Resolved' GROUP BY x.technician_id,x.technician_name ORDER BY x.technician_id;

-- 13. Intermediate: Show total logged minutes per ticket, including tickets with no work logs.
-- Expected: 16 rows on the original dataset.
SELECT t.ticket_id, COALESCE(SUM(w.minutes_spent),0) AS total_minutes FROM tickets t LEFT JOIN work_logs w ON w.ticket_id=t.ticket_id GROUP BY t.ticket_id ORDER BY t.ticket_id;

-- 14. Intermediate: Find unassigned assets.
-- Expected: 2 rows on the original dataset.
SELECT asset_id, hostname FROM assets WHERE employee_id IS NULL ORDER BY asset_id;

-- 15. Intermediate: Label resolved tickets On Time or Late according to their due_date.
-- Expected: 7 rows on the original dataset.
SELECT ticket_id, CASE WHEN resolved_date <= due_date THEN 'On Time' ELSE 'Late' END AS sla_result FROM tickets WHERE status='Resolved' ORDER BY ticket_id;

-- 16. Advanced: Calculate average calendar days to resolution by category, rounded to two decimals. This is not a business-hours metric.
-- Expected: 5 rows on the original dataset.
SELECT category, ROUND(AVG(DATEDIFF(resolved_date,opened_date)),2) AS average_days FROM tickets WHERE status='Resolved' GROUP BY category ORDER BY category;

-- 17. Advanced: Using a CTE, find tickets with more total logged minutes than the average across ALL tickets, including zero-log tickets.
-- Expected: 7 rows on the original dataset.
WITH totals AS (SELECT t.ticket_id, COALESCE(SUM(w.minutes_spent),0) AS total_minutes FROM tickets t LEFT JOIN work_logs w ON w.ticket_id=t.ticket_id GROUP BY t.ticket_id) SELECT ticket_id,total_minutes FROM totals WHERE total_minutes > (SELECT AVG(total_minutes) FROM totals) ORDER BY ticket_id;

-- 18. Advanced: Find the most recent ticket per employee using ROW_NUMBER. Break date ties with the highest ticket_id.
-- Expected: 6 rows on the original dataset.
WITH ranked AS (SELECT ticket_id,employee_id,opened_date, ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY opened_date DESC,ticket_id DESC) AS rn FROM tickets) SELECT ticket_id,employee_id,opened_date FROM ranked WHERE rn=1 ORDER BY employee_id;

-- 19. Advanced: Produce daily ticket counts and a running total using a window function.
-- Expected: 14 rows on the original dataset.
WITH daily AS (SELECT opened_date,COUNT(*) AS tickets_opened FROM tickets GROUP BY opened_date) SELECT opened_date,tickets_opened,SUM(tickets_opened) OVER (ORDER BY opened_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM daily ORDER BY opened_date;

-- 20. Advanced: Rank technicians by minutes actually logged, including zero. Use DENSE_RANK and show ties.
-- Expected: 4 rows on the original dataset.
WITH effort AS (SELECT x.technician_id,x.technician_name,COALESCE(SUM(w.minutes_spent),0) AS total_minutes FROM technicians x LEFT JOIN work_logs w ON w.technician_id=x.technician_id GROUP BY x.technician_id,x.technician_name) SELECT technician_name,total_minutes,DENSE_RANK() OVER (ORDER BY total_minutes DESC) AS effort_rank FROM effort ORDER BY effort_rank,technician_id;

-- 21. Advanced: Calculate the percentage of resolved tickets that met their due date.
-- Expected: 1 rows on the original dataset.
SELECT ROUND(100.0 * SUM(CASE WHEN resolved_date <= due_date THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),2) AS on_time_percent FROM tickets WHERE status='Resolved';
