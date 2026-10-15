USE sql_resources_helpdesk_lab;

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
