-- ============================================================
-- SQLNOIR Case #001: The Vanishing Briefcase
-- Investigator: Ralph Cange
-- Date: 3/23/2026
-- ============================================================
-- CASE BRIEF:
-- Set in the gritty 1980s, a valuable briefcase has disappeared
-- from the Blue Note Lounge. A witness reported that a man in a
-- trench coat was seen fleeing the scene. Investigate the crime
-- scene, review the list of suspects, and examine interview
-- transcripts to reveal the culprit.
--
-- OBJECTIVES:
-- 1. Retrieve the correct crime scene details to gather the key clue.
-- 2. Identify the suspect whose profile matches the witness description.
-- 3. Verify the suspect using their interview transcript.
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: Retrieve the crime scene at the Blue Note Lounge
-- Goal: Find the witness clue that describes the suspect
-- ------------------------------------------------------------

SELECT *
FROM crime_scene
WHERE location = 'Blue Note Lounge';

-- FINDING:
-- Witness: Emma Hall
-- Clue: The suspect was a man with a scar on his left cheek
--       and was wearing a trench coat.


-- ------------------------------------------------------------
-- STEP 2: Find suspects matching the witness description
-- Goal: Filter suspects by scar = 'left cheek' AND attire = 'trench coat'
-- ------------------------------------------------------------

SELECT sus.name, sus.scar, sus.attire, int.transcript
FROM suspects AS sus
    INNER JOIN interviews AS int
    ON int.suspect_id = sus.id
WHERE sus.scar = 'left cheek'
  AND sus.attire = 'trench coat';

-- FINDING:
-- Two suspects matched the physical description:
--   1. Frankie Lombardi  -- no interview transcript on file
--   2. Vincent Malone    -- has an interview transcript


-- ------------------------------------------------------------
-- STEP 3: Verify suspect using interview transcript
-- Goal: Confirm which suspect admits to the theft
-- ------------------------------------------------------------

SELECT sus.name, sus.scar, sus.attire, int.transcript
FROM suspects AS sus
    INNER JOIN interviews AS int
    ON int.suspect_id = sus.id
WHERE sus.scar    = 'left cheek'
  AND sus.attire  = 'trench coat'
  AND int.transcript IS NOT NULL;

-- FINDING:
-- Vincent Malone's transcript confirms he admits to stealing
-- the briefcase from the Blue Note Lounge.
-- Frankie Lombardi had no interview transcript and could not
-- be confirmed.


-- ============================================================
-- CONCLUSION
-- ============================================================
-- The culprit is: VINCENT MALONE
--
-- Investigation Summary:
-- 1. Crime scene at the Blue Note Lounge revealed a witness
--    named Emma Hall who described a man with a scar on his
--    left cheek wearing a trench coat.
-- 2. Querying the suspects table with those filters returned
--    two matches: Frankie Lombardi and Vincent Malone.
-- 3. Only Vincent Malone had an interview transcript, in which
--    he admits to stealing the briefcase.
-- ============================================================
