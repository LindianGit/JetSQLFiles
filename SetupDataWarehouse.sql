USE Jet;
GO

-- Drop the stored procedure if it already exists
IF OBJECT_ID('Jet.dbo.SetupDataWarehouse', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.SetupDataWarehouse;
END;
GO

-- Create the stored procedure to set up the data warehouse
CREATE PROCEDURE  dbo.SetupDataWarehouse
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Drop staging tables if they already exist
        IF OBJECT_ID('Jet.dbo.Staging_Sales', 'U') IS NOT NULL DROP TABLE Jet.dbo.Staging_Sales;
        IF OBJECT_ID('Jet.dbo.Staging_Customers', 'U') IS NOT NULL DROP TABLE Jet.dbo.Staging_Customers;
        IF OBJECT_ID('Jet.dbo.Staging_Inventory', 'U') IS NOT NULL DROP TABLE Jet.dbo.Staging_Inventory;

        -- Drop fact table if it exists
        IF OBJECT_ID('Jet.dbo.Fact_Sales', 'U') IS NOT NULL DROP TABLE Jet.dbo.Fact_Sales;

        -- Drop dimension tables if they exist
        IF OBJECT_ID('Jet.dbo.Dim_Customers', 'U') IS NOT NULL DROP TABLE Jet.dbo.Dim_Customers;
        IF OBJECT_ID('Jet.dbo.Dim_Products', 'U') IS NOT NULL DROP TABLE Jet.dbo.Dim_Products;
        IF OBJECT_ID('Jet.dbo.Dim_Date', 'U') IS NOT NULL DROP TABLE Jet.dbo.Dim_Date;
        IF OBJECT_ID('Jet.dbo.Dim_Region', 'U') IS NOT NULL DROP TABLE Jet.dbo.Dim_Region;

        -- Create Staging Tables
        CREATE TABLE Jet.dbo.Staging_Sales (
            SaleID INT,
            CustomerID INT,
            ProductID INT,
            SaleDate DATE,
            Quantity INT,
            Amount DECIMAL(10, 2)
        );

        CREATE TABLE Jet.dbo.Staging_Customers (
            CustomerID INT,
            CustomerName NVARCHAR(100),
            Email NVARCHAR(100),
            Address NVARCHAR(200),
            Region NVARCHAR(100)
        );

        CREATE TABLE Jet.dbo.Staging_Inventory (
            ProductID INT,
            ProductName NVARCHAR(100),
            Category NVARCHAR(100),
            Price DECIMAL(10, 2),
            ProductDescription NVARCHAR(255)
        );

        -- Create Dimension Tables
        CREATE TABLE Jet.dbo.Dim_Customers (
            SurrogateKey INT IDENTITY(1,1) NOT NULL,
            CustomerID INT NULL,
            CustomerName NVARCHAR(100) NULL,
            Email NVARCHAR(100) NULL,
            Address NVARCHAR(200) NULL,
            Region NVARCHAR(100) NULL,
            StartDate DATE NULL,
            EndDate DATE NULL,
            IsCurrent BIT NULL,
            CreatedAt DATETIME DEFAULT GETDATE() NULL,
            UpdatedAt DATETIME DEFAULT GETDATE() NULL,
            PRIMARY KEY CLUSTERED (SurrogateKey ASC)
        );

        CREATE TABLE Jet.dbo.Dim_Products (
            SurrogateKey INT IDENTITY(1,1) NOT NULL,
            ProductID INT NULL,
            ProductName NVARCHAR(100) NULL,
            Category NVARCHAR(100) NULL,
            Price DECIMAL(10, 2) NULL,
            ProductDescription NVARCHAR(255) NULL,
            StartDate DATE NULL,
            EndDate DATE NULL,
            IsCurrent BIT NULL,
            CreatedAt DATETIME DEFAULT GETDATE() NULL,
            UpdatedAt DATETIME DEFAULT GETDATE() NULL,
            PRIMARY KEY CLUSTERED (SurrogateKey ASC)
        );

        CREATE TABLE Jet.dbo.Dim_Date (
            DateKey INT PRIMARY KEY,
            Date DATE,
            Year INT,
            Quarter INT,
            Month INT,
            Day INT,
            Week INT,
            DayOfWeek INT,
            IsWeekend BIT,
            CreatedAt DATETIME DEFAULT GETDATE()
        );

        CREATE TABLE Jet.dbo.Dim_Region (
            RegionKey INT IDENTITY(1,1) NOT NULL,
            Region NVARCHAR(100) NULL,
            StartDate DATE NULL,
            EndDate DATE NULL,
            IsCurrent BIT NULL,
            CreatedAt DATETIME DEFAULT GETDATE() NULL,
            UpdatedAt DATETIME DEFAULT GETDATE() NULL,
            PRIMARY KEY CLUSTERED (RegionKey ASC)
        );

        -- Create Fact Table with Foreign Key Constraints
        CREATE TABLE Jet.dbo.Fact_Sales (
            SaleID INT PRIMARY KEY,
            CustomerKey INT,
            ProductKey INT,
            DateKey INT,
            RegionKey INT,
            Quantity INT,
            Amount DECIMAL(10, 2),
            CreatedAt DATETIME DEFAULT GETDATE(),
            UpdatedAt DATETIME DEFAULT GETDATE(),
            CONSTRAINT FK_Fact_Sales_CustomerKey FOREIGN KEY (CustomerKey) REFERENCES Jet.dbo.Dim_Customers(SurrogateKey),
            CONSTRAINT FK_Fact_Sales_ProductKey FOREIGN KEY (ProductKey) REFERENCES Jet.dbo.Dim_Products(SurrogateKey),
            CONSTRAINT FK_Fact_Sales_DateKey FOREIGN KEY (DateKey) REFERENCES Jet.dbo.Dim_Date(DateKey),
            CONSTRAINT FK_Fact_Sales_RegionKey FOREIGN KEY (RegionKey) REFERENCES Jet.dbo.Dim_Region(RegionKey)
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;