CREATE DATABASE TechNova;

USE TechNova;

-- DROP TABLES if exist
DROP TABLE IF EXISTS employees, keycard_logs, calls, alibis, evidence;

-- Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    role VARCHAR(50)
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', 'Engineering', 'Software Engineer'),
(2, 'Bob Smith', 'HR', 'HR Manager'),
(3, 'Clara Lee', 'Finance', 'Accountant'),
(4, 'David Kumar', 'Engineering', 'DevOps Engineer'),
(5, 'Eva Brown', 'Marketing', 'Marketing Lead'),
(6, 'Frank Li', 'Engineering', 'QA Engineer'),
(7, 'Grace Tan', 'Finance', 'CFO'),
(8, 'Henry Wu', 'Engineering', 'CTO'),
(9, 'Isla Patel', 'Support', 'Customer Support'),
(10, 'Jack Chen', 'HR', 'Recruiter');

-- Keycard Logs Table
CREATE TABLE keycard_logs (
    log_id INT PRIMARY KEY,
    employee_id INT,
    room VARCHAR(50),
    entry_time TIMESTAMP,
    exit_time TIMESTAMP
);

INSERT INTO keycard_logs VALUES
(1, 1, 'Office', '2025-10-15 08:00', '2025-10-15 12:00'),
(2, 2, 'HR Office', '2025-10-15 08:30', '2025-10-15 17:00'),
(3, 3, 'Finance Office', '2025-10-15 08:45', '2025-10-15 12:30'),
(4, 4, 'Server Room', '2025-10-15 08:50', '2025-10-15 09:10'),
(5, 5, 'Marketing Office', '2025-10-15 09:00', '2025-10-15 17:30'),
(6, 6, 'Office', '2025-10-15 08:30', '2025-10-15 12:30'),
(7, 7, 'Finance Office', '2025-10-15 08:00', '2025-10-15 18:00'),
(8, 8, 'Server Room', '2025-10-15 08:40', '2025-10-15 09:05'),
(9, 9, 'Support Office', '2025-10-15 08:30', '2025-10-15 16:30'),
(10, 10, 'HR Office', '2025-10-15 09:00', '2025-10-15 17:00'),
(11, 4, 'CEO Office', '2025-10-15 20:50', '2025-10-15 21:00'); -- killer

-- Calls Table
CREATE TABLE calls (
    call_id INT PRIMARY KEY,
    caller_id INT,
    receiver_id INT,
    call_time TIMESTAMP,
    duration_sec INT
);

INSERT INTO calls VALUES
(1, 4, 1, '2025-10-15 20:55', 45),
(2, 5, 1, '2025-10-15 19:30', 120),
(3, 3, 7, '2025-10-15 14:00', 60),
(4, 2, 10, '2025-10-15 16:30', 30),
(5, 4, 7, '2025-10-15 20:40', 90);

-- Alibis Table
CREATE TABLE alibis (
    alibi_id INT PRIMARY KEY,
    employee_id INT,
    claimed_location VARCHAR(50),
    claim_time TIMESTAMP
);

INSERT INTO alibis VALUES
(1, 1, 'Office', '2025-10-15 20:50'),
(2, 4, 'Server Room', '2025-10-15 20:50'), -- false alibi
(3, 5, 'Marketing Office', '2025-10-15 20:50'),
(4, 6, 'Office', '2025-10-15 20:50');

-- Evidence Table
CREATE TABLE evidence (
    evidence_id INT PRIMARY KEY,
    room VARCHAR(50),
    description VARCHAR(255),
    found_time TIMESTAMP
);

INSERT INTO evidence VALUES
(1, 'CEO Office', 'Fingerprint on desk', '2025-10-15 21:05'),
(2, 'CEO Office', 'Keycard swipe logs mismatch', '2025-10-15 21:10'),
(3, 'Server Room', 'Unusual access pattern', '2025-10-15 21:15');


select * from evidence;
select * from calls;
select * from employees;
select * from keycard_logs;
select * from alibis;

-- Who entered the CEO Office around the time of the murder (20:50–21:00)?
-- (Use keycard_logs room + entry/exit times.)

SELECT *
FROM keycard_logs
WHERE room = 'CEO Office'
  AND entry_time <= '2025-10-15 21:00:00'
  AND exit_time  >= '2025-10-15 20:50:00';


-- Which employee claims they were somewhere else at 20:50, but their keycard log shows a different 
-- room at that time?
-- (Compare alibis claim_time/location vs keycard_logs.)

SELECT
  a.employee_id,
  e.name,
  a.claim_time,
  a.claimed_location,
  k.room AS actual_room
FROM alibis a
JOIN employees e
  ON e.employee_id = a.employee_id
JOIN keycard_logs k
  ON k.employee_id = a.employee_id
 AND a.claim_time BETWEEN k.entry_time AND k.exit_time
WHERE a.claimed_location <> k.room;


-- Who was inside the CEO Office closest to when the fingerprint evidence was found (21:05)?
-- (Match evidence.found_time with nearest keycard_logs for CEO Office.)

select * from evidence;
select * from keycard_logs;

SELECT
  evi.evidence_id,
  evi.found_time,
  k.employee_id,
  emp.name,
  k.entry_time,
  k.exit_time,
  LEAST(
    ABS(TIMESTAMPDIFF(SECOND, k.entry_time, evi.found_time)),
    ABS(TIMESTAMPDIFF(SECOND, k.exit_time,  evi.found_time))
  ) AS seconds_away
FROM evidence evi
JOIN keycard_logs k
  ON k.room = evi.room
JOIN employees emp
  ON emp.employee_id = k.employee_id
WHERE evi.room = 'CEO Office'
  AND evi.description = 'Fingerprint on desk'
ORDER BY seconds_away
LIMIT 1;


-- Which employee has a keycard record for the CEO Office but never listed that location in their alibi?
-- (Join keycard_logs with alibis.)

SELECT DISTINCT
  k.employee_id,
  e.name
FROM keycard_logs k
JOIN employees e
  ON e.employee_id = k.employee_id
LEFT JOIN alibis a
  ON a.employee_id = k.employee_id
 AND a.claimed_location = 'CEO Office'
WHERE k.room = 'CEO Office'
  AND a.employee_id IS NULL;


-- 1. **Who entered the CEO Office after 8:00 PM on 2025-10-15?**

SELECT k.*, e.name
FROM keycard_logs k
JOIN employees e ON e.employee_id = k.employee_id
WHERE k.room = 'CEO Office'
  AND k.entry_time >= '2025-10-15 20:00:00';

-- 2. **Which employees have an alibi recorded at exactly 20:50?**

SELECT a.*, e.name
FROM alibis a
JOIN employees e ON e.employee_id = a.employee_id
WHERE a.claim_time = '2025-10-15 20:50:00';


-- 3. **Does the person who claims “Server Room” at 20:50 have a keycard log that supports it?**

SELECT
  e.name,
  a.claimed_location,
  a.claim_time,
  k.room AS actual_room,
  k.entry_time,
  k.exit_time
FROM alibis a
JOIN employees e ON e.employee_id = a.employee_id
JOIN keycard_logs k
  ON k.employee_id = a.employee_id
 AND a.claim_time BETWEEN k.entry_time AND k.exit_time
WHERE a.claim_time = '2025-10-15 20:50:00'
  AND a.claimed_location = 'Server Room';



-- 4. **List the names of employees who have any keycard record for the CEO Office.**

SELECT DISTINCT e.employee_id, e.name
FROM keycard_logs k
JOIN employees e ON e.employee_id = k.employee_id
WHERE k.room = 'CEO Office';


-- 5. **How many calls happened between 20:40 and 21:00, and who made them?**

SELECT
  c.caller_id,
  e.name,
  COUNT(*) AS total_calls
FROM calls c
JOIN employees e ON e.employee_id = c.caller_id
WHERE c.call_time BETWEEN '2025-10-15 20:40:00' AND '2025-10-15 21:00:00'
GROUP BY c.caller_id, e.name;


-- 6. **Who made the longest call between 20:40 and 21:00?**

SELECT
  c.*,
  caller.name AS caller_name,
  receiver.name AS receiver_name
FROM calls c
JOIN employees caller ON caller.employee_id = c.caller_id
JOIN employees receiver ON receiver.employee_id = c.receiver_id
WHERE c.call_time BETWEEN '2025-10-15 20:40:00' AND '2025-10-15 21:00:00'
ORDER BY c.duration_sec DESC
LIMIT 1;

	
-- 7. **Who entered the Server Room in the morning (08:00–10:00)?**

SELECT k.*, e.name
FROM keycard_logs k
JOIN employees e ON e.employee_id = k.employee_id
WHERE k.room = 'Server Room'
  AND k.entry_time BETWEEN '2025-10-15 08:00:00' AND '2025-10-15 10:00:00';

-- 8. **Which employees were present in rooms where evidence was found (CEO Office or Server Room)?**

SELECT DISTINCT e.employee_id, e.name, k.room
FROM evidence ev
JOIN keycard_logs k ON k.room = ev.room
JOIN employees e ON e.employee_id = k.employee_id
WHERE ev.room IN ('CEO Office', 'Server Room');


-- 9. **Which employees made more than one phone call in the calls table?**

SELECT
  c.caller_id,
  e.name,
  COUNT(*) AS total_calls
FROM calls c
JOIN employees e ON e.employee_id = c.caller_id
GROUP BY c.caller_id, e.name
HAVING COUNT(*) > 1;

-- 10. **Did anyone who entered the CEO Office also make a phone call that day? If yes, who?**

SELECT DISTINCT e.employee_id, e.name
FROM employees e
JOIN keycard_logs k ON k.employee_id = e.employee_id
JOIN calls c ON c.caller_id = e.employee_id
WHERE k.room = 'CEO Office'
  AND DATE(k.entry_time) = '2025-10-15'
  AND DATE(c.call_time) = '2025-10-15';


