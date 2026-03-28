-- ============================================================
-- SQLNOIR MYSTERY #003: The Miami Marina Murder
-- Student: Haroon Ahmed
-- Course: CS SQL Mysteries Assignment
-- Date: 2026-03-27
-- Tool: SQLNoir (https://www.sqlnoir.com/)
-- Database: SQLNoir built-in (crime_scene, person, interviews,
--           hotel_checkins, surveillance_records, confessions)
-- ============================================================
-- CASE BRIEF:
-- A body was found floating near the docks of Coral Bay Marina
-- in the early hours of August 14, 1986. The case requires JOINs,
-- wildcard searches, and logical deduction across multiple tables
-- to identify the murderer.
-- ============================================================


-- ============================================================
-- SECTION 1: Retrieve the Crime Scene Report
-- ============================================================
-- We know the location (Coral Bay Marina) and date (August 14,
-- 1986). The crime scene description will give us physical
-- descriptors to hunt suspects with in the person table.
-- ============================================================

SELECT *
FROM crime_scene
WHERE location = 'Coral Bay Marina'
AND date = 19860814;

-- RESULTS:
-- id | date     | location          | description
-- 43 | 19860814 | Coral Bay Marina  | The body of an unidentified man was
--    |          |                   | found near the docks. Two people were
--    |          |                   | seen nearby: one who lives on 300ish
--    |          |                   | "Ocean Drive" and another whose first
--    |          |                   | name ends with "ul" and last name
--    |          |                   | ends with "ez".

-- KEY CLUES EXTRACTED:
-- Suspect 1: Address contains "Ocean Drive" with a 3xx street number.
-- Suspect 2: Name matches pattern '%ul %ez' (wildcard search).


-- ============================================================
-- SECTION 2: Identify Initial Suspects from Person Table
-- ============================================================
-- We use LIKE wildcards to match both suspect descriptions
-- simultaneously using OR logic. This surfaces all persons
-- matching either the address clue or the name pattern.
-- ============================================================

SELECT *
FROM person
WHERE (address LIKE '%Ocean Drive%' AND address LIKE '%3%')
OR name LIKE '%ul %ez';

-- RESULTS:
-- id  | name             | alias      | occupation    | address
-- 5   | Michael Santos   | Silent Mike| Bartender     | 33 Ocean Drive
-- 62  | Jesse Brooks     | The Judge  | Court Clerk   | 234 Ocean Drive
-- 101 | Carlos Mendez    | Los Ojos   | Fisherman     | 369 Ocean Drive
-- 102 | Raul Gutierrez   | The Cobra  | Nightclub Owner| 45 Sunset Ave
-- 105 | Victor Martinez  | Slick Vic  | Bartender     | 33 Ocean Drive

-- NOTE:
-- Five persons of interest identified. We now cross-reference
-- hotel checkins and surveillance records to place them
-- near the scene around the time of the murder.


-- ============================================================
-- SECTION 3: Cross-Reference Hotel Checkins & Surveillance
-- ============================================================
-- We JOIN person, hotel_checkins, and surveillance_records
-- to see which suspects were staying nearby and flagged
-- for suspicious activity around the murder date.
-- ============================================================

SELECT p.name, p.alias, h.hotel_name, h.check_in_date, s.suspicious_activity
FROM person p
JOIN hotel_checkins h ON h.person_id = p.id
JOIN surveillance_records s ON s.person_id = p.id
WHERE p.id IN (5, 62, 101, 102, 105);

-- RESULTS:
-- name           | alias     | hotel_name              | check_in_date | suspicious_activity
-- Jesse Brooks   | The Judge | Island Paradise Resort  | 19860815      | Requested taxi service
-- Carlos Mendez  | Los Ojos  | Coral View Resort       | 19860812      | Asked for room service menu
-- Raul Gutierrez | The Cobra | Marina Paradise Inn     | 19860815      | NULL
-- Victor Martinez| Slick Vic | Beach Light Inn         | 19860812      | NULL

-- NOTE:
-- Michael Santos has no hotel record. Raul and Victor have NULL
-- suspicious activity. Interviews needed to follow the trail further.


-- ============================================================
-- SECTION 4: Interview Transcripts — Following the Trail
-- ============================================================
-- We pull interview transcripts for all five initial suspects.
-- Their statements redirect us: Raul mentions someone checked
-- into a hotel with "Sunset" in the name on August 13.
-- ============================================================

SELECT p.name, i.transcript
FROM person p
JOIN interviews i ON i.person_id = p.id
WHERE p.id IN (5, 62, 101, 102, 105);

-- RESULTS:
-- name           | transcript
-- Carlos Mendez  | I saw someone check into a hotel on August 13.
--                | The guy looked nervous.
-- Raul Gutierrez | I heard someone checked into a hotel with "Sunset"
--                | in the name.
-- Victor Martinez| I didn't do anything. Ask Raul. He knows more.

-- KEY CLUE: Someone checked into a hotel with "Sunset" in the name
-- on August 13, 1986 — the night before the murder.


-- ============================================================
-- SECTION 5: Hunt the Sunset Hotel Guest with Suspicious Activity
-- ============================================================
-- We expand the search: JOIN hotel_checkins and surveillance_records
-- filtering on hotel names containing "Sunset" and check-in date
-- of August 13. We filter for non-NULL suspicious activity.
-- ============================================================

SELECT p.name, p.alias, h.hotel_name, h.check_in_date, s.suspicious_activity
FROM person p
JOIN hotel_checkins h ON h.person_id = p.id
JOIN surveillance_records s ON s.hotel_checkin_id = h.id
WHERE h.hotel_name LIKE '%Sunset%'
AND h.check_in_date = 19860813
AND s.suspicious_activity IS NOT NULL;

-- RESULTS (notable entries):
-- Jacob Campbell  | The Joker | Sunset Bay Hotel      | 19860813 | Left suddenly at 3 AM
-- Gregory Stewart | The Ghost | Sunset Coast Inn      | 19860813 | Spotted entering late at night
-- (+ many others with routine hotel activity)

-- NOTE:
-- Jacob Campbell's activity (left suddenly at 3 AM) is the most
-- suspicious given the body was found early morning August 14.
-- We check confessions for all Sunset hotel guests to find the killer.


-- ============================================================
-- SECTION 6: Confessions — Identifying the Murderer
-- ============================================================
-- We pull confessions for all persons who checked into a Sunset
-- hotel on August 13. Most confess to unrelated crimes; one
-- directly confesses to the marina murder.
-- ============================================================

SELECT p.name, p.alias, c.confession
FROM person p
JOIN confessions c ON c.person_id = p.id
JOIN hotel_checkins h ON h.person_id = p.id
WHERE h.hotel_name LIKE '%Sunset%'
AND h.check_in_date = 19860813;

-- RESULTS (key entry):
-- name          | alias    | confession
-- Thomas Brown  | The Fox  | Alright! I did it. I was paid to make sure
--               |          | he never left the marina alive.
-- (All others confess to unrelated crimes: fraud, theft, smuggling, etc.)

-- FINDING:
-- Thomas Brown is the only suspect whose confession directly
-- references the marina killing. All other confessions relate
-- to unrelated criminal activity. The murderer is Thomas Brown.


-- ============================================================
-- MASTER QUERY — Full Investigation via CTE
-- ============================================================
-- This single CTE-based query consolidates the entire
-- investigation into one optimized statement. It:
--   1. Locates the crime scene (CTE: scene)
--   2. Finds all persons checked into Sunset hotels on Aug 13 (CTE: sunset_guests)
--   3. Filters for those with suspicious activity (CTE: suspicious_guests)
--   4. Joins confessions and filters for marina-specific confession (final SELECT)
-- ============================================================

WITH scene AS (
    -- Step 1: Identify the crime scene
    SELECT id, description
    FROM crime_scene
    WHERE location = 'Coral Bay Marina'
    AND date = 19860814
),
sunset_guests AS (
    -- Step 2: Find all persons checked into Sunset hotels night before murder
    SELECT p.id, p.name, p.alias, h.id AS checkin_id, h.hotel_name
    FROM person p
    JOIN hotel_checkins h ON h.person_id = p.id
    WHERE h.hotel_name LIKE '%Sunset%'
    AND h.check_in_date = 19860813
),
suspicious_guests AS (
    -- Step 3: Cross-reference with surveillance for suspicious activity
    SELECT sg.id, sg.name, sg.alias, s.suspicious_activity
    FROM sunset_guests sg
    JOIN surveillance_records s ON s.hotel_checkin_id = sg.checkin_id
    WHERE s.suspicious_activity IS NOT NULL
)
-- Step 4: Match confessions referencing the marina killing specifically
SELECT
    p.name          AS murderer,
    p.alias         AS known_as,
    c.confession    AS confession
FROM suspicious_guests sg
JOIN person p ON p.id = sg.id
JOIN confessions c ON c.person_id = p.id
WHERE c.confession LIKE '%marina%'
   OR c.confession LIKE '%paid%'
   OR c.confession LIKE '%never left%';

-- FINAL RESULT:
-- murderer      | known_as | confession
-- Thomas Brown  | The Fox  | "Alright! I did it. I was paid to make sure
--               |          |  he never left the marina alive."

-- ============================================================
-- CASE CLOSED
-- ============================================================
-- The murderer is THOMAS BROWN, alias "The Fox."
-- He checked into the Sunset Palm Resort on August 13, 1986 —
-- the night before the body was discovered at Coral Bay Marina.
-- His own confession confirmed he was hired to commit the murder.
-- The Miami Marina Murder of August 14, 1986 is hereby solved.
-- ============================================================
