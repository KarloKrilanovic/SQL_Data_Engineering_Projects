# Exploratory Data Analysis w/ SQL: Job Market Analysis

![Project 1 Overview](../Images/1_1_Project1_EDA.png)

An SQL project analyzing the data engineer job market using real world job posting data, **demonstrating my ability to write production-quality analytical SQL, design efficient queries and answer business questions through data analysis.**

## Executive Summary

- **Project scope:** Create 3 analytical queries (listed below) to answer some questions about the data engineer job market
- **Data modeling:** Using multi-table joins across fact and dimension tables to extract information
- **Analytics:** Applied aggregations, filtering and sorting for query creation

[Top Demanded Skills Query](01_top_demanded_skills.sql)\
[Top Paying Skills Query](02_top_paying_skills.sql)\
[Top Optimal Skills Query](03_top_optimal_skills.sql)

## Problem & Context

While writing my master's degree and searching for a job, I thought I might brush up on my data engineering skills and try to answer some questions about the job market I had. Specifically, what might be useful skills for me to learn while transitioning from college to a real world working environment. This project analyzes a **data warehouse** built using a star schema design. The entity relationship diagram (ERD), shown below, illustrates the structure of the warehouse:

![Entity relationship diagram, ERD](../Images/1_2_Data_Warehouse.png)

- **Fact Table:** `job_postings_fact` - The central table containing all the job posting details such as location, titles, salaries, etc.
- **Dimension Tables:**\
&nbsp;&nbsp;- `company_dim` - Company information linked to job postings\
&nbsp;&nbsp;- `skills_dim` - Catalog of skills with name and type
- **Bridge Table:** `skills_job_dim` - Used to resolve the many-to-many relationship between job postings and skills

## Tech Stack

- **Query Engine:** DuckDB for fast online analytical processing (OLAP) workloads
- **Language:** SQL (ANSI-style)
- **Data Model:** Star schema with fact, dimension and bridge tables
- **Development** VS Code for SQL editing + Terminal for DuckDB CLI
- **Version Control:** Git/GitHub for versioned SQL scripts

## Analysis Overview

### Query Structure

1. [Top Demanded Skills](01_top_demanded_skills.sql) - Identifies the 10 most in-demand skills for remote data engineer positions\
2. [Top Paying Skills](02_top_paying_skills.sql) - Analyzes the 25 highest-paying skills with regards to salary and demand\
3. [Top Optimal Skills](03_top_optimal_skills.sql) - Introduces the concept of "optimal score" to allow deeper insight into useful skills by combining the salary and demand variables into one

### Key Insights

- SQL and Python each appear in ~29,000 job postings, making them essential tools for working in data engineering
-  Cloud platforms like AWS and Azure are runners up in demand, being critical for modern data engineering roles
- Terraform stands out as the skill with the highest optimal score despite having a relatively low demand compared to other skills in the top 5
- Apache Spark, used to distribute workloads across many computers at once, shows up as the number one big data tool with a balanced demand and salary 
- For monitoring, scheduling and programmatically authoring workflows, Airflow stands out among similar tools.

## SQL Skills Demonstrated

### Query Design & Optimization

- **Complex Joins:** Multi-table `INNER JOIN` operations across `job_postings_fact`, `skills_job_dim`, and `skills_dim`
- **Aggregations:** `COUNT()`, `MEDIAN()`, `ROUND()` for statistical analysis
- **Filtering:** Boolean logic with `WHERE` clauses and multiple conditions (`job_title_short`, `job_work_from_home`, `salary_year_avg IS NOT NULL`)
- **Sorting & Limiting:** `ORDER BY` with `DESC` and `LIMIT` for top-N analysis

### Data Analysis Techniques

- **Grouping:** `GROUP BY` for categorical analysis by skill
- **Mathematical Functions:** `LN()` for natural logarithm transformation to normalize demand metrics
- **Calculated Metrics:** Derived optimal score combining log-transformed demand with median salary
- **HAVING Clause:** Filtering aggregated results (skills with >= 100 postings)
- **NULL Handling:** Proper filtering of incomplete records (`salary_year_avg IS NOT NULL`)
