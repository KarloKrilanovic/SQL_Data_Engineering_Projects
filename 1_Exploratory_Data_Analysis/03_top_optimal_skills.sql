/*
Question: What are the most optimal skills for data engineers—balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.
- Why?
    - This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately instead of letting rare, outlier skills distort the results.
    - The natural log transformation ensures that both high-salary and widely in-demand skills surface as the most practical and valuable to learn for data engineering careers.
*/

SELECT
    sd.skills,
    COUNT (sd.skills) AS demand,
    ROUND (MEDIAN  (jpf.salary_year_avg), 0) AS median_salary,
    ROUND(LN(COUNT(sd.skills)), 1) AS ln_demand, -- Smoothing out and compressing the demand count for skills
    --LN(COUNT(sd.skills) * MEDIAN (jpf.salary_year_avg)/1_000_000) AS optimal_score --(not as informative as the line below. No point in flattening the salary through ln)
    ROUND((LN(COUNT(sd.skills)) * MEDIAN (jpf.salary_year_avg)) / 1_000_000, 2) AS optimal_score
FROM    
    job_postings_fact AS jpf

INNER JOIN skills_job_dim AS sjd 
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id

WHERE
    job_work_from_home = TRUE
    AND jpf.job_title_short = 'Data Engineer'
    AND jpf.salary_year_avg IS NOT NULL

GROUP BY
    sd.skills

HAVING
    COUNT (sd.skills) > 100

ORDER BY 
    optimal_score DESC

LIMIT 25;

/*
Breakdown of the top optimal skills for data engineers, based on demand and salary:

We can see that despite having only 193 postings, the salary for Terraform pushes it to the top with an optimal score of 0.97. Python and SQL are second and third with very
high demand (over 1100 postings each) and strong median salaries of $135K and $130K, respectively. AWS (783 postings, $137K median), Spark (503 postings, $140K median),
and Airflow (386 postings, $150K median) are all highly sought-after cloud and big data technologies. Kafka offers high compensation ($145K median) and solid demand (292 postings).
Tools like Snowflake, Azure, and Databricks each have 250–475 postings and median salaries between $128–$137K.

DevOps & Engineering Tools:
- Airflow ($150K), Kubernetes ($150.5K), and Docker ($135K) stand out for their mix of demand and top median salaries.
- Git ($140K/208 postings) and Github ($135K/127 postings) have broad utility and competitive compensation.

Noteworthy Languages:
- Java (303 postings, $135K median) and Scala (247 postings, $137K median) remain strong choices for well-paid data engineering roles.
- Go ($140K/113 postings) is another programming language with excellent compensation.

Databases & Cloud:
- Redshift ($130K/274 postings), GCP ($136K/196 postings), Hadoop ($135K/198 postings), NoSQL ($134.4K/193 postings), and MongoDB ($135.8K/136 postings) add to a well-rounded data engineering skill set.
- R, Pyspark, and BigQuery each deliver competitive salaries and meet the threshold for demand.

Conclusion:
Skills that consistently appear near the top balance a strong combination of market demand (job security) and financial benefit. Python, SQL, AWS, Spark, Airflow, and 
Terraform are particularly strategic for both immediate opportunities and longer-term career growth in data engineering.

┌────────────┬────────┬───────────────┬───────────┬───────────────┐
│   skills   │ demand │ median_salary │ ln_demand │ optimal_score │
│  varchar   │ int64  │    double     │  double   │    double     │
├────────────┼────────┼───────────────┼───────────┼───────────────┤
│ terraform  │    193 │      184000.0 │       5.3 │          0.97 │
│ python     │   1133 │      135000.0 │       7.0 │          0.95 │
│ sql        │   1128 │      130000.0 │       7.0 │          0.91 │
│ aws        │    783 │      137320.0 │       6.7 │          0.91 │
│ airflow    │    386 │      150000.0 │       6.0 │          0.89 │
│ spark      │    503 │      140000.0 │       6.2 │          0.87 │
│ kafka      │    292 │      145000.0 │       5.7 │          0.82 │
│ snowflake  │    438 │      135500.0 │       6.1 │          0.82 │
│ azure      │    475 │      128000.0 │       6.2 │          0.79 │
│ java       │    303 │      135000.0 │       5.7 │          0.77 │
│ scala      │    247 │      137290.0 │       5.5 │          0.76 │
│ git        │    208 │      140000.0 │       5.3 │          0.75 │
│ kubernetes │    147 │      150500.0 │       5.0 │          0.75 │
│ databricks │    266 │      132750.0 │       5.6 │          0.74 │
│ redshift   │    274 │      130000.0 │       5.6 │          0.73 │
│ gcp        │    196 │      136000.0 │       5.3 │          0.72 │
│ hadoop     │    198 │      135000.0 │       5.3 │          0.71 │
│ nosql      │    193 │      134415.0 │       5.3 │          0.71 │
│ pyspark    │    152 │      140000.0 │       5.0 │           0.7 │
│ mongodb    │    136 │      135750.0 │       4.9 │          0.67 │
│ docker     │    144 │      135000.0 │       5.0 │          0.67 │
│ go         │    113 │      140000.0 │       4.7 │          0.66 │
│ r          │    133 │      134775.0 │       4.9 │          0.66 │
│ github     │    127 │      135000.0 │       4.8 │          0.65 │
│ bigquery   │    123 │      135000.0 │       4.8 │          0.65 │
└────────────┴────────┴───────────────┴───────────┴───────────────┘
  25 rows                                               5 columns
*/