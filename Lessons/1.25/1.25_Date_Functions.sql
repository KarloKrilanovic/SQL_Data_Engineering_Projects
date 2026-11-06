SELECT 
    job_posted_date,
    job_posted_date::DATE AS date,
    job_posted_date::TIME AS time,
    job_posted_date::TIMESTAMP AS timestamp,
    job_posted_date::TIMESTAMPTZ AS timestamptz

FROM 
    job_postings_fact
LIMIT 10;

--EXTRACT(part FROM column_name)

SELECT
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count

FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP BY 
    EXTRACT(YEAR FROM job_posted_date),
    EXTRACT(MONTH FROM job_posted_date)
ORDER BY 
    job_posted_year,
    job_posted_month;

--DATE_TRUNC('precision', date_time), rounds down on precision
    
SELECT
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count

FROM job_postings_fact
WHERE   
    job_title_short = 'Data Engineer' AND
    EXTRACT(YEAR FROM job_posted_date) = 2024
GROUP BY
    DATE_TRUNC('month', job_posted_date)
ORDER BY
    job_posted_month;

--Timestamps without time zone are treated automatically as local time in DuckDB
--AT TIME ZONE assumes the machine's time zone for conversion. Have to specify first what the data time zone is and then say which timezone you want to get to 

SELECT
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS job_posted_hour,
    COUNT(job_id)
FROM
    job_postings_fact
WHERE
    job_location LIKE 'New York, NY'

GROUP BY
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') 
ORDER BY 
    job_posted_hour;