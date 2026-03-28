-- ============================================================
-- SQLNOIR MYSTERY #002: The Stolen Sound
-- Student: Haroon Ahmed
-- Course: CS SQL Mysteries Assignment
-- Date: 2026-03-27
-- Tool: SQLNoir (https://www.sqlnoir.com/)
-- Database: SQLNoir built-in (crime_scene, witnesses, suspects, interviews)
-- ============================================================
-- CASE BRIEF:
-- In the neon glow of 1980s Los Angeles, the West Hollywood Records
-- store was rocked by a daring theft. A prized vinyl record worth
-- over $10,000 vanished during a busy evening on July 15, 1983.
-- The store owner is desperate for answers. Our task: track down
-- the thief using witness clues and interview transcripts.
-- ============================================================


-- ============================================================
-- SECTION 1: Retrieve the Crime Scene Report
-- ============================================================
-- We know two facts going in: the date (July 15, 1983, stored
-- as integer 19830715) and the location (West Hollywood Records).
-- Filtering on both gives us the exact crime scene record and,
-- crucially, its id — which we'll need to find the witnesses.
-- ============================================================

SELECT *
FROM crime_scene
WHERE location = 'West Hollywood Records'
AND date = 19830715;

-- RESULTS:
-- id | date     | type  | location               | description
-- 65 | 19830715 | theft | West Hollywood Records | A prized vinyl record was
--    |          |       |                        | stolen from the store during
--    |          |       |                        | a busy evening.

-- KEY CLUE EXTRACTED:
-- Crime scene id = 65. We'll use this to retrieve witness records.


-- ============================================================
-- SECTION 2: Retrieve Witness Clues Linked to the Crime Scene
-- ============================================================
-- The witnesses table links to crime_scene via crime_scene_id.
-- Filtering on id = 65 surfaces all witnesses who reported
-- observations at the scene, along with their clues.
-- ============================================================

SELECT *
FROM witnesses
WHERE crime_scene_id = 65;

-- RESULTS:
-- id | crime_scene_id | clue
-- 28 | 65             | I saw a man wearing a red bandana rushing out of the store.
-- 75 | 65             | The main thing I remember is that he had a distinctive
--    |                | gold watch on his wrist.

-- KEY CLUES EXTRACTED:
-- Witness 1: Suspect wore a red bandana.
-- Witness 2: Suspect had a gold watch on his wrist.
-- These map to suspects.bandana_color and suspects.accessory.


-- ============================================================
-- SECTION 3: Identify the Suspect Using Witness Clues
-- ============================================================
-- We filter the suspects table using both physical descriptors
-- extracted from the witness clues. This narrows the pool
-- to only those matching both traits simultaneously.
-- ============================================================

SELECT *
FROM suspects
WHERE bandana_color = 'red'
AND accessory = 'gold watch';

-- RESULTS:
-- id | name          | bandana_color | accessory
-- 35 | Tony Ramirez  | red           | gold watch
-- 44 | Mickey Rivera | red           | gold watch
-- 97 | Rico Delgado  | red           | gold watch

-- NOTE:
-- Three suspects match the physical description. We cannot
-- determine the culprit from traits alone. Interview transcripts
-- are required to confirm guilt.


-- ============================================================
-- SECTION 4: Confirm the Culprit via Interview Transcript
-- ============================================================
-- We JOIN suspects to interviews on suspect_id to retrieve
-- each matching suspect's transcript. Two suspects deny
-- involvement; one provides a direct confession.
-- ============================================================

SELECT s.name, i.transcript
FROM suspects s
JOIN interviews i ON i.suspect_id = s.id
WHERE s.bandana_color = 'red'
AND s.accessory = 'gold watch';

-- RESULTS:
-- name          | transcript
-- Tony Ramirez  | I wasn't anywhere near West Hollywood Records that night.
-- Mickey Rivera | I was busy with my music career; I have nothing to do with this theft.
-- Rico Delgado  | I couldn't help it. I snapped and took the record.

-- FINDING:
-- Tony Ramirez and Mickey Rivera both denied involvement.
-- Rico Delgado's transcript is a direct confession.
-- The culprit is Rico Delgado.


-- ============================================================
-- SECTION 5: MASTER QUERY — Full Investigation via CTE
-- ============================================================
-- This single CTE-based query consolidates the entire
-- investigation into one optimized statement. It:
--   1. Locates the crime scene by date and location (CTE: scene)
--   2. Retrieves witness clues linked to that scene (CTE: clues)
--   3. Filters suspects matching both witness descriptions (CTE: matching_suspects)
--   4. Joins interview transcripts to confirm the culprit (final SELECT)
-- Only the suspect with a confessional transcript is returned.
-- ============================================================

WITH scene AS (
    -- Step 1: Identify the crime scene by known date and location
    SELECT id
    FROM crime_scene
    WHERE location = 'West Hollywood Records'
    AND date = 19830715
),
clues AS (
    -- Step 2: Pull witness clues tied to that crime scene
    SELECT clue
    FROM witnesses
    WHERE crime_scene_id = (SELECT id FROM scene)
),
matching_suspects AS (
    -- Step 3: Filter suspects matching both witness-described traits
    SELECT id, name
    FROM suspects
    WHERE bandana_color = 'red'
    AND accessory = 'gold watch'
)
-- Step 4: Join with interviews; return only the suspect with a confession
SELECT
    ms.name      AS culprit,
    i.transcript AS confession
FROM matching_suspects ms
JOIN interviews i ON i.suspect_id = ms.id
WHERE i.transcript LIKE '%took%'
   OR i.transcript LIKE '%snapped%'
   OR i.transcript LIKE '%couldn%';

-- FINAL RESULT:
-- culprit      | confession
-- Rico Delgado | "I couldn't help it. I snapped and took the record."

-- ============================================================
-- CASE CLOSED
-- ============================================================
-- The thief is RICO DELGADO.
-- He matched both witness descriptions (red bandana, gold watch)
-- and his own interview transcript confirmed his guilt.
-- The vinyl record theft at West Hollywood Records on
-- July 15, 1983 is hereby solved.
-- ============================================================
