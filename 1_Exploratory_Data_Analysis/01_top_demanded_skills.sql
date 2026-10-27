/*
Question: What are the most in-demand skills for data engineers?
- Join job postings to inner join table similar to query 2
- Identify the top 10 in-demand skills for data engineers
- Focus on remote job postings
- Why? Retrieves the top 10 skills with the highest demand in the remote job market,
    providing insights into the most valuable skills for data engineers seeking remote work
*/

SELECT
    sd.skills,
    COUNT (jpf.*) AS demand
FROM    
    job_postings_fact AS jpf

INNER JOIN skills_job_dim AS sjd 
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id

WHERE
    job_work_from_home = TRUE
    AND jpf.job_title_short = 'Data Engineer'

GROUP BY
    sd.skills

ORDER BY 
    demand DESC

LIMIT 10;


/*

Breakdown of highest in-demand skills for data engineers:

SQL and Python are by far the most in-demand skills for Data Engineering, showing up about 29,000 times each in the job postings filtered by the query above. Following them are cloud platforms like
Azure and AWS (17823 and 14,143 respectively). Closing out the top 5 is Apache Spark with 12,799 postings. Data pipeline tools (Airflow, Snowflake, Databricks) make their appearance showing growing 
demand (9996, 8639, 8183 postings respectively). Java and GCP close out the top 10 with around seven and six thousand postings.

Conclusion: SQL and Python seem to be foundational skills to learn for Data Engineering with Cloud platforms for modern DE being runner up and pipeline tools following third.
┌────────────┬────────┐
│   skills   │ demand │
│  varchar   │ int64  │
├────────────┼────────┤
│ sql        │  29221 │
│ python     │  28776 │
│ aws        │  17823 │
│ azure      │  14143 │
│ spark      │  12799 │
│ airflow    │   9996 │
│ snowflake  │   8639 │
│ databricks │   8183 │
│ java       │   7267 │
│ gcp        │   6446 │
└────────────┴────────┘
  10 rows   2 columns                               
*/

                     