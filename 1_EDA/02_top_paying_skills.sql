/*
Question: What are the highest-paying skills for data engineers?
- Calculate the median salary for each skill required in data engineer positions
- Focus on remote positions with specified salaries
- Include skill frequency to identify both salary and demand
- Why? Helps identify which skills command the highest compensation while also showing 
    how common those skills are, providing a more complete picture for skill development priorities
*/


SELECT
    sd.skills,
    COUNT (sd.skills) AS demand,
    ROUND (MEDIAN  (jpf.salary_year_avg), 0) AS median_yearly_avg_salary
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

HAVING
    COUNT (sd.skills) > 100

ORDER BY 
    median_yearly_avg_salary DESC

LIMIT 25;

/*
Breakdown of highest-paying skills for Data Engineering:

Key insights
- Rust is shown to have the highest median salary, though with low demand of only 232 postings.
- Terraform and Golang both have high median salaries at $184K and strong demand (Terraform: 3,248 postings; Golang: 912 postings).
- Notable skills with both high pay and moderate-to-high frequency include:
  - Spring: $175.5K median salary (364 postings)
  - Neo4j: $170K median salary (277 postings)
  - GDPR: $169.6K median salary (582 postings)
  - GraphQL: $167.5K median salary (445 postings)
  - Kubernetes: $150.5K median salary (4,202 postings)
  - Airflow: $150K median salary (9,996 postings)
- Bitbucket, Ruby, Redis, Ansible, and Jupyter all appear in the top 25 for pay, each with hundreds of postings.

Conclusion: While the very top-paying skill (Rust) still has less demand than major cloud and data tools, most of the top-paying skills have both solid salaries and significant demand, 
Terraform, Kubernets and Airflow being leading examples. This suggests that learning tools like Terraform, Golang, Spring, Neo4j, and especially core data engineering tools (Airflow, Kubernetes) provides a strong balance between compensation and marketability.


┌────────────┬────────┬──────────────────────────┐
│   skills   │ demand │ median_yearly_avg_salary │
│  varchar   │ int64  │          double          │
├────────────┼────────┼──────────────────────────┤
│ rust       │    232 │                 210000.0 │
│ terraform  │   3248 │                 184000.0 │
│ golang     │    912 │                 184000.0 │
│ spring     │    364 │                 175500.0 │
│ neo4j      │    277 │                 170000.0 │
│ gdpr       │    582 │                 169616.0 │
│ zoom       │    127 │                 168438.0 │
│ graphql    │    445 │                 167500.0 │
│ mongo      │    265 │                 162250.0 │
│ fastapi    │    204 │                 157500.0 │
│ django     │    265 │                 155000.0 │
│ bitbucket  │    478 │                 155000.0 │
│ crystal    │    129 │                 154224.0 │
│ atlassian  │    249 │                 151500.0 │
│ c          │    444 │                 151500.0 │
│ typescript │    388 │                 151000.0 │
│ kubernetes │   4202 │                 150500.0 │
│ airflow    │   9996 │                 150000.0 │
│ css        │    262 │                 150000.0 │
│ ruby       │    736 │                 150000.0 │
│ node       │    179 │                 150000.0 │
│ redis      │    605 │                 149000.0 │
│ ansible    │    475 │                 148798.0 │
│ vmware     │    136 │                 148798.0 │
│ jupyter    │    400 │                 147500.0 │
└────────────┴────────┴──────────────────────────┘
  25 rows                              3 columns
*/
