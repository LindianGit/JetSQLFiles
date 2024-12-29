USE Jet;
GO

-- Drop the stored procedure if it already exists
IF OBJECT_ID('Jet.dbo.LoadStagingArea', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE  dbo.LoadStagingArea;
END;
GO

-- Create the stored procedure to load the staging area
CREATE PROCEDURE  dbo.LoadStagingArea
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        ---- Ensure the externalDb database is in multi-user mode
        --IF DB_ID('Jet') IS NOT NULL
        --BEGIN
        --    ALTER DATABASE Jet SET MULTI_USER WITH ROLLBACK IMMEDIATE;
        --END

        -- Create staging tables if they do not exist
        IF OBJECT_ID('Jet.dbo.Staging_Sales', 'U') IS NULL
        BEGIN
            CREATE TABLE Jet.dbo.Staging_Sales (
                SaleID INT,
                CustomerID INT,
                ProductID INT,
                SaleDate DATE,
                Quantity INT,
                Amount DECIMAL(10, 2)
            );
        END

        IF OBJECT_ID('Jet.dbo.Staging_Customers', 'U') IS NULL
        BEGIN
            CREATE TABLE Jet.dbo.Staging_Customers (
                CustomerID INT,
                CustomerName NVARCHAR(100),
                Email NVARCHAR(100),
                Address NVARCHAR(200),
                Region NVARCHAR(100)
            );
        END

        IF OBJECT_ID('Jet.dbo.Staging_Inventory', 'U') IS NULL
        BEGIN
            CREATE TABLE Jet.dbo.Staging_Inventory (
                ProductID INT,
                ProductName NVARCHAR(100),
                Category NVARCHAR(100),
                Price DECIMAL(10, 2),
                ProductDescription NVARCHAR(255)
            );
        END

        -- Truncate staging tables before loading new data
        TRUNCATE TABLE Jet.dbo.Staging_Sales;
        TRUNCATE TABLE Jet.dbo.Staging_Customers;
        TRUNCATE TABLE Jet.dbo.Staging_Inventory;

        -- Load Staging Tables
        -- Load Sales Data from externalDb
        INSERT INTO Jet.dbo.Staging_Sales (SaleID, CustomerID, ProductID, SaleDate, Quantity, Amount)
        SELECT SaleID, CustomerID, ProductID, SaleDate, Quantity, Amount FROM externalDb.dbo.Sales;

        -- Load Customer Data from externalDb
        INSERT INTO Jet.dbo.Staging_Customers (CustomerID, CustomerName, Email, Address, Region)  
        SELECT CustomerID, CustomerName, Email, Address, Region FROM externalDb.dbo.Customers;

        -- Load Inventory Data from CSV
        BULK INSERT Jet.dbo.Staging_Inventory
        FROM 'C:\Users\thoma\OneDrive\Documents\inventory.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            FIRSTROW = 2,
            TABLOCK,
            BATCHSIZE = 10000
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO