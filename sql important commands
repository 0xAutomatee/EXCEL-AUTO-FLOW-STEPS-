-- show all tables in the overstockDB database and then back up the database to a specified location.
USE overstockDB;

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'

-- Back up the overstockDB database to a specified location
BACKUP DATABASE overstockDB
TO DISK = 'D:\overstockDB.bak';
