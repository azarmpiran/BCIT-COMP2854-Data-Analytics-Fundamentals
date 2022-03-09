--Assignment 8 | Data Model and Customer Signiture
--Azarm Piran | A01195657
----------------------------------------------------------------------------
--AdvantureWork Practice
--Profiling Classification Model
--To find the most popular product in a Bill Address Id
--This is similar to the example in course material but instead based on AdvantureWork just for PRACTICE
--Here is the most popular product group
USE AdventureWorks2017
GO
SELECT
	TOP 1 PC.Name
FROM Sales.SalesOrderHeader OH
INNER JOIN Sales.SalesOrderDetail OD
ON OD.SalesOrderID = OH.SalesOrderID
INNER JOIN Production.Product P
ON P.ProductID = OD.ProductID
INNER JOIN Production.ProductSubcategory PSC
ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
INNER JOIN Production.ProductCategory PC
ON PSC.ProductCategoryID = PC.ProductCategoryID
GROUP BY PC.Name
ORDER BY COUNT(*) DESC
GO
--Refine the model by Address Id
USE AdventureWorks2017
GO
SELECT
	BillToAddressID, 
	Name
FROM
(
		SELECT
			OH.BillToAddressID, 
			PC.Name, 
			COUNT(*) AS cnt,
			ROW_NUMBER() OVER (PARTITION BY OH.BillToAddressID ORDER BY COUNT(*) DESC) AS SequentialNumber
		FROM Sales.SalesOrderHeader OH
		INNER JOIN Sales.SalesOrderDetail OD
		ON OD.SalesOrderID = OH.SalesOrderID
		INNER JOIN Production.Product P
		ON P.ProductID = OD.ProductID
		INNER JOIN Production.ProductSubcategory PSC
		ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
		INNER JOIN Production.ProductCategory PC
		ON PSC.ProductCategoryID = PC.ProductCategoryID
		GROUP BY OH.BillToAddressID, PC.Name
) AG
WHERE SequentialNumber = 1
ORDER BY BillToAddressID
GO
--Determine product groups and the number of BillToAddressId where that group is the most popular
USE AdventureWorks2017
GO
WITH CTE
AS
(
SELECT
	Name,
	COUNT(*) AS [Group Count]
FROM
(
		SELECT
			OH.BillToAddressID, 
			PC.Name, 
			COUNT(*) AS cnt,
			ROW_NUMBER() OVER (PARTITION BY OH.BillToAddressID ORDER BY COUNT(*) DESC,PC.Name) AS SequentialNumber
		FROM Sales.SalesOrderHeader OH
		INNER JOIN Sales.SalesOrderDetail OD
		ON OD.SalesOrderID = OH.SalesOrderID
		INNER JOIN Production.Product P
		ON P.ProductID = OD.ProductID
		INNER JOIN Production.ProductSubcategory PSC
		ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
		INNER JOIN Production.ProductCategory PC
		ON PSC.ProductCategoryID = PC.ProductCategoryID
		GROUP BY OH.BillToAddressID, PC.Name
) AG
WHERE SequentialNumber = 1
GROUP BY Name
)
SELECT
	Name AS [Product Group Name],
	[Group Count] AS [Number of Address Id],
	([Group Count]*100.00) / (SELECT SUM([Group Count]) FROM CTE) AS [Percentage of all AdressIds]
FROM CTE
GO
--Use a profiling Lookup Model for prediction. First collect data for the Classification Matrix:
--Determine product groups and the number of BillToAddressId where that group is the most popular
USE AdventureWorks2017
GO
WITH 
[lookup] AS
(
SELECT
	BillToAddressID,
	Name
FROM
(
		SELECT
			OH.BillToAddressID, 
			PC.Name, 
			COUNT(*) AS cnt,
			ROW_NUMBER() OVER (PARTITION BY OH.BillToAddressID ORDER BY COUNT(*) DESC, PC.Name) AS SequentialNumber
		FROM Sales.SalesOrderHeader OH
		INNER JOIN Sales.SalesOrderDetail OD
		ON OD.SalesOrderID = OH.SalesOrderID
		INNER JOIN Production.Product P
		ON P.ProductID = OD.ProductID 
		INNER JOIN Production.ProductSubcategory PSC
		ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
		INNER JOIN Production.ProductCategory PC
		ON PSC.ProductCategoryID = PC.ProductCategoryID
		GROUP BY OH.BillToAddressID, PC.Name
) AG
WHERE SequentialNumber = 1
),
[actuals] AS
(
SELECT
	BillToAddressID,
	Name
FROM
(
		SELECT
			OH.BillToAddressID, 
			PC.Name, 
			COUNT(*) AS cnt,
			ROW_NUMBER() OVER (PARTITION BY OH.BillToAddressID ORDER BY COUNT(*) DESC, PC.Name) AS SequentialNumber
		FROM Sales.SalesOrderHeader OH
		INNER JOIN Sales.SalesOrderDetail OD
		ON OD.SalesOrderID = OH.SalesOrderID
		INNER JOIN Production.Product P
		ON P.ProductID = OD.ProductID 
		INNER JOIN Production.ProductSubcategory PSC
		ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
		INNER JOIN Production.ProductCategory PC
		ON PSC.ProductCategoryID = PC.ProductCategoryID
		GROUP BY OH.BillToAddressID, PC.Name
) AG
WHERE SequentialNumber = 1
),
[results] AS
(	
	SELECT
		L.Name AS [Predicted Group Name],
		A.Name AS [Actual Group Name],
		COUNT(*) AS [Number of AddressIds]
	FROM [lookup] AS L
	JOIN [actuals] AS A
	ON L.BillToAddressID = A.BillToAddressID
	GROUP BY L.Name ,A.Name
)
SELECT 
* 
FROM [results]
PIVOT
(
   MAX([Number of AddressIds])
   FOR [Actual Group Name] IN ([Accessories],[Bikes],[Clothing],[Components])
) pivot1
GO
--Calculate accuracy of prediction that Accessories is actually the most popular product
USE SQLBook
GO
USE AdventureWorks2017
GO
WITH 
[lookup] AS
(
SELECT
	BillToAddressID,
	Name
FROM
(
		SELECT
			OH.BillToAddressID, 
			PC.Name, 
			COUNT(*) AS cnt,
			ROW_NUMBER() OVER (PARTITION BY OH.BillToAddressID ORDER BY COUNT(*) DESC, PC.Name) AS SequentialNumber
		FROM Sales.SalesOrderHeader OH
		INNER JOIN Sales.SalesOrderDetail OD
		ON OD.SalesOrderID = OH.SalesOrderID
		INNER JOIN Production.Product P
		ON P.ProductID = OD.ProductID 
		INNER JOIN Production.ProductSubcategory PSC
		ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
		INNER JOIN Production.ProductCategory PC
		ON PSC.ProductCategoryID = PC.ProductCategoryID
		GROUP BY OH.BillToAddressID, PC.Name
) AG
WHERE SequentialNumber = 1
),
[actuals] AS
(
SELECT
	BillToAddressID,
	Name
FROM
(
		SELECT
			OH.BillToAddressID, 
			PC.Name, 
			COUNT(*) AS cnt,
			ROW_NUMBER() OVER (PARTITION BY OH.BillToAddressID ORDER BY COUNT(*) DESC, PC.Name) AS SequentialNumber
		FROM Sales.SalesOrderHeader OH
		INNER JOIN Sales.SalesOrderDetail OD
		ON OD.SalesOrderID = OH.SalesOrderID
		INNER JOIN Production.Product P
		ON P.ProductID = OD.ProductID 
		INNER JOIN Production.ProductSubcategory PSC
		ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
		INNER JOIN Production.ProductCategory PC
		ON PSC.ProductCategoryID = PC.ProductCategoryID
		GROUP BY OH.BillToAddressID, PC.Name
) AG
WHERE SequentialNumber = 1
),
[results] AS
(	
	SELECT
		L.Name AS [Predicted Group Name],
		A.Name AS [Actual Group Name],
		COUNT(*) AS [Number of AddressIds]
	FROM [lookup] AS L
	JOIN [actuals] AS A
	ON L.BillToAddressID = A.BillToAddressID
	GROUP BY L.Name ,A.Name
)
SELECT
	SUM([results].[Number of AddressIds]) AS Total,
	SUM(CASE WHEN [results].[Actual Group Name] = 'Accessories' THEN [results].[Number of AddressIds] ELSE 0 END) AS [Accessories],
	SUM(CASE WHEN [results].[Actual Group Name] <> 'Accessories' THEN [results].[Number of AddressIds] ELSE 0 END) AS [Non-Accessories],
	SUM(CASE WHEN [results].[Actual Group Name] = 'Accessories' THEN [results].[Number of AddressIds] ELSE 0 END) * 100.00 /
	SUM([results].[Number of AddressIds]) AS [Accessories Percentage]
FROM [results]
GO
--Calculate overall accuracy of prediction
--I will do this later
--Write the Binary Model as well
----------------------------------------------------------------------------
--1
--Profiling Classification Model
--Goal: to find the best sales person per each state (By best I mean whoever has the highest amount of sub total)
--Determine the best sales person
--In this part we JUST want to know who sold the most amount
USE AdventureWorks2017
GO
SELECT
	TOP 1 SalesPersonID
FROM Sales.SalesOrderHeader H
LEFT JOIN Person.Person P
ON P.BusinessEntityID = H.SalesPersonID
LEFT JOIN Person.Address A
ON A.AddressID = H.BillToAddressID
LEFT JOIN Person.StateProvince SP
ON SP.StateProvinceID = A.StateProvinceID
GROUP BY SalesPersonID
HAVING SalesPersonID IS NOT NULL
ORDER BY COUNT(*)
GO
--Refine the model by state
USE AdventureWorks2017
GO
SELECT
*
FROM
(
SELECT
	SP.StateProvinceCode,
	SalesPersonID,
	COUNT(*) AS cnt,
	ROW_NUMBER() OVER (PARTITION BY SP.StateProvinceCode ORDER BY COUNT(*) DESC) AS [Sequence Namber]
FROM Sales.SalesOrderHeader H
LEFT JOIN Person.Person P
ON P.BusinessEntityID = H.SalesPersonID
LEFT JOIN Person.Address A
ON A.AddressID = H.BillToAddressID
LEFT JOIN Person.StateProvince SP
ON SP.StateProvinceID = A.StateProvinceID
GROUP BY SP.StateProvinceCode,SalesPersonID
HAVING H.SalesPersonID IS NOT NULL
)SS
WHERE  [Sequence Namber] = 1
ORDER BY StateProvinceCode
GO
--Determine SalesPerson and the number of states where that SalesPerson has the highes number of orders:
USE AdventureWorks2017
GO
WITH
CTE AS
(
SELECT
	SalesPersonID,
	COUNT(cnt) AS [Number of States where this SalesPerson has the highest number of Orders]
FROM
(
SELECT
	SP.StateProvinceCode,
	SalesPersonID,
	COUNT(*) AS cnt,
	ROW_NUMBER() OVER (PARTITION BY SP.StateProvinceCode ORDER BY COUNT(*) DESC, SP.StateProvinceCode) AS [Sequence Namber]
FROM Sales.SalesOrderHeader H
LEFT JOIN Person.Person P
ON P.BusinessEntityID = H.SalesPersonID
LEFT JOIN Person.Address A
ON A.AddressID = H.BillToAddressID
LEFT JOIN Person.StateProvince SP
ON SP.StateProvinceID = A.StateProvinceID
GROUP BY SP.StateProvinceCode,SalesPersonID
HAVING SalesPersonID IS NOT NULL
)SS
WHERE  [Sequence Namber] = 1
GROUP BY SalesPersonID
)
SELECT
	SalesPersonID , 
    [Number of States where this SalesPerson has the highest number of Orders],
    ([Number of States where this SalesPerson has the highest number of Orders] * 100.0) / (SELECT SUM([Number of States where this SalesPerson has the highest number of Orders]) FROM CTE) AS [% of All Orders]
FROM CTE
ORDER BY [Number of States where this SalesPerson has the highest number of Orders] DESC
--If we take a look at salesPerson Ids we will see that SalePersonId = 285 is not in the list at all
--The reason for that is in no state in where id = 285 has the most number of orders.
--Next step:
--Use a profiling Lookup Model for prediction. 
--First collect data for the Classification Matrix:
USE AdventureWorks2017
GO
WITH 
[lookup] AS
(
SELECT
	SalesPersonID,
	StateProvinceCode
FROM
(
SELECT
	SP.StateProvinceCode,
	SalesPersonID,
	COUNT(*) AS cnt,
	ROW_NUMBER() OVER (PARTITION BY SP.StateProvinceCode ORDER BY COUNT(*) DESC, SalesPersonID) AS [Sequence Namber]
FROM Sales.SalesOrderHeader H
LEFT JOIN Person.Person P
ON P.BusinessEntityID = H.SalesPersonID
LEFT JOIN Person.Address A
ON A.AddressID = H.BillToAddressID
LEFT JOIN Person.StateProvince SP
ON SP.StateProvinceID = A.StateProvinceID
GROUP BY SP.StateProvinceCode,SalesPersonID
HAVING H.SalesPersonID IS NOT NULL
)SS
WHERE  [Sequence Namber] = 1
),
[actuals] AS
(
SELECT
	SalesPersonID,
	StateProvinceCode
FROM
(
SELECT
	SP.StateProvinceCode,
	SalesPersonID,
	COUNT(*) AS cnt,
	ROW_NUMBER() OVER (PARTITION BY SP.StateProvinceCode ORDER BY COUNT(*) DESC, SalesPersonID) AS [Sequence Namber]
FROM Sales.SalesOrderHeader H
LEFT JOIN Person.Person P
ON P.BusinessEntityID = H.SalesPersonID
LEFT JOIN Person.Address A
ON A.AddressID = H.BillToAddressID
LEFT JOIN Person.StateProvince SP
ON SP.StateProvinceID = A.StateProvinceID
GROUP BY SP.StateProvinceCode,SalesPersonID
HAVING H.SalesPersonID IS NOT NULL
)SS
WHERE  [Sequence Namber] = 1
),
[results] AS
(
SELECT
	L.SalesPersonID AS [Predicted SalesPerson],
	A.SalesPersonID AS [Actual SalesPerson],
	COUNT(*) AS [Number of States]
FROM [lookup] L
JOIN [actuals] A
ON L.SalesPersonID = A.SalesPersonID
GROUP BY L.SalesPersonID,A.SalesPersonID
)
SELECT
*
FROM results
PIVOT
(
   MAX([Number of States])
   FOR [Actual SalesPerson] IN ([275],[276],[277],[278],[279],[281],[282],[283],[284],[286],[288],[289],[290])
) MyPivot
--Next step here should be calculate accuracy of prediction that SalesPersonId = 285 is actually the best
--But, we do not see that Id in the list at all!
----------------------------------------------------------------------------
--2
--Predictive Model With No Dimensions
--Task: Based on Avg of VacationHours of Female, predict the Avg of VacationHours of Male
USE AdventureWorks2017
GO
SELECT
	Gender,
	AVG(VacationHours*1.00) AS [Avg Hours of Vacation]
FROM HumanResources.Employee E
GROUP BY Gender
GO
--Next, I will add a MaritalStatus dimension 
USE AdventureWorks2017
GO
DECLARE @FemaleAverage FLOAT = (SELECT AVG([VacationHours]*1.00) FROM HumanResources.Employee WHERE Gender = 'F');
WITH
[ScoreSet] AS
(
	SELECT 
		* 
	FROM HumanResources.Employee E
	WHERE Gender = 'M' AND CurrentFlag = 1
),
[ModelSet] AS
(
	SELECT
		MaritalStatus,
		AVG(VacationHours*1.00) AS [Avg Hours of Vacation for Females]
	FROM HumanResources.Employee
	WHERE Gender = 'F' AND CurrentFlag = 1
	GROUP BY MaritalStatus
)
SELECT
	S.BusinessEntityID,
	S.JobTitle,
	S.MaritalStatus,
	S.VacationHours,
	S.SickLeaveHours,
	M.[Avg Hours of Vacation for Females],
	@FemaleAverage 
FROM [ScoreSet] S
LEFT JOIN [ModelSet] M
ON S.MaritalStatus = M.MaritalStatus
ORDER BY M.[Avg Hours of Vacation for Females]
GO
--Next, I will assess my model by comparing the Avg predicted hours and Avg of actual hours
USE AdventureWorks2017
GO
DECLARE @FemaleAverage FLOAT = (SELECT AVG([VacationHours]*1.00) FROM HumanResources.Employee WHERE Gender = 'F');
WITH
[ScoreSet] AS
(
	SELECT 
		* 
	FROM HumanResources.Employee E
	WHERE Gender = 'M' AND CurrentFlag = 1
),
[ModelSet] AS
(
	SELECT
		MaritalStatus,
		AVG(VacationHours*1.00) AS [Avg Hours of Vacation for Females]
	FROM HumanResources.Employee
	WHERE Gender = 'F' AND CurrentFlag = 1
	GROUP BY MaritalStatus
)
SELECT
	AVG(M.[Avg Hours of Vacation for Females]) AS [Predicted],
	AVG(S.VacationHours*1.00) AS [Actual]
FROM [ScoreSet] S
LEFT JOIN [ModelSet] M
ON S.MaritalStatus = M.MaritalStatus
GO
--Next, Avg by other dimension --> JobTitle
USE AdventureWorks2017
GO
DECLARE @FemaleAverage FLOAT = (SELECT AVG([VacationHours]*1.00) FROM HumanResources.Employee WHERE Gender = 'F');
WITH
[ScoreSet] AS
(
	SELECT 
		* 
	FROM HumanResources.Employee E
	WHERE Gender = 'M' AND CurrentFlag = 1
),
[ModelSet] AS
(
	SELECT
		JobTitle,
		AVG(VacationHours*1.00) AS [Avg Hours of Vacation for Females]
	FROM HumanResources.Employee
	WHERE Gender = 'F' AND CurrentFlag = 1
	GROUP BY JobTitle
)
SELECT
	AVG(M.[Avg Hours of Vacation for Females]) AS [Predicted],
	AVG(S.VacationHours*1.00) AS [Actual]
FROM [ScoreSet] S
LEFT JOIN [ModelSet] M
ON S.JobTitle = M.JobTitle
GO
--Next, Avg by two dimensions --> MaritalStatus and JobTitle 
USE AdventureWorks2017
GO
DECLARE @FemaleAverage FLOAT = (SELECT AVG([VacationHours]*1.00) FROM HumanResources.Employee WHERE Gender = 'F');
WITH
[ScoreSet] AS
(
	SELECT 
		* 
	FROM HumanResources.Employee E
	WHERE Gender = 'M' AND CurrentFlag = 1
),
[ModelSet] AS
(
	SELECT
		MaritalStatus,
		JobTitle,
		AVG(VacationHours*1.00) AS [Avg Hours of Vacation for Females]
	FROM HumanResources.Employee
	WHERE Gender = 'F' AND CurrentFlag = 1
	GROUP BY MaritalStatus,JobTitle
)
SELECT
	AVG(M.[Avg Hours of Vacation for Females]) AS [Predicted],
	AVG(S.VacationHours*1.00) AS [Actual]
FROM [ScoreSet] S
LEFT JOIN [ModelSet] M
ON S.JobTitle = M.JobTitle AND S.MaritalStatus = M.MaritalStatus
GO
--Avg by two dimensions --> OrganizationLevel and JobTitle
USE AdventureWorks2017
GO
DECLARE @FemaleAverage FLOAT = (SELECT AVG([VacationHours]*1.00) FROM HumanResources.Employee WHERE Gender = 'F');
WITH
[ScoreSet] AS
(
	SELECT 
		* 
	FROM HumanResources.Employee E
	WHERE Gender = 'M' AND CurrentFlag = 1
),
[ModelSet] AS
(
	SELECT
		JobTitle,
		OrganizationLevel,
		AVG(VacationHours*1.00) AS [Avg Hours of Vacation for Females]
	FROM HumanResources.Employee
	WHERE Gender = 'F' AND CurrentFlag = 1
	GROUP BY JobTitle, OrganizationLevel
)
SELECT
	AVG(M.[Avg Hours of Vacation for Females]) AS [Predicted],
	AVG(S.VacationHours*1.00) AS [Actual]
FROM [ScoreSet] S
LEFT JOIN [ModelSet] M
ON S.JobTitle = M.JobTitle AND S.OrganizationLevel = M.OrganizationLevel
GO
--The model is more accurate by JobTitle Dimension and the same Avg for JobTitle and OrganizationLevel Dimensions together
----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------

----------------------------------------------------------------------------