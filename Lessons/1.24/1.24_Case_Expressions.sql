--Bucket salaries
-- <25 = 'Low'
-- 25-50 = 'Medium'
-- >50 = 'High'

SELECT  
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
LIMIT 10;

/*
┌─────────────────┬─────────────────┬─────────────────┐
│ job_title_short │ salary_hour_avg │ salary_category │
│     varchar     │     double      │     varchar     │
├─────────────────┼─────────────────┼─────────────────┤
│ Data Analyst    │            20.0 │ Low             │
│ Data Scientist  │            20.0 │ Low             │
│ Data Analyst    │            15.0 │ Low             │
│ Data Analyst    │           35.75 │ Medium          │
│ Data Analyst    │            36.0 │ Medium          │
│ Data Analyst    │            55.0 │ High            │
│ Data Engineer   │            64.5 │ High            │
│ Data Scientist  │            20.0 │ Low             │
│ Data Scientist  │            20.0 │ Low             │
│ Data Engineer   │            25.5 │ Medium          │
└─────────────────┴─────────────────┴─────────────────┘
  10 rows                                   3 columns
*/

--Handling missing data (nulls)
--filter null salaries

SELECT  
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg IS NULL THEN 'Missing'
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
LIMIT 10;

/*
┌─────────────────────┬─────────────────┬─────────────────┐
│   job_title_short   │ salary_hour_avg │ salary_category │
│       varchar       │     double      │     varchar     │
├─────────────────────┼─────────────────┼─────────────────┤
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Senior Data Analyst │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Senior Data Analyst │            NULL │ Missing         │
│ Business Analyst    │            NULL │ Missing         │
└─────────────────────┴─────────────────┴─────────────────┘
  10 rows                                       3 columns
*/

--Categorizing values
--classify job_title column as 
    --Data analyst
    --Data engineer
    --Data scientist

SELECT
    job_title,
    CASE
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Analyst%' THEN 'Data Analyst'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Engineer%' THEN 'Data Engineer'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Scientist%' THEN 'Data Scientist'
        ELSE 'Other'
    END AS job_title_category,
    job_title_short

FROM job_postings_fact
ORDER BY RANDOM ()
LIMIT 20;

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

  --conditional aggregation
  --calculate median salaries for different buckets
    --<$100K
    -->=$100K

SELECT
    job_title_short,
    COUNT(*) AS totalpostings,
    MEDIAN (
        CASE
            WHEN salary_year_avg < 100_000 THEN salary_year_avg
        END
    ) AS median_low_salary,
    MEDIAN (
        CASE 
            WHEN salary_year_avg >= 100_000 THEN salary_year_avg
        END
    ) AS median_high_salary

FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short;

/*
┌───────────────────────────┬───────────────┬───────────────────┬────────────────────┐
│      job_title_short      │ totalpostings │ median_low_salary │ median_high_salary │
│          varchar          │     int64     │      double       │       double       │
├───────────────────────────┼───────────────┼───────────────────┼────────────────────┤
│ Senior Data Scientist     │          3271 │           89100.0 │           157500.0 │
│ Senior Data Engineer      │          3283 │           87179.5 │           150000.0 │
│ Machine Learning Engineer │          1334 │           78261.5 │           166000.0 │
│ Senior Data Analyst       │          2603 │           87500.0 │           120000.0 │
│ Cloud Engineer            │           219 │           79200.0 │           135500.0 │
│ Data Engineer             │         10551 │           87500.0 │           140000.0 │
│ Data Analyst              │         13600 │           75000.0 │          114978.25 │
│ Software Engineer         │          1578 │           79200.0 │           174400.0 │
│ Data Scientist            │         12625 │           80000.0 │           140000.0 │
│ Business Analyst          │          1962 │           80000.0 │           125000.0 │
└───────────────────────────┴───────────────┴───────────────────┴────────────────────┘
  10 rows                                                                  4 columns
  */

