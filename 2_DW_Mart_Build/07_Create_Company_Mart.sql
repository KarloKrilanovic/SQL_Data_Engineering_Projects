-- Step 7: Mart - Create company mart

DROP SCHEMA  IF EXISTS company_mart CASCADE;

CREATE SCHEMA company_mart;

SELECT '===Creating Tables for Company Mart===' AS info;

CREATE TABLE company_mart.dim_job_title_short (
    job_title_short_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR
);
INSERT INTO company_mart.dim_job_title_short (
    job_title_short_id,
    job_title_short
)

SELECT
    ROW_NUMBER () OVER () AS job_title_short_id,
    jpf.job_title_short
FROM 
    job_postings_fact AS jpf
GROUP BY
    jpf.job_title_short;
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
CREATE TABLE company_mart.dim_job_title (
    job_title_id INTEGER PRIMARY KEY,
    job_title VARCHAR
);
INSERT INTO company_mart.dim_job_title (
    job_title_id,
    job_title
)

SELECT 
    ROW_NUMBER () OVER () AS job_title_id,
    jpf.job_title
FROM 
    job_postings_fact AS jpf
GROUP BY    
    jpf.job_title;
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
CREATE TABLE company_mart.bridge_job_title (
    job_title_short_id INTEGER,
    job_title_id INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id) REFERENCES company_mart.dim_job_title(job_title_id)
);
INSERT INTO company_mart.bridge_job_title (
    job_title_short_id,
    job_title_id
)

SELECT DISTINCT
    djts.job_title_short_id,
    djt.job_title_id
FROM
    job_postings_fact AS jpf
INNER JOIN 
    company_mart.dim_job_title_short AS djts
    ON jpf.job_title_short = djts.job_title_short
INNER JOIN 
    company_mart.dim_job_title AS djt
    ON jpf.job_title = djt.job_title
WHERE jpf.job_title_short IS NOT NULL
    AND jpf.job_title IS NOT NULL;
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
CREATE TABLE company_mart.dim_company (
    company_id INTEGER PRIMARY KEY,
    company_name VARCHAR
);
INSERT INTO company_mart.dim_company (
    company_id,
    company_name
)

SELECT
    cd.company_id,
    cd.name
FROM
    company_dim AS cd;
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
CREATE TABLE company_mart.dim_location (
    location_id INTEGER PRIMARY KEY,
    job_country VARCHAR,
    job_location VARCHAR
);
INSERT INTO company_mart.dim_location (
    location_id,
    job_country,
    job_location
)

SELECT
    ROW_NUMBER () OVER (),
    REGEXP_REPLACE(jpf.job_location, ' \(\+.*\)', '') AS job_location,
    jpf.job_country
FROM
    job_postings_fact AS jpf
WHERE 
    jpf.job_location IS NOT NULL 
    AND jpf.job_country IS NOT NULL
GROUP BY 
    REGEXP_REPLACE(jpf.job_location, ' \(\+.*\)', ''),
    jpf.job_country;
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
CREATE TABLE company_mart.bridge_company_location (
    company_id INTEGER,
    location_id INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_mart.dim_location(location_id)
);
INSERT INTO company_mart.bridge_company_location (
    company_id,
    location_id
)

SELECT DISTINCT
    dc.company_id,
    dl.location_id
FROM
    job_postings_fact AS jpf
INNER JOIN company_mart.dim_company AS dc
    ON jpf.company_id = dc.company_id
INNER JOIN company_mart.dim_location AS dl
    ON jpf.job_location = dl.job_location
    AND jpf.job_country = dl.job_country;
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
CREATE TABLE company_mart.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    YEAR INTEGER,
    MONTH INTEGER
);
INSERT INTO company_mart.dim_date_month (
    month_start_date,
    year,
    month
)
SELECT DISTINCT
    DATE_TRUNC('month', jpf.job_posted_date)::DATE AS month_start_date,
    EXTRACT(YEAR FROM jpf.job_posted_date) AS year,
    EXTRACT(MONTH FROM jpf.job_posted_date) AS month
FROM
    job_postings_fact AS jpf;
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
CREATE TABLE company_mart.fact_company_hiring_monthly (
    company_id INTEGER,
    job_title_short_id INTEGER,
    month_start_date DATE,
    job_country VARCHAR,
    postings_count INTEGER,
    median_salary_year DOUBLE,
    min_salary_year DOUBLE,
    max_salary_year DOUBLE,
    remote_share DOUBLE,
    health_insurance_share DOUBLE,
    no_degree_mentioned_share DOUBLE,
    PRIMARY KEY (company_id, job_title_short_id, month_start_date, job_country),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (month_start_date) REFERENCES company_mart.dim_date_month(month_start_date)
);
INSERT INTO company_mart.fact_company_hiring_monthly (
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    postings_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mentioned_share
)
WITH preparation AS (
    SELECT
        jpf.company_id,
        djs.job_title_short_id,
        jpf.job_country,
        DATE_TRUNC('month', jpf.job_posted_date)::DATE AS month_start_date,
        jpf.salary_year_avg,
        -- Convert boolean flags to numeric values (1.0 or 0.0)
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1.0 ELSE 0.0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1.0 ELSE 0.0 END AS has_health_insurance,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1.0 ELSE 0.0 END AS no_degree_required
    FROM
        job_postings_fact jpf
    INNER JOIN company_mart.dim_job_title_short djs 
        ON jpf.job_title_short = djs.job_title_short
    WHERE
        jpf.company_id IS NOT NULL
        AND jpf.job_posted_date IS NOT NULL
        AND jpf.job_country IS NOT NULL
)
SELECT 
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    COUNT(*) AS postings_count,
    MEDIAN(salary_year_avg) AS median_salary_year,
    MIN(salary_year_avg) AS min_salary_year,
    MAX(salary_year_avg) AS max_salary_year,
    AVG(is_remote) AS remote_share,
    AVG(has_health_insurance) AS health_insurance_share,
    AVG(no_degree_required) AS no_degree_mentioned_share
FROM 
    preparation
GROUP BY
    company_id,
    job_title_short_id,
    month_start_date,
    job_country;


SELECT *
FROM company_mart.fact_company_hiring_monthly
LIMIT 10;