-- ============================================================
-- SQLNOIR Case #002: The Stolen Sound
-- Investigator: Ralph Cange
-- Date: 3/23/2026
-- ============================================================
-- CASE BRIEF:
-- In the neon glow of 1980s Los Angeles, the West Hollywood
-- Records store was rocked by a daring theft. A prized vinyl
-- record, worth over $10,000, vanished during a busy evening,
-- leaving the store owner desperate for answers. The incident
-- occurred on July 15, 1983, at this famous store.
-- Your task is to track down the thief and bring them to justice.
--
-- OBJECTIVES:
-- 1. Retrieve the crime scene report using the known date and location.
-- 2. Retrieve witness records linked to that crime scene.
-- 3. Use the clues from witnesses to find the suspect.
-- 4. Retrieve the suspect's interview transcript to confirm the confession.
--
-- SCHEMA:
-- crime_scene  : id, date, type, location, description
-- witnesses    : id, crime_scene_id (FK), clue
-- suspects     : id, name, bandana_color, accessory
-- interviews   : suspect_id (FK), transcript
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: Retrieve the crime scene report
-- Goal: Find the theft at West Hollywood Records on July 15, 1983
-- ------------------------------------------------------------

SELECT *
FROM crime_scene
WHERE date     = 19830715
  AND location = 'West Hollywood Records';

-- FINDING:
-- Crime Scene Report: A prized vinyl record was stolen from
-- the store during a busy evening.


-- ------------------------------------------------------------
-- STEP 2: Retrieve witness clues linked to the crime scene
-- Goal: Get the physical descriptions of the suspect
-- ------------------------------------------------------------

SELECT w.clue
FROM witnesses AS w
WHERE w.crime_scene_id = (
    SELECT id
    FROM crime_scene
    WHERE date     = 19830715
      AND location = 'West Hollywood Records'
);

-- FINDING:
-- Clue #1: A man wearing a red bandana was seen rushing out
--          of the store.
-- Clue #2: He had a distinctive gold watch on his wrist.


-- ------------------------------------------------------------
-- STEP 3: Find the suspect matching the witness description
-- Goal: Filter suspects by bandana_color = 'red'
--       AND accessory = 'gold watch', then join their transcript
-- ------------------------------------------------------------

SELECT sus.name, i.transcript
FROM suspects AS sus
INNER JOIN interviews AS i
    ON i.suspect_id = sus.id
WHERE sus.bandana_color = 'red'
  AND sus.accessory     = 'gold watch';

-- FINDING:
-- Three suspects matched and returned transcripts:
--
-- Tony Ramirez  -- "I wasn't anywhere near West Hollywood
--                  Records that night."
--
-- Mickey Rivera -- "I was busy with my music career;
--                  I have nothing to do with this theft."
--
-- Rico Delgado  -- "I couldn't help it. I snapped and
--                  took the record."


-- ------------------------------------------------------------
-- STEP 4: Verify the confessor
-- Goal: Isolate the suspect whose transcript contains a confession
-- ------------------------------------------------------------

SELECT sus.name, i.transcript
FROM suspects AS sus
INNER JOIN interviews AS i
    ON i.suspect_id = sus.id
WHERE sus.bandana_color = 'red'
  AND sus.accessory     = 'gold watch'
  AND i.transcript LIKE '%took the record%';

-- FINDING:
-- Rico Delgado is the only suspect who admits to stealing
-- the vinyl record in his interview transcript.


-- ============================================================
-- CONCLUSION
-- ============================================================
-- The culprit is: RICO DELGADO
--
-- Investigation Summary:
-- 1. The crime scene report confirmed a vinyl record theft at
--    West Hollywood Records on July 15, 1983.
-- 2. Two witness clues described a man with a red bandana and
--    a gold watch on his wrist.
-- 3. Filtering suspects by those traits returned three matches:
--    Tony Ramirez, Mickey Rivera, and Rico Delgado.
-- 4. Tony Ramirez and Mickey Rivera denied involvement.
--    Rico Delgado's transcript contained a clear confession:
--    "I couldn't help it. I snapped and took the record."
-- ============================================================
