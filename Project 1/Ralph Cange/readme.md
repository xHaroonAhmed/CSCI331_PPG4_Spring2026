# 🕵️ SQLNoir — Mystery Case Files

> *"The truth is always in the data. You just have to know how to query it."*

SQLNoir is a detective-themed SQL puzzle platform set in the gritty world of 1980s Miami. Each case challenges you to solve crimes — murders, thefts, and sabotage — using only your SQL skills. Start with the crime scene, follow the clues, and name your suspect.

---

## 🗂️ Case Files

### 🟢 Beginner

#### Case #001 · The Vanishing Briefcase · 50 XP
> *Set in the 1980s, a valuable briefcase has disappeared from the Blue Note Lounge. A witness reported a man in a trench coat was seen fleeing the scene.*

**Objectives:**
1. Retrieve the correct crime scene details to gather the key clue.
2. Identify the suspect whose profile matches the witness description.
3. Verify the suspect using their interview transcript.

**Skills practiced:** `SELECT`, `WHERE`, `JOIN`

---

#### Case #002 · The Stolen Sound · 100 XP
> *In the neon glow of 1980s Los Angeles, the West Hollywood Records store was rocked by a daring theft. A prized vinyl record, worth over $10,000, vanished on July 15, 1983.*

**Objectives:**
1. Retrieve the crime scene report using the known date and location.
2. Retrieve witness records linked to that crime scene.
3. Use witness clues to find the suspect.
4. Retrieve the suspect's interview transcript to confirm the confession.

**Skills practiced:** `JOIN`, `WHERE`, `date filtering`

---

### 🟡 Intermediate

#### Case #003 · The Miami Marina Murder · 200 XP
> *A body was found floating near the docks of Coral Bay Marina in the early hours of August 14, 1986.*

**Objectives:**
1. Find the murderer. *(Start by finding the crime scene and go from there.)*

**Skills practiced:** `JOIN`, `wildcard searches`, `logical deduction`

---

#### Case #006 · The Vanishing Diamond · 250 XP
> *At Miami's prestigious Fontainebleau Hotel charity gala, the famous "Heart of Atlantis" diamond necklace suddenly disappeared from its display.*

**Objectives:**
1. Find who stole the diamond.

**Skills practiced:** `multi-table JOINs`, `subqueries`

---

### 🔴 Advanced

#### Case #004 · The Midnight Masquerade Murder · 300 XP
> *On October 31, 1987, at a Coconut Grove mansion masked ball, Leonard Pierce was found dead in the garden.*

**Objectives:**
1. Reveal the true murderer of this complex case.

**Skills practiced:** `CTEs`, `multi-JOIN chains`, `deductive filtering`

---

#### Case #005 · The Silicon Sabotage · 1000 XP ⭐ NEW
> *QuantumTech, Miami's leading technology corporation, was about to unveil its groundbreaking microprocessor called "QuantaX." Just hours before the reveal, the prototype was destroyed and all research data was erased. Detectives suspect corporate espionage.*

**Objectives:**
1. Find who sabotaged the microprocessor.

**Skills practiced:** `advanced CTEs`, `keycard & access log analysis`, `multi-source correlation`, `subqueries`, `window functions`

---

## 🧠 How to Play

Each case follows this investigation loop:

```
1. Read the Case Brief
2. Check the Schema tab to understand available tables
3. Open the SQL Workspace and start querying
4. Follow the clues — each query result points to the next
5. Name your suspect in the Submit tab
```

### General Starting Query
```sql
-- Always start by finding the crime scene
SELECT * FROM crime_scene
WHERE date = [date] AND location LIKE '%[location]%';
```

---

## 🗃️ Common Tables

| Table | Description |
|---|---|
| `crime_scene` | Date, location, and description of each incident |
| `person` | All individuals — name, occupation, address |
| `witness_statements` | Clues provided by witnesses at crime scenes |
| `interview_transcripts` | Suspect confessions and statements |
| `suspects` | Filtered list of persons of interest |
| `hotel_checkins` | Hotel booking records |
| `phone_records` | Call logs between persons |
| `vehicle_registry` | Vehicle ownership records |
| `keycard_access_logs` | Facility access by keycard |
| `computer_access_logs` | Server and computer access records |
| `email_logs` | Internal email communications |
| `surveillance_records` | Surveillance notes tied to hotel stays |

> ⚠️ Not all tables appear in every case. Check the **Schema** tab for the exact tables available per case.

---

## 💡 Tips & Strategy

- **Start broad, narrow down.** Pull all crime scene records first, then filter.
- **Read witness clues carefully.** They often contain exact field values to filter on (e.g., hair color, car model, keycard code format).
- **Use JOINs to connect dots.** Most answers require linking 3+ tables.
- **NULL values are clues too.** Missing surveillance notes or no keycard records can indicate someone was hiding their tracks.
- **CTEs keep complex logic readable.** Build up your investigation step by step.

### Useful Query Patterns

```sql
-- Find witnesses for a crime scene
SELECT p.name, ws.clue
FROM witness_statements ws
JOIN person p ON ws.witness_id = p.id
WHERE ws.crime_scene_id = [id];

-- Cross-reference hotel + phone activity
SELECT p.name, hc.hotel_name, pr.call_time, pr.note
FROM person p
JOIN hotel_checkins hc ON hc.person_id = p.id
JOIN phone_records pr  ON pr.caller_id  = p.id
WHERE hc.date = [date];

-- Keycard access at suspicious hours
SELECT e.employee_name, k.keycard_code, k.access_time
FROM employee_records e
JOIN keycard_access_logs k ON k.employee_id = e.id
WHERE k.access_time < '06:00'
ORDER BY k.access_time;
```

---

## 🏆 XP Leaderboard

| Case | Difficulty | XP |
|---|---|---|
| The Vanishing Briefcase | Beginner | 50 |
| The Stolen Sound | Beginner | 100 |
| The Miami Marina Murder | Intermediate | 200 |
| The Vanishing Diamond | Intermediate | 250 |
| The Midnight Masquerade Murder | Advanced | 300 |
| The Silicon Sabotage | Advanced | 1000 |
| **Total Available** | | **1900 XP** |

---

## 🔗 Resources

- [SQLNoir Website](https://sqlnoir.com)
- Recommended SQL practice: `SELECT`, `WHERE`, `JOIN`, `GROUP BY`, `CTEs`, `Window Functions`
- Compatible with: PostgreSQL, MySQL, SQLite, SQL Server (T-SQL)

---

*Good luck, detective. The city doesn't sleep — and neither does the truth.*
