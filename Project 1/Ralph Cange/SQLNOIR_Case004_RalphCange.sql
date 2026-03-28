-- ============================================================
-- SQLNOIR Case #004: The Midnight Masquerade Murder
-- Investigator: Ralph Cange
-- Date: 03/25/2026
-- ============================================================
-- CASE BRIEF:
-- On October 31, 1987, at a Coconut Grove mansion masked ball,
-- Leonard Pierce was found dead in the garden. Can you piece
-- together all the clues to expose the true murderer?
--
-- OBJECTIVES:
-- 1. Reveal the true murderer of this complex case.
--
-- SCHEMA:
-- crime_scene          : id, date, location, description
-- person               : id, name, occupation, address
-- witness_statements   : id, crime_scene_id (FK), witness_id (FK), clue
-- hotel_checkins       : id, person_id (FK), hotel_name, check_in_date, room_number
-- surveillance_records : id, hotel_checkin_id (FK), note
-- phone_records        : id, caller_id (FK), recipient_id (FK),
--                        call_date, call_time, note
-- vehicle_registry     : id, person_id (FK), plate_number,
--                        car_make, car_model
-- catering_orders      : id, person_id (FK), order_date, item, amount
-- final_interviews     : id, person_id (FK), confession
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: Retrieve the crime scene
-- Goal: Find the masked ball murder at Miami Mansion, Coconut Grove
-- ------------------------------------------------------------

SELECT *
FROM crime_scene
WHERE date     = 19871031
  AND location LIKE '%Coconut Grove%';

-- FINDING:
-- Date: 19871031 | Location: Miami Mansion, Coconut Grove
-- Description: During a masked ball, a body was found in the
-- garden. Witnesses mentioned a hotel booking and suspicious
-- phone activity.


-- ------------------------------------------------------------
-- STEP 2: Gather witness statements
-- Goal: Get clues from witnesses at the crime scene
-- ------------------------------------------------------------

SELECT p.name AS witness, ws.clue
FROM witness_statements ws
JOIN person p ON ws.witness_id = p.id
WHERE ws.crime_scene_id = (
    SELECT id FROM crime_scene
    WHERE date     = 19871031
      AND location LIKE '%Coconut Grove%'
);

-- FINDING:
-- Clue: "I overheard a booking at The Grand Regency."
-- Key lead: Someone booked The Grand Regency around the time
--           of the murder + suspicious phone activity flagged.


-- ------------------------------------------------------------
-- STEP 3: Check hotel bookings at The Grand Regency
-- Goal: Find who checked in and what surveillance noted
-- ------------------------------------------------------------

SELECT p.name, p.occupation, p.address,
       hc.hotel_name, hc.check_in_date, hc.room_number,
       sr.note AS surveillance_note
FROM hotel_checkins hc
JOIN person p               ON hc.person_id       = p.id
LEFT JOIN surveillance_records sr ON sr.hotel_checkin_id = hc.id
WHERE hc.hotel_name      = 'The Grand Regency'
  AND hc.check_in_date   = 19871030;

-- FINDING:
-- Multiple guests at The Grand Regency on 19871030.
-- KEY ALERT -- Antonio Rossi (Auto Importer, 999 Dark Alley):
--   Surveillance note: "Subject was overheard yelling on a
--   phone: 'Did you kill him?'"
-- This places Rossi as a co-conspirator, not the triggerman.


-- ------------------------------------------------------------
-- STEP 4: Investigate suspicious phone activity
-- Goal: Find who Rossi called and what was said
-- ------------------------------------------------------------

SELECT
    caller.name    AS caller,
    recipient.name AS recipient,
    pr.call_date,
    pr.call_time,
    pr.note        AS phone_note
FROM phone_records pr
JOIN person caller    ON pr.caller_id    = caller.id
JOIN person recipient ON pr.recipient_id = recipient.id
WHERE pr.call_date = 19871030
  AND (
      caller.name    = 'Antonio Rossi'
   OR recipient.name = 'Antonio Rossi'
  );

-- FINDING:
-- Call at 23:30 on 19871030:
-- Antonio Rossi called Victor DiMarco
-- Phone note: "Why did you kill him, bro? You should have
--              left the carpenter do it himself!"
-- Key lead: "the carpenter" -- DiMarco was hired to do the job
--           but someone else (a carpenter) was the original plan.


-- ------------------------------------------------------------
-- STEP 5: Identify Victor DiMarco and his role
-- Goal: Find DiMarco's details and what he admitted
-- ------------------------------------------------------------

SELECT p.name, p.occupation, p.address, fi.confession
FROM person p
LEFT JOIN final_interviews fi ON fi.person_id = p.id
WHERE p.name = 'Victor DiMarco';

-- FINDING:
-- Victor DiMarco | Jobless | 707 Cedarwood Avenue
-- Confession: "I didn't kill Leo per se.
--              I was just a middleman."
-- DiMarco admitted to being a middleman -- he arranged the hit.
-- He negotiated to commit it himself for a Lamborghini.


-- ------------------------------------------------------------
-- STEP 6: Find who owns the Lamborghini (the mastermind)
-- Goal: The person who paid DiMarco with a Lamborghini
--       is the one who ordered the murder
-- ------------------------------------------------------------

SELECT
    p.name,
    p.occupation,
    p.address,
    vr.car_make,
    vr.car_model,
    vr.plate_number,
    fi.confession,
    hc.hotel_name,
    hc.check_in_date     AS checkin_date,
    sr.note              AS surveillance_note,
    pr.call_date,
    pr.call_time,
    pr.note              AS phone_note
FROM vehicle_registry vr
JOIN person p ON vr.person_id = p.id
LEFT JOIN final_interviews fi      ON fi.person_id        = p.id
LEFT JOIN hotel_checkins hc        ON hc.person_id        = p.id
LEFT JOIN surveillance_records sr  ON sr.hotel_checkin_id = hc.id
LEFT JOIN phone_records pr         ON (pr.caller_id       = p.id
                                    OR pr.recipient_id    = p.id)
WHERE LOWER(vr.car_make)  LIKE '%lambo%'
   OR LOWER(vr.car_model) LIKE '%lambo%'
   OR LOWER(vr.car_make)  LIKE '%lamborghini%';

-- FINDING:
-- Marco Santos | Carpenter | 112 Forestwood Way
-- Vehicle: Lamborghini Countach | Plate: EFG901
-- Confession: "I ordered the hit. It was me. You caught me."
-- Marco Santos IS the carpenter referenced in DiMarco's phone
-- call. He owns the Lamborghini used to pay DiMarco and
-- confesses to ordering the murder of Leonard Pierce.


-- ============================================================
-- CONCLUSION
-- ============================================================
-- The murderer (mastermind) is: MARCO SANTOS
--
-- Investigation Summary:
-- 1. The crime scene at Miami Mansion, Coconut Grove on
--    October 31, 1987 flagged a hotel booking and suspicious
--    phone activity as key leads.
-- 2. Witness clue pointed to The Grand Regency hotel.
--    Surveillance caught Antonio Rossi yelling on the phone:
--    "Did you kill him?" -- placing him as a co-conspirator.
-- 3. Phone records revealed Rossi called Victor DiMarco at
--    23:30, saying DiMarco should have "left the carpenter
--    do it himself" -- revealing a third party: a carpenter.
-- 4. Victor DiMarco confessed to being a middleman who was
--    paid to arrange and carry out the murder.
-- 5. Searching the vehicle registry for a Lamborghini
--    (DiMarco's payment) identified Marco Santos -- a Carpenter
--    at 112 Forestwood Way -- who owns a Lamborghini Countach
--    (plate EFG901) and confessed: "I ordered the hit.
--    It was me. You caught me."
-- ============================================================
