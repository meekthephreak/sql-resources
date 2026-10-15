-- MySQL 8.0.16+; CHECK constraints are enforced from this version.
-- Creates only lab objects; does not drop or reset data.
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
