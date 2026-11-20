-- Step 4: DW - Create skills demand mart

DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA IF NOT EXISTS skills_mart;

CREATE TABLE IF NOT EXISTS skills_mart.dim_skill (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);
INSERT INTO skills_mart.dim_skill (
    skill_id,
    skills,
    type
)
SELECT 
    skill_id,
    skills,
    type
FROM 
    skills_dim;

CREATE TABLE IF NOT EXISTS skills_mart.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    quarter_name VARCHAR,
    year_quarter VARCHAR
);
INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name,
    CONCAT(EXTRACT(YEAR FROM job_posted_date), '-', 'Q' || EXTRACT(QUARTER FROM job_posted_date)) AS year_quarter
FROM 
    job_postings_fact
ORDER BY 
    month_start_date;

CREATE TABLE IF NOT EXISTS skills_mart.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    postings_count INTEGER,
    remote_postings_count INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_mentioned_postings_count INTEGER,
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skill(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);
INSERT INTO skills_mart.fact_skill_demand_monthly (
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_mentioned_postings_count
)
SELECT 
    sd.skill_id,
    DATE_TRUNC('month', jpf.job_posted_date)::DATE AS month_start_date,
    jpf.job_title_short,
    COUNT(jpf.job_id) AS postings_count,
    COUNT(CASE WHEN jpf.job_work_from_home = TRUE THEN 1 END) AS remote_postings_count,
    COUNT(CASE WHEN jpf.job_health_insurance = TRUE THEN 1 END) AS health_insurance_postings_count,
    COUNT(CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 END) AS no_degree_mentioned_postings_count
FROM
    job_postings_fact AS jpf
INNER JOIN 
    skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN
    skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
GROUP BY 
    sd.skill_id,
    DATE_TRUNC('month', jpf.job_posted_date)::DATE,
    jpf.job_title_short
ORDER BY
    DATE_TRUNC('month', jpf.job_posted_date)::DATE;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'skills_mart';

SELECT 'Skill Dim' AS table_name, COUNT(*) AS record_count FROM skills_mart.dim_skill
UNION ALL
SELECT 'Date Month Dim', COUNT(*) FROM skills_mart.dim_date_month
UNION ALL
SELECT 'Skill Demand Fact', COUNT(*) FROM skills_mart.fact_skill_demand_monthly;

SELECT '===Skill Dim Sample===' AS info;
SELECT * FROM skills_mart.dim_skill LIMIT 5;

SELECT '===Date Month Dim Sample===' AS info;
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT '===Skill Demand Fact Sample===' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;
