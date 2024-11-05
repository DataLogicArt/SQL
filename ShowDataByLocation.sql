/* Show population Of race  by %  where Asian more than 50 %*/
WITH RACE AS (
SELECT [Longitude],
[Latitude],
IIF(pctWhite1 > 0, [pctWhite1], 0) AS [White],
IIF(pctBlack1 > 0, [pctBlack1], 0) AS [Black],
IIF(pctAsian1 > 0, [pctAsian1], 0) AS [Asian],
IIF(pctIndian1 > 0, [pctIndian1], 0) AS [Indian]
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0)

SELECT [Longitude],
       [Latitude],
       FORMAT([White], 'P1') AS [White],
	   FORMAT([Black], 'P1') AS [Black],
	   FORMAT([Asian], 'P1') AS [Asian],
	   FORMAT([Indian], 'P1') AS [Indian]
FROM Race
WHERE [Asian] > 0.5 
GO

/*2 Sum of orders mapping by location where Sum of Order more than 1000*/
SELECT [Longitude], [Latitude], [Total Sum of Orders] 
FROM [SQLBook].[dbo].[ZipCensus] zc
JOIN
   (SELECT [ZipCode], Sum([TotalPrice]) AS [Total Sum of Orders]
   FROM [SQLBook].[dbo].[Orders]
   GROUP BY [ZipCode]) o
ON zc.[zcta5] = o.[ZipCode]
WHERE [Latitude] BETWEEN 24 AND 50 AND
      [Longitude] BETWEEN -125 AND -65 AND [Total Sum of Orders] > 1000

/*3. Show sum of total price in state of MA*/
SELECT [Longitude], [Latitude], [SUM of total Price], zc.Stab
FROM [SQLBook].[dbo].[ZipCensus] zc
JOIN
   (SELECT [ZipCode], SUM([TotalPrice]) AS [SUM of total Price]
   FROM [SQLBook].[dbo].[Orders]
   GROUP BY [ZipCode]) o
ON zc.[zcta5] = o.[ZipCode]
WHERE [Latitude] BETWEEN 24 AND 50 AND
      [Longitude] BETWEEN -125 AND -65
      AND zc.Stab = 'MA'
GO

/*4. Show population by % of full time workers Male and Female */
SELECT [Longitude],[Latitude],
IIF(pctFullTimeWorkersMale > 0, [pctFullTimeWorkersMale], 0) AS [Full Time Workers Male],
IIF(pctFullTimeWorkersFemale > 0, [pctFullTimeWorkersFemale], 0) AS [Full Time Workers Female]

FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0
AND pctFullTimeWorkersMale > 0.8 OR 
pctFullTimeWorkersFemale >  0.8 
GO 

/*5. Show Median Earnings more or equal $80000 */
SELECT [Longitude],[Latitude], [MedianEarnings]
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0
AND [MedianEarnings] >= 80000
GO

/*6. Show walk to home more 80% */
SELECT [Longitude], [Latitude], [pctWalkToWork]
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0
AND [pctWalkToWork] > 0.8
GO

/*7. Group Median rent by Category and show more that $1500*/
SELECT
   [Longitude], [Latitude],
   IIF([MedianGrossRent] < 1000, [MedianGrossRent], 0) AS [Median Gross Rent less $1000], 
   IIF([MedianGrossRent] > 1000 AND [MedianGrossRent] < 1500, [MedianGrossRent], 0) AS [Median Gross Rent $1000 - $1500],
   IIF([MedianGrossRent] > 1500, [MedianGrossRent], 0) AS [Median Gross Rent more $1500]
   
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0 
GO

/*8. Group family by average members 1-2, 2-3, 3-4, 4 and more by territory*/
SELECT
   [Longitude], [Latitude],
   IIF(AvgFamSize > 1 AND AvgFamSize < 2 , [AvgFamSize], 0) AS [Agerage 1], 
   IIF(AvgFamSize >= 2 AND AvgFamSize < 3, [AvgFamSize], 0) AS [Agerage 2],
   IIF(AvgFamSize >= 3 AND AvgFamSize < 4, [AvgFamSize], 0) AS [Agerage 3],
   IIF(AvgFamSize >= 4, [AvgFamSize], 0) AS [Agerage 4]
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0
GO

/*9. Show sum of average sum of sales by states*/
SELECT  
   zc.[Longitude], 
   zc.[Latitude], 
   o.[Avg of total Price],
   zc.[Stab] + ': ' + CONVERT(varchar(10), o.[Avg of total Price]) AS [Info]
FROM (
   SELECT
      [ZipCode], 
      [State],
      AVG([TotalPrice]) AS [Avg of total Price],
      ROW_NUMBER() OVER (PARTITION BY [State] ORDER BY COUNT(*) DESC) as [Row Number]
   FROM [SQLBook].[dbo].[Orders]
   GROUP BY [ZipCode], [State]
) o
JOIN
      [SQLBook].[dbo].[ZipCensus] zc
      ON zc.[zcta5] = o.[ZipCode]
WHERE [Row Number] = 1 AND
      [Latitude]  BETWEEN 20 and 50 AND 
      [Longitude] BETWEEN -135 AND -65
ORDER BY [Info]
GO

/*10 Show the most Builing built before 1940 by territory*/
SELECT
     [Longitude], [Latitude],
     [BuiltBefore1940] AS [Builing built before 1940],
	 [Stab]
FROM [SQLBook].[dbo].[ZipCensus]
WHERE [Latitude] < 50.0 AND [Longitude] > -125.0 AND [BuiltBefore1940] > 10000