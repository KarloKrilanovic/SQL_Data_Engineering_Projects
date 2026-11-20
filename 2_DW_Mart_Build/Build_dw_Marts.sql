-- duckdb dw_marts.duckdb -c ".read Build_dw_Marts.sql"

-- Step 1: DW - Create star schema tables
.read 01_Create_Tables_dw.sql

-- Step 2: DW - Load data from CSV files into tables
.read 02_Load_Schema_dw.sql

-- Step 3: DW - Create flat mart
.read 03_Create_Flat_Mart.sql

-- Step 4: DW - Create skills demand mart
.read 04_Create_Skills_Mart.sql