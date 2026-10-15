-- Requires CREATE ROUTINE; some binary-logging configurations restrict function creation.
-- Do not weaken server settings to load this example; use an authorized lab account.
USE sql_resources_helpdesk_lab;
DROP FUNCTION IF EXISTS lab_resolution_days;
DELIMITER $$
CREATE FUNCTION lab_resolution_days(p_opened DATE, p_resolved DATE)
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
 RETURN CASE WHEN p_resolved IS NULL THEN NULL
             ELSE DATEDIFF(p_resolved,p_opened) END;
END$$
DELIMITER ;
SELECT ticket_id, lab_resolution_days(opened_date,resolved_date) AS resolution_days
FROM tickets WHERE ticket_id IN (1,2,3,4) ORDER BY ticket_id;
-- Expected: (1,1), (2,1), (3,2), (4,0).
