/*Determine the most popular Payment Method*/
SELECT TOP 1 PaymentType
FROM SQLBook.dbo.Orders
GROUP BY PaymentType 
ORDER BY COUNT(*) DESC;
/*Resule is Viza*/
/* Find the Most Popular Product group in a zip code.*/
USE SQLBook;
SELECT ZipCode, PaymentType
FROM (
   SELECT ZipCode, PaymentType, COUNT(*) as cnt,
   ROW_NUMBER() OVER (PARTITION BY ZipCode ORDER BY COUNT(*) DESC) as SequentialNumber
   FROM dbo.Orders
      GROUP BY ZipCode, PaymentType
) zg
WHERE SequentialNumber = 1
ORDER BY ZipCode;

/*Determine Payment type groups and the number of zip codes 
where that group is the most popular*/
USE SQLBook;
WITH t as (
SELECT
   [PaymentType],
   COUNT(*) as [GroupCount]
FROM (
   SELECT
      [ZipCode], 
      [PaymentType], 
      COUNT(*) as [Count],
      ROW_NUMBER() OVER 
         (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
         AS [SequentialNumber]
      FROM dbo.Orders
      GROUP BY ZipCode, PaymentType
) zg
WHERE [SequentialNumber] = 1
GROUP BY [PaymentType]
)
SELECT
   [PaymentType] AS [Product Group], 
   [GroupCount] AS [Number of Zips],
   ([GroupCount] * 100.0) / (SELECT SUM([GroupCount]) FROM t) AS [% of All Zips]
FROM t
ORDER BY [GroupCount] DESC
GO

/*Collect data for the Classification Matrix and implement Look up Model
for prediction and Generate it by using use PIVOT T-SQL statement to have convinievce
view*/
USE SQLBook;
DECLARE @YEAR VARCHAR(4) = '2015';

WITH
[lookup] AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate < @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    ) zg 
    WHERE [SequentialNumber] = 1
),
[actuals]  AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate >= @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    )zg 
    WHERE [SequentialNumber] = 1
),
[result] AS (
SELECT
    l.PaymentType AS [Predicted Group Payment Type], 
    a.PaymentType AS [Actual Group Payment Type], 
    COUNT(*) as [Number of Zips]
FROM [lookup] l
JOIN [actuals] a ON l.ZipCode = a.ZipCode
/*WHERE l.PaymentType = a.PaymentType if you want see the coincidences
of the same group in payment type 
WHERE l.GroupName = 'VI' if you want analyze Visa for exzample*/
GROUP BY l.PaymentType, a.PaymentType
)
SELECT * FROM [result]
PIVOT
(
   MAX([Number of Zips])
   FOR [Actual Group Payment Type] IN ([AE],[DB],[MC],[OC],[VI],[??])
) pivot1
GO
/*The correctly predicted groups are in cells that are diagonally adjacent.
IN WHERE l.PaymentType = a.PaymentType*/
USE SQLBook;
DECLARE @YEAR VARCHAR(4) = '2015';

WITH
[lookup] AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate < @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    ) zg 
    WHERE [SequentialNumber] = 1
),
[actuals]  AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate >= @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    )zg 
    WHERE [SequentialNumber] = 1
),
[result] AS (
SELECT
    l.PaymentType AS [Predicted Group Payment Type], 
    a.PaymentType AS [Actual Group Payment Type], 
    COUNT(*) as [Number of Zips]
FROM [lookup] l
JOIN [actuals] a ON l.ZipCode = a.ZipCode
WHERE l.PaymentType = a.PaymentType 
GROUP BY l.PaymentType, a.PaymentType
)
SELECT * FROM [result]
ORDER BY [Predicted Group Payment Type], [Actual Group Payment Type]
GO
/* The model is correct for 530 + 14 + 482 + 5 + 1699 =  2730 zip codes
out of 4727(57.75%) */ 

/*Analyse Visa category prediction*/
/*Collect data for the Classification Matrix and implement Look up Model
for prediction*/
USE SQLBook;
DECLARE @YEAR VARCHAR(4) = '2015';

WITH
[lookup] AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate < @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    ) zg 
    WHERE [SequentialNumber] = 1
),
[actuals]  AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate >= @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    )zg 
    WHERE [SequentialNumber] = 1
),
[result] AS (
SELECT
    l.PaymentType AS [Predicted Group Payment Type], 
    a.PaymentType AS [Actual Group Payment Type], 
    COUNT(*) as [Number of Zips]
FROM [lookup] l
JOIN [actuals] a ON l.ZipCode = a.ZipCode

WHERE l.PaymentType = 'VI'
GROUP BY l.PaymentType, a.PaymentType
)
SELECT * FROM [result]
ORDER BY [Predicted Group Payment Type], [Actual Group Payment Type]
GO

/*Calculate accuracy of prediction that Visa is actually the most popular*/
USE SQLBook;
DECLARE @YEAR VARCHAR(4) = '2015';

WITH
[lookup] AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate < @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    ) zg 
    WHERE [SequentialNumber] = 1
),
[actuals]  AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate >= @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    )zg 
    WHERE [SequentialNumber] = 1
),
[result] AS (
SELECT
    l.PaymentType AS [Predicted Group Payment Type], 
    a.PaymentType AS [Actual Group Payment Type], 
    COUNT(*) as [Number of Zips]
FROM [lookup] l
JOIN [actuals] a ON l.ZipCode = a.ZipCode
GROUP BY l.PaymentType, a.PaymentType
)
SELECT
SUM([result].[Number of Zips]) AS [Total],
SUM(CASE WHEN [result].[Actual Group Payment Type] = 'VI' THEN [result].[Number of Zips] ELSE 0 END) as [Visa],
SUM(CASE WHEN [result].[Actual Group Payment Type] <> 'VI' THEN [result].[Number of Zips] ELSE 0 END) as [Non-Visa],
SUM(CASE WHEN [result].[Actual Group Payment Type] = 'VI' THEN [result].[Number of Zips] ELSE 0 END) * 100.0
   / SUM([result].[Number of Zips]) AS [Visa Percent]
FROM [result]
GO

/*Calculate overall accuracy of prediction*/
USE SQLBook;
DECLARE @YEAR VARCHAR(4) = '2015';

WITH
[lookup] AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate < @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    ) zg 
    WHERE [SequentialNumber] = 1
),
[actuals]  AS (
    SELECT
        ZipCode, 
        PaymentType
    FROM (
        SELECT
            [ZipCode], 
            [PaymentType], 
            COUNT(*) as [Count],
            ROW_NUMBER() OVER 
            (PARTITION BY [ZipCode] ORDER BY COUNT(*) DESC,[PaymentType]) 
            AS [SequentialNumber]
      FROM dbo.Orders
        WHERE OrderDate >= @YEAR + '-01-01'
        GROUP BY ZipCode, PaymentType
    )zg 
    WHERE [SequentialNumber] = 1
),
[result] AS (
SELECT
    l.PaymentType AS [Predicted Group Payment Type], 
    a.PaymentType AS [Actual Group Payment Type], 
    COUNT(*) as [Number of Zips]
FROM [lookup] l
JOIN [actuals] a ON l.ZipCode = a.ZipCode
WHERE l.PaymentType = a.PaymentType 
GROUP BY l.PaymentType, a.PaymentType
)
SELECT
4727 AS [Total],
SUM([result].[Number of Zips]) AS [Correctly Predicted],
SUM([result].[Number of Zips]) * 100.0 / 4727 AS [Percent]
FROM [result]
GO

/* The modul use one Variable, conditional probability of a customer stopping by market*/
USE SQLBook;
SELECT
	Market,
	AVG(IIF(MonthlyFee < 365 AND StopType IS NOT NULL, 1.0, 0)) AS StopProbability,
	SUM(IIF(MonthlyFee < 365 AND StopType IS NOT NULL, 1, 0)) AS NumStops,
	SUM(IIF(MonthlyFee < 365 AND StopType IS NOT NULL, 0, 1)) AS NumNotStops
FROM Subscribers
WHERE YEAR(StartDate) = 2005
GROUP BY Market
ORDER BY Market
GO

/*Customer Signature where Sales before the cutoff date are included and State can be chosen*/
USE SQLBook;
DROP FUNCTION IF EXISTS A01049690_Get_SumOfTotalPrice_Signature
GO

CREATE FUNCTION A01049690_Get_SumOfTotalPrice_Signature
(   
   @CutoffDate  DateTime, @state varchar(255)
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
   WHERE [OrderDate] < @CutoffDate AND
         [OrderDate] < DATEADD(month,1,@CutoffDate) 

 
   GROUP BY [ZipCode]) o
ON zc.[zcta5] = o.[ZipCode]
WHERE [Latitude] BETWEEN 24 AND 50 AND
      [Longitude] BETWEEN -125 AND -65
      AND zc.Stab = @state 
	  )
GO
SELECT * FROM A01049690_Get_SumOfTotalPrice_Signature('2016-09-01','NY');
GO