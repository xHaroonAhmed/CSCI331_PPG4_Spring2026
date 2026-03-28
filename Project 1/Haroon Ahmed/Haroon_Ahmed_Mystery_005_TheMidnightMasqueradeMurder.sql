-- ============================================================
-- SQLNOIR MYSTERY #005: The Midnight Masquerade Murder
-- Student: Haroon Ahmed
-- Course: CS SQL Mysteries Assignment
-- Date: 2026-03-27
-- Tool: SQLNoir (https://www.sqlnoir.com/)
-- Database: SQLNoir built-in (crime_scene, person,
--           witness_statements, hotel_checkins,
--           surveillance_records, phone_records,
--           vehicle_registry, catering_orders, final_interviews)
-- ============================================================
-- CASE BRIEF:
-- On October 31, 1987, at a Coconut Grove mansion masked ball,
-- Leonard Pierce was found dead in the garden. This advanced
-- case requires chaining 8 tables through witness statements,
-- hotel records, phone activity, and confessions to expose
-- the true murderer behind the hit.
-- ============================================================


-- ============================================================
-- SECTION 1: Retrieve the Crime Scene Report
-- ============================================================
-- We know the murder occurred at a Coconut Grove mansion on
-- Halloween 1987. The description hints at two key leads:
-- a hotel booking and suspicious phone activity.
-- ============================================================

SELECT *
FROM crime_scene
WHERE location LIKE '%Coconut Grove%'
AND date = 19871031;

-- RESULTS:
-- id | date     | location                    | description
-- 75 | 19871031 | Miami Mansion, Coconut Grove| During a masked ball, a body
--    |          |                             | was found in the garden.
--    |          |                             | Witnesses mentioned a hotel
--    |          |                             | booking and suspicious phone
--    |          |                             | activity.

-- KEY LEADS:
-- 1. A hotel booking is connected to the crime.
-- 2. Suspicious phone activity was observed.
-- Crime scene id = 75 — used to retrieve witness statements.


-- ============================================================
-- SECTION 2: Retrieve Witness Statements
-- ============================================================
-- We JOIN person to witness_statements on witness_id,
-- filtering by crime_scene_id = 75 to surface the two
-- witnesses who provided actionable clues.
-- ============================================================

SELECT p.name, p.occupation, p.address, w.clue
FROM person p
JOIN witness_statements w ON w.witness_id = p.id
WHERE w.crime_scene_id = 75;

-- RESULTS:
-- name            | occupation        | address              | clue
-- Steven Nelson   | Doctor            | 294 Cedar Place      | I overheard a booking
--                 |                   |                      | at The Grand Regency.
-- Sharon Phillips | Marketing Manager | 849 Ashwood Court    | I noticed someone at
--                 |                   |                      | the front desk discussing
--                 |                   |                      | Room 707 for a reservation
--                 |                   |                      | made yesterday.

-- KEY CLUES EXTRACTED:
-- Hotel: The Grand Regency
-- Room: 707
-- Check-in date: October 30, 1987 (day before the murder = 19871030)


-- ============================================================
-- SECTION 3: Identify Suspects via Hotel Checkins
-- ============================================================
-- We JOIN person to hotel_checkins filtering on the hotel name,
-- room number, and check-in date derived from witness clues.
-- This surfaces everyone who booked Room 707 that night.
-- ============================================================

SELECT DISTINCT p.name, p.occupation, p.address,
       h.hotel_name, h.room_number, h.check_in_date
FROM person p
JOIN hotel_checkins h ON h.person_id = p.id
WHERE h.hotel_name LIKE '%Grand Regency%'
AND h.room_number = '707'
AND h.check_in_date = 19871030;

-- RESULTS:
-- name               | occupation        | address
-- Frances Morgan     | Financial Analyst | 909 Maplewood Street
-- Christopher Baker  | Insurance Agent   | 990 Oakwood Court
-- Susan Scott        | Psychologist      | 861 Forest Drive
-- Antonio Rossi      | Auto Importer     | 999 Dark Alley
-- Gladys Henderson   | Pharmacist        | 334 Sycamorewood Drive
-- Lois Henderson     | Painter           | 112 Juniperwood Way
-- Kathy Fisher       | Pharmacist        | 667 Sycamorewood Drive

-- NOTE:
-- Multiple suspects checked into Room 707. We now cross-reference
-- phone records for suspicious activity on the night of the murder.


-- ============================================================
-- SECTION 4: Follow the Phone Records
-- ============================================================
-- We JOIN hotel checkin suspects to phone_records on caller_id
-- to find any calls made around the time of the murder.
-- A call on the check-in date surfaces a critical lead.
-- ============================================================

SELECT DISTINCT p.id, p.name, p.occupation,
       pr.call_date, pr.call_time, pr.note
FROM person p
JOIN hotel_checkins h ON h.person_id = p.id
JOIN phone_records pr ON pr.caller_id = p.id
WHERE h.hotel_name LIKE '%Grand Regency%'
AND h.room_number = '707'
AND h.check_in_date = 19871030;

-- RESULTS:
-- id | name          | occupation   | call_date | call_time | note
-- 11 | Antonio Rossi | Auto Importer| 19871030  | 23:30     | Why did you kill him,
--    |               |              |           |           | bro? You should have
--    |               |              |           |           | left the carpenter
--    |               |              |           |           | do it himself!

-- KEY CLUE: Antonio Rossi made a call at 11:30 PM referencing
-- the killing and mentioning "the carpenter." We must identify
-- who he called to follow the chain.


-- ============================================================
-- SECTION 5: Trace the Phone Call Recipient
-- ============================================================
-- We find the recipient of Antonio Rossi's 11:30 PM call
-- by querying phone_records where caller_id = 11.
-- The recipient is directly implicated by the call content.
-- ============================================================

SELECT p.name, p.occupation, p.address,
       pr.call_date, pr.call_time, pr.note
FROM phone_records pr
JOIN person p ON p.id = pr.recipient_id
WHERE pr.caller_id = 11
AND pr.call_date = 19871030;

-- RESULTS:
-- name          | occupation | address              | call_date | call_time | note
-- Victor DiMarco| Jobless    | 707 Cedarwood Avenue | 19871030  | 23:30     | Why did you kill
--               |            |                      |           |           | him, bro? You
--               |            |                      |           |           | should have left
--               |            |                      |           |           | the carpenter
--               |            |                      |           |           | do it himself!

-- KEY FINDING: Victor DiMarco lives at 707 Cedarwood Avenue —
-- mirroring the hotel room number. He is the middleman.
-- The note references "the carpenter" as the actual killer.


-- ============================================================
-- SECTION 6: Confront Victor DiMarco
-- ============================================================
-- We pull Victor DiMarco's final interview confession to
-- confirm his role and redirect us to the true killer.
-- ============================================================

SELECT p.name, p.occupation, p.address, f.confession
FROM person p
JOIN final_interviews f ON f.person_id = p.id
WHERE p.name = 'Victor DiMarco';

-- RESULTS:
-- name          | occupation | address              | confession
-- Victor DiMarco| Jobless    | 707 Cedarwood Avenue | I didn't kill Leo per se.
--               |            |                      | I was just a middleman.

-- FINDING: Victor confirms he was a middleman, not the killer.
-- The phone note referenced "the carpenter" — we must now
-- search for a person with carpenter as their occupation.


-- ============================================================
-- SECTION 7: Identify the Carpenter — The True Murderer
-- ============================================================
-- We query final_interviews for all persons with occupation
-- 'carpenter' to find who ordered or carried out the hit.
-- Only one will confess to ordering the murder.
-- ============================================================

SELECT p.name, p.occupation, p.address, f.confession
FROM person p
JOIN final_interviews f ON f.person_id = p.id
WHERE p.occupation LIKE '%carpenter%';

-- RESULTS:
-- name          | occupation | confession
-- Frank Price   | Carpenter  | Youre making a mistake. I didnt kill that person.
-- Julie Sanders | Carpenter  | I was visiting my parents. I couldnt possibly kill someone.
-- Marco Santos  | Carpenter  | I ordered the hit. It was me. You caught me.
-- Amy Evans     | Carpenter  | Check my internet service logs. Im not the murderer.
-- Judith Fisher | Carpenter  | The bank cameras caught me making a deposit. I wouldnt take a life.

-- FINDING: Marco Santos is the only carpenter who confesses.
-- "I ordered the hit. It was me. You caught me." — case closed.


-- ============================================================
-- MASTER QUERY — Full Investigation via CTE
-- ============================================================
-- This single CTE-based query consolidates the entire
-- investigation into one optimized statement. It:
--   1. Locates the crime scene (CTE: scene)
--   2. Finds witness clues pointing to hotel and phone activity (CTE: witnesses)
--   3. Identifies hotel suspects in Room 707 (CTE: hotel_suspects)
--   4. Finds the suspect with suspicious phone activity (CTE: phone_lead)
--   5. Traces the call recipient as the middleman (CTE: middleman)
--   6. Finds all carpenters with confessions (CTE: carpenters)
--   7. Returns the carpenter who ordered the hit (final SELECT)
-- ============================================================

WITH scene AS (
    -- Step 1: Locate the crime scene
    SELECT id
    FROM crime_scene
    WHERE location LIKE '%Coconut Grove%'
    AND date = 19871031
),
hotel_suspects AS (
    -- Step 2: Find all persons who checked into Room 707
    -- at The Grand Regency the night before the murder
    SELECT DISTINCT p.id, p.name
    FROM person p
    JOIN hotel_checkins h ON h.person_id = p.id
    WHERE h.hotel_name LIKE '%Grand Regency%'
    AND h.room_number = '707'
    AND h.check_in_date = 19871030
),
phone_lead AS (
    -- Step 3: Find the hotel suspect who made a suspicious call
    SELECT DISTINCT p.id, p.name, pr.recipient_id
    FROM hotel_suspects hs
    JOIN person p ON p.id = hs.id
    JOIN phone_records pr ON pr.caller_id = p.id
    WHERE pr.note LIKE '%kill%'
),
middleman AS (
    -- Step 4: Identify the recipient of the suspicious call
    SELECT p.id, p.name
    FROM phone_lead pl
    JOIN person p ON p.id = pl.recipient_id
),
carpenters AS (
    -- Step 5: Find all persons with carpenter occupation
    -- and pull their confessions
    SELECT p.id, p.name, p.occupation, f.confession
    FROM person p
    JOIN final_interviews f ON f.person_id = p.id
    WHERE p.occupation LIKE '%carpenter%'
)
-- Step 6: Return the carpenter who confesses to ordering the hit
SELECT
    c.name          AS murderer,
    c.occupation    AS occupation,
    c.confession    AS confession
FROM carpenters c
WHERE c.confession LIKE '%ordered%'
OR c.confession LIKE '%hit%'
OR c.confession LIKE '%caught me%';

-- FINAL RESULT:
-- murderer     | occupation | confession
-- Marco Santos | Carpenter  | "I ordered the hit. It was me. You caught me."

-- ============================================================
-- CASE CLOSED
-- ============================================================
-- The murderer is MARCO SANTOS, a Carpenter.
-- The kill chain:
--   Marco Santos (ordered the hit)
--     → Victor DiMarco (middleman, 707 Cedarwood Ave)
--       → Murder carried out at the Coconut Grove masked ball
--         on October 31, 1987.
-- Antonio Rossi's late-night phone call to Victor DiMarco
-- inadvertently exposed the entire conspiracy.
-- The Midnight Masquerade Murder is hereby solved.
-- ============================================================
