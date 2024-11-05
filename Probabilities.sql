/*1. What is % of probability and % of chance to Use American Express*/
DECLARE @t1 DATETIME2 = SYSDATETIME();
WITH AmExpress AS 
(
	SELECT AVG(IIF([PaymentType] = 'AE', 100.0, 0)) AS AmEx
	FROM [SQLBook].[dbo].[Orders]
)
SELECT
	FORMAT(AmEx, 'N2')  AS [AmEx Payment % Probability],
	FORMAT(AmEx/(100 - AmEx)*100, 'N2') AS [Amex Payment % Chance]
FROM AmExpress
GO

/*2. What is % of probability and % of chance to Use Visa*/
DECLARE @t5 DATETIME2 = SYSDATETIME();
WITH 
VISACard AS 
(
	SELECT AVG(IIF([PaymentType] = 'VI', 100.0, 0)) AS VISA
	FROM [SQLBook].[dbo].[Orders] 
)
SELECT
    FORMAT(VISA, 'N2')  AS [VISA Payment % Probability],
	FORMAT(VISA/(100 - VISA)*100, 'N2') AS [VISA Payment % Chance]
FROM VISACard
GO
	

/*3. What in the probability for Customer using Visa Or Master Cards?*/
DECLARE @t2 DATETIME2 = SYSDATETIME();
WITH  VISACard AS 
(
	SELECT AVG(IIF([PaymentType] = 'VI', 100.0, 0)) AS VISA
	FROM [SQLBook].[dbo].[Orders] 
),
MasterCard AS (
    SELECT AVG(IIF([PaymentType] = 'MC', 100.0, 0)) AS MasterC
	FROM [SQLBook].[dbo].[Orders]
)
SELECT
    FORMAT(VISACard.VISA + MasterCard.MasterC, 'N2')AS [VISA OR Master Card Payment % Probability]
	FROM VISACard,MasterCard
GO

/*4.Probability using missing of Data Payment Type*/ 
 DECLARE @t3 DATETIME2 = SYSDATETIME();
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
	FORMAT(100 - AmExpress.AmEx - VISACard.VISA -MasterCard.MasterC
	- OverCard.OverC , 'N2')  AS [% missing of Data Payment Type]
    FROM AmExpress, VISACard,MasterCard,OverCard
GO

/*5. What is probability of Master Card Payment in States: MA, MI and TX*/
DECLARE @t4 DATETIME2 = SYSDATETIME();
WITH MC AS ( 
    SELECT 
    [State],
    AVG(IIF([PaymentType] = 'MC', 100.0, 0)) AS MasterC
	FROM [SQLBook].[dbo].[Orders]
	GROUP BY [State]
)
SELECT
    [State],
    FORMAT (MC.MasterC, 'N2')  AS [Master Card Payment % Probability]
FROM MC
WHERE [State] = 'MA' OR [State] ='MI' OR [State] ='TX'
GO

/*6. What is probability that next payment will be proceeded in New York State
By American Axpress*/
DECLARE @t6 DATETIME2 = SYSDATETIME();
WITH  VISACard AS 
(
	SELECT AVG(IIF([State] = 'NY', 1.0, 0)) AS [New York],
	       AVG(IIF([PaymentType] = 'AE', 1.0, 0)) AS [AmEx]
	FROM [SQLBook].[dbo].[Orders] 
)
SELECT
    [New York],
	[AmEx],
	([New York] * [AmEx])*100 AS [Probability %]
FROM VISACard
GO

/*7. What is probability that next payment will be proceeded in New York State
By Master Card. Grouping Payment Type by State as well for more accuracy*/
DECLARE @t7 DATETIME2 = SYSDATETIME();
WITH  MC AS 
(
	SELECT AVG(IIF([State] = 'NY', 1.0, 0)) AS [New York]
	FROM [SQLBook].[dbo].[Orders] 
),
Payment AS
(SELECT
        AVG(IIF([PaymentType] = 'MC', 1.0, 0)) AS [MC]
		FROM [SQLBook].[dbo].[Orders] 
		WHERE [State] = 'NY'
		GROUP BY [State]
)

SELECT
    MC.[New York],
	Payment.[MC],
   (MC.[New York] *Payment.[MC])*100 AS [Probability %]
FROM MC, Payment
GO

/*8. What in the probability for Customers using Visa first and next payment proceed by Master Card?*/
DECLARE @t8 DATETIME2 = SYSDATETIME();
WITH  VISACard AS 
(
	SELECT AVG(IIF([PaymentType] = 'VI', 1.0, 0)) AS VISA
	FROM [SQLBook].[dbo].[Orders] 
),
MasterCard AS (
    SELECT AVG(IIF([PaymentType] = 'MC', 1.0, 0)) AS MasterC
	FROM [SQLBook].[dbo].[Orders]
)
SELECT
    FORMAT(VISACard.VISA * MasterCard.MasterC*100, 'N2')AS [VISA and then Master Card Payment % Probability]
	FROM VISACard,MasterCard
GO

/*9. What is the Chance for Customers using Visa first and next payment proceed by Master Card?*/
DECLARE @t9 DATETIME2 = SYSDATETIME();
WITH  VISACard AS 
(
	SELECT AVG(IIF([PaymentType] = 'VI', 1.0, 0)) AS VISA
	FROM [SQLBook].[dbo].[Orders] 
),
MasterCard AS (
    SELECT AVG(IIF([PaymentType] = 'MC', 1.0, 0)) AS MasterC
	FROM [SQLBook].[dbo].[Orders]
)
SELECT
    FORMAT((VISACard.VISA * MasterCard.MasterC)
	/(1 -(VISACard.VISA * MasterCard.MasterC)) * 100, 'N2')AS [VISA and then Master Card Payment % Chance]
	FROM VISACard,MasterCard
GO

/*Show probability all Payment Methods*/
DECLARE @t10 DATETIME2 = SYSDATETIME();
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
),
Other AS
(    SELECT
	FORMAT(100 - AmExpress.AmEx - VISACard.VISA -MasterCard.MasterC
	- OverCard.OverC , 'N2')  AS [Other]
    FROM AmExpress, VISACard,MasterCard,OverCard
)
SELECT FORMAT(AmEx,'N2') AS AmExpress,
       FORMAT(VISA,'N2') AS VISA,
       FORMAT(MasterC,'N2') AS MasterC,
	   FORMAT(OverC,'N2') AS OverC,
	   Other
FROM AmExpress,VisaCard,MasterCard,OverCard,Other





	