-- ============================================================
-- SQLNOIR Case #006: The Vanishing Diamond
-- Investigator: Ralph Cange
-- Date: 03/27/2026
-- ============================================================
-- CASE BRIEF:
-- At Miami's prestigious Fontainebleau Hotel charity gala,
-- the famous "Heart of Atlantis" diamond necklace suddenly
-- disappeared from its display.
--
-- OBJECTIVES:
-- 1. Find who stole the diamond.
--
-- SCHEMA:
-- crime_scene       : id, date, location, description
-- guest             : id, name, occupation, invitation_code
-- witness_statements: id, guest_id (FK), clue
-- attire_registry   : id, guest_id (FK), note
-- marina_rentals    : id, dock_number, renter_guest_id (FK),
--                     rental_date, boat_name
-- final_interviews  : id, guest_id (FK), confession
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: Retrieve the crime scene at the Fontainebleau Hotel
-- Goal: Find the description and any initial clues
-- ------------------------------------------------------------

SELECT *
FROM crime_scene
WHERE location LIKE '%Fontainebleau%';

-- FINDING:
-- The famous "Heart of Atlantis" diamond necklace disappeared
-- from its display during the charity gala.


-- ------------------------------------------------------------
-- STEP 2: Gather witness statements
-- Goal: Collect clues from guests who saw something suspicious
-- ------------------------------------------------------------

SELECT g.name AS witness, ws.clue
FROM witness_statements ws
JOIN guest g ON ws.guest_id = g.id;

-- FINDING:
-- Key Clue: "I overheard someone say, 'Meet me at the marina,
--            dock 3.'"
-- Lead: The thief coordinated a marina rendezvous at dock 3
--       to make their escape with the diamond.


-- ------------------------------------------------------------
-- STEP 3: Find who rented a boat at dock 3
-- Goal: Identify the guest who had access to dock 3
--       on the night of the gala
-- ------------------------------------------------------------

SELECT g.id, g.name, g.occupation, g.invitation_code,
       m.dock_number, m.boat_name, m.rental_date
FROM guest AS g
INNER JOIN marina_rentals AS m
    ON g.id = m.renter_guest_id
WHERE m.dock_number = '3';

-- FINDING:
-- One guest rented a boat at dock 3 on the night of the gala.
-- This person had pre-arranged their escape route.


-- ------------------------------------------------------------
-- STEP 4: Confirm the thief via final interview confession
-- Goal: Use a CTE to cleanly link the dock 3 renter
--       to their confession
-- ------------------------------------------------------------

WITH C AS (
    SELECT g.id, g.name
    FROM guest AS g
    INNER JOIN marina_rentals AS m
        ON g.id = m.renter_guest_id
    WHERE m.dock_number = '3'
)
SELECT C.name, f.confession
FROM C
INNER JOIN final_interviews AS f
    ON f.guest_id = C.id;

-- FINDING:
-- The guest who rented dock 3 has a confession in
-- final_interviews confirming they stole the diamond.


-- ============================================================
-- CONCLUSION
-- ============================================================
-- The diamond thief is identified by the dock 3 marina rental
-- Which was Mike Manning
