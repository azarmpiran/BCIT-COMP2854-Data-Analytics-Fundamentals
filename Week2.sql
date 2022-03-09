--Azarm Piran
--A01195657
--Assignment 2 
--My queries are based on both SQLBook and AdvantureWork
------------------------------------------------------------------------------------------
--1
--PIVOT - Common Table Expression - RIGHT JOIN - LEFT JOIN
--I would like to know how many orders we have per each Sales Reason in pivot format
USE AdventureWorks2017
GO
WITH Reason_CTE
AS
(
SELECT 
	R.Name AS ReasonName,
	OH.SalesOrderID AS ID
FROM Sales.SalesOrderHeader AS OH
RIGHT JOIN Sales.SalesOrderHeaderSalesReason AS OHR
ON OH.SalesOrderID = OHR.SalesOrderID
LEFT JOIN Sales.SalesReason AS R
ON R.SalesReasonID = OHR.SalesReasonID
)
SELECT 
	'Total Order ID' AS [List of Reasons],
	[On Promotion],
	[Manufacturer],
	[Review],
	[Television  Advertisement],
	[Price],
	[Quality],
	[Other]
FROM Reason_CTE
PIVOT
(
	COUNT(ID)
	FOR ReasonName
	IN
	(
	[On Promotion],
	[Manufacturer],
	[Review],
	[Television  Advertisement],
	[Price],
	[Quality],
	[Other]
	)
) AS Reason_PVT
GO
------------------------------------------------------------------------------------------
--2
--PIVOT - Common Table Expression 
--I would like to know the sub total for all orders per each year in a pivot format
USE AdventureWorks2017
GO
WITH Order_SubTotal_CTE
AS
(
SELECT
	YEAR(OrderDate) AS [Order Year],
	SubTotal
FROM Sales.SalesOrderHeader AS OH
)
SELECT 
	'Sub Total' AS [Year],
	[2011],
	[2012],
	[2013],
	[2014]
FROM Order_SubTotal_CTE
PIVOT
(
	SUM(SubTotal) 
	FOR [Order Year]
	IN
	(
	[2011],
	[2012],
	[2013],
	[2014]
	)
) AS Order_SubTotal_PVT
GO
------------------------------------------------------------------------------------------
--3
--PIVOT - Common Table Expression - LEFT JOIN 
--I would like to know the number of employee per each Department Group - I used IS NULL to not consider the employee who do not work here anymore
USE AdventureWorks2017
GO
WITH Department_CTE
AS
(
SELECT
	H.BusinessEntityID AS BusinessEntityID,
	D.GroupName AS GroupName
FROM HumanResources.EmployeeDepartmentHistory AS H
LEFT JOIN HumanResources.Department AS D
ON H.DepartmentID = D.DepartmentID
WHERE EndDate IS NULL
)
SELECT
	'Total Number of Employee' AS [Department Group Name],
	[Executive General and Administration],
	[Inventory Management],
	[Manufacturing],
	[Quality Assurance],
	[Research and Development],
	[Sales and Marketing]
FROM Department_CTE
PIVOT
(
	COUNT(BusinessEntityID)
	FOR GroupName
	IN
	(
	[Executive General and Administration],
	[Inventory Management],
	[Manufacturing],
	[Quality Assurance],
	[Research and Development],
	[Sales and Marketing]
	)
) AS Department_PVT
GO
------------------------------------------------------------------------------------------
--4
--PIVOT - Common Table Expression - LEFT JOIN
--I would like to know how many employee work per each shift in a pivot format
USE AdventureWorks2017
GO
WITH Shift_CTE
AS
(
SELECT
	H.BusinessEntityID AS BusinessEntityID,
	S.Name AS [Shift Name]
FROM HumanResources.EmployeeDepartmentHistory AS H
LEFT JOIN HumanResources.Shift AS S
ON H.ShiftID = S.ShiftID
WHERE EndDate IS NULL
)
SELECT
	'Total Number of Employee' AS [Shift],
	[Day],
	[Evening],
	[Night]
FROM Shift_CTE
PIVOT
(
	COUNT(BusinessEntityID)
	FOR [Shift Name]
	IN
	(
	[Day],
	[Evening],
	[Night]
	)
) AS Shift_PVT
GO
------------------------------------------------------------------------------------------
--5
--IIF - Auxiliary Data - common Table Expression
--I would like to know what is the avg of employee who work in night shift
USE AdventureWorks2017
GO
WITH Shift_Auxiliary_CTE
AS
(
SELECT
	S.Name AS [Shift Name],
	IIF(S.Name = 'Night',100.0,0) AS [Night Shift Flag]
FROM HumanResources.EmployeeDepartmentHistory AS H
LEFT JOIN HumanResources.Shift AS S
ON H.ShiftID = S.ShiftID
WHERE EndDate IS NULL
)
SELECT
	AVG([Night Shift Flag]) AS [Average Employee per Night Shift]
FROM Shift_Auxiliary_CTE
GO
------------------------------------------------------------------------------------------
--6
--IIF - Auxiliary Data - Common Table Expression
--I would like to know the average number of employee per Research and Development group 
USE AdventureWorks2017
GO
WITH Department_Auxiliary_CTE
AS
(
SELECT
	D.GroupName AS GroupName,
	IIF(GroupName = 'Research and Development',100.0,0) AS Flag
FROM HumanResources.EmployeeDepartmentHistory AS H
LEFT JOIN HumanResources.Department AS D
ON H.DepartmentID = D.DepartmentID
WHERE EndDate IS NULL
)
SELECT
	AVG(Flag) AS [Average of Employee per Research and Development Group]
FROM Department_Auxiliary_CTE
GO
------------------------------------------------------------------------------------------
--7
--ISNULL
--I would like to replace all the null in 'MiddleName' field in Person table with ''
USE AdventureWorks2017
GO
SELECT
	FirstName,
	ISNULL(MiddleName, '') AS MiddleName,
	LastName
FROM Person.Person
GO
------------------------------------------------------------------------------------------
--8
--COALESCE
--I would like to fill FirstNotNull coloumn with the first not null value among these three(MiddleName,Title,Suffix)
USE AdventureWorks2017
GO
SELECT
	FirstName,
	LastName,
	MiddleName,
	Title,
	Suffix,
	COALESCE(MiddleName,Title,Suffix) AS FirstNotNull
FROM Person.Person
GO
------------------------------------------------------------------------------------------
--9
--Common Table Expression - LEFT JOIN - GROUP BY - ORDER BY
--I would like to know the total and average number of orders per each state
--Plus, subtotal of all orders per each state
USE AdventureWorks2017
GO
WITH State_CTE
AS
(
SELECT
	OH.SalesOrderID,
	OH.ShipToAddressID,
	OH.SubTotal,
	A.AddressID,
	A.City,
	A.StateProvinceID,
	SP.StateProvinceCode,
	SP.Name,
	SP.CountryRegionCode
FROM Sales.SalesOrderHeader AS OH
LEFT JOIN Person.Address AS A
ON A.AddressID = OH.ShipToAddressID
LEFT JOIN Person.StateProvince AS SP
ON A.StateProvinceID = SP.StateProvinceID
)
SELECT
	Name AS [State Province Name],
	SUM(SalesOrderID) AS [Total Orders],
	AVG(SalesOrderID) AS [Average Orders],
	AVG(SubTotal) AS [Sub Total]
FROM State_CTE
GROUP BY StateProvinceID,StateProvinceCode,Name
ORDER BY [Sub Total] DESC
GO
------------------------------------------------------------------------------------------
--10
--Common Table Expression - LEFT JOIN - GROUP BY - ORDER BY
-- I would like to know the total and average number of orders per each country
--Plus, the sub total of all orders per each country
USE AdventureWorks2017
GO
WITH Country_CTE
AS
(
SELECT
	OH.SalesOrderID,
	OH.ShipToAddressID,
	OH.SubTotal,
	A.AddressID,
	A.City,
	A.StateProvinceID,
	SP.StateProvinceCode,
	SP.Name AS [State Name],
	SP.CountryRegionCode,
	CR.Name AS [Country Name]
FROM Sales.SalesOrderHeader AS OH
LEFT JOIN Person.Address AS A
ON A.AddressID = OH.ShipToAddressID
LEFT JOIN Person.StateProvince AS SP
ON A.StateProvinceID = SP.StateProvinceID
LEFT JOIN Person.CountryRegion AS CR
ON CR.CountryRegionCode = SP.CountryRegionCode
)
SELECT
	CountryRegionCode,
	[Country Name],
	SUM(SalesOrderID) AS [Total Number of Orders],
	AVG(SalesOrderID) AS [Average Number of Orders],
	SUM(SubTotal) AS [Sub Total of Orders]
FROM Country_CTE
GROUP BY CountryRegionCode,[Country Name]
ORDER BY SUM(SubTotal) DESC
GO
------------------------------------------------------------------------------------------
--11
--Common Table Expression - LEFT JOIN - GROUP BY - ORDER BY
--I would like to know the total and average number of orders per year per each country
--Plus, the sub total per each year and per each country
USE AdventureWorks2017
GO
WITH Country_Year_CTE
AS
(
SELECT
	OH.SalesOrderID,
	OH.SubTotal,
	YEAR(OH.OrderDate) AS [Order Year],
	SP.CountryRegionCode,
	CR.Name AS [Country Name]
FROM Sales.SalesOrderHeader AS OH
LEFT JOIN Person.Address AS A
ON A.AddressID = OH.ShipToAddressID
LEFT JOIN Person.StateProvince AS SP
ON A.StateProvinceID = SP.StateProvinceID
LEFT JOIN Person.CountryRegion AS CR
ON CR.CountryRegionCode = SP.CountryRegionCode
)
SELECT
	[Country Name],
	[Order Year],
	SUM(SalesOrderID) AS [Total Number of Orders],
	AVG(SalesOrderID) AS [Average Number of Orders],
	SUM(SubTotal) AS [Sub Total]
FROM Country_Year_CTE
GROUP BY [Order Year],[Country Name]
ORDER BY [Country Name],[Order Year]
GO
------------------------------------------------------------------------------------------
--12
--PIVOT 
--I would like to know the number of female and male customers
USE SQLBook
GO
SELECT
	'Count' AS [Gender],
	[F],
	[M]
FROM (SELECT Gender From Customers WHERE Gender !='') AS GenderTable
PIVOT
(
	COUNT(Gender)
	FOR Gender
	In
	(
	[F],
	[M]
	)
) AS Gender_PVT
GO
------------------------------------------------------------------------------------------
--13
--PIVOT
--I would like to know the number of products per each group
USE SQLBook
GO
SELECT
	'Count' AS [Group Name],
	[GAME],
	[OTHER],
	[BOOK],
	[OCCASION],
	[ARTWORK],
	[APPAREL],
	[FREEBIE],
	[CALENDAR]
FROM (SELECT GroupName FROM Products WHERE GroupCode != '#N') AS GroupNameTable
PIVOT
(
	COUNT(GroupName)
	FOR GroupName
	IN
	(
	[GAME],
	[OTHER],
	[BOOK],
	[OCCASION],
	[ARTWORK],
	[APPAREL],
	[FREEBIE],
	[CALENDAR]	
	)
) AS GroupName_PVT
GO
------------------------------------------------------------------------------------------
--14
--Common Table Expression
--I would like to know how many orders we have per each day of the week
--Highest number belongs to Monday. We have the least amount of orders for Saturday.
USE SQLBook
GO
WITH Day_CTE
AS
(
SELECT 
	C.DOW AS [WeekDay] 
FROM Orders AS O 
LEFT JOIN Calendar AS C 
ON O.OrderDate = C.Date
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
GO
------------------------------------------------------------------------------------------
--15
--Common Table Expression
--I would like to know how many orders we have per each month of the year
--Highest number belongs to November. 
USE SQLBook
GO
WITH Month_CTE
AS
(
SELECT 
	C.MonthAbbr AS [Month] 
FROM Orders AS O 
LEFT JOIN Calendar AS C 
ON O.OrderDate = C.Date
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
GO
------------------------------------------------------------------------------------------
--16
--Group by
--I would like to know total number of quantity in an order.
--Lets say I have 2 kind of products in an order. I ordered 2 of the first one and 3 of the second one. 
-- It will be 5 totally per this order.
USE AdventureWorks2017
GO
SELECT
	OD.SalesOrderID,
	SUM(OD.OrderQty) AS TotalProductQtyPerOrder
FROM Sales.SalesOrderDetail AS OD
GROUP BY SalesOrderID
GO
------------------------------------------------------------------------------------------
--17
--GROUP BY
-- Total money that each customer paid on their orders each year
USE AdventureWorks2017
GO
SELECT 
	CustomerID,
	year(ModifiedDate) AS year,
	SUM(SubTotal) AS TOTALPRICE
FROM [Sales].[SalesOrderHeader]
GROUP BY  CustomerID, ModifiedDate
ORDER BY  CustomerID,ModifiedDate
GO
------------------------------------------------------------------------------------------
--18
--Group by
--I would like to know how many times we orderd each product
--Lets say, how many times customers ordered productID = 925 totally
--In this query we can see, the product id = 712 has been ordered the most.
USE AdventureWorks2017
GO
 SELECT
	OD.ProductID,
	SUM(OD.OrderQty) AS NumberOfProductPerAllOrders
FROM Sales.SalesOrderDetail AS OD
GROUP BY ProductID
ORDER BY SUM(OD.OrderQty) DESC
GO
------------------------------------------------------------------------------------------
--19
--Group by - Several Fields
--I would like to know what is the Max and min price for each product per year. 
USE AdventureWorks2017
GO
SELECT 
	ProductID,
	YEAR(ModifiedDate) AS Year,
	MAX(UnitPrice) AS MaxPrice,
	min(UnitPrice) AS minPrice
FROM [AdventureWorks2017].[Sales].[SalesOrderDetail]
GROUP BY ProductID, YEAR(ModifiedDate)
ORDER BY ProductID,YEAR(ModifiedDate)
GO
------------------------------------------------------------------------------------------
--20
--Group by - Having
-- I would like to have the list of all orders when the total number of OrderQty for is more that 20
USE AdventureWorks2017
GO
SELECT
	OD.SalesOrderID,
	SUM(OD.OrderQty) AS TotalProductQtyPerOrder
FROM Sales.SalesOrderDetail AS OD
GROUP BY SalesOrderID
HAVING SUM(OD.OrderQty) > 20
ORDER BY SUM(OD.OrderQty) 
GO
------------------------------------------------------------------------------------------
--21
--Rollup
-- Total number of payments by each type of CreditCards 
--and the total number of payments for all Creditcards in all orders by ROLLUP 
USE AdventureWorks2017
GO
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
------------------------------------------------------------------------------------------
--22
------------------------------------------------------------------------------------------
--23
--RIGHT JOIN
-- Distinct count of all products that a customer ordered. 
--Lets say customer ID = 29543 has 8 orders. These 8 orders totally have 179 order line and products. BUT there is only 59 kind of 
-- products that they ordered. Product diversity is 59.
USE AdventureWorks2017
GO
SELECT
	SOH.CustomerID,
	COUNT(DISTINCT SOD.ProductID) AS ProductDiversity
FROM [Sales].[SalesOrderHeader] AS SOH
RIGHT JOIN  [Sales].[SalesOrderDetail] AS SOD
ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY CustomerID
ORDER BY CustomerID
GO
------------------------------------------------------------------------------------------
--24
--INNER JOIN
-- I would like to know the name of all products in each order
USE AdventureWorks2017
GO
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
------------------------------------------------------------------------------------------
--25
--FULL OUTER JOIN
-- List of all products name and ID with its orderID either they have been ordered so far or not
USE AdventureWorks2017
GO
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
------------------------------------------------------------------------------------------
--26
--FULL OUTER JOIN
-- List of all products that they have never been ordered.
-- We have 238 products that never been ordered.
USE AdventureWorks2017
GO
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
------------------------------------------------------------------------------------------
--27
--Cross Join
--List of all product Category and subcategory together
USE AdventureWorks2017
GO
SELECT
	PSC.ProductSubcategoryID,
	PSC.Name,
	PC.ProductCategoryID,
	PC.Name
  FROM Production.ProductSubcategory PSC
  CROSS JOIN Production.ProductCategory PC
GO
------------------------------------------------------------------------------------------
--28
--Common table Expression - CASE
-- I would like to know the total number of each kind of shipping method in all orders
USE AdventureWorks2017
GO
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
------------------------------------------------------------------------------------------
--29
--Common table Expression with Argument
-- First I would like to know the number of orders per each customer. Then by using the common table expression, I would like to know
-- total number of customers, total number of orders and average number of orders per each customer.
USE AdventureWorks2017
GO
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
------------------------------------------------------------------------------------------
--30
--Common table Expression without Argument
-- Average number of orders per customer
USE AdventureWorks2017
GO
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
------------------------------------------------------------------------------------------
--31
--Common Table Expression
--How many locations we can find each product by average.
-- This query tells us, we can find each product in 2 different inventory by average
USE AdventureWorks2017
GO
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
------------------------------------------------------------------------------------------
--32
--Common Table Expression
--How many orders have been placed by each salesperson. Plus, sub total amount of orders per each sales person.
--Plus, How many Online Orders we have and how much is the sub total for all online orders.
USE AdventureWorks2017
GO
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
------------------------------------------------------------------------------------------