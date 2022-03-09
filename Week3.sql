--Assignment3
--Azarm Piran
--A01195657
-----------------------------------------------------------------------------------------------------------
--1
--ROW_NUMBER 
--List of all customers with their orders and row number per each order. It is sorted by order id
USE AdventureWorks2017
GO
SELECT
ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY SalesOrderID) AS RowNumber,
SalesOrderID,
CustomerID,
SubTotal
FROM Sales.SalesOrderHeader AS OH
GO
-----------------------------------------------------------------------------------------------------------
--2
--ROW_NUMBER | Common Table Expression
--I would like to know all orders per each year with row number. Results are sorted by order id
USE AdventureWorks2017
GO
WITH Sales_Year_CTE
AS
(
SELECT
YEAR(OrderDate) AS Year,
SalesOrderID,
SubTotal
FROM Sales.SalesOrderHeader AS OH
)
SELECT
	ROW_NUMBER() OVER(PARTITION BY Year ORDER BY SalesOrderID) AS RowNumber,
	Year,
	SalesOrderID
FROM Sales_Year_CTE
GO
-----------------------------------------------------------------------------------------------------------
--3
--ROW_NUMBER | OVER
--I would like to know the list of departments per each group with row number for each department
USE AdventureWorks2017
GO
SELECT
	ROW_NUMBER() OVER(PARTITION BY GroupName ORDER BY DepartmentID) AS RowNumber,
	Name,
	GroupName
FROM HumanResources.Department
GO
-----------------------------------------------------------------------------------------------------------
--4
--RANK | ROW_NUMBER | PERCENT_RANK | CUME_DIST | DENSE_RANK | Common Table Expression
-- I would like to know the rank of each order based on their subtotal in each month of each year
USE AdventureWorks2017
GO
WITH Month_CTE
AS
(
SELECT
	SalesOrderID,
	YEAR(OrderDate) AS Year,
	MONTH(OrderDate) AS Month,
	SubTotal,
	OH.CustomerID
FROM Sales.SalesOrderHeader AS OH
LEFT JOIN Sales.Customer AS C
ON C.CustomerID = OH.CustomerID
)
SELECT
	SalesOrderID,
	Year,
	Month,
	CustomerID,
	SubTotal,
	RANK() OVER(PARTITION BY Year,Month ORDER BY SubTotal) AS Rank,
	PERCENT_RANK() OVER(PARTITION BY Year,Month ORDER BY SubTotal) AS [Percent Rank],
	CUME_DIST() OVER(PARTITION BY Year,Month ORDER BY SubTotal) AS [Cume Dist],
	DENSE_RANK() OVER(PARTITION BY Year,Month ORDER BY SubTotal) AS Dense_Rank,
	ROW_NUMBER() OVER(PARTITION BY Year,Month ORDER BY SubTotal) AS RowNumber
FROM Month_CTE
GO
-----------------------------------------------------------------------------------------------------------
--5
--Min | Max | Avg | Common Table Exxpression | Left Join
--I would like to know the Min,Max and Avg age of employee in each department
USE AdventureWorks2017
GO
WITH Employee_Department_Age_CTE
AS
(
SELECT
	E.BusinessEntityID,
	E.JobTitle,
	E.BirthDate,
	DATEDIFF(YEAR,E.BirthDate,GETDATE()) AS Age,
	E.Gender,
	D.Name AS [Department Name],
	D.DepartmentID,
	D.GroupName
FROM HumanResources.Employee AS E
LEFT JOIN HumanResources.EmployeeDepartmentHistory AS DH
ON DH.BusinessEntityID = E.BusinessEntityID
LEFT JOIN HumanResources.Department AS D
ON D.DepartmentID = DH.DepartmentID
WHERE DH.EndDate IS NULL
)
SELECT 
	DISTINCT [Department Name],
	MAX(Age) OVER(PARTITION BY [Department Name]) AS [Max Age],
	MIN(Age) OVER(PARTITION BY [Department Name]) AS [Min Age],
	AVG(Age) OVER(PARTITION BY [Department Name]) AS [Avg Age]
FROM Employee_Department_Age_CTE 
GO
-----------------------------------------------------------------------------------------------------------
--6
--Min | Max | Avg | Common Table Exxpression | Left Join
--I would like to know the Min,Max and Avg age of employee in each department and per each gender 
USE AdventureWorks2017
GO
WITH Employee_Department_Age_Gender_CTE
AS
(
SELECT
	E.BusinessEntityID,
	E.Gender,
	E.JobTitle,
	E.BirthDate,
	DATEDIFF(YEAR,E.BirthDate,GETDATE()) AS Age,
	E.Gender AS [Employee Gender],
	D.Name AS [Department Name],
	D.DepartmentID,
	D.GroupName
FROM HumanResources.Employee AS E
LEFT JOIN HumanResources.EmployeeDepartmentHistory AS DH
ON DH.BusinessEntityID = E.BusinessEntityID
LEFT JOIN HumanResources.Department AS D
ON D.DepartmentID = DH.DepartmentID
WHERE DH.EndDate IS NULL
)
SELECT 
	DISTINCT [Department Name],
	[Employee Gender],
	MAX(Age) OVER(PARTITION BY [Department Name],Gender) AS [Max Age],
	MIN(Age) OVER(PARTITION BY [Department Name],Gender) AS [Min Age],
	AVG(Age) OVER(PARTITION BY [Department Name],Gender) AS [Avg Age]
FROM Employee_Department_Age_Gender_CTE 
GO
-----------------------------------------------------------------------------------------------------------
--7
--Count | Common Table Exxpression | LEFT JOIN | CASE
--I would like to know the number of single and married employee per each department
USE AdventureWorks2017
GO
WITH Employee_MaritalStatus_CTE
AS
(
SELECT
	E.BusinessEntityID,
	E.Gender,
	E.MaritalStatus,
	D.Name AS [Department Name],
	D.DepartmentID,
	D.GroupName
FROM HumanResources.Employee AS E
LEFT JOIN HumanResources.EmployeeDepartmentHistory AS DH
ON DH.BusinessEntityID = E.BusinessEntityID
LEFT JOIN HumanResources.Department AS D
ON D.DepartmentID = DH.DepartmentID
WHERE DH.EndDate IS NULL
)
SELECT 
	DISTINCT [Department Name],
	DepartmentID,
	CASE MaritalStatus
		WHEN 'M' THEN 'Married' 
		ELSE 'Single' 
		END AS [Marital Status],
	COUNT(MaritalStatus) OVER(PARTITION BY [Department Name],MaritalStatus) AS [Count]
FROM Employee_MaritalStatus_CTE 
GO
-----------------------------------------------------------------------------------------------------------
--8
--Max | Min | Avg | Sum | VAR | VARP | STDEV | STDEVP | Common Table Exxpression | LEFT JOIN
--I would like to know the Max,Min and Avg SickLeaveHours per each department
USE AdventureWorks2017
GO
WITH SickHours_CTE
AS
(
SELECT
	E.BusinessEntityID,
	E.SickLeaveHours,
	D.Name AS [Department Name],
	DATEDIFF(YEAR,E.BirthDate,GETDATE()) AS Age,
	D.DepartmentID,
	D.GroupName
FROM HumanResources.Employee AS E
LEFT JOIN HumanResources.EmployeeDepartmentHistory AS DH
ON DH.BusinessEntityID = E.BusinessEntityID
LEFT JOIN HumanResources.Department AS D
ON D.DepartmentID = DH.DepartmentID
WHERE DH.EndDate IS NULL
)
SELECT 
	DISTINCT [Department Name],
	MAX(SickLeaveHours) OVER(PARTITION BY [Department Name]) AS [Max SickLeaveHours],
	MIN(SickLeaveHours) OVER(PARTITION BY [Department Name]) AS [Min SickLeaveHours],
	AVG(SickLeaveHours) OVER(PARTITION BY [Department Name]) AS [Avg SickLeaveHours],
	VAR(SickLeaveHours) OVER(PARTITION BY [Department Name]) AS [Var SickLeaveHours],
	VARP(SickLeaveHours) OVER(PARTITION BY [Department Name]) AS [VarP SickLeaveHours],
	STDEV(SickLeaveHours) OVER(PARTITION BY [Department Name]) AS [STDEV SickLeaveHours],
	STDEVP(SickLeaveHours) OVER(PARTITION BY [Department Name]) AS [STDEVP SickLeaveHours],
	SUM(SickLeaveHours) OVER(PARTITION BY [Department Name]) AS [SUM SickLeaveHours]
FROM SickHours_CTE 
GO
-----------------------------------------------------------------------------------------------------------
--9
--Max | Min | Avg | Count | Sum | Var | VARP | STDEV | STDEVP | Common Table Expression | CASE
--I would like to know the Max,Min,Avg of subtotal per each salesperson
--Plus, the count of orders per each salesperson as well.
USE AdventureWorks2017
GO
WITH SalesPerson_SubTotal_CTE
AS
(
SELECT 
	SalesOrderID,
	OrderDate,
	SOH.SubTotal,
	SOH.SalesPersonID,
	CASE
		WHEN OnlineOrderFlag = 1 THEN 'Online'
		WHEN OnlineOrderFlag = 0 THEN 'By SalesPerson'
	END AS OnlineFlag
FROM Sales.SalesOrderHeader SOH
WHERE SalesPersonID IS NOT NULL
)
SELECT 
	DISTINCT SalesPersonID,
	MAX(SubTotal) OVER(PARTITION BY SalesPersonID) AS [Max SubTotal],
	MIN(SubTotal) OVER(PARTITION BY SalesPersonID) AS [Min SubTotal],
	AVG(SubTotal) OVER(PARTITION BY SalesPersonID) AS [Avg SubTotal],
	VAR(SubTotal) OVER(PARTITION BY SalesPersonID) AS [VAR SubTotal],
	VARP(SubTotal) OVER(PARTITION BY SalesPersonID) AS [VARP SubTotal],
	STDEV(SubTotal) OVER(PARTITION BY SalesPersonID) AS [STDEV SubTotal],
	STDEVP(SubTotal) OVER(PARTITION BY SalesPersonID) AS [STDEVP SubTotal],
	SUM(SubTotal) OVER(PARTITION BY SalesPersonID) AS [Sum SubTotal],
	COUNT(SalesOrderID) OVER(PARTITION BY SalesPersonID) AS [Count Orders]
FROM SalesPerson_SubTotal_CTE
GO
-----------------------------------------------------------------------------------------------------------
--10
--First Value | Common Table Expression 
--I would like to know the date of first order submitted by each salesperson
USE AdventureWorks2017
GO
WITH FirstOrder_CTE
AS
(
SELECT 
	SalesOrderID,
	CONVERT(varchar, OrderDate, 23) AS OrderDate,
	SOH.SubTotal,
	SOH.SalesPersonID,
	CASE
		WHEN OnlineOrderFlag = 1 THEN 'Online'
		WHEN OnlineOrderFlag = 0 THEN 'By SalesPerson'
	END AS OnlineFlag
FROM Sales.SalesOrderHeader SOH
WHERE SalesPersonID IS NOT NULL
)
SELECT 
	DISTINCT SalesPersonID,
	FIRST_VALUE(OrderDate) OVER(PARTITION BY SalesPersonID ORDER BY OrderDate) AS [First Order]
FROM FirstOrder_CTE
GO
-----------------------------------------------------------------------------------------------------------
--11
--LAG | Common Table Expression | DATEDIFF
--I would like to know the day difference between each orders of each customers.
USE SQLBook
GO
WITH Order_DateDiff_CTE
AS
(
SELECT
	OrderId,
	CustomerId,
	TotalPrice,
	OrderDate,
	LAG(OrderDate) OVER(PARTITION BY CustomerId ORDER BY OrderDate) AS [LAG]
FROM Orders
)
SELECT 
	*,
	DATEDIFF(DAY,[LAG],OrderDate) AS OrderDateDiff
FROM Order_DateDiff_CTE
GO
-----------------------------------------------------------------------------------------------------------
--12
--LAG | Common Table Expression 
--I would like to know the difference amount of order subtotal between each two orders of all customers.
USE SQLBook
GO
WITH SubTotal_Diff_CTE
AS
(
SELECT
	OrderId,
	CustomerId,
	OrderDate,
	TotalPrice,
	LAG(TotalPrice) OVER(PARTITION BY CustomerId ORDER BY OrderDate) AS [LAG]
FROM Orders
)
SELECT 
	*,
	(TotalPrice - [LAG]) AS [TotalPrice Diff]
FROM SubTotal_Diff_CTE
GO
-----------------------------------------------------------------------------------------------------------
--13
--NTILE - Common Table Expression
--I would like to see all the orders in 12 groups while the orders are ordered by orderdate
USE AdventureWorks2017
GO
WITH SalesPersonOrderDate_CTE
AS
(
SELECT
	SalesOrderID,
	CONVERT(varchar, OrderDate, 23) AS OrderDate,
	CustomerID,
	SalesPersonID,
	SubTotal
FROM Sales.SalesOrderHeader AS OH
WHERE SalesPersonID IS NOT NULL
)
SELECT
	SalesPersonID,
	OrderDate,
	NTILE(12) OVER(ORDER BY OrderDate) AS NTILE
FROM SalesPersonOrderDate_CTE
GO
-----------------------------------------------------------------------------------------------------------
--14
--RANK | DENSE RANK | PERCENT_RANK | CUME_DIST | Common Table Expression
--I would like to know the rank of age of each employee in each department
USE AdventureWorks2017
GO
WITH Employee_Department_Age_CTE
AS
(
SELECT
	E.BusinessEntityID,
	E.JobTitle,
	E.BirthDate,
	DATEDIFF(YEAR,E.BirthDate,GETDATE()) AS Age,
	E.Gender,
	D.Name AS [Department Name],
	D.DepartmentID,
	D.GroupName
FROM HumanResources.Employee AS E
LEFT JOIN HumanResources.EmployeeDepartmentHistory AS DH
ON DH.BusinessEntityID = E.BusinessEntityID
LEFT JOIN HumanResources.Department AS D
ON D.DepartmentID = DH.DepartmentID
WHERE DH.EndDate IS NULL
)
SELECT 
	[Department Name],
	BusinessEntityID,
	Age,
	RANK() OVER(PARTITION BY [Department Name] ORDER BY Age) AS [Age Rank],
	DENSE_RANK() OVER(PARTITION BY [Department Name] ORDER BY Age) AS [Age Dense Rank],
	PERCENT_RANK() OVER(PARTITION BY [Department Name] ORDER BY Age) AS [Age Percent Rank],
	CUME_DIST() OVER(PARTITION BY [Department Name] ORDER BY Age) AS [Age Cume Dist]
FROM Employee_Department_Age_CTE 
GO
-----------------------------------------------------------------------------------------------------------
--15
--MAX | MIN | COUNT | SUM | AVG | Common Table Expression
--I would like to know the MAX, MIN, COUNT, SUM and AVG of subtotal per each state
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
	DISTINCT Name AS [State Province Name],
	MAX(SalesOrderID) OVER(PARTITION BY StateProvinceID,StateProvinceCode,Name) AS [MAX SubTotal],
	MIN(SalesOrderID) OVER(PARTITION BY StateProvinceID,StateProvinceCode,Name) AS [MIN SubTotal],
	COUNT(SalesOrderID) OVER(PARTITION BY StateProvinceID,StateProvinceCode,Name) AS [COUNT SubTotal],
	SUM(SalesOrderID) OVER(PARTITION BY StateProvinceID,StateProvinceCode,Name) AS [SUM SubTotal],
	AVG(SalesOrderID) OVER(PARTITION BY StateProvinceID,StateProvinceCode,Name) AS [Average SubTotal] 
FROM State_CTE
GO
-----------------------------------------------------------------------------------------------------------
--16
--PERCENTILE_CONT | PERCENTILE_DISC | Common Table Expression
--I would like to know the median SubTotal per each state
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
	DISTINCT Name AS [State Province Name],
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY SubTotal) OVER(PARTITION BY StateProvinceID,StateProvinceCode,Name) AS MedianCont,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY SubTotal) OVER(PARTITION BY StateProvinceID,StateProvinceCode,Name) AS MedianDisc
FROM State_CTE
GO
-----------------------------------------------------------------------------------------------------------
--17
--MAX | MIN | COUNT | SUM | AVG | Common Table Expression
--I would like to know the MAX, MIN, COUNT, SUM and AVG of SubTotal per each Country
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
	DISTINCT [Country Name],
	COUNT(SalesOrderID) OVER(PARTITION BY CountryRegionCode,[Country Name]) AS [# of Orders],
	AVG(SubTotal) OVER(PARTITION BY CountryRegionCode,[Country Name]) AS [AVG SubTotal of Orders],
	MAX(SubTotal) OVER(PARTITION BY CountryRegionCode,[Country Name]) AS [MAX SubTotal of Orders],
	MIN(SubTotal) OVER(PARTITION BY CountryRegionCode,[Country Name]) AS [MIN SubTotal of Orders],
	SUM(SubTotal) OVER(PARTITION BY CountryRegionCode,[Country Name]) AS [SUM SubTotal of Orders]
FROM Country_CTE
GO
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------


