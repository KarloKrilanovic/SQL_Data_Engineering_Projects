/*
The HR team needs a clean list of company names and their websites. Some company names 
have leading or trailing spaces, and some website links are missing (NULL).
*/

SELECT
    TRIM(name),
    COALESCE(link, 'No Website')
FROM
    company_dim
WHERE
    TRIM(name) LIKE 'A%';

/*
The finance team wants a single string that summarizes every job posting that 
pays over 100,000.
*/

WITH job_summaries AS (
    SELECT TO_JSON ({job:[jpf.job_id], skills:[ARRAY_AGG(sd.skills)], salary:[jpf.salary_year_avg]}) AS job_json
    FROM job_postings_fact AS jpf
    LEFT JOIN skills_job_dim AS sjd
        ON jpf.job_id = sjd.job_id
    LEFT JOIN skills_dim AS sd
        ON sjd.skill_id = sd.skill_id
    WHERE
        jpf.salary_year_avg >= 100000
    GROUP BY
        jpf.job_id,
        jpf.salary_year_avg
    ORDER BY 
        jpf.job_id
)
SELECT 
    job_json
FROM 
    job_summaries;

/* ovo je kao pravo rjesenje. keep it simple stupid
SELECT 
    CONCAT(
        job_title_short, 
        ': ', 
        CAST(ROUND(salary_year_avg) AS VARCHAR)
    ) AS job_summary
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL 
    AND salary_year_avg > 100000
LIMIT 10;
*/

/*
The data team is building a JSON API and needs a specific structure for the skills.
Write a query using STRUCT_PACK that creates a struct with two keys: skill_name 
(from skills_dim) and skill_type (from skills_dim). Name the column skill_info. 
Use ARRAY_AGG to group all these structs into a single array, but only for skills 
where the type is 'programming'.
*/

WITH skill_table AS (
    SELECT sd.skills AS skill_name, sd.type AS skill_type
    FROM skills_dim AS sd
    WHERE skill_type LIKE 'programming'
)

SELECT 
    ARRAY_AGG (
        STRUCT_PACK (
            skill_name := skill_name,
            skill_type := skill_type
        ) 
    ) AS skill_info
FROM
    skill_table;

/*
The business wants to know how quickly they are hiring for high-paying roles.
Write a query that returns the job_title_short, the job_posted_date 
(formatted as 'YYYY-MM'), and the salary_year_avg. Create a new column called 
days_since_posted that calculates the difference in days between today and the 
job_posted_date. Finally, use a nested CASE statement to categorize the salary_year_avg 
into 'High' (over 150k), 'Medium' (75k-150k), and 'Low' (under 75k), but only if 
days_since_posted is greater than 30. Otherwise, display 'Too Recent'.
*/

SELECT
    job_title_short,
    CONCAT(EXTRACT(YEAR FROM job_posted_date), '-', EXTRACT(MONTH FROM job_posted_date)) AS job_posted_date,
    salary_year_avg,
    DATE_DIFF('day', job_posted_date, current_date) AS days_since_posted,
    CASE
        WHEN salary_year_avg > 150000 AND DATE_DIFF('day', job_posted_date, current_date) > 30 THEN 'High'
        WHEN salary_year_avg > 75000 AND DATE_DIFF('day', job_posted_date, current_date) > 30 THEN 'Medium'
        WHEN salary_year_avg < 75000 AND DATE_DIFF('day', job_posted_date, current_date) > 30 THEN 'Low'
        ELSE 'Too Recent'
    END AS salary_category
FROM
    job_postings_fact
WHERE 
     salary_year_avg IS NOT NULL
ORDER BY days_since_posted;

/*
The executive team wants a report on the most expensive "remote" skills.

    Create a CTE that finds all remote jobs and extracts the year from job_posted_date.

    Create a second CTE that joins the first CTE to the skills tables. Use a window 
    function to rank the individual jobs by salary (DESC) partitioned by the skills name.

    Create a third CTE that filters for jobs where that rank is 1 (the highest-paying 
    job for that skill), and calculates the average salary for each skill.

    In the final SELECT, return the skills, the average salary (rounded to the nearest 
    whole number), and use CONCAT to combine the skill name with the average salary into 
    a single string (e.g., "Python: 145000"). Also, use COALESCE to handle any NULL skills 
    by displaying 'Uncategorized'. Only include skills that have been posted in at least 
    2 different years.
*/

WITH year_remote AS (
    SELECT
        job_id, 
        job_title_short,
        salary_year_avg,
        EXTRACT(YEAR FROM job_posted_date) AS post_year
    FROM
        job_postings_fact
    WHERE 
        job_work_from_home = TRUE
), skill_table_join AS (
    SELECT
        yr.job_id, 
        yr.job_title_short,
        yr.salary_year_avg,
        yr.post_year,
        sd.skills,
        RANK() OVER (
            PARTITION BY sd.skills
            ORDER BY yr.salary_year_avg DESC
        ) AS rank
    FROM
        year_remote AS yr
    LEFT JOIN skills_job_dim AS sjd
        ON yr.job_id = sjd.job_id
    LEFT JOIN skills_dim AS sd
        ON sjd.skill_id = sd.skill_id
    WHERE 
        yr.salary_year_avg IS NOT NULL
), rank_one_jobs AS (
    SELECT
        stj.job_id, 
        stj.job_title_short,
        stj.salary_year_avg,
        stj.post_year,
        stj.skills,
        stj.rank,
        ROUND(AVG(salary_year_avg) OVER (
            PARTITION BY stj.skills
        )) AS average_yearly_salary
    FROM    
        skill_table_join AS stj   
    WHERE
        stj.rank = 1  
)
SELECT  
    CONCAT(COALESCE(skills, 'Uncategorized'), '--', average_yearly_salary) AS skill_info
FROM
    rank_one_jobs
GROUP BY 
    skills,
    average_yearly_salary
HAVING
    COUNT(DISTINCT post_year) >=2
ORDER BY 
    average_yearly_salary DESC;


