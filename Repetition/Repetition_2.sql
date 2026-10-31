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

--CTAS

CREATE DATABASE IF NOT EXISTS sandbox_db;
USE sandbox_db;
CREATE SCHEMA IF NOT EXISTS testing;
CREATE TABLE IF NOT EXISTS testing.remote_jobs_snapshot AS
SELECT
    *
FROM 
    data_jobs.main.job_postings_fact AS jpf
WHERE jpf.job_work_from_home = TRUE;

SELECT * FROM information_schema.schemata;
SELECT * FROM information_schema.tables
WHERE table_catalog = 'sandbox_db';

--VIEW

CREATE OR REPLACE VIEW testing.us_health_insurance_jobs AS

SELECT
    job_id,
    job_title_short,
    salary_year_avg

FROM
    data_jobs.main.job_postings_fact
WHERE 
    job_country = 'United States' 
    AND job_health_insurance = TRUE;

SELECT *
FROM testing.us_health_insurance_jobs;

--TEMP TABLE

SELECT *
FROM information_schema.tables
WHERE table_catalog = 'sandbox_db';

CREATE OR REPLACE TEMPORARY TABLE temp_skills_count AS
SELECT 
    sd.skills,
    COUNT (job_id)
FROM 
    data_jobs.main.skills_job_dim AS sjd
LEFT JOIN data_jobs.main.skills_dim AS sd
    ON sjd.skill_id = sd.skill_id

GROUP BY 
    sd.skills

ORDER BY
    COUNT(job_id) DESC;

SELECT *
FROM temp_skills_count;

TRUNCATE temp_skills_count;

SELECT *
FROM temp_skills_count;

--Snapshot update

TRUNCATE testing.remote_jobs_snapshot;

INSERT INTO testing.remote_jobs_snapshot 

SELECT
    *
FROM
    data_jobs.main.job_postings_fact as jpf

WHERE   
    salary_year_avg > 100_000
    AND job_work_from_home = TRUE;

SELECT *
FROM testing.remote_jobs_snapshot;

--A pipeline

CREATE OR REPLACE TEMPORARY TABLE top_companies AS
SELECT
    jpf.company_id AS company_id,
    COUNT (job_id) AS job_postings
FROM
    data_jobs.main.job_postings_fact AS jpf
GROUP BY 
    jpf.company_id
HAVING
    COUNT(job_id) > 500
ORDER BY 
    COUNT(job_id) DESC;

SELECT *
FROM top_companies;

CREATE OR REPLACE TABLE testing.top_company_details AS
SELECT
    cd.company_id,
    cd.name,
    cd.link,
    tc.job_postings AS job_postings
FROM 
    data_jobs.main.company_dim AS cd
INNER JOIN top_companies AS tc
    ON cd.company_id = tc.company_id

ORDER BY 
    job_postings DESC;

SELECT *
FROM testing.top_company_details;

CREATE OR REPLACE VIEW testing.vw_top_company_remote_jobs AS
SELECT
    *
FROM
    data_jobs.main.job_postings_fact AS jpf
INNER JOIN testing.top_company_details as tcd 
    ON jpf.company_id = tcd.company_id

WHERE 
    jpf.job_work_from_home = TRUE;


SELECT *
FROM testing.vw_top_company_remote_jobs;