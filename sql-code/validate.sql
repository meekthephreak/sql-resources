-- Run on original seed data. Every passed column should return 1.
USE sql_resources_helpdesk_lab;
SELECT (SELECT COUNT(*) FROM departments)=4 AS departments_passed,
 (SELECT COUNT(*) FROM employees)=8 AS employees_passed,
 (SELECT COUNT(*) FROM technicians)=4 AS technicians_passed,
 (SELECT COUNT(*) FROM assets)=8 AS assets_passed,
 (SELECT COUNT(*) FROM tickets)=16 AS tickets_passed,
 (SELECT COUNT(*) FROM work_logs)=13 AS work_logs_passed;
SELECT COUNT(*)=4 AS overdue_passed FROM tickets
WHERE status<>'Resolved' AND due_date<'2026-10-14';
SELECT COUNT(*)=3 AS unassigned_passed FROM tickets WHERE technician_id IS NULL;
SELECT COUNT(*)=7 AS resolved_passed FROM tickets WHERE status='Resolved';
SELECT SUM(minutes_spent)=655 AS total_minutes_passed FROM work_logs;
-- Then run the complete rollback demos in procedures.sql and triggers.sql.
