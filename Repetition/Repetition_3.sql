/*
The HR team wants to categorize all jobs based on their yearly salary.
Write a query that returns the job_id, job_title_short, and a new column called salary_tier.
The tiers are:
'High' if the salary is 150,000 or more.

'Medium' if the salary is between 75,000 and 149,999.

'Low' if the salary is less than 75,000.

'Not Specified' if the salary is NULL.
Order the results so the highest salaries appear first.
*/

SELECT  
    job_title_short,
    job_id,
    CASE
        WHEN salary_year_avg IS NULL THEN 'Not Specified'
        WHEN salary_year_avg < 75000 THEN 'Low'
        WHEN salary_year_avg < 149999 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
ORDER BY salary_category 
LIMIT 10;

/*
The data quality team wants to know how old the job postings are.
Write a query that returns the job_id, job_posted_date, and a new column called days_since_posted that calculates the exact number of days between today's date and the job_posted_date.
Additionally, include a column called posting_age that uses a CASE statement to output 'Recent' if the job was posted within the last 30 days, and 'Old' otherwise. Only include jobs posted in the year 2023.
*/

WITH days_since_posted AS (
    SELECT 
        job_id,
        (current_date - job_posted_date) AS interval,
        EXTRACT(EPOCH FROM interval)/(60*60*24) AS days
    FROM job_postings_fact
)

SELECT  
    jpf.job_id,
    jpf.job_posted_date,
    dsp.days AS days_since_post,
    CASE
        WHEN dsp.days < 30 THEN 'Recent'
        ELSE 'Old'
    END AS posting_ag
FROM job_postings_fact as jpf
INNER JOIN days_since_posted AS dsp
    ON jpf.job_id = dsp.job_id

WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;
---------------------------------------------------------------
--bolje rjesenje
/*
SELECT  
    job_id,
    job_posted_date,
    DATE_DIFF('day', job_posted_date, current_date) AS days_since_posted,
    CASE
        WHEN DATE_DIFF('day', job_posted_date, current_date) < 30 THEN 'Recent'
        ELSE 'Old'
    END AS posting_age
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;
*/
---------------------------------------------------------------
/*
The business wants a unified list of job postings from two different markets: 
the United States and the United Kingdom.
Using set operations, write a query that returns the job_id and job_title_short 
for all US jobs that are remote. Then, combine that with all UK jobs that are remote. 
Remove any duplicates. Sort the final list by job_id.
*/

CREATE OR REPLACE TEMP TABLE USA AS
SELECT
    job_id,
    job_title_short
FROM job_postings_fact
WHERE 
    job_country LIKE 'United States' 
    AND job_work_from_home = TRUE;

CREATE OR REPLACE TEMP TABLE UK AS 
SELECT
    job_id,
    job_title_short
FROM job_postings_fact
WHERE 
    job_country LIKE 'United Kingdom'
    AND job_work_from_home = TRUE;

SELECT * FROM USA
UNION
SELECT * FROM UK

ORDER BY 
    job_id;

/*
The marketing team wants to find extreme outliers in the market.
First, find all skills that are only required by "Ghost" companies 
(companies that have exactly 0 job postings). Second, find all skills that are 
required by "Unicorn" companies (companies with an average salary over 200,000). 
Use EXCEPT or UNION to combine these two distinct lists. For any company name 
that is NULL, display the word 'Unknown' instead.
*/

CREATE OR REPLACE TEMP TABLE ghost_companies AS
SELECT
    CASE    
        WHEN cd.name IS NULL THEN 'Unknown'
        ELSE cd.name
    END AS company_name
FROM
    job_postings_fact AS jpf

LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id --ovo ne radi jer vucem iz jpf u kojem trebaju
                                      --podatci vec biti obradeni (svaka firma ima
                                      --svoju objavu za posao). Treba izvuci sva imena
                                      --firmi iz company_dim i onda vidjeti koje nemaju
                                      --ili imaju objavu (WHERE NOT EXISTS)

GROUP BY 
    cd.name

HAVING
    COUNT(jpf.job_id) = 0

ORDER BY
    COUNT(jpf.job_id) DESC;


CREATE OR REPLACE TEMP TABLE unicorn_companies AS
SELECT
    CASE    
        WHEN cd.name IS NULL THEN 'Unknown'
        ELSE cd.name
    END AS company_name
FROM
    job_postings_fact AS jpf

LEFT JOIN company_dim AS cd --mora biti INNER JOIN jer ne zelim firme bez objave jer je onda placa NULL
    ON jpf.company_id = cd.company_id

WHERE 
    salary_year_avg > 200000

GROUP BY    
    cd.name

ORDER BY 
    COUNT(jpf.job_id) DESC;

SELECT * FROM ghost_companies
UNION 
SELECT * FROM unicorn_companies;
------------------------------------------------------------------
CREATE OR REPLACE TEMP TABLE ghost_companies AS
SELECT
    COALESCE(cd.name, 'Unknown')
FROM company_dim AS cd
WHERE NOT EXISTS (
    SELECT 1
    FROM job_postings_fact AS jpf
    WHERE jpf.company_id = cd.company_id
);

CREATE OR REPLACE TEMP TABLE unicorn_companies AS
SELECT
    CASE    
        WHEN cd.name IS NULL THEN 'Unknown'
        ELSE cd.name
    END AS company_name
FROM
    job_postings_fact AS jpf

INNER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id

GROUP BY    
    cd.name

HAVING
    AVG(jpf.salary_year_avg) > 200000

ORDER BY 
    COUNT(jpf.job_id) DESC;

SELECT * FROM ghost_companies
UNION 
SELECT * FROM unicorn_companies;

/*
The lead architect wants to evaluate the database's schema design.

    Using the information_schema tables, write a query that counts how many Fact tables 
    and how many Dimension tables exist in the data_jobs catalog. Assume a table 
    is a Fact table if its name contains 'fact', and a Dimension table if its name 
    contains 'dim'. Output the counts as fact_table_count and dim_table_count.

    Write a second query that identifies the top 5 "central" dimension tables—those that 
    are joined to the most other tables. You can determine this by counting how many 
    times each table_name appears as a table_name in the information_schema.columns where 
    the column name ends in '_id'. Output the table name and the join count.

    Finally, write a query that compares the total number of rows in job_postings_fact 
    to the total number of rows in skills_job_dim. If the fact table has more rows, 
    output 'Star Schema'. Otherwise, output 'Snowflake Schema'.
*/

CREATE OR REPLACE TEMP TABLE counter AS
SELECT 
    CASE
        WHEN table_name LIKE '%dim%' THEN 'dim_table_count'
        WHEN table_name LIKE '%fact%' THEN 'fact_table_count'
    END AS table_categories

FROM 
    information_schema.tables

WHERE 
    table_catalog = 'data_jobs';

SELECT
    table_categories,
    COUNT(table_categories)

FROM 
    counter

GROUP BY 
    table_categories;

/*
SELECT
    COUNT(CASE WHEN table_name LIKE '%fact%' THEN 1 END) AS fact_table_count,
    COUNT(CASE WHEN table_name LIKE '%dim%' THEN 1 END) AS dimension_table_count
FROM 
    information_schema.tables
WHERE 
    table_catalog = 'data_jobs' 
    AND table_schema = 'main' 
    AND table_type = 'BASE TABLE';
*/
----------------------------------------
SELECT 
    table_name,
    COUNT(table_name),
    column_name

FROM 
    information_schema.columns

WHERE
    column_name LIKE '%_id' AND
    table_catalog = 'data_jobs' 
    AND table_schema = 'main' 

GROUP BY 
    table_name,
    column_name

ORDER BY 
    COUNT(table_name) DESC

LIMIT 5;