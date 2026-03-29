-- ============================================================
-- SQLNOIR Case #003: The Miami Marina Murder
-- Investigator: Ralph Cange
-- Date: 03/24/2026
-- ============================================================
-- CASE BRIEF:
-- A body was found floating near the docks of Coral Bay Marina
-- in the early hours of August 14, 1986. Your job, detective,
-- is to find the murderer and bring them to justice. This case
-- requires the use of JOINs, wildcard searches, and logical
-- deduction.
--
-- OBJECTIVES:
-- 1. Find the murderer. (Start by finding the crime scene
--    and go from there.)
--
-- SCHEMA:
-- crime_scene         : id, date, location, description
-- person              : id, name, alias, occupation, address
-- hotel_checkins      : id, person_id (FK), hotel_name, check_in_date
-- surveillance_records: id, person_id (FK), hotel_checkin_id (FK),
--                       suspicious_activity
-- interviews          : id, person_id (FK), transcript
-- confessions         : id, person_id (FK), confession
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: Retrieve the crime scene at Coral Bay Marina
-- ------------------------------------------------------------

SELECT *
FROM crime_scene
WHERE date     = 19860814
  AND location LIKE '%Marina%';

-- FINDING:
-- Crime Scene Report: The body of an unidentified man was found
-- near the docks. Two people were seen nearby:
--   Clue #1: One who lives on 300ish "Ocean Drive"
--   Clue #2: Another whose first name ends with "ul" and
--            last name ends with "ez"


-- ------------------------------------------------------------
-- STEP 2: Find the two persons of interest from the clues
-- ------------------------------------------------------------

-- Clue #1: Person living on 300-range Ocean Drive
SELECT *
FROM person
WHERE address LIKE '3__ Ocean Drive';

-- FINDING:
-- Carlos Mendez -- 369 Ocean Drive

-- Clue #2: First name ends with 'ul', last name ends with 'ez'
SELECT *
FROM person
WHERE name LIKE '%ul %ez';

-- FINDING:
-- (Returns second witness near the crime scene)


-- ------------------------------------------------------------
-- STEP 3: Get Carlos Mendez's interview transcript
-- ------------------------------------------------------------

SELECT p.name, p.address, i.transcript
FROM person AS p
INNER JOIN interviews AS i
    ON i.person_id = p.id
WHERE p.address LIKE '3__ Ocean Drive';

-- FINDING:
-- Carlos Mendez: "I saw someone check into a hotel on August 13.
--                The guy looked nervous."
-- Key lead: Suspicious hotel check-in on August 13, 1986


-- ------------------------------------------------------------
-- STEP 4: Find who checked into a hotel on August 13, 1986
-- ------------------------------------------------------------

SELECT p.name, h.hotel_name, p.alias, s.suspicious_activity
FROM hotel_checkins AS h
INNER JOIN surveillance_records AS s
    ON h.person_id = s.person_id
INNER JOIN person AS p
    ON p.id = h.person_id
WHERE h.check_in_date = '19860813';

-- FINDING:
-- Robert Smith | Sunset Marina Hotel | Alias: Red Rob
-- Suspicious Activity: Seen arguing with an unknown person


-- ------------------------------------------------------------
-- STEP 5: Confirm the murderer via confession
-- ------------------------------------------------------------

SELECT O.name, c.confession
FROM (
    SELECT p.name, h.hotel_name, p.alias, s.suspicious_activity, p.id
    FROM hotel_checkins AS h
    INNER JOIN surveillance_records AS s
        ON h.person_id = s.person_id
    INNER JOIN person AS p
        ON p.id = h.person_id
    WHERE h.check_in_date = '19860813'
) AS O
INNER JOIN confessions AS c
    ON O.id = c.person_id
ORDER BY name;

-- FINDING:
-- Robert Smith's confession: "he walking his dog last night"
-- Robert Smith (alias: Red Rob) was seen arguing with an
-- unknown person at the Sunset Marina Hotel the night before
-- the murder and his confession places him at the scene.


-- ============================================================
-- CONCLUSION
-- ============================================================
-- The murderer is: ROBERT SMITH (alias: Red Rob)
