USE externalDb;
GO

-- Drop the stored procedure if it already exists
IF OBJECT_ID('externalDb.dbo.LoadExternalSourceData', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE  dbo.LoadExternalSourceData;
END;
GO

-- Create the stored procedure
CREATE PROCEDURE  dbo.LoadExternalSourceData
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    -- Insert sample data into external tables
    DELETE FROM externalDb.dbo.Sales;
    DELETE FROM externalDb.dbo.Customers;
    DELETE FROM externalDb.dbo.Products;

    INSERT INTO externalDb.dbo.Sales (SaleID, CustomerID, ProductID, SaleDate, Quantity, Amount) VALUES
    (1, 101, 201, '2022-01-01', 2, 200.00),
    (2, 102, 202, '2022-01-02', 1, 150.00),
    (3, 101, 203, '2022-01-03', 3, 300.00),
    (4, 101, 203, '2022-01-02', 1, 150.00);

    INSERT INTO externalDb.dbo.Customers (CustomerID, CustomerName, Email, Address, Region) VALUES
    (101, 'John Doe', 'john@example.com', '123 Main St', 'USA'),
    (102, 'Jane Smith', 'jane@example.com', '456 Oak St', 'Germany');

    INSERT INTO externalDb.dbo.Products (ProductID, ProductName, Category, Price, ProductDescription) VALUES
    (201, 'Product A', 'Category 1', 100.00, 'Description for Product A'),
    (202, 'Product B', 'Category 2', 150.00, 'Description for Product B'),
    (203, 'Product C', 'Category 1', 100.00, 'Description for Product C');

    COMMIT TRANSACTION;
END;
GO