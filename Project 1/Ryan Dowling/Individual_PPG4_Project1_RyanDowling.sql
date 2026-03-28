--Mystery 1
--1. Retrieve the correct crime scene details to gather the key clue.
--2. Identify the suspect whose profile matches the witness description.
--3. Verify the suspect using their interview transcript

SELECT * FROM crime_scene as cs
WHERE cs.location LIKE 'Blue Note Lounge'; --gets the crime scene

SELECT * FROM suspects as s
WHERE s.attire LIKE 'trench coat'; --finds the suspects that have a trench coat

SELECT * FROM suspects as s
LEFT JOIN interviews as i on s.id = i.suspect_id --joins interview onto suspects table to match the suspects that have a trench coat on
WHERE s.attire LIKE 'trench coat'; --filters for the suspects that have a trench coat

SELECT * FROM suspects as s
LEFT JOIN interviews as i ON s.id = i.suspect_id
WHERE s.attire = 'trench coat'
AND EXISTS (
SELECT *
FROM crime_scene
WHERE location = 'Blue Note Lounge'
); --all three querys as one

--Mystery 2
--1. Retrieve the crime scene report for the record theft using the known date and location
--2. Retrieve witness records linked to that crime scene to obtain their clues
--3. Use the clues from the witnesses to find the suspect in the suspects table
--4. Retrieve the suspect's interview transcript to confirm the confession

SELECT * FROM crime_scene as cs
WHERE cs.location LIKE 'West Hollywood Records'; --gets the crime scene

SELECT * FROM crime_scene as cs
Left join witnesses as w on w.crime_scene_id = cs.id
WHERE cs.location LIKE 'West Hollywood Records'; --finds the witness reports that were made at the crime scene

SELECT * FROM suspects as s
WHERE s.bandana_color LIKE 'red' AND s.accessory LIKE 'gold watch' --finds the suspects with the accessories the witnesses saw

SELECT * FROM suspects as s
LEFT Join interviews as i on s.id = i.suspect_id --joins interview onto suspects table to see the suspects interview answers
WHERE s.bandana_color LIKE 'red' AND s.accessory LIKE 'gold watch' --filters the table to suspects who had fit the description

--Mystery 3
--1. Find the murderer. (Start by finding the crime scene and go from there)

SELECT * FROM crime_scene as cs
WHERE cs.location LIKE 'Coral Bay Marina'; --gets the crime scene and relevant details

SELECT name, address FROM person as p
WHERE p.address LIKE '%Ocean Drive' OR p.name LIKE '%ez'; --gets people who fits the case description

Select name, transcript from person as p
LEFT JOIN interviews as i on i.person_id = p.id
WHERE p.name LIKE 'Carlos Mendez' OR p.name LIKE 'Raul Gutierrez'; --Check their interview statements

Select name, hotel_name, suspicious_activity, transcript, check_in_date from person as p
LEFT JOIN hotel_checkins as h on p.id = h.person_id
LEFT JOIN surveillance_records as s on s.hotel_checkin_id = h.id
LEFT JOIN interviews as i on i.person_id = p.id
WHERE check_in_date = '19860813' AND hotel_name LIKE '%Sunset%'; --checked all statements from people who checked in to a hotel with "Sunset" in it

Select name, transcript from person as p
LEFT JOIN interviews as i on i.person_id = p.id
WHERE p.name LIKE 'Gregory Stewart' OR p.name LIKE 'Jacob Campbell'; --Checked the most reasonable suspicous people

Select name, confession from person as p --rechecked all statements and saw he never made a statement
LEFT JOIN confessions as i on i.person_id = p.id
WHERE p.name LIKE 'Thomas Brown'; --it was Thomas Brown

--Mystery 6
--1. Find who stole the diamond

SELECT * FROM crime_scene as cs
WHERE cs.location LIKE 'Fontainebleau Hotel'; --get the crime scene

SELECT name, occupation, clue from guest as g
LEFT JOIN witness_statements as w on w.guest_id = g.id
WHERE g.occupation LIKE 'actor' OR g.occupation LIKE 'consultant'; --search for the witnesses described by the crime scene report

SELECT name, dock_number, note, invitation_code from guest as g
LEFT JOIN marina_rentals as m on g.id = m.renter_guest_id --joins to get all needed information into guest table
LEFT JOIN attire_registry as a on a.guest_id = g.id --joins to get all needed information into guest table
Where dock_number = 3 AND invitation_code LIKE '%r' AND note LIKE 'navy suit, white tie'; --searches for attire and dock number given by the witnesses

SELECT name, confession, dock_number, note, invitation_code from guest as g
LEFT JOIN marina_rentals as m on g.id = m.renter_guest_id
LEFT JOIN attire_registry as a on a.guest_id = g.id
LEFT JOIN final_interviews as f on f.guest_id = g.id
Where dock_number = 3 AND invitation_code LIKE '%r' AND note LIKE 'navy suit, white tie'; --Only one person showed up so I joined the final_interviews
                                                                                          --table so I could see if it was them (it was)

--Mystery 4
--1. Reveal the true murderer of this complex case
SELECT * FROM crime_scene as cs
WHERE cs.location LIKE 'Miami Mansion, Coconut Grove'; --get the crime scene report

SELECT name, caller_id, recipient_id, call_date, call_time, note  from person as p
LEFT JOIN phone_records as ph on ph.caller_id = p.id
WHERE call_time IS NOT NULL --checking for sny suspicious phone calls

Select * FROM person as p
WHERE p.id = 58; --searched for the recipient from the suspicious call saying "Why did you kill him (...)"

select name, confession FROM person as p
LEFT JOIN final_interviews as f on f.person_id = p.id
WHERE p.id = 58; --turns out he was not the killer

SELECT name, occupation, clue from person as p
Left JOIN witness_statements as w on w.witness_id = p.id
WHERE occupation = 'Carpenter'; --I checked the carpenters as they were mentioned in the suspicious phone call as well

SELECT name, confession from person as p
Left JOIN final_interviews as f on f.person_id = p.id
WHERE occupation = 'Carpenter'; --4 of them didn't make statements so I got the confessions from the carpenters and it was the one named Marco Santos

--Mystery 5
--Find who sabotaged the microprocessor
SELECT * FROM incident_reports as i
WHERE i.location = 'QuantumTech HQ'; --get the incident report details

Select employee_name, department, statement, incident_id from employee_records as e
LEFT JOIN witness_statements as w on w.employee_id = e.id
WHERE incident_id = 74; -- gets witness statements from the scene of the incident

Select employee_name, department, keycard_code, server_location from employee_records as e
LEFT JOIN keycard_access_logs as k on k.employee_id = e.id
LEFT JOIN computer_access_logs as c on c.employee_id = e.id
WHERE keycard_code LIKE 'QX-0%' AND server_location = 'Helsinki'; --searched who accessed computer from helsinki who also fit the keycard code description