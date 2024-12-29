-- Test Script for SetupExternalDatabase and LoadExternalSourceData
USE externalDB
GO

-- Step 2: Execute the SetupExternalDatabase stored procedure
EXEC externalDb.dbo.SetupExternalDatabase;
GO

-- Step 3: Verify that the tables were created
-- Check Sales table
IF NOT EXISTS (SELECT * FROM externalDb.sys.tables WHERE name = 'Sales' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Sales table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Sales table was created.';
END

-- Check Customers table
IF NOT EXISTS (SELECT * FROM externalDb.sys.tables WHERE name = 'Customers' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Customers table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Customers table was created.';
END

-- Check Products table
IF NOT EXISTS (SELECT * FROM externalDb.sys.tables WHERE name = 'Products' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Products table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Products table was created.';
END

-- Step 4: Verify that the indexes were created
-- Check indexes on Sales table
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_CustomerID' AND object_id = OBJECT_ID('externalDb.dbo.Sales'))
BEGIN
    PRINT 'Error: Index IX_Sales_CustomerID was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Index IX_Sales_CustomerID was created.';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_ProductID' AND object_id = OBJECT_ID('externalDb.dbo.Sales'))
BEGIN
    PRINT 'Error: Index IX_Sales_ProductID was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Index IX_Sales_ProductID was created.';
END

-- Check index on Customers table
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customers_Email' AND object_id = OBJECT_ID('externalDb.dbo.Customers'))
BEGIN
    PRINT 'Error: Index IX_Customers_Email was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Index IX_Customers_Email was created.';
END

-- Check index on Products table
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_Category' AND object_id = OBJECT_ID('externalDb.dbo.Products'))
BEGIN
    PRINT 'Error: Index IX_Products_Category was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Index IX_Products_Category was created.';
END

-- Step 5: Execute the LoadExternalSourceData stored procedure
EXEC externalDb.dbo.LoadExternalSourceData;
GO

-- Step 6: Verify that the data was inserted correctly
-- Check data in Sales table
IF NOT EXISTS (SELECT * FROM externalDb.dbo.Sales WHERE SaleID = 1 AND CustomerID = 101 AND ProductID = 201 AND SaleDate = '2022-01-01' AND Quantity = 2 AND Amount = 200.00)
BEGIN
    PRINT 'Error: Data was not inserted correctly into Sales table.';
END
ELSE
BEGIN
    PRINT 'Success: Data was inserted correctly into Sales table.';
END

-- Check data in Customers table
IF NOT EXISTS (SELECT * FROM externalDb.dbo.Customers WHERE CustomerID = 101 AND CustomerName = 'John Doe' AND Email = 'john@example.com' AND Address = '123 Main St' AND Region = 'USA')
BEGIN
    PRINT 'Error: Data was not inserted correctly into Customers table.';
END
ELSE
BEGIN
    PRINT 'Success: Data was inserted correctly into Customers table.';
END

-- Check data in Products table
IF NOT EXISTS (SELECT * FROM externalDb.dbo.Products WHERE ProductID = 201 AND ProductName = 'Product A' AND Category = 'Category 1' AND Price = 100.00 AND ProductDescription = 'Description for Product A')
BEGIN
    PRINT 'Error: Data was not inserted correctly into Products table.';
END
ELSE
BEGIN
    PRINT 'Success: Data was inserted correctly into Products table.';
END

-- Test Script for SetupDataWarehouse

-- Step 1: Ensure the Jet database exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Jet')
BEGIN
    CREATE DATABASE Jet;
END;
GO

USE Jet;
GO

-- Step 2: Execute the SetupDataWarehouse stored procedure
EXEC Jet.dbo.SetupDataWarehouse;
GO

-- Step 3: Verify that the staging tables were created
-- Check Staging_Sales table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Staging_Sales' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Staging_Sales table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Staging_Sales table was created.';
END

-- Check Staging_Customers table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Staging_Customers' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Staging_Customers table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Staging_Customers table was created.';
END

-- Check Staging_Inventory table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Staging_Inventory' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Staging_Inventory table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Staging_Inventory table was created.';
END

-- Step 4: Verify that the dimension tables were created
-- Check Dim_Customers table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Dim_Customers' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Dim_Customers table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Dim_Customers table was created.';
END

-- Check Dim_Products table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Dim_Products' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Dim_Products table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Dim_Products table was created.';
END

-- Check Dim_Date table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Dim_Date' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Dim_Date table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Dim_Date table was created.';
END

-- Check Dim_Region table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Dim_Region' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Dim_Region table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Dim_Region table was created.';
END

-- Step 5: Verify that the fact table was created
-- Check Fact_Sales table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Fact_Sales' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Fact_Sales table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Fact_Sales table was created.';
END

-- Step 6: Verify foreign key constraints on Fact_Sales table
-- Check foreign key constraint on CustomerKey
DECLARE @CustomerKeyConstraintExists BIT;
SELECT @CustomerKeyConstraintExists = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
FROM sys.foreign_keys
WHERE name = 'FK_Fact_Sales_CustomerKey' AND parent_object_id = OBJECT_ID('Jet.dbo.Fact_Sales');

IF @CustomerKeyConstraintExists = 1
BEGIN
    PRINT 'Success: Foreign key constraint on CustomerKey was created.';
END
ELSE
BEGIN
    PRINT 'Error: Foreign key constraint on CustomerKey was not created.';
END

-- Check foreign key constraint on ProductKey
DECLARE @ProductKeyConstraintExists BIT;
SELECT @ProductKeyConstraintExists = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
FROM sys.foreign_keys
WHERE name = 'FK_Fact_Sales_ProductKey' AND parent_object_id = OBJECT_ID('Jet.dbo.Fact_Sales');

IF @ProductKeyConstraintExists = 1
BEGIN
    PRINT 'Success: Foreign key constraint on ProductKey was created.';
END
ELSE
BEGIN
    PRINT 'Error: Foreign key constraint on ProductKey was not created.';
END

-- Check foreign key constraint on DateKey
DECLARE @DateKeyConstraintExists BIT;
SELECT @DateKeyConstraintExists = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
FROM sys.foreign_keys
WHERE name = 'FK_Fact_Sales_DateKey' AND parent_object_id = OBJECT_ID('Jet.dbo.Fact_Sales');

IF @DateKeyConstraintExists = 1
BEGIN
    PRINT 'Success: Foreign key constraint on DateKey was created.';
END
ELSE
BEGIN
    PRINT 'Error: Foreign key constraint on DateKey was not created.';
END

-- Check foreign key constraint on RegionKey
DECLARE @RegionKeyConstraintExists BIT;
SELECT @RegionKeyConstraintExists = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
FROM sys.foreign_keys
WHERE name = 'FK_Fact_Sales_RegionKey' AND parent_object_id = OBJECT_ID('Jet.dbo.Fact_Sales');

IF @RegionKeyConstraintExists = 1
BEGIN
    PRINT 'Success: Foreign key constraint on RegionKey was created.';
END
ELSE
BEGIN
    PRINT 'Error: Foreign key constraint on RegionKey was not created.';
END

-- Step 7: Verify transaction handling
-- Simulate an error to test transaction rollback
BEGIN TRY
    BEGIN TRANSACTION;

    -- Intentionally cause an error by inserting a duplicate primary key
    INSERT INTO Jet.dbo.Fact_Sales (SaleID, CustomerKey, ProductKey, DateKey, RegionKey, Quantity, Amount)
    VALUES (1, 1, 1, 1, 1, 1, 1.00);

    -- This should cause a primary key violation
    INSERT INTO Jet.dbo.Fact_Sales (SaleID, CustomerKey, ProductKey, DateKey, RegionKey, Quantity, Amount)
    VALUES (1, 1, 1, 1, 1, 1, 1.00);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back successfully due to error.';
END CATCH
GO

-- Test Script for LoadStagingArea

-- Step 1: Ensure the Jet database exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Jet')
BEGIN
    CREATE DATABASE Jet;
END;
GO

USE Jet;
GO

-- Step 2: Execute the LoadStagingArea stored procedure
EXEC Jet.dbo.LoadStagingArea;
GO

-- Step 3: Verify that the staging tables were created
-- Check Staging_Sales table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Staging_Sales' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Staging_Sales table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Staging_Sales table was created.';
END

-- Check Staging_Customers table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Staging_Customers' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Staging_Customers table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Staging_Customers table was created.';
END

-- Check Staging_Inventory table
IF NOT EXISTS (SELECT * FROM Jet.sys.tables WHERE name = 'Staging_Inventory' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Error: Staging_Inventory table was not created.';
END
ELSE
BEGIN
    PRINT 'Success: Staging_Inventory table was created.';
END


-- Step 5: Verify that data is loaded into the staging tables
-- Check data in Staging_Sales table
IF NOT EXISTS (SELECT * FROM Jet.dbo.Staging_Sales)
BEGIN
    PRINT 'Error: Data was not loaded into Staging_Sales table.';
END
ELSE
BEGIN
    PRINT 'Success: Data was loaded into Staging_Sales table.';
END

-- Check data in Staging_Customers table
IF NOT EXISTS (SELECT * FROM Jet.dbo.Staging_Customers)
BEGIN
    PRINT 'Error: Data was not loaded into Staging_Customers table.';
END
ELSE
BEGIN
    PRINT 'Success: Data was loaded into Staging_Customers table.';
END

-- Check data in Staging_Inventory table
IF NOT EXISTS (SELECT * FROM Jet.dbo.Staging_Inventory)
BEGIN
    PRINT 'Error: Data was not loaded into Staging_Inventory table.';
END
ELSE
BEGIN
    PRINT 'Success: Data was loaded into Staging_Inventory table.';
END

-- Step 6: Verify transaction handling
-- Simulate an error to test transaction rollback
BEGIN TRY
    BEGIN TRANSACTION;

    -- Intentionally cause an error by inserting a duplicate primary key
    INSERT INTO Jet.dbo.Staging_Sales (SaleID, CustomerID, ProductID, SaleDate, Quantity, Amount)
    VALUES (1, 1, 1, '2022-01-01', 1, 1.00);

    -- This should cause a primary key violation
    INSERT INTO Jet.dbo.Staging_Sales (SaleID, CustomerID, ProductID, SaleDate, Quantity, Amount)
    VALUES (1, 1, 1, '2022-01-01', 1, 1.00);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back successfully due to error.';
END CATCH
GO

-- Test Script for LoadDataWarehouse



-- Step 4: Verify initial data load in Dim_Customers
SELECT * FROM Jet.dbo.Dim_Customers;

-- Verify initial data load in Dim_Products
SELECT * FROM Jet.dbo.Dim_Products;

-- Verify initial data load in Dim_Region
SELECT * FROM Jet.dbo.Dim_Region;

-- Verify initial data load in Fact_Sales
SELECT * FROM Jet.dbo.Fact_Sales;

-- Test 1: Verify SCD Type 2 Update for Customers
-- Update a customer in the staging table
UPDATE Jet.dbo.Staging_Customers
SET CustomerName = 'John Doe Updated', Email = 'john.updated@example.com'
WHERE CustomerID = 101;

-- Run the LoadDataWarehouse procedure
EXEC Jet.dbo.LoadDataWarehouse;

-- Verify that the old customer record is updated with EndDate and IsCurrent = 0
SELECT * FROM Jet.dbo.Dim_Customers WHERE CustomerID = 101 AND IsCurrent = 0;

-- Verify that a new customer record is inserted with IsCurrent = 1
SELECT * FROM Jet.dbo.Dim_Customers WHERE CustomerID = 101 AND IsCurrent = 1;

-- Test 2: Verify SCD Type 2 Update for Products
-- Update a product in the staging table
UPDATE Jet.dbo.Staging_Inventory
SET ProductName = 'Product A Updated', Price = 120.00
WHERE ProductID = 201;

-- Run the LoadDataWarehouse procedure
EXEC Jet.dbo.LoadDataWarehouse;

-- Verify that the old product record is updated with EndDate and IsCurrent = 0
SELECT * FROM Jet.dbo.Dim_Products WHERE ProductID = 201 AND IsCurrent = 0;

-- Verify that a new product record is inserted with IsCurrent = 1
SELECT * FROM Jet.dbo.Dim_Products WHERE ProductID = 201 AND IsCurrent = 1;

-- Test 3: Verify SCD Type 2 Update for Regions
-- Update a region in the staging table
UPDATE Jet.dbo.Staging_Customers
SET Region = 'Canada'
WHERE CustomerID = 102;

-- Run the LoadDataWarehouse procedure
EXEC Jet.dbo.LoadDataWarehouse;

-- Verify that the old region record is updated with EndDate and IsCurrent = 0
SELECT * FROM Jet.dbo.Dim_Region WHERE Region = 'Germany' AND IsCurrent = 0;

-- Verify that a new region record is inserted with IsCurrent = 1
SELECT * FROM Jet.dbo.Dim_Region WHERE Region = 'Canada' AND IsCurrent = 1;

-- Test 4: Verify Fact Table Load
-- Verify that the fact table is loaded correctly
SELECT * FROM Jet.dbo.Fact_Sales;

-- Test 5: Verify Sales by Customer
-- Verify sales by customer
SELECT dc.CustomerName, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Customers dc ON fs.CustomerKey = dc.SurrogateKey
GROUP BY dc.CustomerName;

-- Test 6: Verify Sales by Product
-- Verify sales by product
SELECT dp.ProductName, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Products dp ON fs.ProductKey = dp.SurrogateKey
GROUP BY dp.ProductName;

-- Test 7: Verify Sales by Region
-- Verify sales by region
SELECT dr.Region, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Region dr ON fs.RegionKey = dr.RegionKey
GROUP BY dr.Region;

-- Test 8: Verify Sales by Date
-- Verify sales by date
SELECT dd.Date, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Date dd ON fs.DateKey = dd.DateKey
GROUP BY dd.Date;

-- Test 9: Verify Sales by Customer and Product
-- Verify sales by customer and product
SELECT dc.CustomerName, dp.ProductName, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Customers dc ON fs.CustomerKey = dc.SurrogateKey
JOIN Jet.dbo.Dim_Products dp ON fs.ProductKey = dp.SurrogateKey
GROUP BY dc.CustomerName, dp.ProductName;

-- Test 10: Add a new customer without any sales
-- Insert a new customer into the staging table
INSERT INTO Jet.dbo.Staging_Customers (CustomerID, CustomerName, Email, Address, Region)
VALUES (103, 'Alice Johnson', 'alice@example.com', '789 Pine St', 'Canada');
GO

-- Run the LoadDataWarehouse procedure
EXEC Jet.dbo.LoadDataWarehouse;

-- Customers without Sales.
-- Determine customers without sales
SELECT dc.CustomerID, dc.CustomerName, dc.Email, dc.Address, dc.Region
FROM Jet.dbo.Dim_Customers dc
LEFT JOIN Jet.dbo.Fact_Sales fs ON dc.SurrogateKey = fs.CustomerKey
WHERE fs.CustomerKey IS NULL;

-- Verify that the new customer is added to Dim_Customers
SELECT * FROM Jet.dbo.Dim_Customers WHERE CustomerID = 103;

-- Test 11: Add a sale for the new customer
-- Insert a new sale into the staging table
INSERT INTO Jet.dbo.Staging_Sales (SaleID, CustomerID, ProductID, SaleDate, Quantity, Amount)
VALUES (5, 103, 203, '2022-01-03', 1, 100.00);
GO

-- Run the LoadDataWarehouse procedure
EXEC Jet.dbo.LoadDataWarehouse;

-- Verify that the sale is added to Fact_Sales
SELECT * FROM Jet.dbo.Fact_Sales WHERE SaleID = 5;

-- Test 12: Add a new customer and sale
-- Insert a new customer into the staging table
INSERT INTO Jet.dbo.Staging_Customers (CustomerID, CustomerName, Email, Address, Region)
VALUES (104, 'Bob Martin', 'bob.martin@example.com', '101 Maple St', 'UK');
GO

-- Insert a new sale into the staging table
INSERT INTO Jet.dbo.Staging_Sales (SaleID, CustomerID, ProductID, SaleDate, Quantity, Amount)
VALUES (6, 104, 204, '2022-01-04', 2, 200.00);
GO

-- Run the LoadDataWarehouse procedure
EXEC Jet.dbo.LoadDataWarehouse;

-- Verify that the new customer and sale are added
SELECT * FROM Jet.dbo.Dim_Customers WHERE CustomerID = 104;
SELECT * FROM Jet.dbo.Fact_Sales WHERE SaleID = 6;

-- Additional Tests

-- Test 13: Verify SCD Type 2 Update for Multiple Customers
-- Update multiple customers in the staging table
UPDATE Jet.dbo.Staging_Customers
SET CustomerName = 'Jane Smith Updated', Email = 'jane.updated@example.com'
WHERE CustomerID = 102;

UPDATE Jet.dbo.Staging_Customers
SET CustomerName = 'Alice Johnson Updated', Email = 'alice.updated@example.com'
WHERE CustomerID = 103;

-- Run the LoadDataWarehouse procedure
EXEC Jet.dbo.LoadDataWarehouse;

-- Verify that the old customer records are updated with EndDate and IsCurrent = 0
SELECT * FROM Jet.dbo.Dim_Customers WHERE CustomerID IN (102, 103) AND IsCurrent = 0;

-- Verify that new customer records are inserted with IsCurrent = 1
SELECT * FROM Jet.dbo.Dim_Customers WHERE CustomerID IN (102, 103) AND IsCurrent = 1;

-- Test 14: Verify SCD Type 2 Update for Multiple Products
-- Update multiple products in the staging table
UPDATE Jet.dbo.Staging_Inventory
SET ProductName = 'Product B Updated', Price = 160.00
WHERE ProductID = 202;

UPDATE Jet.dbo.Staging_Inventory
SET ProductName = 'Product C Updated', Price = 110.00
WHERE ProductID = 203;

-- Run the LoadDataWarehouse procedure
EXEC Jet.dbo.LoadDataWarehouse;

-- Verify that the old product records are updated with EndDate and IsCurrent = 0
SELECT * FROM Jet.dbo.Dim_Products WHERE ProductID IN (202, 203) AND IsCurrent = 0;

-- Verify that new product records are inserted with IsCurrent = 1
SELECT * FROM Jet.dbo.Dim_Products WHERE ProductID IN (202, 203) AND IsCurrent = 1;

-- Test 15: Verify SCD Type 2 Update for Multiple Regions
-- Update multiple regions in the staging table
UPDATE Jet.dbo.Staging_Customers
SET Region = 'Australia'
WHERE CustomerID = 101;

UPDATE Jet.dbo.Staging_Customers
SET Region = 'New Zealand'
WHERE CustomerID = 104;

-- Run the LoadDataWarehouse procedure
EXEC Jet.dbo.LoadDataWarehouse;

SELECT * FROM Jet.dbo.Dim_Customers

-- Verify that the old region records are updated with EndDate and IsCurrent = 0
SELECT * FROM Jet.dbo.Dim_Region WHERE Region IN ('USA', 'UK') AND IsCurrent = 0;

-- Verify that new region records are inserted with IsCurrent = 1
SELECT * FROM Jet.dbo.Dim_Region WHERE Region IN ('Australia', 'New Zealand') AND IsCurrent = 1;

-- Test 16: Verify Fact Table Load with Multiple Updates
-- Verify that the fact table is loaded correctly after multiple updates
SELECT * FROM Jet.dbo.Fact_Sales;

-- Test 17: Verify Sales by Customer after Multiple Updates
-- Verify sales by customer after multiple updates
SELECT dc.CustomerName, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Customers dc ON fs.CustomerKey = dc.SurrogateKey
GROUP BY dc.CustomerName;

-- Test 18: Verify Sales by Product after Multiple Updates
-- Verify sales by product after multiple updates
SELECT dp.ProductName, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Products dp ON fs.ProductKey = dp.SurrogateKey
GROUP BY dp.ProductName;

-- Test 19: Verify Sales by Region after Multiple Updates
-- Verify sales by region after multiple updates
SELECT dr.Region, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Region dr ON fs.RegionKey = dr.RegionKey
GROUP BY dr.Region;

-- Test 20: Verify Sales by Date after Multiple Updates
-- Verify sales by date after multiple updates
SELECT dd.Date, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Date dd ON fs.DateKey = dd.DateKey
GROUP BY dd.Date;

-- Test 21: Verify Sales by Customer and Product after Multiple Updates
-- Verify sales by customer and product after multiple updates
SELECT dc.CustomerName, dp.ProductName, SUM(fs.Amount) AS TotalSales
FROM Jet.dbo.Fact_Sales fs
JOIN Jet.dbo.Dim_Customers dc ON fs.CustomerKey = dc.SurrogateKey
JOIN Jet.dbo.Dim_Products dp ON fs.ProductKey = dp.SurrogateKey
GROUP BY dc.CustomerName, dp.ProductName;