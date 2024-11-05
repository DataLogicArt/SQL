/*1. Show Top 10 Sum of Sales by States */
SELECT TOP(10)
     State,
	 SUM(IIF(YEAR([OrderDate]) = 2010, [TotalPrice],NULL)) AS [2010],
	 SUM(IIF(YEAR([OrderDate]) = 2011, [TotalPrice],NULL)) AS [2011],
     SUM(IIF(YEAR([OrderDate]) = 2012, [TotalPrice],NULL)) AS [2012],
     SUM(IIF(YEAR([OrderDate]) = 2013, [TotalPrice],NULL)) AS [2013],
     SUM(IIF(YEAR([OrderDate]) = 2014, [TotalPrice],NULL)) AS [2014],
	 SUM(IIF(YEAR([OrderDate]) = 2015, [TotalPrice],NULL)) AS [2015],
	 SUM(IIF(YEAR([OrderDate]) = 2016, [TotalPrice],NULL)) AS [2016]
FROM [SQLBook].dbo.Orders
WHERE YEAR ([OrderDate]) IN (2010,2011,2012,2013,2014,2015,2016) AND ([State]) IS NOT NULL 
GROUP BY State
ORDER BY [2016] DESC
GO

/*2. What type of payments Customers used by Percent*/
DECLARE @t1 DATETIME2 = SYSDATETIME();
WITH AmExpress AS 
(
	SELECT AVG(IIF([PaymentType] = 'AE', 100.0, 0)) AS AmEx
	FROM [SQLBook].[dbo].[Orders]
),
VISACard AS 
(
	SELECT AVG(IIF([PaymentType] = 'VI', 100.0, 0)) AS VISA
	FROM [SQLBook].[dbo].[Orders] 
),
MasterCard AS (
    SELECT AVG(IIF([PaymentType] = 'MC', 100.0, 0)) AS MasterC
	FROM [SQLBook].[dbo].[Orders]
),
OverCard  AS
(
	SELECT AVG(IIF([PaymentType] = 'OC', 100.0, 0)) AS OverC
	FROM [SQLBook].[dbo].[Orders]
)
SELECT
	FORMAT(AmExpress.AmEx, 'N2')  AS [AmEx Payment %],
	FORMAT(VISACard.VISA, 'N2') AS [VISA Payment %],
	FORMAT(MasterCard.MasterC, 'N2') AS [Master Card Payment %],
	FORMAT(OverCard.OverC, 'N2') AS [Over-collateralization %]


	FROM AmExpress, VISACard,MasterCard,OverCard
GO

/*3. Now many Customers used each Channel by each year */
USE [SQLBook];
SELECT
	pvt.[Channel Name],
	pvt.[2012],
	pvt.[2013],
	pvt.[2014],
	pvt.[2015],
	pvt.[2016]

FROM (
    SELECT
        cam.[Channel] AS [Channel Name],
	    o.[TotalPrice],
	    YEAR(o.[OrderDate]) AS [Year]
     FROM [SQLBook].dbo.Orders o
      JOIN [SQLBook].dbo.Campaigns  cam
	  ON o.[CampaignID] = cam. [CampaignID]

) AS cam
PIVOT
(
   COUNT([TotalPrice])
   FOR [YEAR]
   IN ([2012],[2013],[2014],[2015],[2016])
) AS pvt
ORDER BY pvt.[Channel Name]
GO

/*4. How many units shiped by Product Group in 2010-2016*/
SELECT
      p.GroupName AS [Product by Group],
	  SUM(IIF(YEAR([ShipDate])  = 2010, [NumUnits],0)) AS [2010],
	  SUM(IIF(YEAR([ShipDate])  = 2011, [NumUnits],0)) AS [2011],
	  SUM(IIF(YEAR([ShipDate])  = 2012, [NumUnits],0)) AS [2012],
	  SUM(IIF(YEAR([ShipDate])  = 2013, [NumUnits],0)) AS [2013],
	  SUM(IIF(YEAR([ShipDate])  = 2014, [NumUnits],0)) AS [2014],
	  SUM(IIF(YEAR([ShipDate])  = 2015, [NumUnits],0)) AS [2015],
	  SUM(IIF(YEAR([ShipDate])  = 2016, [NumUnits],0)) AS [2016]
FROM [SQLBook].dbo.Products p
JOIN [SQLBook].dbo.OrderLines o
ON p.ProductID = o.ProductID
WHERE YEAR([ShipDate]) IN (2010,2011,2012,2013,2014,2015,2016) 
GROUP BY p.[GroupName]
ORDER BY [2016]
GO

/*5. Female and male Percent in Customer list */
DECLARE @t1 DATETIME2 = SYSDATETIME();
WITH FemCustomer AS 
(
	SELECT AVG(IIF([Gender] = 'F', 100.0, 0)) AS Female
	FROM [SQLBook].[dbo].[Customers]
),
MaleCustomer AS 
(
	SELECT AVG(IIF([Gender] = 'M', 100.0, 0)) AS Male
	FROM [SQLBook].[dbo].[Customers]
)

SELECT
	FORMAT(FemCustomer.Female, 'N2')  AS [Female % Customer],
	FORMAT(MaleCustomer.Male, 'N2') AS [Male % Customer]


FROM FemCustomer,MaleCustomer
GO

/*6. Show Monthly in 2015 year  Top 6 Sales by State*/
SELECT TOP 6
     State,
	 SUM(IIF(MONTH([OrderDate]) = 01, [TotalPrice],NULL)) AS [January],
	 SUM(IIF(MONTH([OrderDate]) = 02, [TotalPrice],NULL)) AS [February],
     SUM(IIF(MONTH([OrderDate]) = 03, [TotalPrice],NULL)) AS [March],
     SUM(IIF(MONTH([OrderDate]) = 04, [TotalPrice],NULL)) AS[April],
     SUM(IIF(MONTH([OrderDate]) = 05, [TotalPrice],NULL)) AS [May],
	 SUM(IIF(MONTH([OrderDate]) = 06, [TotalPrice],NULL)) AS [June],
	 SUM(IIF(MONTH([OrderDate]) = 07, [TotalPrice],NULL)) AS [July],
	 SUM(IIF(MONTH([OrderDate]) = 08, [TotalPrice],NULL)) AS [August],
     SUM(IIF(MONTH([OrderDate]) = 09, [TotalPrice],NULL)) AS [September],
     SUM(IIF(MONTH([OrderDate]) = 10, [TotalPrice],NULL)) AS [October],
     SUM(IIF(MONTH([OrderDate]) = 11, [TotalPrice],NULL)) AS [November],
	 SUM(IIF(MONTH([OrderDate]) = 12, [TotalPrice],NULL)) AS [December]
FROM [SQLBook].dbo.Orders
WHERE MONTH([OrderDate]) IN (1,2,3,4,5,6,7,8,9,10,11,12) AND Year([OrderDate]) = 2015 
GROUP BY State
ORDER BY [January] DESC
GO

/*7. Average Sales per year (2013 to 2015)  by Gender*/
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
WHERE YEAR([OrderDate]) IN (2013,2014,2015)
GROUP By n.Gender
GO

/*8. Show the list of Customers who had more than $5000 purshases in 2015*/
     SELECT 
     c.[CustomerId],
     c.[FirstName],
	 SUM(IIF(YEAR([OrderDate]) = 2015,[TotalPrice],0)) AS [2015]
FROM [SQLBook].[dbo].[Orders] o
JOIN [SQLBook].[dbo].[Customers] c
ON o.CustomerId = c.CustomerId

WHERE YEAR([OrderDate]) IN (2014,2015) 
GROUP BY c.CustomerId,c.FirstName
HAVING SUM(IIF(YEAR([OrderDate]) = 2015,[TotalPrice],NULL)) > 5000  
GO

/*9 Select first year when sales value appeared by channels*/
WITH Performance(channel,y2012,y2013,y2014,y2015,y2016)
AS( 
   SELECT
     c.Channel,
     AVG(IIF(YEAR([OrderDate]) = 2012,[TotalPrice],NULL)) AS [Average 2009],
     AVG(IIF(YEAR([OrderDate]) = 2013,[TotalPrice],NULL)) AS [Average 2010],
     AVG(IIF(YEAR([OrderDate]) = 2014,[TotalPrice],NULL)) AS [Average 2011],
	 AVG(IIF(YEAR([OrderDate]) = 2015,[TotalPrice],NULL)) AS [Average 2011],
	 AVG(IIF(YEAR([OrderDate]) = 2016,[TotalPrice],NULL)) AS [Average 2011]
FROM SQLBook.dbo.Orders o
JOIN SQLBook.dbo.Campaigns c
ON o.CampaignId = c.CampaignId
WHERE YEAR([OrderDate]) IN (2012,2013,2014,2015,2016)
GROUP By c.Channel
) SELECT channel AS [Channel], COALESCE(y2012,y2013,y2014,y2015,y2016) AS [First Year Performance]
FROM Performance
GO

/* 10 Divide prices by category : less $200, less $500, less $1000, Over $1000 and count for each Category*/
WITH ArtWork AS (SELECT
                      [ProductID],
                      [GroupName] AS [Group Category],
                      [FullPrice] = 
                                 CASE 
	                                 WHEN [FullPrice] < 200 THEN 'Under $200'
		                             WHEN [FullPrice] >= 200  AND [FullPrice] < 500 THEN 'Under $500'
		                             WHEN [FullPrice] >= 500  AND [FullPrice] < 1000 THEN 'Under $1000'
		                             WHEN [FullPrice] > 100 THEN 'Over $1000'
                                 END

                  FROM SQLBook.dbo.Products
				 )
SELECT [Group Category],
       [FullPrice],
       COUNT(*) AS Quantity 
FROM ArtWork
GROUP BY FullPrice, [Group Category]
GO
