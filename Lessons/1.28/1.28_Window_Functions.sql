/*
SELECT
    column_1,
    window_function () OVER (
        PARTITION BY <...>
        ORDER BY <...>
    ) AS window_column_alias
FROM
    table_name
*/
--Aggregate, row & rank and navigation functions

--PARTITION BY
SELECT  
    job_id,
    job_title_short,
    company_id,
    salary_hour_avg::INTEGER AS average_hour_salary,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short, company_id
    )::INTEGER AS grouped_average_hour_salary

FROM 
    job_postings_fact

WHERE  
    salary_hour_avg IS NOT NULL

ORDER BY
    RANDOM ()

LIMIT 10;

/*
┌─────────┬───────────────────────┬────────────┬─────────────────────┬─────────────────────────────┐
│ job_id  │    job_title_short    │ company_id │ average_hour_salary │ grouped_average_hour_salary │
│  int32  │        varchar        │   int32    │        int32        │            int32            │
├─────────┼───────────────────────┼────────────┼─────────────────────┼─────────────────────────────┤
│  933253 │ Senior Data Engineer  │     289760 │                  72 │                          69 │
│   12633 │ Data Analyst          │      12633 │                  24 │                          24 │
│  976988 │ Data Engineer         │     138060 │                  72 │                          55 │
│ 1227943 │ Data Engineer         │       4805 │                  48 │                          63 │
│ 1001455 │ Senior Data Engineer  │       5321 │                  72 │                          56 │
│  568447 │ Senior Data Scientist │     236751 │                  48 │                          48 │
│ 1535043 │ Data Analyst          │    1427694 │                  30 │                          30 │
│  965512 │ Data Engineer         │       4988 │                  82 │                          69 │
│  646031 │ Data Engineer         │      12559 │                  75 │                          81 │
│  257810 │ Data Scientist        │     157690 │                  70 │                          70 │
└─────────┴───────────────────────┴────────────┴─────────────────────┴─────────────────────────────┘
  10 rows                                                                                5 columns
  */

  --ORDER BY

SELECT  
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS rank

FROM 
    job_postings_fact

WHERE  
    salary_hour_avg IS NOT NULL

ORDER BY
    salary_hour_avg DESC

LIMIT 10;

/*
┌─────────┬───────────────────────────┬─────────────────┬───────┐
│ job_id  │      job_title_short      │ salary_hour_avg │ rank  │
│  int32  │          varchar          │     double      │ int64 │
├─────────┼───────────────────────────┼─────────────────┼───────┤
│  256566 │ Data Analyst              │           391.0 │     1 │
│ 1004296 │ Data Scientist            │           250.0 │     2 │
│  110897 │ Data Analyst              │           242.5 │     3 │
│  646328 │ Data Scientist            │           237.5 │     4 │
│  210821 │ Data Scientist            │           225.0 │     5 │
│ 1203880 │ Data Engineer             │           221.0 │     6 │
│ 1056728 │ Machine Learning Engineer │           220.0 │     7 │
│  193693 │ Data Analyst              │           210.0 │     8 │
│  452720 │ Data Analyst              │           200.0 │     9 │
│ 1113990 │ Data Scientist            │           200.0 │     9 │
└─────────┴───────────────────────────┴─────────────────┴───────┘
  10 rows                                             4 columns
*/

--PARTITION AND ORDER BY

SELECT  
    job_title_short,
    salary_hour_avg,
    job_posted_date,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    ) AS running_avg_hourly_by_title

FROM 
    job_postings_fact

WHERE  
    salary_hour_avg IS NOT NULL

ORDER BY
    job_posted_date,
    job_title_short

LIMIT 10;

/*
┌─────────────────┬─────────────────┬─────────────────────┬─────────────────────────────┐
│ job_title_short │ salary_hour_avg │   job_posted_date   │ running_avg_hourly_by_title │
│     varchar     │     double      │      timestamp      │           double            │
├─────────────────┼─────────────────┼─────────────────────┼─────────────────────────────┤
│ Data Analyst    │            20.0 │ 2023-01-01 00:01:11 │                        20.0 │
│ Data Scientist  │            20.0 │ 2023-01-01 00:18:21 │                        20.0 │
│ Data Analyst    │            15.0 │ 2023-01-01 09:17:03 │                        17.5 │
│ Data Analyst    │           35.75 │ 2023-01-01 13:01:39 │          23.583333333333332 │
│ Data Analyst    │            36.0 │ 2023-01-01 23:01:14 │                     26.6875 │
│ Data Analyst    │            55.0 │ 2023-01-01 23:04:27 │                       32.35 │
│ Data Engineer   │            64.5 │ 2023-01-01 23:06:55 │                        64.5 │
│ Data Scientist  │            20.0 │ 2023-01-01 23:38:31 │                        20.0 │
│ Data Scientist  │            20.0 │ 2023-01-02 05:12:30 │                        20.0 │
│ Data Engineer   │            25.5 │ 2023-01-02 13:08:25 │                        45.0 │
└─────────────────┴─────────────────┴─────────────────────┴─────────────────────────────┘
  10 rows                                                                     4 columns
*/

SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK () OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) AS rank_hr_salary

FROM 
    job_postings_fact
WHERE   
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC,
    job_title_short
LIMIT 10;

/*
┌─────────┬───────────────────────────┬─────────────────┬────────────────┐
│ job_id  │      job_title_short      │ salary_hour_avg │ rank_hr_salary │
│  int32  │          varchar          │     double      │     int64      │
├─────────┼───────────────────────────┼─────────────────┼────────────────┤
│  256566 │ Data Analyst              │           391.0 │              1 │
│ 1004296 │ Data Scientist            │           250.0 │              1 │
│  110897 │ Data Analyst              │           242.5 │              2 │
│  646328 │ Data Scientist            │           237.5 │              2 │
│  210821 │ Data Scientist            │           225.0 │              3 │
│ 1203880 │ Data Engineer             │           221.0 │              1 │
│ 1056728 │ Machine Learning Engineer │           220.0 │              1 │
│  193693 │ Data Analyst              │           210.0 │              3 │
│  452720 │ Data Analyst              │           200.0 │              4 │
│  879148 │ Data Scientist            │           200.0 │              4 │
└─────────┴───────────────────────────┴─────────────────┴────────────────┘
  10 rows                                                      4 columns
*/

SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK () OVER (
        ORDER BY salary_hour_avg DESC
    ) AS rank_hr_salary

FROM 
    job_postings_fact
WHERE   
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC
LIMIT 140;

/*
│  887380 │ Senior Data Scientist     │           200.0 │              9 │
│  835678 │ Senior Data Scientist     │           200.0 │              9 │
│  833111 │ Data Scientist            │           200.0 │              9 │
│  835746 │ Data Scientist            │           200.0 │              9 │
│  861089 │ Senior Data Scientist     │           200.0 │              9 │
│  887642 │ Senior Data Scientist     │           200.0 │              9 │
│  839331 │ Senior Data Scientist     │           200.0 │              9 │
│ 1240360 │ Data Engineer             │           195.0 │            139 │
│  307062 │ Data Scientist            │           187.5 │            140 │
└─────────┴───────────────────────────┴─────────────────┴────────────────┘
  140 rows (40 shown)     use .last to show entire result      4 columns
*/

SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    DENSE_RANK () OVER (
        ORDER BY salary_hour_avg DESC
    ) AS rank_hr_salary

FROM 
    job_postings_fact
WHERE   
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC
LIMIT 140;

/*
│  865847 │ Data Scientist            │           200.0 │              9 │
│  852238 │ Data Scientist            │           200.0 │              9 │
│  873933 │ Senior Data Scientist     │           200.0 │              9 │
│  878939 │ Senior Data Scientist     │           200.0 │              9 │
│  873956 │ Senior Data Scientist     │           200.0 │              9 │
│  848264 │ Data Scientist            │           200.0 │              9 │
│ 1240360 │ Data Engineer             │           195.0 │             10 │ -- promjena
│  307062 │ Data Scientist            │           187.5 │             11 │
└─────────┴───────────────────────────┴─────────────────┴────────────────┘
  140 rows (40 shown)     use .last to show entire result      4 columns
*/

--ROW NUMBER() - PROVIDING A NEW JOB_ID

SELECT *, ROW_NUMBER () OVER ()
FROM job_postings_fact
ORDER BY job_posted_date
LIMIT 20;

--LAG AND LEAD

SELECT 
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS previous_salary,
    salary_year_avg - LAG(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS change
FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY company_id, job_posted_date
LIMIT 60;
--------------------------------------------------------------------------------------------
SELECT 
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_posted_date,
    salary_year_avg,
    LEAD(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS previous_salary,
    salary_year_avg - LEAD(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS change
FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY company_id, job_posted_date
LIMIT 60;