--1
/*
I need a report on our hiring activity. Give me a list of all unique job roles that were posted in the United States and offer remote work. 
I want to know how many unique companies posted each of these roles.
Sort the final result by job postings from highest to lowest.
*/
SELECT
    jpf.job_title_short AS job_role,
    COUNT (DISTINCT cd.name) AS total_companies,
    COUNT (jpf.job_title_short) AS total_job_postings

FROM   
    job_postings_fact AS jpf

LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id

WHERE   
    job_work_from_home = TRUE
    AND job_country = 'United States'

GROUP BY 
    job_role

ORDER BY
    COUNT (jpf.job_title_short) DESC;

/*
┌───────────────────────────┬─────────────────┬────────────────────┐
│         job_role          │ total_companies │ total_job_postings │
│          varchar          │      int64      │       int64        │
├───────────────────────────┼─────────────────┼────────────────────┤
│ Data Engineer             │            4567 │              12593 │
│ Data Scientist            │            4333 │              11087 │
│ Data Analyst              │            3774 │               9066 │
│ Senior Data Engineer      │            1806 │               3577 │
│ Senior Data Scientist     │            1354 │               2695 │
│ Senior Data Analyst       │             934 │               1747 │
│ Business Analyst          │             677 │               1273 │
│ Software Engineer         │             280 │                480 │
│ Machine Learning Engineer │             261 │                394 │
│ Cloud Engineer            │              91 │                109 │
└───────────────────────────┴─────────────────┴────────────────────┘
  10 rows                                                3 columns
  
*/

--2
/*
The business wants to know which skills are the most in-demand, but our data team thinks some jobs might not have any skills attached to them. 
Find me the total count of unique job postings for every single skill in the database, including the jobs that don't have a skill listed. 
Display the skill name and the count of job postings. Order it so the most in-demand skills are at the top.
*/
SELECT
    sd.skills AS skills,
    COUNT(*) AS total_postings
    
FROM 
    job_postings_fact AS jpf

LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd
    ON sjd.skill_id = sd.skill_id

GROUP BY    
    skills

ORDER BY 
    total_postings DESC;

/*
┌─────────────────┬────────────────┐
│     skills      │ total_postings │
│     varchar     │     int64      │
├─────────────────┼────────────────┤
│ python          │         759081 │
│ sql             │         758824 │
│ aws             │         302245 │
│ NULL            │         285375 │
│ azure           │         280137 │
│ excel           │         245645 │
│ tableau         │         241876 │
│ r               │         237602 │
│ spark           │         222464 │
│ power bi        │         205785 │
│ java            │         164723 │
│ sas             │         146388 │
│ snowflake       │         122174 │
│ databricks      │         121834 │
│ hadoop          │         118739 │
│ scala           │         109664 │
│ gcp             │         108917 │
│ kafka           │          96902 │
│ git             │          95940 │
│ airflow         │          94671 │
│   ·             │              · │
│   ·             │              · │
│   ·             │              · │
│ mlpack          │             28 │
│ ember.js        │             27 │
│ homebrew        │             26 │
│ chainer         │             22 │
│ shogun          │             17 │
│ microsoft lists │             13 │
│ dingtalk        │              8 │
│ huggingface     │              6 │
│ deno            │              5 │
│ gtx             │              4 │
│ esquisse        │              4 │
│ asp.netcore     │              3 │
│ workzone        │              2 │
│ rocketchat      │              2 │
│ swit            │              1 │
│ visualbasic     │              1 │
│ fann            │              1 │
│ msaccess        │              1 │
│ wimi            │              1 │
│ rubyon rails    │              1 │
└─────────────────┴────────────────┘
  256 rows (40 shown)    2 columns
  */

--3
/*
The finance team needs a CSV file of high-paying jobs. Write a query that pulls the job id, job title, and average yearly salary. 
Only include jobs with a yearly salary over 100,000, and only include jobs that offer health insurance. Order the results from highest salary to lowest.
Once you have the query working, export the output to a CSV file named high_paying_jobs.csv inside a folder called exports in your home directory.
*/
COPY (
SELECT
    job_id,
    job_title_short,
    salary_year_avg

FROM 
    job_postings_fact

WHERE   
    salary_year_avg > 100_000
    AND job_health_insurance = TRUE

ORDER BY
    salary_year_avg DESC

) TO '/home/karlo/export/high_paying_jobs.csv';


--4
/*
Management suspects that jobs requiring programming skills pay more than jobs that don't. 
Compare the average yearly salary of jobs that require 'python' against jobs that require 'sql'. 
Do not include any jobs where the salary is missing.
*/
SELECT
    sd.skills AS skill_category,
    AVG (salary_year_avg) AS average_yearly_salary
FROM    
    job_postings_fact AS jpf

INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id

WHERE 
    sd.skills = 'python' 
    OR sd.skills = 'sql' --može se koristiti IN operator umjesto OR (WHERE sd.skills IN ('python', 'sql'))

GROUP BY    
    sd.skills;

/*
┌────────────────┬───────────────────────┐
│ skill_category │ average_yearly_salary │
│    varchar     │        double         │
├────────────────┼───────────────────────┤
│ python         │    133093.57603198529 │
│ sql            │    125969.53337046651 │
└────────────────┴───────────────────────┘
*/

--5
/*
I need a list of the top 5 companies that offer the highest average yearly salary for their remote Data Analyst positions. 
To make this list, I only want companies that have posted at least 2 remote Data Analyst roles. 
I also want you to format the company names in all uppercase letters in the final output.
*/
SELECT  
    UPPER(cd.name) AS company_name,
    COUNT (job_id),
    AVG (jpf.salary_year_avg) AS average_yearly_salary
FROM
    job_postings_fact AS jpf

LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id

WHERE
    job_work_from_home = TRUE 
    AND job_title_short = 'Data Analyst'

GROUP BY
    cd.name

HAVING
    COUNT (job_id) >= 2

ORDER BY
    average_yearly_salary DESC

LIMIT 5;

/*
┌──────────────┬───────────────┬───────────────────────┐
│ company_name │ count(job_id) │ average_yearly_salary │
│   varchar    │     int64     │        double         │
├──────────────┼───────────────┼───────────────────────┤
│ NETFLIX      │             7 │              445000.0 │
│ SIEMENS      │             9 │              385000.0 │
│ META         │             4 │              336500.0 │
│ EDGE & NODE  │             4 │              264000.0 │
│ AT&T         │             6 │              255829.5 │
└──────────────┴───────────────┴───────────────────────┘
*/