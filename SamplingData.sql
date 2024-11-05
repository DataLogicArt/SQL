/*1. Balanced Sample of Purchases in NY  and the rest States in 2015 
Where Total Price more $200 */

WITH o AS (
   SELECT
      *, 
      ROW_NUMBER() OVER (PARTITION BY [InNY] ORDER BY NEWID()) AS [RowNumber]
   FROM (
      SELECT
         *,
         IIF([State] = 'NY', 1, 0) AS [InNY]
      FROM [SQLBook].[dbo].[Orders]
      WHERE TotalPrice > 200
   ) o
)
SELECT [OrderDate],
   IIF([InNY] = 1, [TotalPrice], NULL) as [New York],
   IIF([InNY] = 0, [TotalPrice], NULL) as [REST]
FROM o
WHERE [RowNumber] <= 100 AND YEAR([OrderDate]) = 2015
GO

/*2. Randon Sample of Purchases in NY  and the rest States 
where Total Price less $200*/

SELECT TOP 200 OrderDate,
	IIF([State] = 'NY', TotalPrice, NULL) AS [New York],
	IIF([State] = 'NY', NULL, TotalPrice) AS [Others]
FROM [SQLBook].[dbo].[Orders]
WHERE TotalPrice < 200
ORDER BY NEWID()
GO

/*3. Selecting random rows from a large table.
Selecting 5% random rows from a  SalesOrderHeader table */
SELECT *
FROM AdventureWorks2019.Sales.SalesOrderHeader
WHERE (ABS(CAST((BINARY_CHECKSUM(*) * RAND()) as int)) % 100) < 5
GO

/*4.Repeatable Randon Sample.
Selecting 5% random reproducible rows from a  SalesOrderHeader table */

WITH t AS (
	SELECT ROW_NUMBER() OVER (ORDER BY [SalesOrderId]) as [RowNumber], *
	FROM AdventureWorks2019.Sales.SalesOrderHeader
)
SELECT * FROM t
WHERE ([RowNumber] * 55 + 299) % 100 < 5
GO

/*5.Propotional Stratified Sample.
Get a sample 1/50th of the Sales with the same percentage of as Ship Method ID is 1
as the entire sales*/
WITH t as (
	SELECT ROW_NUMBER() OVER (ORDER BY [ShipMethodID]) as [RowNumber], *
	FROM AdventureWorks2019.Sales.SalesOrderHeader
)
SELECT * FROM t
WHERE [RowNumber] % 50 = 1
ORDER BY [ShipMethodID]
GO

/*6. The standard way to select random rows from a small table .
SELECT 5% of rendom Record.*/
SELECT TOP 5 PERCENT *
FROM AdventureWorks2019.Sales.SalesOrderHeader
ORDER BY NEWID();
GO


/*7.Create Predicted Sales model based on Month and Territory*/
USE AdventureWorks2019;
DECLARE @FallBack2011Average FLOAT = (SELECT AVG([TotalDue]) FROM Sales.SalesOrderHeader
WHERE YEAR([OrderDate]) = 2011);
WITH
ScoreSet AS (
	SELECT *, MONTH([OrderDate]) AS [Month] FROM Sales.SalesOrderHeader
	WHERE YEAR([OrderDate]) = 2012
),
ModelSet AS (
	SELECT
		MONTH([OrderDate]) AS [Month],
		[TerritoryID], 
		AVG([TotalDue]) as [Average Amount in 2011]
	FROM Sales.SalesOrderHeader WHERE YEAR([OrderDate]) = 2011
	GROUP BY MONTH([OrderDate]), [TerritoryID]
)
SELECT
	b.[Decile],
	AVG(b.[Predicted]) AS [Average Predicted],
	AVG(b.[Actual]) AS [Average Actual]
	FROM (
		SELECT a.*, NTILE(10) OVER (ORDER BY a.[Predicted] DESC) AS [Decile]
		FROM (
			SELECT
				COALESCE(ModelSet.[Average Amount in 2011], @FallBack2011Average) AS [Predicted],
				ScoreSet.[TotalDue] AS [Actual]
			FROM ScoreSet LEFT JOIN ModelSet
			ON ScoreSet.[Month] = ModelSet.[Month] AND 
			ScoreSet.[TerritoryID] = ModelSet.[TerritoryID]	
		) a
	) b
GROUP BY b.[Decile]
ORDER BY b.[Decile]
GO 

/*8. Create Predicted Sales model based on Sales Person ID and Customer ID*/
USE AdventureWorks2019;
DECLARE @FallBack2011Average FLOAT = (SELECT AVG([TotalDue]) FROM Sales.SalesOrderHeader
WHERE YEAR([OrderDate]) = 2011);
WITH
ScoreSet AS (
	SELECT * FROM Sales.SalesOrderHeader
	WHERE YEAR([OrderDate]) = 2012
),
ModelSet AS (
	SELECT
		[SalesPersonID], 
		[CustomerID],
		AVG([TotalDue]) AS [Average Amount in 2011]
	FROM Sales.SalesOrderHeader WHERE YEAR([OrderDate]) = 2011
	GROUP BY  [SalesPersonID],[CustomerID]
)
SELECT
	b.[Decile],
	AVG(b.[Predicted]) AS [Average Predicted],
	AVG(b.[Actual]) AS [Average Actual]
	FROM (
		SELECT a.*, NTILE(10) OVER (ORDER BY a.[Predicted] DESC) AS [Decile]
		FROM (
			SELECT
				COALESCE(ModelSet.[Average Amount in 2011], @FallBack2011Average) AS [Predicted],
				ScoreSet.[TotalDue] AS [Actual]
			FROM ScoreSet LEFT JOIN ModelSet
			ON ScoreSet.[SalesPersonID] = ModelSet.[SalesPersonID]	AND 
			ScoreSet.[CustomerID] = ModelSet.[CustomerID]
		) a
	) b
GROUP BY b.[Decile]
ORDER BY b.[Decile]
GO


/* Recomended Predicted Sales model based  on Month, TerritorySales and Sales Person ID*/
USE AdventureWorks2019;
DECLARE @FallBack2011Average FLOAT = (SELECT AVG([TotalDue]) FROM Sales.SalesOrderHeader
WHERE YEAR([OrderDate]) = 2011);
WITH
ScoreSet AS (
	SELECT *, MONTH([OrderDate]) AS [Month] FROM Sales.SalesOrderHeader
	WHERE YEAR([OrderDate]) = 2012
),
ModelSet AS (
	SELECT
		MONTH([OrderDate]) AS [Month],
		[TerritoryID], 
		[SalesPersonID],
		AVG([TotalDue]) as [Average Amount in 2011]
	FROM Sales.SalesOrderHeader WHERE YEAR([OrderDate]) = 2011
	GROUP BY MONTH([OrderDate]), [TerritoryID], [SalesPersonID]
)
SELECT
	b.[Decile],
	AVG(b.[Predicted]) AS [Average Predicted],
	AVG(b.[Actual]) AS [Average Actual]
	FROM (
		SELECT a.*, NTILE(10) OVER (ORDER BY a.[Predicted] DESC) AS [Decile]
		FROM (
			SELECT
				COALESCE(ModelSet.[Average Amount in 2011], @FallBack2011Average) AS [Predicted],
				ScoreSet.[TotalDue] AS [Actual]
			FROM ScoreSet LEFT JOIN ModelSet
			ON ScoreSet.[Month] = ModelSet.[Month] AND 
			ScoreSet.[TerritoryID] = ModelSet.[TerritoryID] AND
			ScoreSet.[SalesPersonID] = ModelSet.[SalesPersonID]
		) a
	) b
GROUP BY b.[Decile]
ORDER BY b.[Decile]