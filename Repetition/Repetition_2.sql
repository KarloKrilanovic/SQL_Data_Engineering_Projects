--Database setup

CREATE DATABASE IF NOT EXISTS sandbox_db;
SHOW DATABASES;

USE sandbox_db;

CREATE SCHEMA IF NOT EXISTS testing;

SELECT *
FROM information_schema.schemata;

CREATE TABLE IF NOT EXISTS testing.raw_events (
    event_id INTEGER PRIMARY KEY,
    event_name VARCHAR(50)
);

SELECT *
FROM information_schema.tables
WHERE table_catalog = 'sandbox_db';

--Inserting data

INSERT INTO testing.raw_events (
    event_id,
    event_name
)
VALUES 
    (1, 'Exit festival'),
    (2, 'Terminal V'),
    (3, 'Music Reactions');

SELECT *
FROM testing.raw_events;

--Update to fix grammar

UPDATE testing.raw_events
SET event_name = 'EXIT Festival'
WHERE event_id = 3; --This was obviously a mistake

SELECT *
FROM testing.raw_events;

--fixing the fix

UPDATE testing.raw_events
SET event_name = 'EXIT Festival'
WHERE event_id = 1;

UPDATE testing.raw_events
SET event_name = 'Music Reactions'
WHERE event_id = 3;

SELECT *
FROM testing.raw_events;

--Alternative method

UPDATE testing.raw_events
SET event_name = CASE 
    WHEN event_id = 1 THEN 'EXIT Festival'
    WHEN event_id = 2 THEN 'Terminal V'
    WHEN event_id = 3 THEN 'Music Reactions'
    ELSE 'Unknown' -- Fallback if none of the above match
END
WHERE event_id IN (1, 2, 3); -- Only target these specific rows

SELECT *
FROM testing.raw_events;

--Adding timestamp 

ALTER TABLE testing.raw_events 
ADD COLUMN event_timestamp TEXT;

SELECT *
FROM testing.raw_events;

--Renaming and adding new columns

ALTER TABLE IF EXISTS testing.raw_events
RENAME TO processed_events;

ALTER TABLE testing.processed_events
ALTER COLUMN event_name TYPE VARCHAR(25);

ALTER TABLE testing.processed_events
ADD COLUMN IF NOT EXISTS country_code TEXT;

SELECT *
FROM testing.processed_events;

--Final tweaks

USE data_jobs;

UPDATE sandbox_db.testing.processed_events
SET country_code = 'USA'
WHERE event_id = 1;

SELECT *
FROM sandbox_db.testing.processed_events;

DROP TABLE IF EXISTS sandbox_db.testing.processed_events;

DROP SCHEMA IF EXISTS sandbox_db.testing;

DROP DATABASE IF EXISTS sandbox_db;

