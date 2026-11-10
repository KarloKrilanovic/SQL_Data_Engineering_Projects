/*
The recruitment team wants to see how jobs rank by salary within each job title.
*/

SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    RANK () OVER (
        PARTITION BY job_title_short
        ORDER BY salary_year_avg DESC
    ) AS salary_rank

FROM 
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
ORDER BY 
    salary_year_avg DESC,
    job_title_short
LIMIT 20;

/*
┌─────────┬───────────────────────────┬─────────────────┬─────────────┐
│ job_id  │      job_title_short      │ salary_year_avg │ salary_rank │
│  int32  │          varchar          │     double      │    int64    │
├─────────┼───────────────────────────┼─────────────────┼─────────────┤
│  296745 │ Data Scientist            │        960000.0 │           1 │
│ 1231950 │ Data Scientist            │        920000.0 │           2 │
│  673003 │ Senior Data Scientist     │        890000.0 │           1 │
│ 1575798 │ Machine Learning Engineer │        875000.0 │           1 │
│ 1007105 │ Data Scientist            │        870000.0 │           3 │
│  856772 │ Data Scientist            │        850000.0 │           4 │
│ 1591743 │ Machine Learning Engineer │        800000.0 │           2 │
│ 1443865 │ Senior Data Engineer      │        800000.0 │           1 │
│ 1574285 │ Data Scientist            │        680000.0 │           5 │
│  142665 │ Data Analyst              │        650000.0 │           1 │
│  871759 │ Data Engineer             │        640000.0 │           1 │
│ 1335282 │ Data Scientist            │        640000.0 │           6 │
│  785438 │ Data Scientist            │        585000.0 │           7 │
│  499552 │ Data Scientist            │        550000.0 │           8 │
│  234407 │ Data Engineer             │        525000.0 │           2 │
│  543480 │ Data Scientist            │        525000.0 │           9 │
│ 1218524 │ Data Scientist            │        475000.0 │          10 │
│   95558 │ Senior Data Scientist     │        475000.0 │           2 │
│  685280 │ Senior Data Scientist     │        463500.0 │           3 │
│  494444 │ Data Engineer             │        450000.0 │           3 │
└─────────┴───────────────────────────┴─────────────────┴─────────────┘
  20 rows                                                   4 columns
*/

/*
The finance team wants to track the cumulative salary cost of remote jobs over time.
*/

SELECT
    job_posted_date,
    job_title_short,
    salary_year_avg,
    SUM(salary_year_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    ) AS running_total_salary

FROM 
    job_postings_fact
WHERE
    job_work_from_home = TRUE
    AND salary_year_avg IS NOT NULL 
ORDER BY
    job_title_short,
    job_posted_date
LIMIT 40;

/*
┌─────────────────────┬──────────────────┬─────────────────┬──────────────────────┐
│   job_posted_date   │ job_title_short  │ salary_year_avg │ running_total_salary │
│      timestamp      │     varchar      │     double      │        double        │
├─────────────────────┼──────────────────┼─────────────────┼──────────────────────┤
│ 2023-01-01 00:17:55 │ Business Analyst │         90000.0 │              90000.0 │
│ 2023-01-27 08:03:51 │ Business Analyst │         77500.0 │             167500.0 │
│ 2023-01-27 16:36:44 │ Business Analyst │        110000.0 │             277500.0 │
│ 2023-02-15 15:01:54 │ Business Analyst │        133340.0 │             410840.0 │
│ 2023-03-24 21:02:40 │ Business Analyst │         75000.0 │             485840.0 │
│ 2023-03-27 21:02:06 │ Business Analyst │         63575.0 │             549415.0 │
│ 2023-04-07 19:44:08 │ Business Analyst │         75000.0 │             624415.0 │
│ 2023-04-18 11:02:59 │ Business Analyst │         55500.0 │             679915.0 │
│ 2023-04-23 08:01:03 │ Business Analyst │         90500.0 │             770415.0 │
│ 2023-04-25 16:01:10 │ Business Analyst │        130000.0 │             900415.0 │
│ 2023-04-27 07:01:11 │ Business Analyst │        114500.0 │            1014915.0 │
│ 2023-04-28 09:01:35 │ Business Analyst │         96500.0 │            1111415.0 │
│ 2023-04-30 10:00:42 │ Business Analyst │         93500.0 │            1204915.0 │
│ 2023-05-10 13:56:33 │ Business Analyst │         70000.0 │            1274915.0 │
│ 2023-05-10 17:36:36 │ Business Analyst │         72500.0 │            1347415.0 │
│ 2023-05-16 18:39:05 │ Business Analyst │         16500.0 │            1363915.0 │
│ 2023-05-17 16:10:29 │ Business Analyst │        121500.0 │            1485415.0 │
│ 2023-06-05 18:01:46 │ Business Analyst │         62500.0 │            1547915.0 │
│ 2023-06-18 20:01:06 │ Business Analyst │        106000.0 │            1653915.0 │
│ 2023-06-21 18:11:35 │ Business Analyst │        190000.0 │            1843915.0 │
│ 2023-06-22 13:01:41 │ Business Analyst │        145000.0 │            1988915.0 │
│ 2023-06-30 14:01:54 │ Business Analyst │        138640.0 │            2127555.0 │
│ 2023-07-07 18:43:35 │ Business Analyst │        124000.0 │            2251555.0 │
│ 2023-07-18 02:03:03 │ Business Analyst │         82500.0 │            2334055.0 │
│ 2023-07-26 08:02:33 │ Business Analyst │         75795.0 │            2409850.0 │
│ 2023-08-02 14:02:09 │ Business Analyst │        111500.0 │            2521350.0 │
│ 2023-08-03 19:59:22 │ Business Analyst │        134550.0 │            2655900.0 │
│ 2023-08-09 07:00:35 │ Business Analyst │         85000.0 │            2740900.0 │
│ 2023-08-10 14:01:22 │ Business Analyst │         50000.0 │            2790900.0 │
│ 2023-08-11 00:15:11 │ Business Analyst │         82500.0 │            2873400.0 │
│ 2023-08-12 10:31:47 │ Business Analyst │         65000.0 │            2938400.0 │
│ 2023-08-13 16:30:46 │ Business Analyst │         75000.0 │            3013400.0 │
│ 2023-08-13 17:01:30 │ Business Analyst │         75000.0 │            3088400.0 │
│ 2023-08-17 10:41:08 │ Business Analyst │         82500.0 │            3170900.0 │
│ 2023-08-29 18:04:11 │ Business Analyst │        220000.0 │            3390900.0 │
│ 2023-09-09 09:00:15 │ Business Analyst │        105000.0 │            3495900.0 │
│ 2023-09-10 10:00:23 │ Business Analyst │         60000.0 │            3555900.0 │
│ 2023-09-11 15:00:04 │ Business Analyst │         57500.0 │            3613400.0 │
│ 2023-09-13 09:01:20 │ Business Analyst │        128500.0 │            3741900.0 │
│ 2023-09-15 22:01:25 │ Business Analyst │         90000.0 │            3831900.0 │
└─────────────────────┴──────────────────┴─────────────────┴──────────────────────┘
  40 rows                                                               4 columns
*/

/*
The data team wants to know how an individual job's salary compares to the 
average salary of its specific job title.
*/

SELECT
    job_title_short,
    salary_year_avg,
    AVG(salary_year_avg) OVER (
        PARTITION BY job_title_short
    )::DECIMAL(7,1) AS average_title_salary,
    (salary_year_avg - AVG(salary_year_avg) OVER (
        PARTITION BY job_title_short
    ))::DECIMAL(7,1) AS salary_difference

FROM
    job_postings_fact
WHERE
    salary_year_avg > 100_000
LIMIT 20;

/*
┌───────────────────────┬─────────────────┬──────────────────────┬───────────────────┐
│    job_title_short    │ salary_year_avg │ average_title_salary │ salary_difference │
│        varchar        │     double      │     decimal(7,1)     │   decimal(7,1)    │
├───────────────────────┼─────────────────┼──────────────────────┼───────────────────┤
│ Data Scientist        │        224500.0 │             154379.5 │           70120.5 │
│ Data Scientist        │        145000.0 │             154379.5 │           -9379.5 │
│ Data Scientist        │        157500.0 │             154379.5 │            3120.5 │
│ Senior Data Scientist │        135000.0 │             164921.9 │          -29921.9 │
│ Data Engineer         │        132500.0 │             150085.0 │          -17585.0 │
│ Senior Data Engineer  │        160000.0 │             157722.9 │            2277.1 │
│ Senior Data Scientist │        235000.0 │             164921.9 │           70078.1 │
│ Senior Data Analyst   │        125000.0 │             132069.4 │           -7069.4 │
│ Data Scientist        │        125000.0 │             154379.5 │          -29379.5 │
│ Data Scientist        │        150000.0 │             154379.5 │           -4379.5 │
│ Data Scientist        │        135000.0 │             154379.5 │          -19379.5 │
│ Data Scientist        │        200000.0 │             154379.5 │           45620.5 │
│ Data Scientist        │        115000.0 │             154379.5 │          -39379.5 │
│ Data Scientist        │        125000.0 │             154379.5 │          -29379.5 │
│ Senior Data Scientist │        150000.0 │             164921.9 │          -14921.9 │
│ Data Engineer         │        200000.0 │             150085.0 │           49915.0 │
│ Senior Data Scientist │        125000.0 │             164921.9 │          -39921.9 │
│ Data Scientist        │        125000.0 │             154379.5 │          -29379.5 │
│ Senior Data Engineer  │        125000.0 │             157722.9 │          -32722.9 │
│ Data Scientist        │        125000.0 │             154379.5 │          -29379.5 │
└───────────────────────┴─────────────────┴──────────────────────┴───────────────────┘
*/

/*
The marketing team wants to identify the top 2 highest-paying remote jobs for each company.
*/

WITH company_rank AS (
    SELECT
        COALESCE (cd.name, 'Unknown') AS company_name,
        jpf.job_title_short AS job_title_short,
        jpf.salary_year_avg AS salary_year_avg,
        ROW_NUMBER () OVER (
            PARTITION BY cd.name
            ORDER BY salary_year_avg DESC
        ) AS job_rank
    
    FROM    
        job_postings_fact AS jpf

    INNER JOIN company_dim AS cd
        ON jpf.company_id = cd.company_id

    WHERE 
        jpf.job_work_from_home = TRUE 
        AND jpf.salary_year_avg IS NOT NULL
)

SELECT *
FROM company_rank AS cr
WHERE 
    cr.job_rank = 1 OR cr.job_rank = 2
ORDER BY 
    cr.salary_year_avg DESC
LIMIT 30;

/*
┌───────────────────────────┬───────────────────────────┬─────────────────┬──────────┐
│       company_name        │      job_title_short      │ salary_year_avg │ job_rank │
│          varchar          │          varchar          │     double      │  int64   │
├───────────────────────────┼───────────────────────────┼─────────────────┼──────────┤
│ Netflix                   │ Data Scientist            │        680000.0 │        1 │
│ Mantys                    │ Data Analyst              │        650000.0 │        1 │
│ Selby Jennings            │ Data Scientist            │        550000.0 │        1 │
│ Selby Jennings            │ Data Scientist            │        525000.0 │        2 │
│ Glocomms                  │ Senior Data Scientist     │        475000.0 │        1 │
│ Netflix                   │ Senior Data Scientist     │        445000.0 │        2 │
│ Siemens                   │ Data Analyst              │        385000.0 │        1 │
│ Dow Jones                 │ Data Engineer             │        377500.0 │        1 │
│ Algo Capital Group        │ Senior Data Scientist     │        375000.0 │        2 │
│ Algo Capital Group        │ Data Scientist            │        375000.0 │        1 │
│ Demandbase                │ Data Scientist            │        351500.0 │        1 │
│ Gametime United           │ Machine Learning Engineer │        348000.0 │        1 │
│ Demandbase                │ Data Scientist            │        340000.0 │        2 │
│ Meta                      │ Data Analyst              │        336500.0 │        1 │
│ Roblox                    │ Senior Data Scientist     │        327330.0 │        1 │
│ Okratin Solutions Pte Ltd │ Data Scientist            │        325000.0 │        1 │
│ Harnham                   │ Machine Learning Engineer │        325000.0 │        1 │
│ Storm5                    │ Machine Learning Engineer │        325000.0 │        1 │
│ Engtal                    │ Data Engineer             │        325000.0 │        1 │
│ Engtal                    │ Data Engineer             │        325000.0 │        2 │
│ Career Renew              │ Machine Learning Engineer │        325000.0 │        1 │
│ ServiceNow                │ Data Scientist            │        321000.0 │        1 │
│ Teramind                  │ Data Scientist            │        320000.0 │        1 │
│ Domino Data Lab           │ Software Engineer         │        316000.0 │        1 │
│ Life Science People       │ Senior Data Scientist     │        315000.0 │        1 │
│ LinkedIn                  │ Data Scientist            │        314000.0 │        1 │
│ Reddit                    │ Data Scientist            │        313000.0 │        1 │
│ Indeed                    │ Senior Data Scientist     │        310000.0 │        1 │
│ USAA                      │ Data Scientist            │        306050.0 │        1 │
│ Instacart                 │ Senior Data Scientist     │        301000.0 │        1 │
└───────────────────────────┴───────────────────────────┴─────────────────┴──────────┘
  30 rows                                                                  4 columns
*/

/*
The executive team wants a comprehensive report on the top-performing skills.
*/

WITH high_salary AS (
    SELECT
        job_id,
        company_id,
        salary_year_avg

    FROM
        job_postings_fact
    WHERE
        salary_year_avg > 150000
        AND job_work_from_home = TRUE
),

skills AS (
    SELECT
        hs.company_id AS company_id,
        hs.salary_year_avg AS salary_year_avg,
        sd.skills AS skills
    FROM
        high_salary AS hs
    INNER JOIN skills_job_dim AS sjd
        ON hs.job_id = sjd.job_id
    INNER JOIN skills_dim AS sd
        ON sjd.skill_id = sd.skill_id
),

skill_comparison AS (
    SELECT
        s.skills AS skills,
        AVG(s.salary_year_avg)::DECIMAL(8,1) AS average_salary,
        COUNT(s.skills) AS skill_count,
        RANK () OVER (
            ORDER BY AVG(s.salary_year_avg) DESC
        ) AS salary_rank
    FROM
        skills AS s
    GROUP BY 
        s.skills
)

SELECT
    *
FROM
    skill_comparison AS sc
WHERE EXISTS (
    SELECT 1
    FROM data_jobs.main.skills_dim AS sd
    WHERE sc.skills = sd.skills
) AND sc.skill_count > 5
ORDER BY sc.average_salary DESC
LIMIT 10;

/*
┌────────────┬────────────────┬─────────────┬─────────────┐
│   skills   │ average_salary │ skill_count │ salary_rank │
│  varchar   │  decimal(8,1)  │    int64    │    int64    │
├────────────┼────────────────┼─────────────┼─────────────┤
│ swift      │       236631.6 │          19 │           3 │
│ rust       │       220871.8 │          39 │           6 │
│ node       │       212661.8 │          34 │           8 │
│ windows    │       208881.3 │          12 │          10 │
│ monday.com │       208500.0 │          10 │          11 │
│ graphql    │       206886.2 │          36 │          14 │
│ notion     │       204000.0 │          12 │          15 │
│ perl       │       202416.7 │           6 │          17 │
│ qlik       │       200413.5 │          12 │          18 │
│ gdpr       │       198416.1 │          36 │          21 │
└────────────┴────────────────┴─────────────┴─────────────┘
*/

