--Assignment 5 
--SQLBook
--Azarm Piran | A01195657
--This file contains queries ONLY based on SQLBook.
-----------------------------------------------------------------------------------
--1
--Scalar Function
--Function receives a number as a year and retunrs the total sale
USE SQLBook
GO
IF OBJECT_ID (N'A01195657_01', N'FN') IS NOT NULL  
    DROP FUNCTION A01195657_01; 
GO
CREATE FUNCTION dbo.A01195657_01(@Year int)
RETURNS float 
AS
BEGIN
DECLARE @Arg float;
SELECT
	@Arg = SUM(TotalPrice)
FROM Orders O
WHERE YEAR(OrderDate) = @Year;
RETURN @Arg;
END;
GO
SELECT dbo.A01195657_01(2011) AS [Total Sale Per Year]
GO
-----------------------------------------------------------------------------------
--2
--Scalar Function
--Function receives a number as a year and a state abbrivation and retunrs the total sale per year and state
USE SQLBook
GO
IF OBJECT_ID (N'dbo.A01195657_02', N'FN') IS NOT NULL  
    DROP FUNCTION A01195657_02; 
GO
CREATE FUNCTION dbo.A01195657_02(@Year int,@State varchar(50))
RETURNS float
AS
BEGIN
DECLARE @Arg float;
SELECT
	@Arg = SUM(TotalPrice)
FROM Orders O
WHERE YEAR(OrderDate) = @Year AND State = @State;
RETURN @Arg;
END;
GO
SELECT dbo.A01195657_02(2011,'DE') AS [Total Sale Per Year and State]
GO
-----------------------------------------------------------------------------------
--3
--Scalar Function
--Function receives a number as a year and a product group name and retunrs the total sale per product group and year
USE SQLBook
GO
IF OBJECT_ID (N'A01195657_03', N'FN') IS NOT NULL  
    DROP FUNCTION A01195657_03;
GO
CREATE FUNCTION A01195657_03(@Year int,@GroupName varchar(50))
RETURNS float
AS
BEGIN
DECLARE @Arg float;
WITH CTE_3
AS
(
SELECT
	P.GroupName,
	YEAR(O.OrderDate) AS [Year],
	SUM(OL.TotalPrice) AS [Total Sale]
FROM OrderLines OL
LEFT JOIN Orders O
ON O.OrderId = OL.OrderId
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
GROUP BY GroupName,YEAR(O.OrderDate)
)
SELECT 
	@Arg = [Total Sale]
FROM CTE_3
WHERE [Year] = @Year AND GroupName = @GroupName
RETURN @Arg;
END;
GO
SELECT dbo.A01195657_03(2009,'BOOK') AS [Sales per Year and Product Category]
GO
-----------------------------------------------------------------------------------
--4
--Table Function | Using CASE in group by
--Top 5 customers per state, year and month
USE SQLBook;
GO
IF OBJECT_ID (N'A01195657_04', N'IF') IS NOT NULL  
    DROP FUNCTION A01195657_04;
GO
CREATE FUNCTION dbo.A01195657_04(@Year int, @Month int, @State varchar(50))
RETURNS TABLE
AS
RETURN
(
SELECT
	TOP 5
	YEAR(OrderDate) AS [Year],
	MONTH(OrderDate) AS [Month],
	State,
	CASE Gender
		WHEN 'M' THEN 'Male'
		WHEN 'F' THEN 'Female'
		ELSE 'Unknown'
	END as [Gender],
	O.CustomerId,
	C.FirstName,
	SUM(TotalPrice) AS [Sale]
FROM Orders O
LEFT JOIN Customers C
ON C.CustomerId = O.CustomerId
GROUP BY YEAR(OrderDate),MONTH(OrderDate),State,
	CASE Gender
		WHEN 'M' THEN 'Male'
		WHEN 'F' THEN 'Female'
		ELSE 'Unknown'
	END,
	O.CustomerId,C.FirstName
HAVING YEAR(OrderDate) = @Year AND MONTH(OrderDate) = @Month AND State = @State
ORDER BY YEAR(OrderDate),MONTH(OrderDate),State,SUM(TotalPrice) DESC
);
GO
SELECT * FROM A01195657_04(2010,10,'NY')
GO
-----------------------------------------------------------------------------------
--5
--Table Function
--Top 10 products per state,year and month
USE SQLBook;
GO
IF OBJECT_ID (N'A01195657_05', N'IF') IS NOT NULL  
    DROP FUNCTION A01195657_05;
GO
CREATE FUNCTION dbo.A01195657_05(@Year int, @Month int, @State varchar(50))
RETURNS TABLE
AS
RETURN
(
SELECT
	TOP 10
	YEAR(OrderDate) AS [Year], 
	MONTH(OrderDate) AS [Month],
	State,
	ProductId,
	SUM(OL.TotalPrice) AS [Total Price]
FROM OrderLines OL
LEFT JOIN Orders O
ON O.OrderId = OL.OrderId
GROUP BY YEAR(OrderDate), MONTH(OrderDate), State, ProductId
HAVING YEAR(OrderDate) = @Year AND MONTH(OrderDate) = @Month AND State = @State
ORDER BY YEAR(OrderDate), MONTH(OrderDate),SUM(OL.TotalPrice) DESC
);
GO
SELECT * FROM A01195657_05(2009, 11, 'NY')
GO
-----------------------------------------------------------------------------------
--6
--Table Function | Rollup
--Number of orders and SubTotal of orders per each state in a specific date which is a argument
USE SQLBook;
GO
IF OBJECT_ID (N'A01195657_06', N'IF') IS NOT NULL  
    DROP FUNCTION A01195657_06;
GO
CREATE FUNCTION dbo.A01195657_06(@OrderDate date)
RETURNS TABLE
AS
RETURN
(
SELECT
	IIF(GROUPING(State) = 1, 'SubTotal', State) AS State,
	OrderDate,
	COUNT(*) AS [Number of Orders],
	SUM(TotalPrice) AS [Total Price]
FROM Orders O
GROUP BY ROLLUP(State),OrderDate
HAVING OrderDate = @OrderDate
);
GO
SELECT * FROM A01195657_06('2010-01-20') ORDER BY [Number of Orders],[Total Price]
GO
-----------------------------------------------------------------------------------
---7
--Table Function
--Number of orders and SubTotal of orders between two order dates
USE SQLBook;
GO
IF OBJECT_ID (N'A01195657_07', N'IF') IS NOT NULL  
    DROP FUNCTION A01195657_07;
GO
CREATE FUNCTION dbo.A01195657_07(@StartDate date, @EndDate date)
RETURNS TABLE
AS
RETURN
(
SELECT
	OrderDate,
	COUNT(*) AS [Number of Orders],
	SUM(TotalPrice) AS [Total Price]
FROM Orders O
GROUP BY ROLLUP(OrderDate)
HAVING @StartDate < OrderDate AND @EndDate > OrderDate
);
GO
SELECT * FROM A01195657_07('2010-01-20','2010-01-28') ORDER BY OrderDate,[Number of Orders],[Total Price]
GO
-----------------------------------------------------------------------------------
--8
--Table Function | Pivot
--Number of orders per each day of the week in a pivot format per @year and @month
USE SQLBook;
GO
IF OBJECT_ID (N'A01195657_08', N'IF') IS NOT NULL  
    DROP FUNCTION A01195657_08;
GO
CREATE FUNCTION dbo.A01195657_08(@Year int, @Month int)
RETURNS TABLE
AS
RETURN
(
WITH Day_CTE
AS
(
SELECT 
	C.DOW AS [WeekDay] 
FROM Orders AS O 
LEFT JOIN Calendar AS C 
ON O.OrderDate = C.Date
WHERE YEAR(OrderDate) = @Year AND MONTH(OrderDate) = @Month
)
SELECT
	'Number of Orders' AS [WeekDay],
	[Fri],
	[Sun],
	[Sat],
	[Tue],
	[Mon],
	[Wed],
	[Thu]
FROM Day_CTE
PIVOT
(
	COUNT([WeekDay])
	FOR [WeekDay]
	IN
	(
	[Fri],
	[Sun],
	[Sat],
	[Tue],
	[Mon],
	[Wed],
	[Thu]
	)
) AS DayPivot
)
GO
SELECT * FROM dbo.A01195657_08(2009, 10)
-----------------------------------------------------------------------------------
--9
--Table Function | pivot
--Number of orders per each month in pivot format for @year as an argument
USE SQLBook;
GO
IF OBJECT_ID (N'A01195657_09', N'IF') IS NOT NULL  
    DROP FUNCTION A01195657_09;
GO
CREATE FUNCTION dbo.A01195657_09(@Year int)
RETURNS TABLE
AS
RETURN
(
WITH Month_CTE
AS
(
SELECT 
	C.MonthAbbr AS [Month] 
FROM Orders AS O 
LEFT JOIN Calendar AS C 
ON O.OrderDate = C.Date
WHERE year(OrderDate) = @Year
)
SELECT
	'Number of Orders' AS [Month],
	[Jun],
	[May],
	[Sep],
	[Dec],
	[Aug],
	[Feb],
	[Nov],
	[Oct],
	[Apr],
	[Jul],
	[Jan],
	[Mar]
FROM Month_CTE

PIVOT
(
	COUNT([Month])
	FOR [Month]
	IN
	(
	[Jun],
	[May],
	[Sep],
	[Dec],
	[Aug],
	[Feb],
	[Nov],
	[Oct],
	[Apr],
	[Jul],
	[Jan],
	[Mar]
	)
) AS MonthPivot
)
GO
SELECT * FROM dbo.A01195657_09(2010)
GO
-----------------------------------------------------------------------------------
--10
--Table Function
--List of availablity of all products per product group
USE SQLBook;
GO
IF OBJECT_ID (N'A01195657_10', N'IF') IS NOT NULL  
    DROP FUNCTION A01195657_10;
GO
CREATE FUNCTION dbo.A01195657_10(@GroupName varchar(50))
RETURNS TABLE
AS
RETURN
(
SELECT
	ProductId,
	GroupName,
	IIF(IsInStock = 'N','-','Available') AS [Availability]
FROM Products P
WHERE GroupName = @GroupName 
);
GO
SELECT * FROM dbo.A01195657_10('CALENDAR') ORDER BY Availability
GO
-----------------------------------------------------------------------------------
--11
--Table Function
--List of all orders per year argument which are greater that a specific amount @TotalPrice
USE SQLBook;
GO
IF OBJECT_ID (N'A01195657_11', N'IF') IS NOT NULL  
    DROP FUNCTION A01195657_11;
GO
CREATE FUNCTION dbo.A01195657_11(@Year int,@TotalPrice money)
RETURNS TABLE
AS
RETURN
(
SELECT
	OrderId,
	OrderDate,
	City,
	TotalPrice
FROM Orders O
WHERE YEAR(OrderDate) = @Year AND TotalPrice > @TotalPrice
);
GO
SELECT * FROM A01195657_11(2009, 40.00) ORDER BY OrderDate,TotalPrice
GO
-----------------------------------------------------------------------------------
