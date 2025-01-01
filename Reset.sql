-- Reset DWH for case Study. January 2025. 2025 will be a good year for me. 

-- Check if externalDB exists, if not create it
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'externalDB')
BEGIN
    CREATE DATABASE externalDB;
END;
GO

-- Check if Jet exists, if not create it
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Jet')
BEGIN
    CREATE DATABASE Jet;
END;
GO

-- Use externalDB and execute setup and load procedures
USE externalDB;
GO
EXEC dbo.SetupExternalDatabase;
EXEC dbo.LoadExternalSourceData;
GO

-- Use Jet and execute setup and load procedures
USE Jet;
GO
EXEC dbo.SetupDataWarehouse;
EXEC dbo.LoadStagingArea;
EXEC dbo.LoadDataWarehouse;
GO
