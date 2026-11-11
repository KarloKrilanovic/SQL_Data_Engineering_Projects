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