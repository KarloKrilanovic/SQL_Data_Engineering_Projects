SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'job_postings_fact';

/*
┌───────────────────┬───────────────────────┬───────────┐
│    table_name     │      column_name      │ data_type │
│      varchar      │        varchar        │  varchar  │
├───────────────────┼───────────────────────┼───────────┤
│ job_postings_fact │ job_id                │ INTEGER   │
│ job_postings_fact │ company_id            │ INTEGER   │
│ job_postings_fact │ job_title_short       │ VARCHAR   │
│ job_postings_fact │ job_title             │ VARCHAR   │
│ job_postings_fact │ job_location          │ VARCHAR   │
│ job_postings_fact │ job_via               │ VARCHAR   │
│ job_postings_fact │ job_schedule_type     │ VARCHAR   │
│ job_postings_fact │ job_work_from_home    │ BOOLEAN   │
│ job_postings_fact │ search_location       │ VARCHAR   │
│ job_postings_fact │ job_posted_date       │ TIMESTAMP │
│ job_postings_fact │ job_no_degree_mention │ BOOLEAN   │
│ job_postings_fact │ job_health_insurance  │ BOOLEAN   │
│ job_postings_fact │ job_country           │ VARCHAR   │
│ job_postings_fact │ salary_rate           │ VARCHAR   │
│ job_postings_fact │ salary_year_avg       │ DOUBLE    │
│ job_postings_fact │ salary_hour_avg       │ DOUBLE    │
└───────────────────┴───────────────────────┴───────────┘
  16 rows                                     3 columns
*/

DESCRIBE job_postings_fact; --DuckDB friendly SQL

/*
┌──────────────────────────────────────────┐
│            job_postings_fact             │
│                                          │
│ job_id                integer   not null │
│ company_id            integer            │
│ job_title_short       varchar            │
│ job_title             varchar            │
│ job_location          varchar            │
│ job_via               varchar            │
│ job_schedule_type     varchar            │
│ job_work_from_home    boolean            │
│ search_location       varchar            │
│ job_posted_date       timestamp          │
│ job_no_degree_mention boolean            │
│ job_health_insurance  boolean            │
│ job_country           varchar            │
│ salary_rate           varchar            │
│ salary_year_avg       double             │
│ salary_hour_avg       double             │
└──────────────────────────────────────────┘
*/

DESCRIBE 
SELECT 
    job_title_short,
    salary_year_avg
 FROM job_postings_fact;

 /*
┌─────────────────────────┐
│    job_postings_fact    │
│                         │
│ job_title_short varchar │
│ salary_year_avg double  │
└─────────────────────────┘
*/

--you can convert in the SELECT clause using CAST

SELECT CAST('123' AS INT);

SELECT
  CAST(job_id AS VARCHAR) || '-' || CAST(company_id AS VARCHAR) AS unique_id, --"more" unique identifier using company_id to combine the two with concatenates ||
  CAST(job_work_from_home AS INTEGER) AS working_from_home,
  CAST(job_posted_date AS DATE) AS posted_date,
  CAST(salary_year_avg AS DECIMAL(7,0)) AS salary_year_avg
FROM
  job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

/*
┌───────────┬───────────────────┬─────────────┬─────────────────┐
│ unique_id │ working_from_home │ posted_date │ salary_year_avg │
│  varchar  │       int32       │    date     │  decimal(7,0)   │
├───────────┼───────────────────┼─────────────┼─────────────────┤
│ 4651-4651 │                 0 │ 2023-01-01  │          110000 │
│ 4699-4699 │                 0 │ 2023-01-01  │           65000 │
│ 4804-4804 │                 1 │ 2023-01-01  │           90000 │
│ 4810-4810 │                 0 │ 2023-01-01  │           55000 │
│ 4833-4833 │                 0 │ 2023-01-01  │          120531 │
│ 4846-4846 │                 0 │ 2023-01-01  │          300000 │
│ 5089-5089 │                 0 │ 2023-01-01  │           51000 │
│ 5123-5123 │                 0 │ 2023-01-01  │          133500 │
│ 5321-5321 │                 0 │ 2023-01-01  │           77500 │
│ 5325-5321 │                 0 │ 2023-01-01  │          125000 │
└───────────┴───────────────────┴─────────────┴─────────────────┘
  10 rows                                             4 columns
*/

SELECT (3+5.5)::FLOAT;