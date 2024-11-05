/*1. How many Customers how many sales have */
WITH Sales_Customer (ID, number)
AS
   (
    SELECT CustomerID, COUNT (*)
	FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
	WHERE CustomerID IS NOT NULL
	GROUP BY CustomerID
	)

SELECT 
     COUNT (ID) AS [Total Customers],
	 SUM (number) AS [Total Sales]
	 
FROM Sales_Customer;
GO


/*2. How many Sales per Province/Territory */

WITH Sales_Territory (id, number) AS (
     SELECT [TerritoryID], COUNT(*)
	      FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
		  WHERE[TerritoryID] IS NOT NULL
		  Group By [TerritoryID]
	)
SELECT
     p.Name AS [Province Name],
	  Sales_Territory.number AS [Number of Sales]
	  
FROM Sales_Territory
JOIN AdventureWorks2019.Sales.SalesTerritory n
ON n.TerritoryID = Sales_Territory.id
JOIN AdventureWorks2019.Person.StateProvince p
ON n.TerritoryID = p.TerritoryID 
ORDER by Sales_Territory.number DESC
GO

/* 3.How many people work in each Job Title Categoty*/
 WITH JobTitle (Title ,num)
 AS
 (
    SELECT JobTitle, COUNT (*)
	FROM [AdventureWorks2019].[HumanResources].[Employee]
	WHERE JobTitle IS NOT NULL
	GROUP BY JobTitle
 )
 SELECT *
 FROM JobTitle

 GO

/*4. Count Sum of Total Products */ 
 WITH product(id, num) AS (
	SELECT [ProductID], COUNT(*)
		FROM  [AdventureWorks2019].[Production].[Product]
		WHERE [ProductID] IS NOT NULL
		GROUP BY [ProductID]
        ) 
Select
   
	SUM (num) AS [total Product]
From product

Go

/*5. Maximum and minimum sales per Customer */

WITH sales AS (
	SELECT [CustomerID] AS id, COUNT(*) AS num
		FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
		WHERE [CustomerID] IS NOT NULL
		GROUP BY [CustomerID]
) 
SELECT
     Count(id) AS [Total Customers],
     MAX (num) AS [Maximum sales per customer],
	 Min (num) As [Mimimun sales]
FROM sales
GO 

/*6. How many Customer been served by each Sales Person*/

WITH sales AS (
	SELECT [CustomerID] AS id, COUNT(*) AS num
		FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
		WHERE [CustomerID] IS NOT NULL
		GROUP BY [CustomerID]
) 
SELECT
	CONCAT(p.FirstName, ' ', p.LastName) AS [Sales Person],
	sales.num AS [Number Customer Serve]
FROM sales
RIGHT JOIN [AdventureWorks2019].[Person].[Person] p
ON p.BusinessEntityID = sales.id
ORDER by sales.num DESC
GO

/*7.How Many Employeers older than 55 years, work in Company*/

WITH GenderAge AS (
	SELECT [Gender], DATEDIFF(yyyy, [BirthDate], GETDATE()) AS [Age]
	FROM [AdventureWorks2019].[HumanResources].[Employee]
)
SELECT
	[Gender],
	COUNT([Age]) AS [Total Employers]
	
FROM GenderAge
Where [Age] > 55
GROUP BY [Gender]
GO


/*8  Find min and max age  accordung to Marrige Status Total*/
WITH MarriageSt AS (
            SELECT [Gender], DATEDIFF(yyyy, [BirthDate], GETDATE()) AS [YearsOld],
			MaritalStatus
			FROM [AdventureWorks2019].[HumanResources].[Employee]
			)

SELECT
	IIF(GROUPING([MaritalStatus]) = 1, 'Total', [MaritalStatus]) AS [Matital Status],
	COUNT(*) AS [Total Count],
	MIN([YearsOld]) AS [Youngest],
	MAX([YearsOld]) AS [Oldest]
FROM MarriageSt
GROUP BY ROLLUP ([MaritalStatus]);
GO

/* 9. How many Singles and Married Employees in Company (Table Type)*/
DECLARE @MaritalStatus TABLE (Category NVARCHAR(255));
INSERT INTO @MaritalStatus
     SELECT 
	       CASE
		        WHEN [MaritalStatus] = 'S' THEN 'Single'
				WHEN [MaritalStatus] = 'M' THEN 'Married'
			END AS [Category]
			FROM [AdventureWorks2019].[HumanResources].[Employee];
			

SELECT [Category],COUNT (*) AS [Amount] FROM @MaritalStatus
GROUP BY [Category]
GO

/*10.  Count Credit rating of Vendor by each Category -Best,Good,Not Good, Bad, Warning' */

DECLARE @CreditRating TABLE (Category NVARCHAR (255));

INSERT INTO @CreditRating
       SELECT
	       CASE 
	            WHEN [CreditRating] = 1 THEN 'BEST- pay within 30 days'
				WHEN [CreditRating] = 2  THEN 'GOOD - pay within 60 days '
				WHEN [CreditRating] = 3 THEN 'NOT GOOD- pay within 90 days'
				WHEN [CreditRating] = 4 THEN 'BAD - pay within 180 days'
				WHEN [CreditRating] = 5 THEN 'WARNING - never paid '
		   END
		FROM AdventureWorks2019.Purchasing.Vendor;

 SELECT [Category], COUNT(*) AS [Amount] FROM @CreditRating
	        GROUP BY [Category];
GO

/*11. Change shift name : Day to Morning - Day, Evening - Evening, Night - All nifht (Table Data Type)*/

DROP TABLE IF EXISTS #ShiftsHours;
GO
CREATE TABLE #ShiftsHours (ShiftsHours NVARCHAR(255));
INSERT INTO #ShiftsHours
     SELECT
	    CASE 
	       WHEN [Name] = 'Day' THEN 'Morning - Day'
		   WHEN [Name] = 'Evening' THEN 'Evening'
		   WHEN [Name] = 'Night' THEN 'All Night'
	     END
     FROM [AdventureWorks2019].[HumanResources].Shift
SELECT * FROM #ShiftsHours 
GO 


/*12. Create temprory table how namy Employees need Vacations now, during next 3 month and can wait */
DROP TABLE IF EXISTS #VacationNeeds;
GO 
CREATE TABLE  #VacationNeeds (Category NVARCHAR(255));

INSERT INTO  #VacationNeeds
    SELECT
      CASE
	      WHEN [VacationHours] >= 90 THEN 'Vacation need now'
		  WHEN [VacationHours] >= 70 THEN 'Vacation need during next 3 month'
		  WHEN [VacationHours] < 70 THEN 'Vacation can wait'
	  END 
	FROM [AdventureWorks2019].[HumanResources].[Employee];
	
SELECT [Category], COUNT(*) AS [Amount] FROM #VacationNeeds
GROUP BY [Category]
GO 





