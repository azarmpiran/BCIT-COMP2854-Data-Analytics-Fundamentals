
--Azarm Piran
--Student ID: A01195657
-- Assignment 1
USE AdventureWorks2017
GO
--Group by
--I would like to know total number of quantity in an order.
--Lets say I have 2 kind of products in an order. I ordered 2 of the first one and 3 of the second one. 
-- It will be 5 totally per this order.
SELECT
	OD.SalesOrderID,
	SUM(OD.OrderQty) AS TotalProductQtyPerOrder
FROM Sales.SalesOrderDetail AS OD
GROUP BY SalesOrderID
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--GROUP BY
-- Total money that each customer paid on their orders each year
SELECT 
	CustomerID,
	year(ModifiedDate) AS year,
	SUM(SubTotal) AS TOTALPRICE
FROM [Sales].[SalesOrderHeader]
GROUP BY  CustomerID, ModifiedDate
ORDER BY  CustomerID,ModifiedDate
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Group by
--I would like to know how many times we orderd each product
--Lets say, how many times customers ordered productID = 925 totally
--In this query we can see, the product id = 712 has been ordered the most.
 SELECT
	OD.ProductID,
	SUM(OD.OrderQty) AS NumberOfProductPerAllOrders
FROM Sales.SalesOrderDetail AS OD
GROUP BY ProductID
ORDER BY SUM(OD.OrderQty) DESC
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Group by - Several Fields
--I would like to know what is the Max and min price for each product per year. 
SELECT 
	ProductID,
	YEAR(ModifiedDate) AS Year,
	MAX(UnitPrice) AS MaxPrice,
	min(UnitPrice) AS minPrice
FROM [AdventureWorks2017].[Sales].[SalesOrderDetail]
GROUP BY ProductID, YEAR(ModifiedDate)
ORDER BY ProductID,YEAR(ModifiedDate)
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Group by - Having
-- I would like to have the list of all orders when the total number of OrderQty for is more that 20
SELECT
	OD.SalesOrderID,
	SUM(OD.OrderQty) AS TotalProductQtyPerOrder
FROM Sales.SalesOrderDetail AS OD
GROUP BY SalesOrderID
HAVING SUM(OD.OrderQty) > 20
ORDER BY SUM(OD.OrderQty) 
GO
--Rollup
-- Total number of payments by each type of CreditCards 
--and the total number of payments for all Creditcards in all orders by ROLLUP 
WITH CreditCardPurchases_CTE
AS
(
  SELECT
	SOH.CreditCardID ID
  FROM Sales.SalesOrderHeader SOH 
  WHERE CreditCardID IS NOT NULL
)
SELECT 
COUNT(ID) AS Amount,
CC.CardType
FROM CreditCardPurchases_CTE AS CTE
LEFT JOIN Sales.CreditCard CC
ON CC.CreditCardID = CTE.ID
GROUP BY ROLLUP(CC.CardType)
GO
--LEFT JOIN
-- I would like to know that each order belongs to which customer with their first name and last name. Plus their credit card information
SELECT 
	OH.SalesOrderID,
	--MODIFY THE DATE FORMAT HERE
	OH.OrderDate,
	OH.CustomerID,
	--CONCAT FIRST NAME AND LAST NAME
	P.FirstName,
	P.LastName,
	-- USE IF STATEMENT FOR THIS PART AZARM
	OH.OnlineOrderFlag,
	CC.CardNumber,
	CC.CardType,
	CC.ExpMonth,
	CC.ExpYear
FROM Sales.SalesOrderHeader AS OH
LEFT JOIN Person.Person P
ON P.BusinessEntityID = OH.CustomerID
LEFT JOIN Sales.PersonCreditCard AS PCC
ON P.BusinessEntityID = PCC.BusinessEntityID
LEFT JOIN Sales.CreditCard AS CC
ON CC.CreditCardID = PCC.CreditCardID
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--RIGHT JOIN
-- Distinct count of all products that a customer ordered. 
--Lets say customer ID = 29543 has 8 orders. These 8 orders totally have 179 order line and products. BUT there is only 59 kind of 
-- products that they ordered. Product diversity is 59.
SELECT
	SOH.CustomerID,
	COUNT(DISTINCT SOD.ProductID) AS ProductDiversity
FROM [Sales].[SalesOrderHeader] AS SOH
RIGHT JOIN  [Sales].[SalesOrderDetail] AS SOD
ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY CustomerID
ORDER BY CustomerID
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--LEFT JOIN
--
SELECT
	SOH.CustomerID,
	SOD.ProductID
FROM [Sales].[SalesOrderDetail] AS SOD
LEFT JOIN [Sales].[SalesOrderHeader] AS SOH
ON SOH.SalesOrderID = SOD.SalesOrderID
ORDER BY CustomerID
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--INNER JOIN
-- I would like to know the name of all products in each order
SELECT
	OD.SalesOrderID,
	OD.SalesOrderDetailID,
	OD.OrderQty,
	OD.ProductID,
	P.Name,
	OD.UnitPrice
FROM Sales.SalesOrderDetail AS OD
INNER JOIN Production.Product AS P
ON OD.ProductID = P.ProductID
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--FULL OUTER JOIN
-- List of all products name and ID with its orderID either they have been ordered so far or not
SELECT
	P.ProductID,
	P.Name,
	P.ProductNumber,
	SOD.SalesOrderID,
	SOD.SalesOrderDetailID
FROM Sales.SalesOrderDetail AS SOD
FULL OUTER JOIN Production.Product AS P
ON P.ProductID = SOD.ProductID
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--FULL OUTER JOIN
-- List of all products that they have never been ordered.
-- We have 238 products that never been ordered.
SELECT
	P.ProductID,
	P.Name,
	P.ProductNumber,
	SOD.SalesOrderID,
	SOD.SalesOrderDetailID
FROM Sales.SalesOrderDetail AS SOD
FULL OUTER JOIN Production.Product AS P
ON P.ProductID = SOD.ProductID
WHERE SOD.SalesOrderID IS NULL
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Cross Join
--List of all product Category and subcategory together
 SELECT
	PSC.ProductSubcategoryID,
	PSC.Name,
	PC.ProductCategoryID,
	PC.Name
  FROM Production.ProductSubcategory PSC
  CROSS JOIN Production.ProductCategory PC
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common table Expression
-- I would like to know the total number of each kind of shipping method in all orders
WITH ShipMethodCTE 
AS
(
SELECT 
 CASE 
		WHEN [ShipMethodID] = 1 THEN 'XRQ - TRUCK GROUND'
		WHEN [ShipMethodID] = 2 THEN 'ZY - EXPRESS'
		WHEN [ShipMethodID] = 3 THEN 'OVERSEAS - DELUXE'
		WHEN [ShipMethodID] = 4 THEN 'OVERNIGHT J-FAST'
		WHEN [ShipMethodID] = 5 THEN 'CARGO TRANSPORT 5'
 END AS ShipMethodDesc
FROM [Sales].[SalesOrderHeader]
)
SELECT
	*,
	COUNT(*) AS #
FROM ShipMethodCTE
GROUP BY [ShipMethodDesc]
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common table Expression with Argument
-- First I would like to know the number of orders per each customer. Then by using the common table expression, I would like to know
-- total number of customers, total number of orders and average number of orders per each customer.
WITH CustomerOrder_CTE (id, Number)  
AS  
(  
    SELECT CustomerID, COUNT(*) AS Number 
    FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]  
    GROUP BY CustomerID  
)  
SELECT 
    COUNT(id) AS [Total Customers], 
    SUM(Number)  AS [Total Orders], 
    AVG(Number)  AS [Average Order Per Customer]
FROM CustomerOrder_CTE;  
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common table Expression without Argument
-- Average number of orders per customer
WITH CustomerOrder_CTE  
AS  
(  
    SELECT CustomerID, COUNT(*) AS Number 
    FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]  
    GROUP BY CustomerID  
)  
SELECT 
    AVG(Number)  AS [Average Order Per Customer]
FROM CustomerOrder_CTE;  
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common Table Expression
--How many locations we can find each product by average.
-- This query tells us, we can find each product in 2 different inventory by average
WITH Inventory_CTE
AS
(
SELECT 
	ProductID,
	COUNT(*) AS Amount
FROM Production.ProductInventory 
GROUP BY ProductID
)
SELECT
AVG(Amount) AS AverageInventoryLocation
FROM Inventory_CTE
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common Table Expression
-- How many orders have been placed by each salesperson. Plus, sub total amount of orders per each sales person.
--Plus, How many Online Orders we have and how much is the sub total for all online orders.
WITH Flag_CTE
AS
(
SELECT 
	*,
	CASE
		WHEN OnlineOrderFlag = 1 THEN 'Online'
		WHEN OnlineOrderFlag = 0 THEN 'By SalesPerson'
	END AS OnlineFlag
FROM Sales.SalesOrderHeader SOH
)
SELECT 
	SalesPersonID,
	COUNT(OnlineFlag) OnlineFlag,
	SUM(SubTotal) SUM
FROM Flag_CTE
GROUP BY SalesPersonID
ORDER BY COUNT(OnlineFlag) 
GO
----------------------------------------------------------------------------------------------------------------------------------------------
USE SQLBook
GO
--GROUP BY | HAVING
-- Total money that each customer paid on their orders each year
SELECT 
	O.CustomerId,
	year(O.OrderDate) AS year,
	SUM(O.TotalPrice) AS TOTALPRICE
FROM [SQLBook].[dbo].[Orders] AS O
GROUP BY  CustomerId,OrderDate
HAVING CustomerId != 0
ORDER BY  CustomerId,OrderDate
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--GROUP BY | HAVING
-- I would like to know whether we have any customer who ordered more than 1 time or not.
-- Conculusion: There is only one order per each customer
SELECT 
		CustomerId, 
		COUNT(*) AS Number 
    FROM  [SQLBook].[dbo].[Orders] 
    GROUP BY CustomerId
	HAVING CustomerId != 0 and COUNT(*) > 1
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Group by
--I would like to know how many times we orderd each product
--Lets say, how many times customers ordered productID = 12820 totally
--In this query we can see, the product id = 12820 has been ordered the most.
 SELECT
	OL.ProductId,
	SUM(OL.NumUnits) AS NumberOfProductPerAllOrders
FROM [SQLBook].[dbo].[OrderLines] AS OL
GROUP BY ProductID
ORDER BY SUM(OL.NumUnits) DESC
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Group by - Several Fields
--I would like to know what is the Max and min price for each product per year. 
SELECT 
	ProductID,
	YEAR(BillDate) AS Year,
	MAX(UnitPrice) AS MaxPrice,
	min(UnitPrice) AS minPrice
FROM [SQLBook].[dbo].[OrderLines]
GROUP BY ProductID, YEAR(BillDate)
ORDER BY ProductID,YEAR(BillDate)
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Group by - Having
-- I would like to have the list of all orders when the total number of NumUnit is more that 20
--Lets say I have an order with 3 different products which there is 7 NumUnit per each product.
--Totally it will be 21 NumUnit per this Order and I should see this order in my list
SELECT
	OL.OrderId,
	SUM(OL.NumUnits) AS TotalProductQtyPerOrder
FROM [SQLBook].[dbo].[OrderLines] AS OL
GROUP BY OL.OrderId
HAVING SUM(OL.NumUnits) > 20
ORDER BY SUM(OL.NumUnits) 
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Rollup
-- Total number of orders by each type of payments 
--Plus, total amount of TotalPrice per each type of payments by using ROLLUP 
SELECT 
	O.PaymentType,
	COUNT(*) AS NumberOfOrders,
	SUM(O.TotalPrice) AS TotalPrice	
FROM [SQLBook].[dbo].[Orders] AS O
GROUP BY ROLLUP(O.PaymentType)
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--LEFT JOIN
-- I would like to know that each order belongs to which customer with their first name and last name. 
SELECT 
	O.OrderId,
	O.OrderDate,
	O.CustomerId,
	C.FirstName,
	C.Gender,
	O.City,
	O.State,
	O.TotalPrice
FROM [SQLBook].[dbo].[Orders] AS O
LEFT JOIN [SQLBook].[dbo].[Customers] AS C
ON C.CustomerId = O.CustomerId
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--RIGHT JOIN
-- Distinct count of all products that a customer ordered. 
--Lets say customer ID = 18818 has ONLY 1 order. This 1 order totally have 45 order lines and products. 
--BUT there is only 42 kind of products that he ordered. Product diversity is 42.
--Since product id 10954,11122,12820 is temproray.
SELECT
	O.CustomerId,
	COUNT(DISTINCT OL.ProductId) AS ProductDiversity
FROM [SQLBook].[dbo].[Orders] AS O
RIGHT JOIN  [SQLBook].[dbo].[OrderLines] AS OL
ON O.OrderId = OL.OrderId
GROUP BY CustomerId
ORDER BY COUNT(DISTINCT OL.ProductId)
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--INNER JOIN
-- I would like to know the group code and name of all products in each order
SELECT
	OL.OrderId,
	OL.OrderLineId,
	OL.NumUnits,
	OL.ProductId,
	P.GroupCode,
	P.GroupName,
	OL.UnitPrice
FROM [SQLBook].[dbo].[OrderLines] AS OL
INNER JOIN [SQLBook].[dbo].[Products] AS P
ON OL.ProductId = P.ProductId
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--FULL OUTER JOIN
-- List of all products name and ID with its orderID either they have been ordered so far or not
SELECT
	P.ProductID,
	P.GroupCode,
	P.GroupName,
	OL.OrderId,
	OL.OrderLineId
FROM [SQLBook].[dbo].[OrderLines] AS OL
FULL OUTER JOIN [SQLBook].[dbo].[Products] AS P
ON P.ProductId = OL.ProductId
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--FULL OUTER JOIN
-- List of all products that they have never been ordered.
--We dont have such a product. Each product has been ordered at least once.
SELECT
	P.ProductID,
	P.GroupCode,
	P.GroupName,
	OL.OrderId,
	OL.OrderLineId
FROM [SQLBook].[dbo].[OrderLines] AS OL
FULL OUTER JOIN [SQLBook].[dbo].[Products] AS P
ON P.ProductId = OL.ProductId
WHERE OL.OrderId IS NULL
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Cross Join - Common Table
-- I would like to know the list of all order lines when they have been shipped already.
-- My assumption is, if the shipdate is less than today means they have been shipped already.
WITH Done_CTE
AS
(
SELECT
	'Done!' as Status
)
SELECT 
	O.OrderLineId,
	O.ProductId,
	O.ShipDate,
	O.NumUnits,
	Done_CTE.Status
FROM [SQLBook].[dbo].[OrderLines] O
CROSS JOIN Done_CTE
WHERE O.ShipDate < GETDATE()
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common table Expression
-- I would like to know the total number available products and out of stock products
WITH AvaileabilityCTE 
AS
(
SELECT 
 *,
 CASE 
		WHEN [IsInStock] = 'N' THEN 'Out Of Stock'
		WHEN [IsInStock] = 'Y' THEN 'Available'

 END AS Availeability
FROM [SQLBook].[dbo].[Products]
)
SELECT
	Availeability,
	COUNT(*) AS NumberOfProducts
FROM AvaileabilityCTE
GROUP BY [Availeability]
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common table Expression with Argument
-- total number of customers, total number of orders and average number of orders per each customer.
WITH CustomerOrder_CTE (id, Number)  
AS  
(  
    SELECT 
		CustomerID, 
		COUNT(*) AS Number 
    FROM   [SQLBook].[dbo].[Orders]
    GROUP BY CustomerId
	HAVING CustomerId != 0
)  
SELECT 
    COUNT(id) AS [Total Customers], 
    SUM(Number)  AS [Total Orders], 
    AVG(Number)  AS [Average Order Per Customer]
FROM CustomerOrder_CTE;  
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common table Expression without Argument | Group by | Having
-- Average number of orders per customer
WITH CustomerOrder_CTE  
AS  
(  
    SELECT 
		CustomerId, 
		COUNT(*) AS Number 
    FROM  [SQLBook].[dbo].[Orders] 
    GROUP BY CustomerId
	HAVING CustomerId != 0 
)  
SELECT 
    AVG(Number)  AS [Average Order Per Customer]
FROM CustomerOrder_CTE;  
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common Table Expression | Rollup
-- How many orders have been delivered free and how many paid. 
--Plus, sub total amount of orders while they have been delivered free and paid.
WITH FreeFlag_CTE
AS
(
SELECT 
	*,
	CASE
		WHEN FreeShppingFlag = 'N' THEN 'Paid'
		WHEN FreeShppingFlag = 'Y' THEN 'Free'
	END AS FreeFlag
FROM [SQLBook].[dbo].[Campaigns] C
)
SELECT 
	COUNT(O.OrderId) AS TotalNumberOfOrders,
	FreeFlag,
	SUM(O.TotalPrice) SUM
FROM FreeFlag_CTE AS CTE
RIGHT JOIN [SQLBook].[dbo].[Orders] AS O
ON O.CampaignId = CTE.CampaignId
GROUP BY Rollup(CTE.FreeFlag)
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--Common table expression
--I would like to know the total number of Female and Male customers
WITH GenderCTE 
AS
(
SELECT 
 *,
 CASE 
		WHEN [Gender] = 'F' THEN 'Female'
		WHEN [Gender] = 'M' THEN 'Male'

 END AS GenderDesc
FROM [SQLBook].[dbo].[Customers]
--WHERE Gender IS NOT NULL AND Gender != ''
)
SELECT
	GenderDesc,
	COUNT(*) AS NumberOfCustomers
FROM GenderCTE
GROUP BY GenderDesc
HAVING GenderDesc IS NOT NULL
GO




