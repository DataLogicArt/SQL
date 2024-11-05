/*1. Get Family Average size by chosen State*/
USE SQLBook;
DROP FUNCTION IF EXISTS A01049690_GetAverageFamilySizeByState
GO

CREATE FUNCTION A01049690_GetAverageFamilySizeByState
(   
    @state varchar(255)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT
   [Longitude],[Latitude],
   IIF(AvgFamSize > 1 AND AvgFamSize < 2 , [AvgFamSize], 0) AS [Average 1], 
   IIF(AvgFamSize >= 2 AND AvgFamSize < 3, [AvgFamSize], 0) AS [Average 2],
   IIF(AvgFamSize >= 3 AND AvgFamSize < 4, [AvgFamSize], 0) AS [Average 3],
   IIF(AvgFamSize >= 4, [AvgFamSize], 0) AS [Average 4],
   [Stab]
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0 AND
[Stab] = @state
)
GO
SELECT * FROM A01049690_GetAverageFamilySizeByState('NY');
GO

/*2. Mapping territory by Madian Earning Rate*/

USE SQLBook;
DROP FUNCTION IF EXISTS A01049690_MedianEarningRate
GO

CREATE FUNCTION A01049690_MedianEarningRate
(   
    @MedianEarningsMin int,
	@MedianEarningsMax int
)
RETURNS TABLE 
AS
RETURN 
(

SELECT [Longitude],[Latitude], [MedianEarnings]
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0
AND [MedianEarnings] > @MedianEarningsMin
AND [MedianEarnings] < @MedianEarningsMax
)
GO
SELECT * FROM A01049690_MedianEarningRate(6000, 10000);
GO

/*3. Get 10 best Customers by States and sales */
USE SQLBook;

DROP FUNCTION IF EXISTS A01049690_GetBestCustomersByStateAndPrice
GO

CREATE FUNCTION A01049690_GetBestCustomersByStateAndPrice
(   
    @state CHAR(2), @totalPrice int
)
RETURNS TABLE 
AS
RETURN 
(
SELECT TOP(10)
	 p.[FirstName] as [Customer Person],
	 s.[TotalPrice]
	 FROM[dbo].[Orders] AS s
    JOIN [dbo].[Customers] AS p
	ON s.CustomerId = p.CustomerId
WHERE [OrderId] IS NOT NULL AND [TotalPrice] <>0 
AND State =  @state AND [TotalPrice] >= @totalPrice
) 
GO
SELECT * FROM A01049690_GetBestCustomersByStateAndPrice('AZ', 500);
GO


/*4. Full Time Workers with one argument - State*/
USE SQLBook;

DROP FUNCTION IF EXISTS A01049690_GetFullTimeWorkers
GO

CREATE FUNCTION A01049690_GetFullTimeWorkers
(   
    @state CHAR(2)
)
RETURNS TABLE 
AS
RETURN 
(

SELECT [Longitude],[Latitude],
IIF(pctFullTimeWorkersMale > 0, [pctFullTimeWorkersMale], 0) AS [Full Time Workers Male],
IIF(pctFullTimeWorkersFemale > 0, [pctFullTimeWorkersFemale], 0) AS [Full Time Workers Female]

FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0
      AND [Stab] = @state 
) 
GO
SELECT * FROM A01049690_GetFullTimeWorkers('AZ');
GO

/*5. Function cumulative total price of sales (10 top) with 3 arguments
  - start day and end day (that determ the period of sales time) and State */
USE SQLBook;
DROP FUNCTION IF EXISTS A01049690_Get_SumOfTotalPrice
GO

CREATE FUNCTION A01049690_Get_SumOfTotalPrice
(   
   @startDate DateTime, @endDate DateTime, @state varchar(255)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT
 TOP (10)
[Longitude], [Latitude], [SUM of total Price], zc.Stab
FROM [SQLBook].[dbo].[ZipCensus] zc
JOIN
   (SELECT [ZipCode], SUM([TotalPrice]) AS [SUM of total Price]
   FROM [SQLBook].[dbo].[Orders]
   WHERE [OrderDate] >= @startDate AND
         [OrderDate] < DATEADD(month,1,@startDate) AND
		 [OrderDate] <= @endDate AND
         [OrderDate] < DATEADD(month,1,@endDate)
   GROUP BY [ZipCode]) o
ON zc.[zcta5] = o.[ZipCode]
WHERE [Latitude] BETWEEN 24 AND 50 AND
      [Longitude] BETWEEN -125 AND -65
      AND zc.Stab = @state 
	  )
GO
SELECT * FROM A01049690_Get_SumOfTotalPrice('2015-09-01','2016-09-01','NY');
GO

/*6. Function accumulate total price by Customer where parameter is determed by 
CampainID */
USE SQLBook;

DROP FUNCTION IF EXISTS A01049690_TotalPriceByCustomer_CampainID
GO

CREATE FUNCTION A01049690_TotalPriceByCustomer_CampainID
(   
    @campainID int
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
     p.[FirstName] as [Customer Person],
	 s.[TotalPrice],
	 s.[State]
FROM [SQLBook].[dbo].[Orders] AS s
    JOIN [dbo].[Customers] AS p
	ON s.CustomerId = p.CustomerId
WHERE [OrderId] IS NOT NULL AND [TotalPrice] <>0 AND  CampaignID= @campainID 
)
GO
SELECT * FROM A01049690_TotalPriceByCustomer_CampainID ('2174')
GO

/*7. Function with one payment method parameter (''varchar(50) argument should be used)
show customers and days since last order by Payment Method Parameter */
USE SQLBook;
DROP FUNCTION IF EXISTS A01049690_GetCustomerSinceLastOrderByPaymentMethod
GO

CREATE FUNCTION A01049690_GetCustomerSinceLastOrderByPaymentMethod
(   
    @paymentMethod varchar(50)
)
RETURNS TABLE 
AS
RETURN 
(

SELECT TOP (7)
[CustomerID],
[OrderDate],
LAG([OrderDate]) OVER (
    PARTITION BY[CustomerID] ORDER BY [OrderDate])
	AS [Previous Order Date],
	DATEDIFF(
	day,LAG([OrderDate]) OVER(
	PARTITION BY [CustomerID] ORDER BY[OrderDate]),
	[OrderDate]
	)AS [Days Since Last Order]
FROM [SQLBook].[dbo].[Orders]
WHERE [CustomerID] != 0 AND PaymentType = @paymentMethod

ORDER BY [CustomerId],[OrderDate]
)
GO
SELECT * FROM A01049690_GetCustomerSinceLastOrderByPaymentMethod ('MC')
GO

/*8 Function has 1 Gender parameter and culculate Average Sales
by Years.*/
USE SQLBook;
DROP FUNCTION IF EXISTS A01049690_GetAverageSalesByGender
GO
CREATE FUNCTION A01049690_GetAverageSalesByGender
(   
    @gender varchar(50)
)
RETURNS TABLE 
AS
RETURN 
(

SELECT
[Category] =  
		CASE [Gender]  
			WHEN 'F' THEN 'Femail'  
			WHEN 'M' THEN 'Mail'  
			ELSE 'Not identify'  
		END,  

AVG(IIF(YEAR([OrderDate]) = 2013,[TotalPrice],NULL)) AS [Average 2013],
AVG(IIF(YEAR([OrderDate]) = 2014,[TotalPrice],NULL)) AS [Average 2014],
AVG(IIF(YEAR([OrderDate]) = 2015,[TotalPrice],NULL)) AS [Average 2015]

FROM SQLBook.dbo.Orders o
JOIN SQLBook.dbo.Customers n
ON o.CustomerId = n.CustomerId
WHERE YEAR([OrderDate]) IN (2013,2014,2015) AND Gender = @gender
GROUP By n.Gender
)
GO
SELECT * FROM A01049690_GetAverageSalesByGender('F')
GO

/*9. Show territory where parameter determes the people who gets work by Walk */
USE SQLBook;
DROP FUNCTION IF EXISTS A01049690_GetAverageHomeWork
GO

CREATE FUNCTION A01049690_GetAverageHomeWork
(   
    @homeWork int
)
RETURNS TABLE 
AS
RETURN 
(
SELECT [Longitude], [Latitude], [pctWalkToWork] As [Working to work]
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0
AND [pctWalkToWork] > @homeWork
)
GO
SELECT * FROM A01049690_GetAverageHomeWork(0.5);
GO

/*10. Function get territory where a user chose parameter
with min median earning level*/
USE SQLBook;
DROP FUNCTION IF EXISTS A01049690_GetMedianEarning
GO

CREATE FUNCTION A01049690_GetMedianEarning
(   
    @medianEarning int
)
RETURNS TABLE 
AS
RETURN 
(

SELECT [Longitude],[Latitude], [MedianEarnings]
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0
AND [MedianEarnings] >= @medianEarning
)
GO
SELECT * FROM A01049690_GetMedianEarning(6000);
GO


