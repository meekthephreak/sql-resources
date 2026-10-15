USE sql_resources_helpdesk_lab;
CREATE TABLE IF NOT EXISTS ticket_assignment_audit (
 audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 ticket_id INT NOT NULL,
 old_technician_id INT NULL,
 new_technician_id INT NULL,
 changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- Historical IDs deliberately have no foreign keys; history survives later deletions.
DROP TRIGGER IF EXISTS lab_audit_assignment;
DELIMITER $$
CREATE TRIGGER lab_audit_assignment AFTER UPDATE ON tickets
FOR EACH ROW
BEGIN
 IF NOT (OLD.technician_id <=> NEW.technician_id) THEN
  INSERT INTO ticket_assignment_audit(ticket_id,old_technician_id,new_technician_id)
  VALUES(NEW.ticket_id,OLD.technician_id,NEW.technician_id);
 END IF;
END$$
DELIMITER ;
-- <=> is MySQL's NULL-safe equality operator.
-- Run entire block; both ticket change and audit insert roll back together.
START TRANSACTION;
SET @lab_audit_before = (SELECT COUNT(*) FROM ticket_assignment_audit);
UPDATE tickets SET technician_id=3 WHERE ticket_id=7;
SELECT ticket_id,old_technician_id,new_technician_id
FROM ticket_assignment_audit ORDER BY audit_id DESC LIMIT 1;
-- Original-data result: 7,NULL,3.
ROLLBACK;
SELECT COUNT(*) = @lab_audit_before AS audit_rows_restored
FROM ticket_assignment_audit;
-- Expected: 1. AUTO_INCREMENT gaps after rollback are normal.
