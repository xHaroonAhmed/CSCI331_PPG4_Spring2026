-- ============================================================
-- SQLNOIR MYSTERY #001: The Vanishing Briefcase
-- Student: Haroon Ahmed
-- Course: CS SQL Mysteries Assignment
-- Date: 2026-03-27
-- Tool: SQLNoir (https://www.sqlnoir.com/)
-- Database: SQLNoir built-in (crime_scene, suspects, interviews)
-- ============================================================
-- CASE BRIEF:
-- Set in the gritty 1980s, a valuable briefcase containing
-- sensitive documents has disappeared from the Blue Note Lounge.
-- A witness reported a man in a trench coat fleeing the scene.
-- Objective: Investigate the crime scene, review suspects,
-- and examine interview transcripts to identify the culprit.
-- ============================================================


-- ============================================================
-- SECTION 1: Retrieve Crime Scene Details
-- ============================================================
-- We begin the investigation by pulling the crime scene record
-- for the Blue Note Lounge. This gives us the foundational
-- clue: the date, type of crime, and the witness description
-- of the perpetrator.
-- ============================================================

SELECT *
FROM crime_scene
WHERE location = 'Blue Note Lounge';

-- RESULTS:
-- id   | date     | type  | location         | description
-- 76   | 19851120 | theft | Blue Note Lounge | A briefcase containing
--      |          |       |                  | sensitive documents vanished.
--      |          |       |                  | A witness reported a man in a
--      |          |       |                  | trench coat with a scar on his
--      |          |       |                  | left cheek fleeing the scene.

-- KEY CLUE EXTRACTED:
-- The suspect was wearing a trench coat and had a scar on his left cheek.


-- ============================================================
-- SECTION 2: Identify the Suspect by Physical Description
-- ============================================================
-- Using the witness description from Section 1, we filter the
-- suspects table on both physical identifiers: attire = 'trench coat'
-- and scar = 'left cheek'. This narrows the suspect pool.
-- ============================================================

SELECT *
FROM suspects
WHERE attire = 'trench coat'
AND scar = 'left cheek';

-- RESULTS:
-- id  | name              | attire      | scar
-- 3   | Frankie Lombardi  | trench coat | left cheek
-- 183 | Vincent Malone    | trench coat | left cheek

-- NOTE:
-- Two suspects match the physical description. We cannot
-- conclusively identify the culprit from physical traits alone.
-- We must cross-reference interview transcripts.


-- ============================================================
-- SECTION 3: Verify the Suspect via Interview Transcript
-- ============================================================
-- We JOIN the suspects and interviews tables on suspect_id
-- to retrieve the transcript for each matching suspect.
-- A NULL transcript indicates no statement was given;
-- a self-incriminating statement confirms the culprit.
-- ============================================================

SELECT s.name, i.transcript
FROM suspects s
JOIN interviews i ON i.suspect_id = s.id
WHERE s.attire = 'trench coat'
AND s.scar = 'left cheek';

-- RESULTS:
-- name              | transcript
-- Frankie Lombardi  | NULL
-- Vincent Malone    | "I wasn't going to steal it, but I did."

-- FINDING:
-- Frankie Lombardi has no transcript on record.
-- Vincent Malone's transcript is a direct confession.
-- The culprit is Vincent Malone.


-- ============================================================
-- SECTION 4: MASTER QUERY — Full Investigation via CTE
-- ============================================================
-- This single CTE-based query consolidates the entire
-- investigation into one optimized statement. It:
--   1. Extracts the crime scene clue (CTE: scene)
--   2. Filters suspects matching the witness description (CTE: matching_suspects)
--   3. Joins interview transcripts to confirm the culprit (final SELECT)
-- The result surfaces only the confirmed perpetrator.
-- ============================================================

WITH scene AS (
    -- Step 1: Pull the crime scene record for the Blue Note Lounge
    SELECT description
    FROM crime_scene
    WHERE location = 'Blue Note Lounge'
),
matching_suspects AS (
    -- Step 2: Filter suspects matching witness-described physical traits
    SELECT id, name
    FROM suspects
    WHERE attire = 'trench coat'
    AND scar = 'left cheek'
)
-- Step 3: Join with interviews; return only the suspect with a confession
SELECT
    ms.name          AS culprit,
    i.transcript     AS confession
FROM matching_suspects ms
JOIN interviews i ON i.suspect_id = ms.id
WHERE i.transcript IS NOT NULL;

-- FINAL RESULT:
-- culprit         | confession
-- Vincent Malone  | "I wasn't going to steal it, but I did."

-- ============================================================
-- CASE CLOSED
-- ============================================================
-- The thief is VINCENT MALONE.
-- He matched the witness description (trench coat, left cheek scar)
-- and his own interview transcript confirmed his guilt.
-- The briefcase theft at the Blue Note Lounge on November 20, 1985
-- is hereby solved.
-- ============================================================
