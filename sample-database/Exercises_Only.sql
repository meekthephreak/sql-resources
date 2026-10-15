-- IT HELP DESK LAB: EXERCISES ONLY
-- MySQL 8.0.16+ | All data is fictional.
-- First load sample-database/MySQL_Workbench_Practice.sql,
-- or schema.sql followed by data.sql.
-- Open THIS file in MySQL Workbench and write your queries below each prompt.
-- Select the SQL you want to run; do not execute all your work indiscriminately.
-- Save your edited copy to keep your answers.
-- Reporting date: 2026-10-14. Expected behavior assumes original seed data.
-- Instructions and troubleshooting: ../LAB_README.md
-- This file contains no solutions or expected-result spoilers.
-- Table reference:
-- departments(department_id, department_name)
-- employees(employee_id, employee_name, department_id, email)
-- technicians(technician_id, technician_name)
-- assets(asset_id, hostname, asset_type, employee_id)
-- tickets(ticket_id, employee_id, asset_id, technician_id, category,
--         priority, status, opened_date, due_date, resolved_date)
-- work_logs(work_log_id, ticket_id, technician_id, minutes_spent)
-- In exercise 22, run START TRANSACTION through ROLLBACK together
-- on one connection; verify again after rollback. Keep DDL outside it.

USE sql_resources_helpdesk_lab;

-- 01. [Beginner] List all tickets, newest opened_date first; break ties by ticket_id descending.
-- Your SQL:




-- 02. [Beginner] Find unresolved High or Critical tickets.
-- Your SQL:




-- 03. [Beginner] Find tickets with no assigned technician. Use SQL NULL correctly.
-- Your SQL:




-- 04. [Beginner] List the distinct ticket categories alphabetically.
-- Your SQL:




-- 05. [Beginner] Count tickets in each status.
-- Your SQL:




-- 06. [Beginner] Find tickets opened from October 7 through October 12, inclusive.
-- Your SQL:




-- 07. [Intermediate] Show every ticket with its requester and department.
-- Your SQL:




-- 08. [Intermediate] Show every ticket and assigned technician; display Unassigned when absent.
-- Your SQL:




-- 09. [Intermediate] Find employees who have never submitted a ticket.
-- Your SQL:




-- 10. [Intermediate] Find departments with at least five tickets.
-- Your SQL:




-- 11. [Intermediate] Find overdue unresolved tickets as of 2026-10-14. Due today is not overdue.
-- Your SQL:




-- 12. [Intermediate] Count unresolved tickets per technician, including technicians with zero.
-- Your SQL:




-- 13. [Intermediate] Show total logged minutes per ticket, including tickets with no work logs.
-- Your SQL:




-- 14. [Intermediate] Find unassigned assets.
-- Your SQL:




-- 15. [Intermediate] Label resolved tickets On Time or Late according to their due_date.
-- Your SQL:




-- 16. [Advanced] Calculate average calendar days to resolution by category, rounded to two decimals. This is not a business-hours metric.
-- Your SQL:




-- 17. [Advanced] Using a CTE, find tickets with more total logged minutes than the average across ALL tickets, including zero-log tickets.
-- Your SQL:




-- 18. [Advanced] Find the most recent ticket per employee using ROW_NUMBER. Break date ties with the highest ticket_id.
-- Your SQL:




-- 19. [Advanced] Produce daily ticket counts and a running total using a window function.
-- Your SQL:




-- 20. [Advanced] Rank technicians by minutes actually logged, including zero. Use DENSE_RANK and show ties.
-- Your SQL:




-- 21. [Advanced] Calculate the percentage of resolved tickets that met their due date.
-- Your SQL:




-- 22. [Safe writes] Temporarily assign ticket 7 to technician 3, verify the change, and roll back. Run the WHOLE answer block on the same connection.
-- Your SQL:



