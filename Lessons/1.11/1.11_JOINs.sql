SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    cd.company_id,
    jpf.job_location
FROM
    job_postings_fact AS jpf

LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
LIMIT 10;

SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    cd.company_id,
    jpf.job_location
FROM
    job_postings_fact AS jpf

LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id;


--RIGHT JOIN je više manje isto kao i left join, ali radi u drugom smjeru i sprema sve podatke iz desne tablice umjesto sve podatke iz lijeve.

 SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    cd.company_id,
    jpf.job_location
FROM
    job_postings_fact AS jpf

RIGHT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id


--INNER JOIN vraća redove kad postoji presjek između tablica. INNER JOIN se može napisati samo kao JOIN. Vraća redove samo kada postoji match za redove, nema NULL vrijednosti.

 SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    cd.company_id,
    jpf.job_location
FROM
    job_postings_fact AS jpf

INNER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
LIMIT 10;

--FULL OUTTER JOIN. Unija skupova. može se pisati i FULL JOIN.

 SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    cd.company_id,
    jpf.job_location
FROM
    job_postings_fact AS jpf

FULL OUTER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
LIMIT 10;

--SKILL JOIN za ERD diagram

 SELECT *
 FROM skills_job_dim
 LIMIT 10;

 SELECT *
 FROM skills_dim
 LIMIT 10;

 SELECT 
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills
 FROM 
    job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id

LIMIT 10;


--inner join

 SELECT *
 FROM skills_job_dim
 LIMIT 10;

 SELECT *
 FROM skills_dim
 LIMIT 10;

 SELECT 
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills
 FROM 
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd 
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id;
