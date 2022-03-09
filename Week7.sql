--Assignment 7 | Sampling and Data Models
--Azarm Piram | A01195657
-------------------------------------------------------------------------------
--Random Sample data from Customer table:
USE SQLBook
GO
SELECT 
	TOP 10 PERCENT *,
	NEWID() AS [GUID]
FROM Customers
ORDER BY NEWID()
GO
-------------------------------------------------------------------------------
--Random Sample data from Order table:
USE SQLBook
GO
SELECT 
	*
FROM Orders
WHERE (ABS(CAST((BINARY_CHECKSUM(*) * RAND()) as int)) % 100) < 10
GO
-------------------------------------------------------------------------------
--Random Sample data from Product table:
USE SQLBook
GO
SELECT 
	TOP 10 PERCENT *,
	NEWID() AS [GUID]
FROM Products
ORDER BY NEWID()
GO
-------------------------------------------------------------------------------
--Repeatable Random Sample
USE SQLBook
GO
WITH CTE_Random
AS 
(
	SELECT ROW_NUMBER() OVER (ORDER BY ProductId) as [RowNumber], *
	FROM Products
)
SELECT * FROM CTE_Random
WHERE ([RowNumber] * 88 - 11129) % 100 < 10
GO
-------------------------------------------------------------------------------
--1
--Avarage TotalPrice per sample customers
USE SQLBook
GO
WITH CTE_Customer  
AS
(
SELECT 
	TOP 5 PERCENT 
	C.CustomerId,
	O.TotalPrice,
	NEWID() AS [GUID]
FROM Customers C
RIGHT JOIN Orders O
ON O.CustomerId = C.CustomerId
ORDER BY NEWID()
)
SELECT 
	AVG(TotalPrice*1.0) AS [Overal Total Price Avg for Customers]
FROM CTE_Customer
GO
-------------------------------------------------------------------------------
--2
--Avarage TotalPrice per sample customers per Male, Female
USE SQLBook
GO
WITH CTE_Customer  
AS
(
SELECT 
	TOP 5 PERCENT 
	C.CustomerId,
	C.Gender,
	O.TotalPrice,
	NEWID() AS [GUID]
FROM Customers C
RIGHT JOIN Orders O
ON O.CustomerId = C.CustomerId
WHERE Gender <> ''
ORDER BY NEWID()
)
SELECT 
	Gender,
	AVG(TotalPrice*1.0) AS [Overal Total Price Avg for Customers]
FROM CTE_Customer
GROUP BY Gender
GO
-------------------------------------------------------------------------------
--Predictive model with no dimension
USE SQLBook
GO
WITH CTE_OrderLine
AS
(
SELECT
	O.OrderId,
	OrderDate,
	COUNT(*) AS [Product Diversity]
FROM OrderLines OL
LEFT JOIN Orders O
ON O.OrderId = OL.OrderId
WHERE YEAR(O.OrderDate) IN (2015,2016) --Model set, Score set
GROUP BY O.OrderId,OrderDate
)
SELECT
	YEAR(OrderDate) AS [Year],
	AVG([Product Diversity]) AS [Product Diversity]
FROM CTE_OrderLine
GROUP BY YEAR(OrderDate)
GO
-------------------------------------------------------------------------------
--3
--I have a sample data from product table
--Now, I would like to know the avg of TotalPrice per product sample
USE SQLBook
GO
WITH CTE_Product
AS
(
SELECT 
	TOP 30 PERCENT *,
	NEWID() AS [GUID]
FROM Products
ORDER BY NEWID()
)
SELECT 
	AVG(TotalPrice) AS [Avg of TotalPrice per Sample Product]
FROM OrderLines OL
INNER JOIN CTE_Product C
ON C.ProductId = OL.ProductId
GO
-------------------------------------------------------------------------------
--4
--I have a random sample data from order table here,
--Now, I would like to know how many orders have been placed in each month
USE SQLBook
GO
SELECT 
	MONTH(OrderDate) AS [Month],
	COUNT(*) AS [Number of Orders]
FROM Orders
WHERE (ABS(CAST((BINARY_CHECKSUM(*) * RAND()) as int)) % 100) < 10 
GROUP BY MONTH(OrderDate)
ORDER BY MONTH(OrderDate)
GO
-------------------------------------------------------------------------------
--5
--I have a random sample data from order table here,
--Now, I would like to know the avg of total price for January per each year
USE SQLBook
GO
WITH CTE_Jan
AS
(
SELECT 
	*
FROM Orders
WHERE (ABS(CAST((BINARY_CHECKSUM(*) * RAND()) as int)) % 100) < 10 AND MONTH(OrderDate) = 1
)
SELECT
	YEAR(OrderDate) AS [Year],
	AVG(TotalPrice) AS [Total Price Avg based on random data]
FROM CTE_Jan
GROUP BY YEAR(OrderDate)
GO
-------------------------------------------------------------------------------
--6
--Balanced Sample
--Purchases below 1000 made by female and male
USE SQLBook
GO
WITH X 
AS 
(
   SELECT
      *, 
      ROW_NUMBER() OVER (PARTITION BY [GENDER] ORDER BY NEWID()) AS [RowNumber]
   FROM (
      SELECT
         O.CustomerId,
		 OrderId,
		 TotalPrice,
		 OrderDate,
         (CASE WHEN Gender = 'F' THEN 1 ELSE 0 END) AS [GENDER]
      FROM Orders O
	  LEFT JOIN Customers C
	  ON C.CustomerId = O.CustomerId
      WHERE TotalPrice <= 1000 AND Gender <> ''
   ) X
)
SELECT OrderDate,
   (CASE WHEN [GENDER] = 1 THEN [TotalPrice] END) as [Female],
   (CASE WHEN [GENDER] = 0 THEN [TotalPrice] END) as [Male]
FROM X
WHERE [RowNumber] <= 150;
GO
-------------------------------------------------------------------------------
--7
--All purchases made either in NeyYork city or other states
USE SQLBook
GO
WITH X AS (
   SELECT
      *, 
      ROW_NUMBER() OVER (PARTITION BY [IsNY] ORDER BY NEWID()) AS [RowNumber]
   FROM (
      SELECT
         *,
         (CASE WHEN State = 'NY' THEN 1 ELSE 0 END) AS [IsNY]
      FROM Orders
   ) X
)
SELECT [OrderDate],
   (CASE WHEN [IsNY] = 1 THEN [TotalPrice] END) as [NY],
   (CASE WHEN [IsNY] = 0 THEN [TotalPrice] END) as [NotNY]
FROM X
WHERE [RowNumber] <= 150;
GO
-------------------------------------------------------------------------------
--8
--All orders purchased in first day of all months or in rest days of all months in 2016
USE SQLBook
GO
WITH X AS (
   SELECT
      *, 
      ROW_NUMBER() OVER (PARTITION BY [IsFirstDayOfMonth] ORDER BY NEWID()) AS [RowNumber]
   FROM (
      SELECT
         *,
         (CASE WHEN DAY(OrderDate) = 1 THEN 1 ELSE 0 END) AS [IsFirstDayOfMonth]
      FROM Orders
	  WHERE YEAR(OrderDate) = 2016
   ) X
)
SELECT [OrderDate],
   (CASE WHEN [IsFirstDayOfMonth] = 1 THEN [TotalPrice] END) as [TotalPrice_FirstDayOfMonth],
   (CASE WHEN [IsFirstDayOfMonth] = 0 THEN [TotalPrice] END) as [TotalPrice_Not_IsFirstDayOfMonth]
FROM X
WHERE [RowNumber] <= 150;
GO
-------------------------------------------------------------------------------
--9
--Based on number of orders in 2015, predict the number of order in 2016.
USE SQLBook
GO
DECLARE @FallBack2015Count FLOAT = (SELECT COUNT(OrderId) FROM [Orders] WHERE YEAR(OrderDate) = 2015);
WITH
ScoreSet 
AS 
(
	SELECT * FROM Orders WHERE YEAR(OrderDate) = 2016
),
ModelSet 
AS 
(
	SELECT
		[State], 
		COUNT(OrderId) as [# Orders in 2015]
	FROM Orders WHERE YEAR(OrderDate) = 2015
	GROUP BY State
)
SELECT
	ScoreSet.*,
	ModelSet.[# Orders in 2015],
	@FallBack2015Count
	FROM ScoreSet LEFT JOIN ModelSet
	ON ScoreSet.[State] = ModelSet.[State]
	ORDER BY ModelSet.[# Orders in 2015]
GO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------



