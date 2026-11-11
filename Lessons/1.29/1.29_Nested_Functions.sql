/*

Nested data is semi-structured. It can be split into arrays/lists (ordered collections of same-type values, indexed), struct/record/row (composite data type with multiple fields),
array of structs (ordered collection of struct records), map/object/dictionary (unordered collection of dynamic key-value pairs) and JSONs (text-based serialization format for nested data)

array/list

SELECT ['python', 'sql', 'r'] AS skills_array;
--------------------------------------------------
struct/record/row

SELECT {Skill:'python', level:'advanced} AS skill_struct;
--------------------------------------------------
array of structs

SELECT [{skill:'python', level:'advanced'},
        {skill:'sql', level:'expert'}] AS skills_array_of_structs;
--------------------------------------------------
map/object/dictionary

SELECT MAP (['programming', 'cloud'], [['python', 'sql'],['aws', 'gcp']]) AS skills_map;
--------------------------------------------------
JSON (commonly used for ingestions and serving)

SELECT TO_JSON ({skills:['python', 'sql'], salary:{amount:120000, currency: 'USD'}}) AS job_json;

*/
--------------------------------------------------
--Array into
--------------------------------------------------
SELECT[1,2,3] AS numbers;

WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL 
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
), skills_array AS (
    SELECT ARRAY_AGG(skill ORDER BY skill) AS skills
    FROM skills
)
SELECT 
    skills
FROM skills_array;

--example
--build a flat skill table for co-workers to access job titles, salary info and skills in one table

CREATE OR REPLACE TEMP TABLE job_skills_array AS 
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM
    job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id

GROUP BY 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg;

--analyze the median salary per skill
WITH flat_skills AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) AS SKILL
    FROM
        job_skills_array
)

SELECT
    skill,
    MEDIAN(salary_year_avg) AS median_salary
FROM
    flat_skills
GROUP BY 
    skill
ORDER BY 
    median_salary DESC;
--------------------------------------------------
--STRUCT
--------------------------------------------------
SELECT {skill:'python', type:'programming'} AS skill_struct;

WITH skill_table AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL 
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)

SELECT
    STRUCT_PACK (
        skill := skills,
        type := types
    )
FROM skill_table;
--------------------------------------------------
--Array of structs
--------------------------------------------------
SELECT [
    {skill:'python', type:'programming'},
    {skill:'sql', type:'query_language'}
] AS skills_arr_of_structs;


WITH skills_table AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL 
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
), skills_arr_struct AS (
    SELECT
        ARRAY_AGG (
            STRUCT_PACK (
                skill := skills,
                type := types
            )
        ) AS array_struct
    FROM skills_table
)
SELECT
    array_struct [1], -- accesing strucs using list indices
    array_struct [2].skill, --accesing data inside structs using data alias
    array_struct [3]
FROM 
    skills_arr_struct;

SELECT array_struct
FROM skills_arr_struct;

--example
--build a flat skill &type table for co-workers to access job titles, salary info, skills and type in one table

CREATE OR REPLACE TEMP TABLE job_skills_array_struct AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    CONCAT(jpf.salary_year_avg, (salary_hour_avg * 2080)::DECIMAL(7,1)) AS salary_year_avg,
    ARRAY_AGG (
        STRUCT_PACK (
            skill_type := sd.type,
            skill_name := sd.skills
        )
    ) AS skills_type
FROM
    job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL

GROUP BY 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_hour_avg,
    jpf.salary_year_avg;

--analyze the median per skill type

WITH flat_skills AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_type).skill_type AS skill_type,
        UNNEST(skills_type).skill_name AS skill_name,
    FROM
        job_skills_array_struct
)

SELECT
    skill_type,
    MEDIAN(salary_year_avg) AS median_salary
FROM
    flat_skills
GROUP BY 
    skill_type
ORDER BY 
    median_salary DESC;
--------------------------------------------------
--map/object/dictionary (good at storing metadata)
--------------------------------------------------
WITH skill_map AS (
    SELECT MAP (['programming', 'cloud'], [['python', 'sql'],['aws']]) AS skills_map
)
SELECT
    skills_map['programming'],
    skills_map['cloud']
FROM 
    skill_map;
--------------------------------------------------
--JSON 
--------------------------------------------------
WITH raw_skill_json AS (
    SELECT TO_JSON ({skills:['python', 'sql'], salary:{amount:120000, currency: 'USD'}}) AS job_json
)
SELECT
    STRUCT_PACK (
        skills := json_extract_string(job_json, '$.skills'),
        type := json_extract_string(job_json, '$.salary')
    )
FROM 
    raw_skill_json;

