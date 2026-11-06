SELECT LENGTH('SQL');
SELECT CHAR_LENGTH('SQL'); --Same as length just aliased

/*
┌───────────────┐
│ length('SQL') │
│     int64     │
├───────────────┤
│             3 │
└───────────────┘
*/

SELECT LOWER('SQL');

/*
┌──────────────┐
│ lower('SQL') │
│   varchar    │
├──────────────┤
│ sql          │
└──────────────┘
*/

SELECT UPPER('sql');

/*
┌──────────────┐
│ upper('sql') │
│   varchar    │
├──────────────┤
│ SQL          │
└──────────────┘
*/

--Substring/Extraction

SELECT LEFT ('SQL', 2);

/*
┌──────────────────┐
│ "left"('SQL', 2) │
│     varchar      │
├──────────────────┤
│ SQ               │
└──────────────────┘
*/

SELECT RIGHT ('SQL', 2);

/*
┌───────────────────┐
│ "right"('SQL', 2) │
│      varchar      │
├───────────────────┤
│ QL                │
└───────────────────┘
*/

SELECT SUBSTRING ('SQL', 2, 2);

/*
┌───────────────────────────────┐
│ main."substring"('SQL', 2, 2) │
│            varchar            │
├───────────────────────────────┤
│ QL                            │
└───────────────────────────────┘
*/

--Concatenation

SELECT CONCAT('SQL', '-', 'Function');

SELECT 'SQL' || '-' || 'Functions';

--Trimming TRIM trims white space that is both on the left and right of the string. LTRIM and RTRIM removes extra space on either left or right

SELECT ' SQL ';
SELECT TRIM (' SQL ');

--Replacement: REPLACE('SQL', 'Q', '_') = 'S_L', REGEX_REPLACE('SQL', [A-Z]+'. 'sql') = 'sql'

SELECT REPLACE ('SQL', 'Q', '_');

/*
┌────────────────────────────┐
│ "replace"('SQL', 'Q', '_') │
│          varchar           │
├────────────────────────────┤
│ S_L                        │
└────────────────────────────┘
*/

/*
┌────────────────────────────────────────────────────────────┬────────────────────┬───────────────────────┐
│                         job_title                          │ job_title_category │    job_title_short    │
│                          varchar                           │      varchar       │        varchar        │
├────────────────────────────────────────────────────────────┼────────────────────┼───────────────────────┤
│ Data Engineer/Scientist (Senior)                           │ Data Engineer      │ Senior Data Scientist │
│ Data BAU Analyst                                           │ Data Analyst       │ Data Analyst          │
│ Data Analyst, IT Requirements Manager, Computer Scientist  │ Data Analyst       │ Data Analyst          │
│ Senior Data Analyst - Fintech, Retail Banking              │ Data Analyst       │ Senior Data Analyst   │
│ Data Scientist 2                                           │ Data Scientist     │ Data Scientist        │
│ IN-Senior Associate_Data Engineer_MS Engg_Advisory_Gurgaon │ Data Engineer      │ Data Engineer         │
│ Associate Data Scientist                                   │ Data Scientist     │ Data Scientist        │
│ Data Governance Analyst 2                                  │ Data Analyst       │ Data Analyst          │
│ Data-Analyst (m/w/d) in SaaS-Startup                       │ Data Analyst       │ Data Analyst          │
│ Junior Scientist                                           │ Other              │ Data Analyst          │
│ Data Analyst                                               │ Data Analyst       │ Data Analyst          │
│ Data Analyst                                               │ Data Analyst       │ Data Analyst          │
│ Data Engineer                                              │ Data Engineer      │ Data Engineer         │
│ Data Engineer - Large Scale Digital Solutions              │ Data Engineer      │ Data Engineer         │
│ data science                                               │ Other              │ Data Scientist        │
│ Cloud Data Engineer                                        │ Data Engineer      │ Data Engineer         │
│ Data Engineer, Devices and Services FinTech, DaS FinTech   │ Data Engineer      │ Data Engineer         │
│ Asset Management Marketing, Business Intelligence          │ Other              │ Business Analyst      │
│ Azure Data Engineer                                        │ Data Engineer      │ Data Engineer         │
│ Data Integration                                           │ Other              │ Data Scientist        │
└────────────────────────────────────────────────────────────┴────────────────────┴───────────────────────┘
  20 rows                                                                                       3 columns
  */

--Cleanup using text functions

WITH title_lower AS (
    SELECT
        job_title,
        LOWER(TRIM(job_title)) AS job_title_clean
    FROM job_postings_fact
)

SELECT
    job_title,
    CASE
        WHEN job_title_clean LIKE '%data%' 
         AND job_title_clean LIKE '%analyst%' THEN 'data analyst'
        WHEN job_title_clean LIKE '%data%' 
         AND job_title_clean LIKE '%engineer%' THEN 'data engineer'
        WHEN job_title_clean LIKE '%data%' 
         AND job_title_clean LIKE '%scientist%' THEN 'data scientist'
        ELSE 'Other'
    END AS job_title_category

FROM title_lower
ORDER BY RANDOM ()
LIMIT 20;

--NULL Functions NULLIF(expression1, expression2) returns null if values are equal, COALESCE(value1, value2,... , value n) returns first non-NULL value

SELECT NULLIF(10,10); --Usecase: to remove zeros from columns
SELECT NULLIF(20, 10);

SELECT COALESCE(NULL, 1, 2); 

SELECT
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg * 2080)

FROM
    job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;