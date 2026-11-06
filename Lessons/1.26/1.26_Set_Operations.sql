SELECT UNNEST([1, 1, 1, 2])--list conainting 1 and 2, UNNEST makes the columns into rows;
UNION
SELECT UNNEST([1, 1, 3]);
/*
┌─────────────────────────────────────┐
│ unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   3 │
│                                   2 │
│                                   1 │
└─────────────────────────────────────┘
*/

SELECT UNNEST([1, 1, 1, 2])
UNION ALL
SELECT UNNEST([1, 1, 3]);

/*
┌─────────────────────────────────────┐
│ unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   1 │
│                                   1 │
│                                   1 │
│                                   2 │
│                                   1 │
│                                   1 │
│                                   3 │
└─────────────────────────────────────┘
*/

SELECT UNNEST([1, 1, 1, 2])
INTERSECT
SELECT UNNEST([1, 1, 3]);

/*
┌─────────────────────────────────────┐
│ unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   1 │
└─────────────────────────────────────┘
*/

SELECT UNNEST([1, 1, 1, 2])
INTERSECT ALL
SELECT UNNEST([1, 1, 3]);

/*
┌─────────────────────────────────────┐
│ unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   1 │
│                                   1 │
└─────────────────────────────────────┘
*/

--EXCEPT returns rows in A but not in B. Duplicates removed
--EXCEPT ALL returns rows in A minus rows in B. Duplicates removed one-by-one

SELECT UNNEST([1, 1, 1, 2])
EXCEPT
SELECT UNNEST([1, 1, 3]);

/*
┌─────────────────────────────────────┐
│ unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   2 │
└─────────────────────────────────────┘
*/


SELECT UNNEST([1, 1, 1, 2])
EXCEPT ALL
SELECT UNNEST([1, 1, 3]);

/*
┌─────────────────────────────────────┐
│ unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   2 │
│                                   1 │
└─────────────────────────────────────┘
*/

CREATE TEMP TABLE jobs_2023 AS 
SELECT * EXCLUDE (job_id, job_posted_date) -- EXCLUDE doesn't necessarily work in other databases
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;

CREATE TEMP TABLE jobs_2024 AS 
SELECT * EXCLUDE (job_id, job_posted_date) 
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2024;

--which unique postings appeared in 2023 or 2024?

SELECT 
    'jobs_2023' AS table_name,
    COUNT(*) AS Record_count
FROM jobs_2023
UNION
SELECT 
    'jobs_2024' AS table_name,
    COUNT(*) 
FROM jobs_2024;


SELECT * FROM jobs_2023
UNION
SELECT * FROM jobs_2024;

--which were in 2023 but not in 2024?

SELECT * FROM jobs_2023
EXCEPT
SELECT * FROM jobs_2024;

--which job postings from 2023 remain after subtracting matching 2024 postings, one-for-one?

SELECT * FROM jobs_2023
EXCEPT ALL
SELECT * FROM jobs_2024;

--which appear in both 2023 and 2024?

                      