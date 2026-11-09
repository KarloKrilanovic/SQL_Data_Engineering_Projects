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

