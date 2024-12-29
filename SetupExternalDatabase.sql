-- Drop the stored procedure if it already exists
USE externalDb;
GO
IF OBJECT_ID('externalDb.dbo.SetupExternalDatabase', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.SetupExternalDatabase;
END;
GO

-- Create the stored procedure
CREATE PROCEDURE dbo.SetupExternalDatabase
AS
BEGIN
    SET NOCOUNT ON;

    -- Ensure the externalDb database is in multi-user mode
    IF DB_ID('externalDb') IS NOT NULL
    BEGIN
        -- Set the database to single-user mode to kill all other connections
        ALTER DATABASE externalDb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

        -- Set the database to multi-user mode
        ALTER DATABASE externalDb SET MULTI_USER;
    END

    BEGIN TRANSACTION;

    -- Create external tables if they do not exist
    IF NOT EXISTS (SELECT * FROM externalDb.sys.tables WHERE name = 'Sales' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
        CREATE TABLE externalDb.dbo.Sales (   
            SaleID INT PRIMARY KEY,  
            CustomerID INT,
            ProductID INT,
            SaleDate DATE,
            Quantity INT,
            Amount DECIMAL(10, 2)
        );
        -- Add indexes if necessary
        CREATE INDEX IX_Sales_CustomerID ON externalDb.dbo.Sales(CustomerID);
        CREATE INDEX IX_Sales_ProductID ON externalDb.dbo.Sales(ProductID);
    END

    IF NOT EXISTS (SELECT * FROM externalDb.sys.tables WHERE name = 'Customers' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
        CREATE TABLE externalDb.dbo.Customers (
            CustomerID INT PRIMARY KEY,
            CustomerName NVARCHAR(100),
            Email NVARCHAR(100),
            Address NVARCHAR(200),
            Region NVARCHAR(100)
        );
        -- Add indexes if necessary
        CREATE INDEX IX_Customers_Email ON externalDb.dbo.Customers(Email);
    END

    IF NOT EXISTS (SELECT * FROM externalDb.sys.tables WHERE name = 'Products' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
        CREATE TABLE externalDb.dbo.Products (
            ProductID INT PRIMARY KEY,
            ProductName NVARCHAR(100),
            Category NVARCHAR(100),
            Price DECIMAL(10, 2),
            ProductDescription NVARCHAR(255)
        );
        -- Add indexes if necessary
        CREATE INDEX IX_Products_Category ON externalDb.dbo.Products(Category);
    END

    COMMIT TRANSACTION;
END;
GO