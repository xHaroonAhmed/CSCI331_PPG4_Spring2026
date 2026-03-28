-- ============================================================
-- SQLNOIR MYSTERY #004: The Vanishing Diamond
-- Student: Haroon Ahmed
-- Course: CS SQL Mysteries Assignment
-- Date: 2026-03-27
-- Tool: SQLNoir (https://www.sqlnoir.com/)
-- Database: SQLNoir built-in (crime_scene, guest,
--           witness_statements, attire_registry,
--           marina_rentals, final_interviews)
-- ============================================================
-- CASE BRIEF:
-- At Miami's prestigious Fontainebleau Hotel charity gala,
-- the famous "Heart of Atlantis" diamond necklace suddenly
-- disappeared from its display on May 20, 1987.
-- Objective: Identify the thief using witness clues,
-- attire records, and a final confession.
-- ============================================================


-- ============================================================
-- SECTION 1: Retrieve the Crime Scene Report
-- ============================================================
-- We know the theft occurred at the Fontainebleau Hotel.
-- The crime scene description will identify which witnesses
-- provided useful clues to pursue.
-- ============================================================

SELECT *
FROM crime_scene
WHERE location LIKE '%Fontainebleau%';

-- RESULTS:
-- id | date     | location             | description
-- 48 | 19870520 | Fontainebleau Hotel  | The Heart of Atlantis necklace
--    |          |                      | disappeared. Many guests were
--    |          |                      | questioned but only two gave
--    |          |                      | valuable clues. One is a famous
--    |          |                      | actor. The other is a woman who
--    |          |                      | works as a consultant and her
--    |          |                      | first name ends with "an".

-- KEY CLUES EXTRACTED:
-- Witness 1: A famous actor (occupation LIKE '%actor%')
-- Witness 2: A female consultant whose first name ends in "an"
--            (occupation LIKE '%consultant%', name LIKE '%an %')


-- ============================================================
-- SECTION 2: Identify the Two Key Witnesses
-- ============================================================
-- We query the guest table using OR logic to find both the
-- actor witnesses and the consultant whose name ends in "an".
-- The invitation_code column will be key in a later step.
-- ============================================================

SELECT *
FROM guest
WHERE occupation LIKE '%actor%'
OR (occupation LIKE '%consultant%' AND name LIKE '%an %');

-- RESULTS:
-- id  | name           | occupation  | invitation_code
-- 43  | Ruby Baker     | Actor       | VIP-R1
-- 116 | Vivian Nair    | Consultant  | VIP-R1
-- 29  | Clint Eastwood | Actor       | VIP-G1
-- 64  | River Bowers   | Actor       | VIP-B1
-- 89  | Sage Dillon    | Actor       | VIP-G1
-- 92  | Phoenix Pitts  | Actor       | VIP-G1

-- NOTE:
-- Multiple actors returned. We need to check witness_statements
-- to find which ones actually provided valuable clues.


-- ============================================================
-- SECTION 3: Retrieve Witness Statements
-- ============================================================
-- We JOIN guest to witness_statements to find which of our
-- identified persons actually gave a clue on record.
-- Only guests with a statement will be returned.
-- ============================================================

SELECT g.name, g.occupation, w.clue
FROM guest g
JOIN witness_statements w ON w.guest_id = g.id
WHERE g.id IN (43, 116, 29, 164, 189, 192);

-- RESULTS:
-- name        | occupation  | clue
-- Vivian Nair | Consultant  | I saw someone holding an invitation
--             |             | ending with "-R". He was wearing a
--             |             | navy suit and a white tie.

-- KEY CLUES EXTRACTED:
-- 1. Suspect's invitation code ends in "-R"
-- 2. Suspect was wearing a navy suit and a white tie
-- These map to guest.invitation_code and attire_registry.note


-- ============================================================
-- SECTION 4: Cross-Reference Invitation Code & Attire Registry
-- ============================================================
-- We JOIN guest to attire_registry and filter on both clues:
-- invitation code ending in "-R" AND attire matching the
-- witness description (navy suit, white tie).
-- ============================================================

SELECT g.id, g.name, g.occupation, g.invitation_code, a.note
FROM guest g
JOIN attire_registry a ON a.guest_id = g.id
WHERE g.invitation_code LIKE '%-R'
AND a.note LIKE '%navy suit%'
AND a.note LIKE '%white tie%';

-- RESULTS:
-- id  | name         | occupation                  | invitation_code | note
-- 105 | Mike Manning | Wealth Reallocation Expert  | VIP-R           | navy suit, white tie

-- NOTE:
-- Only one guest matches both criteria. "Wealth Reallocation
-- Expert" is a suspicious occupation for a charity gala.
-- We confirm with his final interview transcript.


-- ============================================================
-- SECTION 5: Confirm the Thief via Final Interview
-- ============================================================
-- We JOIN guest to final_interviews to retrieve Mike Manning's
-- confession and formally close the case.
-- ============================================================

SELECT g.name, f.confession
FROM guest g
JOIN final_interviews f ON f.guest_id = g.id
WHERE g.id = 105;

-- RESULTS:
-- name         | confession
-- Mike Manning | I was the one who took the crystal.
--              | I guess I need a lawyer now?

-- FINDING:
-- Mike Manning directly confesses to taking the necklace.
-- His self-incriminating remark confirms guilt beyond doubt.


-- ============================================================
-- MASTER QUERY — Full Investigation via CTE
-- ============================================================
-- This single CTE-based query consolidates the entire
-- investigation into one optimized statement. It:
--   1. Locates the crime scene (CTE: scene)
--   2. Identifies witnesses matching the description (CTE: key_witnesses)
--   3. Extracts clues from witness statements (CTE: clues)
--   4. Matches suspects by invitation code and attire (CTE: suspect)
--   5. Retrieves the confession to confirm the thief (final SELECT)
-- ============================================================

WITH scene AS (
    -- Step 1: Identify the crime scene at the Fontainebleau Hotel
    SELECT id, description
    FROM crime_scene
    WHERE location LIKE '%Fontainebleau%'
),
key_witnesses AS (
    -- Step 2: Find guests matching the witness descriptions from the scene
    SELECT g.id, g.name, g.occupation
    FROM guest g
    WHERE g.occupation LIKE '%actor%'
    OR (g.occupation LIKE '%consultant%' AND g.name LIKE '%an %')
),
clues AS (
    -- Step 3: Pull witness statements only from our key witnesses
    SELECT kw.name, w.clue
    FROM key_witnesses kw
    JOIN witness_statements w ON w.guest_id = kw.id
),
suspect AS (
    -- Step 4: Match guests by invitation code ending in "-R"
    -- and attire matching the witness description
    SELECT g.id, g.name, g.occupation
    FROM guest g
    JOIN attire_registry a ON a.guest_id = g.id
    WHERE g.invitation_code LIKE '%-R'
    AND a.note LIKE '%navy suit%'
    AND a.note LIKE '%white tie%'
)
-- Step 5: Retrieve the confession to confirm the thief
SELECT
    s.name          AS thief,
    s.occupation    AS occupation,
    f.confession    AS confession
FROM suspect s
JOIN final_interviews f ON f.guest_id = s.id;

-- FINAL RESULT:
-- thief        | occupation                 | confession
-- Mike Manning | Wealth Reallocation Expert | "I was the one who took the
--              |                            |  crystal. I guess I need a
--              |                            |  lawyer now?"

-- ============================================================
-- CASE CLOSED
-- ============================================================
-- The thief is MIKE MANNING, self-styled "Wealth Reallocation Expert."
-- He was identified by his VIP-R invitation code and distinctive
-- navy suit with white tie, matching the witness description
-- provided by consultant Vivian Nair.
-- His own confession sealed the case.
-- The Heart of Atlantis diamond theft at the Fontainebleau Hotel
-- on May 20, 1987 is hereby solved.
-- ============================================================
