USE sql_resources_helpdesk_lab;
DROP PROCEDURE IF EXISTS lab_employee_tickets;
DROP PROCEDURE IF EXISTS lab_assign_ticket;
DELIMITER $$
CREATE PROCEDURE lab_employee_tickets(IN p_employee_id INT)
READS SQL DATA
BEGIN
 SELECT ticket_id,category,priority,status,technician_id
 FROM tickets WHERE employee_id=p_employee_id ORDER BY ticket_id;
END$$
CREATE PROCEDURE lab_assign_ticket(IN p_ticket_id INT, IN p_technician_id INT)
MODIFIES SQL DATA
BEGIN
 IF NOT EXISTS (SELECT 1 FROM technicians WHERE technician_id=p_technician_id) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unknown technician';
 END IF;
 UPDATE tickets SET technician_id=p_technician_id
 WHERE ticket_id=p_ticket_id AND status <> 'Resolved';
 SELECT ROW_COUNT() AS changed_tickets;
END$$
DELIMITER ;
CALL lab_employee_tickets(1);
-- Expected ticket IDs: 1,7,13.
-- Safe demo: run this whole transaction on one connection. No COMMIT in procedure.
START TRANSACTION;
CALL lab_assign_ticket(7,3);
SELECT ticket_id,technician_id FROM tickets WHERE ticket_id=7;
-- Expected: 7,3 on original data. ROW_COUNT is 0 if already assigned to 3.
ROLLBACK;
SELECT ticket_id,technician_id FROM tickets WHERE ticket_id=7;
-- Expected: 7,NULL on original data.
