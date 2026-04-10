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









-- This script cleans specified tables by removing duplicate rows while preserving the original structure and identity columns if present.

BEGIN TRAN;

DECLARE @table SYSNAME; -- Declare a variable to hold the current table name
DECLARE @sql NVARCHAR(MAX);-- Declare a variable to hold the dynamic SQL statement
DECLARE @cols NVARCHAR(MAX); -- Declare a variable to hold the comma-separated list of columns for the current table
DECLARE @identity_col SYSNAME; -- Declare a variable to hold the name of the identity column, if it exists

DECLARE table_cursor CURSOR FOR -- Define a cursor to iterate over the specified list of tables
SELECT name -- Get the names of the tables to clean from the sys.tables system catalog view
FROM sys.tables -- Filter to include only the specified tables
WHERE name IN (
    'rpt_02a_cr_sheet',
    'rpt_02b_in_sheet',
    'rpt_02c_db_sheet',
    'upload_batches',
    'step_03_payments_combined',
    'raw_rows',
    'combine_rows',
    'generated_files',
    'workbook_cells',
    'master_rows',
    'step_01_inquiry',
    'step_02_combine_invoice',
    'step_02_farooq',
    'step_02_po_details'
);

OPEN table_cursor;
FETCH NEXT FROM table_cursor INTO @table;

WHILE @@FETCH_STATUS = 0 -- Loop through each table fetched by the cursor
BEGIN
    PRINT 'Cleaning table: ' + @table;

    -- ✅ FIXED COLUMN LIST
    SELECT @cols = STRING_AGG(QUOTENAME(name), ', ')
                  WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns
    WHERE object_id = OBJECT_ID(@table);

    -- Identity column check
    SELECT @identity_col = name
    FROM sys.columns
    WHERE object_id = OBJECT_ID(@table)
      AND is_identity = 1;

    SET @sql = '
    SELECT DISTINCT ' + @cols + '
    INTO #temp_clean
    FROM ' + QUOTENAME(@table) + ';

    DELETE FROM ' + QUOTENAME(@table) + ';

    ' + CASE 
        WHEN @identity_col IS NOT NULL 
        THEN 'SET IDENTITY_INSERT ' + QUOTENAME(@table) + ' ON;' 
        ELSE '' 
    END + '

    INSERT INTO ' + QUOTENAME(@table) + ' (' + @cols + ')
    SELECT ' + @cols + ' FROM #temp_clean;

    ' + CASE 
        WHEN @identity_col IS NOT NULL 
        THEN 'SET IDENTITY_INSERT ' + QUOTENAME(@table) + ' OFF;' 
        ELSE '' 
    END + '

    DROP TABLE #temp_clean;
    ';

    EXEC sp_executesql @sql;

    FETCH NEXT FROM table_cursor INTO @table;
END

CLOSE table_cursor;
DEALLOCATE table_cursor;

COMMIT;
