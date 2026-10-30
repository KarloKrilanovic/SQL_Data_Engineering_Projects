--.read Lessons/1.21/1.21_DDL_DML_1.sql

USE data_jobs; --Use a different DB before manipulating the default DB.

DROP DATABASE IF EXISTS jobs_mart;

CREATE DATABASE IF NOT EXISTS jobs_mart; --IF NOT EXISTS removes the error

SHOW DATABASES;

--DROP DATABASE IF EXISTS jobs_mart;

SELECT *

FROM information_schema.schemata;

USE jobs_mart;

CREATE SCHEMA IF NOT EXISTS staging;

--DROP SCHEMA staging;

CREATE TABLE IF NOT EXISTS staging.preffered_roles(
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
    
);

SELECT *

FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';


--DROP TABLE IF EXISTS preffered_roles;

--scripts need to be idempotent
-----------------–------------------------------–------------------------------–-------------
--INSERT, UPDATE, MERGE = INSERT + UPDATE

INSERT INTO staging.preffered_roles (role_id, role_name)

VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer');

SELECT *
FROM staging.preffered_roles;

----------------------------------------------------------------------------------------------
--ALTER TABLE table_name

--ADD COLUMN, DROP COLLUMN, RENAME COLUMN/TABLE, ALTER COLUMN
/*
--ADD COLUMN

ALTER TABLE table_name
ADD COLUMN column_name;
-----------------------
--DROP COLUMN

ALTER TABLE table_name
DROP COLUMN column_name; 
-----------------------
--RENAME COLUMN/TABLE:

ALTER TABLE table_name
RENAME COLUMN old_name TO new_name;

ALTER TABLE table_name
RENAME TABLE old_name TO new_name;
-----------------------
-- ALTER COLUMN

ALTER TABLE table_name
ALTER COLUMN column_name
    TYPE data_type
    SET DEFAULT value
    DROP DEFAULT
    SET NOT NULL
*/

SELECT *
FROM staging.priority_roles;

ALTER TABLE staging.priority_roles
ADD COLUMN priority_lvl BOOLEAN; --DROP column to remove

ALTER TABLE staging.priority_roles
DROP COLUMN preffered_role; --DROP column to remove


--To add to column: UPDATE   

UPDATE staging.priority_roles
SET priority_role = TRUE
WHERE role_id = 1 OR role_id = 2;

UPDATE staging.priority_roles
SET priority_lvl = FALSE
WHERE role_id = 3;

ALTER TABLE staging.priority_roless
RENAME TO priority_roles;

ALTER TABLE staging.priority_roles
RENAME COLUMN priority_roles TO priority_lvl;

ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;

UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;

--CTAS

CREATE OR REPLACE TABLE staging.job_postings_flat AS 
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.company_id,
    cd.name AS company_name

FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id;

SELECT
    COUNT(*)
FROM staging.job_postings_flat;

LIMIT 10;

--VIEW (virtual table, saves the query that you ran and displays the table as such when you call upon it)

CREATE OR REPLACE VIEW main.priority_jobs_flat_view AS
SELECT 
    jpflat.*
FROM 
    staging.job_postings_flat AS jpflat

INNER JOIN staging.priority_roles AS pr
    ON jpflat.job_title_short = pr.role_name

WHERE
    pr.priority_lvl = 1;


SELECT
    job_title_short,
    COUNT(*) AS job_count
FROM main.priority_jobs_flat_view

GROUP BY job_title_short
LIMIT 10;

--TEMP TABLE (disappears after logging off)

CREATE TEMPORARY TABLE senior_jobs_flat_temp AS
SELECT *

FROM main.priority_jobs_flat_view

WHERE job_title_short = 'Senior Data Engineer';


SELECT
    job_title_short,
    COUNT(*) AS job_count
FROM senior_jobs_flat_temp

GROUP BY job_title_short
LIMIT 10;

--DELETE 

SELECT COUNT(*) FROM staging.job_postings_flat;
SELECT COUNT(*) FROM main.priority_jobs_flat_view;
SELECT COUNT(*) FROM senior_jobs_flat_temp;

DELETE FROM staging.job_postings_flat
WHERE job_posted_date < '2024-01-01';

SELECT COUNT(*) FROM staging.job_postings_flat;
SELECT COUNT(*) FROM main.priority_jobs_flat_view;
SELECT COUNT(*) FROM senior_jobs_flat_temp;

--TRUNCATE (removes all rows, keeps columns)

TRUNCATE TABLE staging.job_postings_flat;

INSERT INTO staging.job_postings_flat
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.company_id,
    cd.name AS company_name

FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE job_posted_date >= '2024-01-01';

SELECT COUNT(*) FROM staging.job_postings_flat;
SELECT COUNT(*) FROM main.priority_jobs_flat_view;
SELECT COUNT(*) FROM senior_jobs_flat_temp;
