--SQL query za OOE
--nadi top 10 firmi za objavljivanje posla, moraju imati >3000 objava i gledamo samo u americi


EXPLAIN -- NE EXECUTE-a query. Za to služi EXPLAIN ANALYSE
SELECT
    cd.name AS company_name,
    COUNT(jpf.*) AS posting_count

FROM job_postings_fact AS jpf

LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id

WHERE jpf.job_country = 'United States'

GROUP BY cd.name

HAVING COUNT(jpf.job_id) > 3000

ORDER BY posting_count DESC

LIMIT 10;

EXPLAIN ANALYSE
SELECT
    cd.name AS company_name,
    COUNT(jpf.*) AS posting_count

FROM job_postings_fact AS jpf

LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id

WHERE jpf.job_country = 'United States'

GROUP BY cd.name

HAVING COUNT(jpf.job_id) > 3000

ORDER BY posting_count DESC

LIMIT 10;