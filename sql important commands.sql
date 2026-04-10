-- show all tables in the overstockDB database and then back up the database to a specified location.
USE overstockDB;

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'

-- Back up the overstockDB database to a specified location
BACKUP DATABASE overstockDB
TO DISK = 'D:\overstockDB.bak';


-- Task: Remove duplicate rows from rpt_02a_cr_sheet table while ensuring data integrity.
BEGIN TRAN; --begin transaction to ensure data integrity  


-- Step 1: Keep only distinct rows in temp table
SELECT DISTINCT *
FROM rpt_02a_cr_sheet;

-- Step 2: Empty original table
TRUNCATE TABLE rpt_02a_cr_sheet; -- This is faster than DELETE and resets identity if any

-- Step 3: Insert clean data back
INSERT INTO rpt_02a_cr_sheet 
SELECT * FROM #temp_clean; -- Assuming #temp_clean is the result of Step 1

-- Step 4: Drop temp table
--DROP TABLE #temp_clean;

COMMIT; --commit transaction to save changes
