-- ============================================================
-- SQLNOIR MYSTERY #006: The Silicon Sabotage
-- Student: Haroon Ahmed
-- Course: CS SQL Mysteries Assignment
-- Date: 2026-03-27
-- Tool: SQLNoir (https://www.sqlnoir.com/)
-- Database: SQLNoir built-in (incident_reports, witness_statements,
--           employee_records, keycard_access_logs,
--           computer_access_logs, email_logs, facility_access_logs)
-- ============================================================
-- CASE BRIEF:
-- QuantumTech, Miami's leading technology corporation, was about
-- to unveil its groundbreaking microprocessor "QuantaX" on
-- April 21, 1989. Just hours before the reveal, the prototype
-- was destroyed and all research data was erased from servers.
-- Detectives suspect corporate espionage. Our task: follow a
-- chain of anonymous emails, facility access logs, and witness
-- statements to expose the true saboteur.
-- ============================================================


-- ============================================================
-- SECTION 1: Retrieve the Incident Report
-- ============================================================
-- We search incident_reports for the QuantumTech sabotage event.
-- This gives us the incident id needed to pull witness statements.
-- ============================================================

SELECT *
FROM incident_reports
WHERE location LIKE '%QuantumTech%'
OR description LIKE '%QuantaX%';

-- RESULTS:
-- id | date     | location        | description
-- 74 | 19890421 | QuantumTech HQ  | Prototype destroyed;
--    |          |                 | data erased from servers.

-- KEY LEADS:
-- Incident id = 74. Both physical prototype and server data
-- were targeted — suggesting coordinated insider access.


-- ============================================================
-- SECTION 2: Retrieve Witness Statements
-- ============================================================
-- We JOIN employee_records to witness_statements filtering
-- on incident_id = 74 to surface actionable clues.
-- ============================================================

SELECT e.employee_name, e.department, e.occupation, w.statement
FROM employee_records e
JOIN witness_statements w ON w.employee_id = e.id
WHERE w.incident_id = 74;

-- RESULTS:
-- employee_name  | department      | occupation            | statement
-- Carl Jenkins   | Hardware        | Electronics Engineer  | I heard someone mention
--                |                 |                       | a server in Helsinki.
-- Tina Ruiz      | Human Resources | Training Coordinator  | I saw someone holding a
--                |                 |                       | keycard marked QX- succeeded
--                |                 |                       | by a two-digit odd number.

-- KEY CLUES:
-- Clue 1: Server access in Helsinki → computer_access_logs
-- Clue 2: Keycard code QX-[two-digit odd number] → keycard_access_logs


-- ============================================================
-- SECTION 3: Cross-Reference Keycard + Helsinki Server Access
-- ============================================================
-- JOIN keycard and computer access logs to find the employee
-- matching both witness clues simultaneously on the day of
-- the sabotage. SUBSTR extracts the numeric keycard suffix.
-- ============================================================

SELECT DISTINCT e.employee_name, e.department, e.occupation,
       k.keycard_code, c.server_location, c.access_date
FROM employee_records e
JOIN keycard_access_logs k ON k.employee_id = e.id
JOIN computer_access_logs c ON c.employee_id = e.id
WHERE k.access_date = 19890421
AND c.access_date = 19890421
AND c.server_location LIKE '%Helsinki%'
AND CAST(SUBSTR(k.keycard_code, 4) AS INTEGER) BETWEEN 10 AND 99
AND CAST(SUBSTR(k.keycard_code, 4) AS INTEGER) % 2 = 1;

-- RESULTS:
-- employee_name    | department  | occupation          | keycard | server    | date
-- Elizabeth Gordon | Engineering | Solutions Architect | QX-035  | Helsinki  | 19890421

-- NOTE: Elizabeth Gordon matches both witness clues but is NOT
-- the final saboteur — she is a link in a larger conspiracy.


-- ============================================================
-- SECTION 4: Pull Elizabeth Gordon's Witness Statement
-- ============================================================
-- Elizabeth's own statement reveals she received an email about
-- an alarm malfunction near the chip, directing her to
-- Facility 18 — unknowingly clearing the path for the real saboteur.
-- ============================================================

SELECT e.employee_name, e.department, e.occupation, w.statement
FROM employee_records e
JOIN witness_statements w ON w.employee_id = e.id
WHERE e.employee_name = 'Elizabeth Gordon';

-- RESULTS:
-- employee_name    | statement
-- Elizabeth Gordon | That day, I received an email from a colleague saying
--                  | something was wrong with the alarm system. I went to
--                  | check it out, but didn't find anything unusual.


-- ============================================================
-- SECTION 5: Trace the Email Chain to Norman Owens
-- ============================================================
-- We search email_logs for all emails sent to or from
-- Elizabeth Gordon, revealing Norman Owens sent her a coded
-- message guiding her to the prototype location.
-- ============================================================

SELECT
    sender.employee_name AS sender,
    recipient.employee_name AS recipient,
    el.email_date,
    el.email_subject,
    el.email_content
FROM email_logs el
JOIN employee_records sender ON sender.id = el.sender_employee_id
JOIN employee_records recipient ON recipient.id = el.recipient_employee_id
WHERE sender.employee_name = 'Elizabeth Gordon'
OR recipient.employee_name = 'Elizabeth Gordon';

-- RESULTS:
-- sender        | recipient        | subject              | content
-- Norman Owens  | Elizabeth Gordon | Alarm System Concern | I noticed something strange
--               |                  |                      | with the alarm system. There
--               |                  |                      | might be a potential malfunction
--               |                  |                      | near the chip. Thought you
--               |                  |                      | should check it out to be safe.


-- ============================================================
-- SECTION 6: Uncover Anonymous Emails Sent to Norman Owens
-- ============================================================
-- Norman Owens (appearing twice in employee_records with ids
-- 85 and 263) received instructions from a NULL sender —
-- an anonymous external orchestrator who directed him to
-- unlock Facility 18 and move Elizabeth into position.
-- ============================================================

SELECT
    el.sender_employee_id AS sender_id,
    recipient.employee_name AS recipient,
    el.email_date,
    el.email_subject,
    el.email_content
FROM email_logs el
JOIN employee_records recipient ON recipient.id = el.recipient_employee_id
WHERE recipient.employee_name = 'Norman Owens'
AND el.sender_employee_id IS NULL;

-- RESULTS:
-- sender_id | recipient    | content
-- NULL      | Norman Owens | Move L into place.
-- NULL      | Norman Owens | Unlock Facility 18 so they can finish things.

-- KEY FINDING: An anonymous external actor orchestrated the
-- entire conspiracy through Norman Owens as intermediary.


-- ============================================================
-- SECTION 7: Check Facility 18 Access Logs
-- ============================================================
-- We pull all employees who accessed Facility 18 on the day
-- of the sabotage, ordered by access time. Elizabeth entered
-- first; Hristo Bogoev followed and destroyed the prototype.
-- ============================================================

SELECT e.employee_name, e.department, e.occupation,
       f.facility_name, f.access_date, f.access_time
FROM employee_records e
JOIN facility_access_logs f ON f.employee_id = e.id
WHERE f.facility_name = 'Facility 18'
AND f.access_date = 19890421
ORDER BY f.access_time;

-- RESULTS:
-- employee_name    | department  | occupation          | time
-- Elizabeth Gordon | Engineering | Solutions Architect | 08:55
-- Hristo Bogoev    | Engineering | Principal Engineer  | [shortly after]

-- FINDING: Only two employees accessed Facility 18 that day.
-- Elizabeth was directed there by Norman's email.
-- Hristo Bogoev followed and carried out the sabotage.


-- ============================================================
-- MASTER QUERY — Full Investigation via CTE
-- ============================================================
-- This CTE chains the entire conspiracy:
--   1. Locate the incident (CTE: incident)
--   2. Find the keycard+Helsinki employee (CTE: initial_suspect)
--   3. Find all Facility 18 accessors on the day (CTE: facility_18_access)
--   4. Return the saboteur who is NOT the initial suspect (final SELECT)
-- ============================================================

WITH incident AS (
    -- Step 1: Locate the sabotage incident
    SELECT id, date
    FROM incident_reports
    WHERE location LIKE '%QuantumTech%'
),
initial_suspect AS (
    -- Step 2: Find employee matching both witness clues
    -- (odd two-digit keycard + Helsinki server access)
    SELECT DISTINCT e.id, e.employee_name
    FROM employee_records e
    JOIN keycard_access_logs k ON k.employee_id = e.id
    JOIN computer_access_logs c ON c.employee_id = e.id
    WHERE k.access_date = (SELECT date FROM incident)
    AND c.access_date = (SELECT date FROM incident)
    AND c.server_location LIKE '%Helsinki%'
    AND CAST(SUBSTR(k.keycard_code, 4) AS INTEGER) BETWEEN 10 AND 99
    AND CAST(SUBSTR(k.keycard_code, 4) AS INTEGER) % 2 = 1
),
facility_18_access AS (
    -- Step 3: Find all employees who accessed Facility 18
    -- on the day of the sabotage, ordered by time
    SELECT e.id, e.employee_name, e.department,
           e.occupation, f.access_time
    FROM employee_records e
    JOIN facility_access_logs f ON f.employee_id = e.id
    WHERE f.facility_name = 'Facility 18'
    AND f.access_date = (SELECT date FROM incident)
)
-- Step 4: Return the Facility 18 accessor who is NOT Elizabeth Gordon
-- (the true saboteur who followed her in)
SELECT
    fa.employee_name    AS saboteur,
    fa.department       AS department,
    fa.occupation       AS occupation,
    fa.access_time      AS facility_18_access_time
FROM facility_18_access fa
WHERE fa.employee_name NOT IN (SELECT employee_name FROM initial_suspect)
ORDER BY fa.access_time;

-- FINAL RESULT:
-- saboteur      | department  | occupation         | access_time
-- Hristo Bogoev | Engineering | Principal Engineer | [after Elizabeth]

-- ============================================================
-- CASE CLOSED
-- ============================================================
-- The saboteur is HRISTO BOGOEV, Principal Engineer.
-- The full conspiracy chain:
--   Anonymous external actor (NULL sender)
--     → Emailed Norman Owens to "move L into place"
--       and "unlock Facility 18"
--     → Norman Owens emailed Elizabeth Gordon about a fake
--       "alarm malfunction near the chip"
--     → Elizabeth Gordon (keycard QX-035 + Helsinki server
--       access) went to Facility 18 to investigate
--     → Hristo Bogoev followed Elizabeth into Facility 18
--       and destroyed the QuantaX prototype
-- The Silicon Sabotage at QuantumTech HQ on April 21, 1989
-- is hereby solved.
-- ============================================================
