/*1. Show top 10 cities,which year they had  max orders and number of orders during that year*/ 
WITH TopNumberOfOrders(s, y, x, rownumber) AS (
	SELECT 
		o.[City],
		YEAR(o.OrderDate),
		COUNT(*),
		ROW_NUMBER() OVER (PARTITION BY o.[City] ORDER BY COUNT(*) DESC)
	FROM SQLBook.dbo.Orders o
	GROUP BY o.[City], YEAR(o.OrderDate)
)
SELECT TOP (10) s AS [City], y AS [Year], x AS [Max Orders]
FROM TopNumberOfOrders
WHERE rownumber = 1 AND s != ''
ORDER BY x DESC;
GO

/*2. Find products which year they have max number of shipped products. where shipped product more that 4000 */
WITH TopProductsNumbers(s, y, x, rownumber) AS (
SELECT
     [ProductID],
	 Year(ShipDate) AS Year,
	 SUM (NumUnits),
	 ROW_NUMBER() OVER(PARTITION BY [ProductID] ORDER BY COUNT(*) DESC)
FROM [SQLBook].dbo.OrderLines
GROUP BY [ProductId], YEAR(ShipDate)
)
SELECT s AS [Product ID] ,y AS [Year], x AS[Max # shipped Products]
FROM TopProductsNumbers
WHERE rownumber = 1 AND s != '' AND x > 4000
ORDER BY x DESC
GO

/*3. Cities with 3 max numbers of sales and 3 of min number of sales*/
WITH
sales(city, num) AS (
	SELECT
		City,
		sales.num AS [Number of Orders]
	FROM (
		SELECT City, [City] AS id, COUNT(*) AS num
			FROM  SQLBook.dbo.Orders
			WHERE [City] IS NOT NULL
			GROUP BY [City]
		) sales
	),
   
leading(City, num, r) AS (
	SELECT TOP(5) sales.city, sales.num,
		ROW_NUMBER() OVER(ORDER by sales.num DESC) FROM sales
),
trailing(City, num, r) AS (
	SELECT TOP(5) sales.city, sales.num,
		ROW_NUMBER() OVER(ORDER by sales.num ASC) FROM sales
)
SELECT
	l.city AS Leading, l.num AS Sales, 
	t.city AS Trailing, t.num AS Sales
FROM leading l
JOIN trailing t
ON l.r = t.r
GO

/*4. States with 5 max numbers of sales and 5 of min number of sales*/
WITH
sales([State], num) AS (
	SELECT
		[State],
		sales.num AS [Number of Orders]
	FROM (
		SELECT [State], [State] AS id, COUNT(*) AS num
			FROM  SQLBook.dbo.Orders
			WHERE [State] IS NOT NULL
			GROUP BY [State]
		) sales
	),
   
leading(State, num, r) AS (
	SELECT TOP(5) sales.state, sales.num,
		ROW_NUMBER() OVER(ORDER by sales.num DESC) FROM sales
),
trailing(State, num, r) AS (
	SELECT TOP(5) sales.state, sales.num,
		ROW_NUMBER() OVER(ORDER by sales.num ASC) FROM sales
)
SELECT
	l.state AS Leading, l.num AS Sales, 
	t.state AS Trailing, t.num AS Sales
FROM leading l
JOIN trailing t
ON l.r = t.r
GO 


/*5. Rank of CampaignID by City of Number of Units, where Num of Units more that 1000 */

USE  SQLBook;
GO
SELECT 
     CampaignId,
	 City,
	 NumUnits,
	 RANK() OVER (
	         PARTITION BY City ORDER BY NumUnits DESC) AS RANK
FROM [SQLBook].dbo.Orders
WHERE NumUnits > 1000
ORDER BY NumUnits
GO

/*6. Rank of CampaignID by City of Number of Units without any gaps in ranking, where Num of Units more that 1000 */

USE  SQLBook;
GO
SELECT 
     CampaignId,
	 City,
	 NumUnits,
	 DENSE_RANK() OVER (
	         PARTITION BY City ORDER BY NumUnits DESC) AS RANK
FROM [SQLBook].dbo.Orders
WHERE NumUnits > 1000
ORDER BY NumUnits
GO



/*7 Show Max orders grouped  by Payment Type and year */
declare @type char(2);
declare @prevstate char(2) = '##';
declare @year int;
declare @orders int;

create table #tmpTable
(
	[type] char(2),
	[year] int,
	[orders] int
);

declare cursor_values cursor for
select
	o.[PaymentType],
	year(o.OrderDate),
	count(*)
from SQLBook.dbo.Orders o
where o.[PaymentType] != '' and o.PaymentType != '??'
group by o.[PaymentType], year(o.OrderDate)
order by o.[PaymentType], count(*) desc, year(o.OrderDate) desc;

open  cursor_values;
fetch next from cursor_values into @type, @year, @orders;

while @@FETCH_STATUS = 0
begin
	if(@prevstate != @type) insert into #tmpTable values (@type, @year, @orders);
	set @prevstate = @type;
	fetch next from cursor_values into @type, @year, @orders;
end

close cursor_values;
deallocate cursor_values;

select * from #tmpTable
order by [type], [year];

drop table #tmpTable;
GO

/* 8. Show 5 States and days since last order*/
SELECT TOP (5)
[State],
[OrderDate],
LAG([OrderDate]) OVER (
    PARTITION BY[City] ORDER BY [OrderDate])
	AS [Previous Order Date],
	DATEDIFF(
	day,LAG([City]) OVER(
	PARTITION BY [City] ORDER BY[OrderDate]),
	[OrderDate]
	)AS [Days Since Last Order]
FROM [SQLBook].[dbo].[Orders]
ORDER BY City,[OrderDate]
GO

/*9. Best Customers by max sales order in RI State with sales more that 400*/
USE [SQLBook];
GO
SELECT 
     ROW_NUMBER() OVER(PARTITION by [State] ORDER BY [TOTALPRICE] DESC)
	 AS [Row Number],
	 p.[FirstName] as [Customer Person],
	 s.[TotalPrice]
	 FROM[dbo].[Orders] AS s
    JOIN [dbo].[Customers] AS p
	ON s.CustomerId = p.CustomerId
WHERE [OrderId] IS NOT NULL AND [TotalPrice] <>0 AND State IN('RI') AND [TotalPrice] > 400
ORDER BY [State];
GO

/*10. Cumulative Avarage and total of sales more than 5000 by State 'CA'*/
USE SQLBook;
GO
SELECT
     [State],
     DATEPART(yy, [OrderDate]) AS [Year], 
     CONVERT(varchar(20),TotalPrice,1) AS [Sales YTD],
     CONVERT(varchar(20), AVG(TotalPrice) OVER (
        PARTITION BY [State]  
        ORDER BY DATEPART(yy, [OrderDate])   
     ), 1) AS [Average],
	 CONVERT(varchar(20), SUM(TotalPrice) OVER (
        PARTITION BY [State]  
        ORDER BY DATEPART(yy, [OrderDate])   
     ), 1) AS [Cumulative Total]  
FROM dbo.Orders 
WHERE [State] = 'CA' AND TotalPrice > 5000 
ORDER BY State, [Year]; 

GO


/*11. The difference between the sales value for the current quarter and the first and last quarter of the 2016 year By State 'DE' */

SELECT 
      [State],
	  DATEPART(QUARTER,[OrderDate]) AS [Quarter],
	  YEAR([OrderDate]) AS [Sales Year],
	  [TotalPrice],
	  TotalPrice - FIRST_VALUE(TotalPrice)
	           OVER (
			        PARTITION BY [State], YEAR([OrderDate])
					ORDER BY DATEPART(QUARTER, OrderDate)
					) AS [Difference From First Quarter],  
	  TotalPrice - LAST_VALUE(TotalPrice)
	            OVER (
				    PARTITION BY [State], YEAR([OrderDate])
					ORDER BY DATEPART(QUARTER, OrderDate)
				    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
        ) AS [Difference From Last Quarter]  
FROM [SQLBook].dbo.Orders
WHERE YEAR(OrderDate) > 2015 AND [State] = 'DE'
ORDER BY [Sales Year],[Quarter]
GO

/*12. Show customers and days sins last order*/
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
WHERE [CustomerID] != 0
ORDER BY [CustomerId],[OrderDate]

/*13.  Show Cumulative total  and Average of yearly sales by State -'TX'*/

SELECT TOP (5)
     [State],
	 DATEPART(yy, OrderDate) AS [Year] , 
     CONVERT(varchar(20), TotalPrice,1) AS [Sales],
     CONVERT(varchar(20), AVG(TotalPrice) OVER (
        PARTITION BY [State]  
        ORDER BY DATEPART(yy, OrderDate)   
     ), 1) AS [Average] 
   , CONVERT(varchar(20), SUM(TotalPrice) OVER (
        PARTITION BY [State] 
        ORDER BY DATEPART(yy, OrderDate)   
     ), 1) AS [Cumulative Total]  
FROM SQLBook.dbo.Orders
WHERE [State] = 'TX'
ORDER BY [State], [Year]; 