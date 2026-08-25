/*
*****************************
Create Database & Schema
*****************************

Objective:
Create a new database: 'Datawarehouse' after checking if it exists, If it exists drop and recreate. The script also create three schemas : bronze,silver and gold.
*/


-- Create Database 'Datawarehouse'
USE MASTER;
GO

-- Check if database exists,if it exists drop & recreate 
IF EXISTS(SELECT 1 FROM SYS.databases WHERE name = 'DataWarehouse')
BEGIN 
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create database
CREATE DATABASE DataWarehouse;

USE DataWarehouse;

-- Create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

