USE Jet;
GO

-- Drop the stored procedure if it already exists
IF OBJECT_ID('LoadDataWarehouse', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE LoadDataWarehouse;
END;
GO

-- Create the stored procedure to load the data warehouse
CREATE PROCEDURE LoadDataWarehouse
AS
BEGIN
    SET NOCOUNT ON;

    -- Load Dim_Date
    DECLARE @StartDate DATE = '2022-01-01';
    DECLARE @EndDate DATE = '2024-12-31';

    IF NOT EXISTS (SELECT 1 FROM Dim_Date)
    BEGIN
        WITH DateRange AS (
            SELECT @StartDate AS Date
            UNION ALL
            SELECT DATEADD(DAY, 1, Date)
            FROM DateRange
            WHERE DATEADD(DAY, 1, Date) <= @EndDate
        )
        INSERT INTO Dim_Date (DateKey, Date, Year, Quarter, Month, Day, Week, DayOfWeek, IsWeekend)
        SELECT
            CONVERT(INT, CONVERT(VARCHAR, Date, 112)) AS DateKey,
            Date,
            YEAR(Date) AS Year,
            DATEPART(QUARTER, Date) AS Quarter,
            MONTH(Date) AS Month,
            DAY(Date) AS Day,
            DATEPART(WEEK, Date) AS Week,
            DATEPART(WEEKDAY, Date) AS DayOfWeek,
            CASE WHEN DATEPART(WEEKDAY, Date) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
        FROM DateRange
        OPTION (MAXRECURSION 0);
    END

    -- Load Dim_Customers with SCD Type 2
    -- Update existing records to set IsCurrent to 0 and set EndDate
    UPDATE jet.dbo.Dim_Customers
    SET
        EndDate = GETDATE(),
        IsCurrent = 0,
        UpdatedAt = GETDATE()
    FROM jet.dbo.Dim_Customers AS target
    JOIN jet.dbo.Staging_Customers AS source
    ON target.CustomerID = source.CustomerID AND target.IsCurrent = 1
    WHERE
        target.CustomerName != source.CustomerName OR
        target.Email != source.Email OR
        target.Address != source.Address OR
        target.Region != source.Region;

    -- Insert new records
    INSERT INTO jet.dbo.Dim_Customers (CustomerID, CustomerName, Email, Address, Region, StartDate, EndDate, IsCurrent, CreatedAt, UpdatedAt)
    SELECT source.CustomerID, source.CustomerName, source.Email, source.Address, source.Region, GETDATE(), NULL, 1, GETDATE(), GETDATE()
    FROM jet.dbo.Staging_Customers AS source
    LEFT JOIN jet.dbo.Dim_Customers AS target
    ON target.CustomerID = source.CustomerID AND target.IsCurrent = 1
    WHERE
        target.CustomerID IS NULL OR
        (target.CustomerName != source.CustomerName OR
        target.Email != source.Email OR
        target.Address != source.Address OR
        target.Region != source.Region);

    -- Load Dim_Products with SCD Type 2
    -- Update existing records to set IsCurrent to 0 and set EndDate
    UPDATE jet.dbo.Dim_Products
    SET
        EndDate = GETDATE(),
        IsCurrent = 0,
        UpdatedAt = GETDATE()
    FROM jet.dbo.Dim_Products AS target
    JOIN jet.dbo.Staging_Inventory AS source
    ON target.ProductID = source.ProductID AND target.IsCurrent = 1
    WHERE
        target.ProductName != source.ProductName OR
        target.Category != source.Category OR
        target.Price != source.Price OR
        target.ProductDescription != source.ProductDescription;

    -- Insert new records
    INSERT INTO jet.dbo.Dim_Products (ProductID, ProductName, Category, Price, ProductDescription, StartDate, EndDate, IsCurrent, CreatedAt, UpdatedAt)
    SELECT source.ProductID, source.ProductName, source.Category, source.Price, source.ProductDescription, GETDATE(), NULL, 1, GETDATE(), GETDATE()
    FROM jet.dbo.Staging_Inventory AS source
    LEFT JOIN jet.dbo.Dim_Products AS target
    ON target.ProductID = source.ProductID AND target.IsCurrent = 1
    WHERE
        target.ProductID IS NULL OR
        (target.ProductName != source.ProductName OR
        target.Category != source.Category OR
        target.Price != source.Price OR
        target.ProductDescription != source.ProductDescription);

    -- Load Dim_Region with SCD Type 2
    -- Update existing records to set IsCurrent to 0 and set EndDate
    UPDATE jet.dbo.Dim_Region
    SET
        EndDate = GETDATE(),
        IsCurrent = 0,
        UpdatedAt = GETDATE()
    FROM jet.dbo.Dim_Region AS target
    JOIN (SELECT DISTINCT Region FROM jet.dbo.Staging_Customers) AS source
    ON target.Region = source.Region AND target.IsCurrent = 1
    WHERE target.Region != source.Region;

    -- Insert new records
    INSERT INTO jet.dbo.Dim_Region (Region, StartDate, EndDate, IsCurrent, CreatedAt, UpdatedAt)
    SELECT source.Region, GETDATE(), NULL, 1, GETDATE(), GETDATE()
    FROM (SELECT DISTINCT Region FROM jet.dbo.Staging_Customers) AS source
    LEFT JOIN jet.dbo.Dim_Region AS target
    ON target.Region = source.Region AND target.IsCurrent = 1
    WHERE
        target.Region IS NULL OR
        target.Region != source.Region;

    -- Load Fact Table
    MERGE INTO jet.dbo.Fact_Sales AS target
    USING (
        SELECT
            s.SaleID,
            dc.SurrogateKey AS CustomerKey,
            dp.SurrogateKey AS ProductKey,
            CONVERT(INT, CONVERT(VARCHAR, s.SaleDate, 112)) AS DateKey,
            dr.RegionKey AS RegionKey,
            s.Quantity,
            s.Amount,
            GETDATE() AS CreatedAt,
            GETDATE() AS UpdatedAt,
            ROW_NUMBER() OVER (PARTITION BY s.SaleID ORDER BY s.SaleID) AS rn
        FROM jet.dbo.Staging_Sales s
        JOIN jet.dbo.Dim_Customers dc ON s.CustomerID = dc.CustomerID AND dc.IsCurrent = 1
        JOIN jet.dbo.Dim_Products dp ON s.ProductID = dp.ProductID AND dp.IsCurrent = 1
        JOIN jet.dbo.Dim_Region dr ON dc.Region = dr.Region
    ) AS source
    ON target.SaleID = source.SaleID AND source.rn = 1
    WHEN MATCHED THEN
        UPDATE SET
            target.CustomerKey = source.CustomerKey,
            target.ProductKey = source.ProductKey,
            target.DateKey = source.DateKey,
            target.RegionKey = source.RegionKey,
            target.Quantity = source.Quantity,
            target.Amount = source.Amount,
            target.UpdatedAt = source.UpdatedAt
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (SaleID, CustomerKey, ProductKey, DateKey, RegionKey, Quantity, Amount, CreatedAt, UpdatedAt)
        VALUES (source.SaleID, source.CustomerKey, source.ProductKey, source.DateKey, source.RegionKey, source.Quantity, source.Amount, source.CreatedAt, source.UpdatedAt);
END;
GO