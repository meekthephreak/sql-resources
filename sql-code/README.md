# Runnable MySQL Examples

Load the sample database first. Target: MySQL 8.0.16+. Open each script in Workbench and execute all statements in order.

| Order | Script | What it does |
|---|---|---|
| 1 | `queries.sql` | 21 read-only queries, from filters through window functions |
| 2 | `functions.sql` | Creates `lab_resolution_days`; prints four sample results |
| 3 | `procedures.sql` | Creates requester-report and ticket-assignment procedures; rolls back its assignment demo |
| 4 | `triggers.sql` | Creates an audit table and assignment-change trigger; rolls back its demo |
| 5 | `validate.sql` | Checks fresh dataset totals and basic query invariants |

## Workbench delimiters

`DELIMITER $$` tells the client to send a whole routine definition even though its body contains semicolons. `END$$` ends that definition, and `DELIMITER ;` restores normal behavior. Execute the whole definition, including delimiter lines. DELIMITER is a client command, not server SQL; application migration tools may require sending the routine body as one statement instead.

## Permissions and side effects

Routines require CREATE ROUTINE, and execution requires EXECUTE. Replacing existing routines can require ALTER ROUTINE. Triggers require TRIGGER; the audit table requires CREATE. Binary-logging settings may impose additional function/trigger restrictions. Ask your lab administrator rather than weakening global settings.

Scripts replace only their named `lab_` routines/trigger, preserving base records. They are intended for this disposable schema. DDL occurs before demo transactions because DDL can implicitly commit. Run each transaction's complete block on one connection; do not stop after UPDATE. If you do, issue ROLLBACK on that connection.

The assignment trigger records technician changes, including NULL transitions, using MySQL's NULL-safe comparison. Audit data is instructional and is not tamper-resistant. Its sample insert is rolled back with the ticket update.

Expected results assume unmodified seed data. Setup does not reset your edits. Native MySQL execution was unavailable during authoring; run the scripts here on your server and check the expected outputs before adapting them.
