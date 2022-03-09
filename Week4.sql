--Assignment 4
--Azarm Piran - A01195657
----------------------------------------------------------------------------------------
--1
--First, I found the orders which has different ShipToAddressID and BillToAddressID.
--I would like to know the distance between the ShipToAddress and BillToAddress for these orders.
USE AdventureWorks2017
GO
DECLARE @SRID_METRE  INT =   4326;
SELECT
	DISTINCT CustomerID,
	BillToAddressID,
	[Bill Latitude],
	[Bill Longitude],
	x.City,
	x.StateProvinceID,
	FirstName,
	LastName,
	ShipToAddressID,
	SpatialLocation.Lat AS [Ship Latitude],
	SpatialLocation.Long AS [Ship Longitude],
	[Bill SpatialLocation].STDistance(geography::Point(SpatialLocation.Lat, SpatialLocation.Long, @SRID_METRE)) / 1000 AS [Distance KM],
	ShipMethodID
FROM
(
SELECT
	SalesOrderID,
	CustomerID,
	P.FirstName,
	P.LastName,
	A.City,
	A.StateProvinceID,
	BillToAddressID,
	SpatialLocation AS [Bill SpatialLocation],
	SpatialLocation.Lat AS [Bill Latitude],
	SpatialLocation.Long AS [Bill Longitude],
	ShipToAddressID,
	ShipMethodID
FROM Sales.SalesOrderHeader AS H
LEFT JOIN Person.Address AS A
ON A.AddressID = H.BillToAddressID
LEFT JOIN Person.Person AS P
On P.BusinessEntityID = CustomerID
WHERE ShipToAddressID <> BillToAddressID
) x
LEFT JOIN Person.Address AS A
ON A.AddressID = x.ShipToAddressID
ORDER BY [Distance KM]
GO
----------------------------------------------------------------------------------------
--2 
--I would like to know the top 1000 customers in terms of most amount of sub total. 
--Then, I found the the customers within the 100000 distance metre from the toppest customer which is customerID = 29818
--My goal is to find the dispersion of location for top 1000 customers within the 100000 distance from the toppest.
USE AdventureWorks2017
GO
DECLARE @DISTANCE_SOUGHT FLOAT = 1000000.0;
DECLARE @SRID_FOOT INT = 4748;
WITH
TopCustomers_CTE
AS
(
	SELECT
	CustomerID,
	FirstName,
	LastName,
	ShipToAddressID,
	SubTotal,
	AddressID,
	SpatialLocation AS [Point],
	SpatialLocation.STSrid AS SRID,
	SpatialLocation.Lat AS [Latitude],
	SpatialLocation.Long AS [Longitude],
	City
	FROM
	(
		SELECT
			TOP 1000
			OH.CustomerID,
			FirstName,
			LastName,
			OH.ShipToAddressID,
			SUM(OH.SubTotal) AS SubTotal
		FROM Sales.SalesOrderHeader AS OH
		LEFT JOIN Person.Person AS P
		ON P.BusinessEntityID = OH.CustomerID
		GROUP BY CustomerID,FirstName,LastName,ShipToAddressID
		HAVING FirstName IS NOT NULL AND LastName IS NOT NULL
		ORDER BY SubTotal DESC
	) x
	INNER JOIN Person.Address AS A
	ON A.AddressID = ShipToAddressID
)

SELECT
	*
FROM 
(
	SELECT
		a.*,
		a.[Point].STDistance(b.Point)  AS [Distance]
	FROM TopCustomers_CTE a
	CROSS JOIN
	(SELECT * FROM TopCustomers_CTE WHERE CustomerID = 12301) b
) c
WHERE [Distance] < @DISTANCE_SOUGHT
ORDER BY [Distance]
GO
----------------------------------------------------------------------------------------
--3
--I would like to know the bottom 1000 customers in terms of most amount of sub total. 
--Then, I found the the customers within the 100000 distance metre from the toppest customer which is customerID = 28286
--My goal is to find the dispersion of location for BOTTOM 1000 customers
--If we compare query number 2 and 3 we can see that we have 88 of bottom customers in the given distance so they are closer to each other compare to query 2 which there is only 6 customers
USE AdventureWorks2017
GO
DECLARE @DISTANCE_SOUGHT FLOAT = 100000.0;
DECLARE @SRID_FOOT INT = 4748;
WITH
Bottom10Customers_CTE
AS
(
	SELECT
	CustomerID,
	ShipToAddressID,
	SubTotal,
	AddressID,
	SpatialLocation AS [Point],
	SpatialLocation.STSrid AS SRID
	FROM
	(
		SELECT
			TOP 1000
			OH.CustomerID,
			OH.ShipToAddressID,
			SUM(OH.SubTotal) AS SubTotal
		FROM Sales.SalesOrderHeader AS OH
		GROUP BY CustomerID,ShipToAddressID
		ORDER BY SubTotal ASC
	) x
	INNER JOIN Person.Address AS A
	ON A.AddressID = ShipToAddressID
)

SELECT
	*
FROM 
(
	SELECT
		a.*,
		a.[Point].STDistance(b.Point)  AS [Distance]
	FROM Bottom10Customers_CTE a
	CROSS JOIN
	(SELECT * FROM Bottom10Customers_CTE WHERE CustomerID = 28286) b
) c
WHERE [Distance] < @DISTANCE_SOUGHT
ORDER BY [Distance]
GO
----------------------------------------------------------------------------------------
--4
--The most purchased product is product id = 712
--I would like to know the top 10 locations on the map where they got this product. Top 10 with the most OrderQty.
USE AdventureWorks2017
GO
WITH
TopProduct_CTE
AS
(
	SELECT
	ProductID,
	BillToAddressID,
	OrderQty,
	AddressID,
	x.Name,
	SpatialLocation AS [Point],
	SpatialLocation.STSrid AS SRID,
	SpatialLocation.Lat AS [Latitude],
	SpatialLocation.Long AS [Longitude],
	A.City,
	A.StateProvinceID
	FROM
	(
		SELECT
			OD.ProductID,
			P.Name,
			OH.BillToAddressID,
			SUM(OrderQty) AS OrderQty
		FROM Sales.SalesOrderDetail AS OD
		INNER JOIN Sales.SalesOrderHeader AS OH
		ON OH.SalesOrderID = OD.SalesOrderID
		LEFT JOIN Production.Product P
		ON P.ProductID = OD.ProductID
		GROUP BY OD.ProductID,Name,BillToAddressID
		--ProductID = 712 is the product which has been ordered the most
		HAVING OD.ProductID = 712
	) x
	INNER JOIN Person.Address AS A
	ON A.AddressID = BillToAddressID
)
SELECT
TOP 10*
FROM TopProduct_CTE
ORDER BY OrderQty DESC
GO
----------------------------------------------------------------------------------------
--5
--The most purchased product is product id = 712 and adress id = 459 has ordered this product more than others
--I would like to find how many addresses are within distance of 100000.0 from address id 459 
USE AdventureWorks2017
GO
DECLARE @DISTANCE_SOUGHT FLOAT = 100000.0;
WITH
TopProduct_CTE
AS
(
	SELECT
	ProductID,
	BillToAddressID,
	OrderQty,
	AddressID,
	SpatialLocation AS [Point],
	SpatialLocation.STSrid AS SRID
	FROM
	(
		SELECT
			OD.ProductID,
			OH.BillToAddressID,
			SUM(OrderQty) AS OrderQty
		FROM Sales.SalesOrderDetail AS OD
		INNER JOIN Sales.SalesOrderHeader AS OH
		ON OH.SalesOrderID = OD.SalesOrderID
		GROUP BY ProductID,BillToAddressID
		--ProductID = 712 is the product which has been ordered the most
		HAVING ProductID = 712
	) x
	INNER JOIN Person.Address AS A
	ON A.AddressID = BillToAddressID
)

SELECT
	c.ProductID,
	c.BillToAddressID,
	c.OrderQty,
	c.AddressID,
	c.Distance
FROM 
(
	SELECT
		a.*,
		a.[Point].STDistance(b.[Point])  AS [Distance]
	FROM TopProduct_CTE a
	CROSS JOIN
	(SELECT * FROM TopProduct_CTE WHERE BillToAddressID = 459 ) b --This adress id is one with the most OrderQty
) c
WHERE [Distance] < @DISTANCE_SOUGHT
ORDER BY [Distance]
GO
----------------------------------------------------------------------------------------
--6
--I would like to know who are the top 10 customers who have the most amount of sub total
--Then, I would like to know their location
USE AdventureWorks2017
GO
WITH
Top10Customers_CTE
AS
(
SELECT
	TOP 10
	OH.CustomerID,
	P.FirstName,
	P.LastName,
	OH.ShipToAddressID,
	SUM(OH.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader AS OH
LEFT JOIN Person.Person P
ON P.BusinessEntityID = OH.CustomerID
GROUP BY CustomerID,P.FirstName,P.LastName,ShipToAddressID
ORDER BY SubTotal DESC
)
SELECT
	CustomerID,
	FirstName,
	LastName,
	SubTotal,
	A.AddressID,
	A.City,
	ShipToAddressID,
	SpatialLocation,
	SpatialLocation.Lat AS Latitude,
	SpatialLocation.Long AS Longtitude,
	SpatialLocation.STSrid AS SRID
FROM Top10Customers_CTE
INNER JOIN Person.Address AS A
ON A.AddressID = ShipToAddressID
GO
----------------------------------------------------------------------------------------
--7
--I would like to find the dispersion of location for top 1000 customers within the 1000000.0 distance from the toppest customer.
USE SQLBook
GO
DECLARE @DISTANCE_SOUGHT FLOAT = 1000000.0;
DECLARE @SRID_FOOT INT = 4748;
WITH
TopCustomers_CTE
AS
(
	SELECT
	CustomerID,
	ZipCode,
	County,
	state,
	Longitude,
	Latitude,
	geography::Point(Latitude,Longitude,@SRID_FOOT) AS [Point],
	SubTotal
	FROM
	(
		SELECT
			TOP 1000
			CustomerID,
			ZipCode,
			SUM(TotalPrice) AS SubTotal
		FROM Orders AS O
		GROUP BY CustomerID,ZipCode
		ORDER BY SubTotal DESC
	) x
	INNER JOIN ZipCensus AS Z
	ON Z.zcta5 = ZipCode
)

SELECT
	*
FROM 
(
	SELECT
		a.*,
		a.[Point].STDistance(b.Point)  AS [Distance]
	FROM TopCustomers_CTE a
	CROSS JOIN
	(SELECT * FROM TopCustomers_CTE WHERE CustomerID = 146401) b
) c
WHERE [Distance] < @DISTANCE_SOUGHT
ORDER BY [Distance]
GO
----------------------------------------------------------------------------------------
--8
--My goal is to find the dispersion of location for top 100 customers(in term of most number of orders) within the 100000 distance from the toppest.
USE AdventureWorks2017
GO
DECLARE @DISTANCE_SOUGHT FLOAT = 100000.0;
DECLARE @SRID_FOOT INT = 4748;
WITH
TopCustomers_CTE
AS
(
	SELECT
	CustomerID,
	ShipToAddressID,
	[Number of Orders],
	AddressID,
	SpatialLocation AS [Point],
	SpatialLocation.STSrid AS SRID
	FROM
	(
		SELECT
			TOP 100
			OH.CustomerID,
			OH.ShipToAddressID,
			COUNT(SalesOrderID) AS [Number of Orders]
		FROM Sales.SalesOrderHeader AS OH
		GROUP BY CustomerID,ShipToAddressID
		ORDER BY [Number of Orders] DESC
	) x
	INNER JOIN Person.Address AS A
	ON A.AddressID = ShipToAddressID
)
SELECT
	*
FROM 
(
	SELECT
		a.*,
		a.[Point].STDistance(b.Point)  AS [Distance]
	FROM TopCustomers_CTE a
	CROSS JOIN
	(SELECT * FROM TopCustomers_CTE WHERE CustomerID = 11176) b
) c
WHERE [Distance] < @DISTANCE_SOUGHT
ORDER BY [Distance]
GO
----------------------------------------------------------------------------------------
--9
--I would like to find the Latitude and Longitude of top 1000 customers in terms of their Sub Total
USE AdventureWorks2017
GO
WITH
TopCustomers_CTE
AS
(
	SELECT
	CustomerID,
	ShipToAddressID,
	SubTotal,
	AddressID,
	SpatialLocation AS [Point],
	SpatialLocation.Lat AS [Latitude],
	SpatialLocation.Long AS [Longitude],
	SpatialLocation.STSrid AS SRID,
	City
	FROM
	(
		SELECT
			TOP 1000
			OH.CustomerID,
			OH.ShipToAddressID,
			SUM(OH.SubTotal) AS SubTotal
		FROM Sales.SalesOrderHeader AS OH
		GROUP BY CustomerID,ShipToAddressID
		ORDER BY SubTotal DESC
	) x
	INNER JOIN Person.Address AS A
	ON A.AddressID = ShipToAddressID
)

SELECT
	*
FROM TopCustomers_CTE
GO
----------------------------------------------------------------------------------------
--10
--10
--I would like to know the location of top 10 salesperson in terms of sub total
USE AdventureWorks2017
GO
WITH
Top10SalesPerson_CTE
AS
(
SELECT
	TOP 10
	OH.SalesPersonID,
	P.FirstName,
	P.LastName,
	SUM(OH.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader AS OH
LEFT JOIN Person.Person P
ON P.BusinessEntityID = OH.SalesPersonID
GROUP BY OH.SalesPersonID,P.FirstName,P.LastName
HAVING SalesPersonID IS NOT NULL
ORDER BY SubTotal DESC
)
SELECT
	SalesPersonID,
	FirstName,
	LastName,
	BA.AddressID
	SubTotal,
	BA.AddressID,
	A.City,
	A.SpatialLocation.Lat [Latitude],
	A.SpatialLocation.Long [Longitude]
FROM Top10SalesPerson_CTE CTE
LEFT JOIN Person.BusinessEntityAddress BA
ON BA.BusinessEntityID = CTE.SalesPersonID
LEFT JOIN Person.Address A
ON A.AddressID = BA.AddressID
GO
----------------------------------------------------------------------------------------
--11
-- The location of top 100 customers in terms of number of orders
USE AdventureWorks2017
GO
WITH
TopCustomers_CTE
AS
(
	SELECT
	CustomerID,
	ShipToAddressID,
	[Number of Orders],
	AddressID,
	SpatialLocation AS [Point],
	SpatialLocation.STSrid AS SRID,
	SpatialLocation.Lat [Latitude],
	SpatialLocation.Long [Longitude],
	City	
	FROM
	(
		SELECT
			TOP 100
			OH.CustomerID,
			OH.ShipToAddressID,
			COUNT(SalesOrderID) AS [Number of Orders]
		FROM Sales.SalesOrderHeader AS OH
		GROUP BY CustomerID,ShipToAddressID
		ORDER BY [Number of Orders] DESC
	) x
	INNER JOIN Person.Address AS A
	ON A.AddressID = ShipToAddressID
)
SELECT
	*
FROM TopCustomers_CTE
GO
----------------------------------------------------------------------------------------
--12
--The location of bottom 1000 customers in terms of sub total
USE AdventureWorks2017
GO
DECLARE @DISTANCE_SOUGHT FLOAT = 100000.0;
DECLARE @SRID_FOOT INT = 4748;
WITH
Bottom10Customers_CTE
AS
(
	SELECT
	CustomerID,
	ShipToAddressID,
	SubTotal,
	AddressID,
	SpatialLocation AS [Point],
	SpatialLocation.STSrid AS SRID,
	SpatialLocation.Lat [Latitude],
	SpatialLocation.Long [Longitude],
	City
	FROM
	(
		SELECT
			TOP 1000
			OH.CustomerID,
			OH.ShipToAddressID,
			SUM(OH.SubTotal) AS SubTotal
		FROM Sales.SalesOrderHeader AS OH
		GROUP BY CustomerID,ShipToAddressID
		ORDER BY SubTotal ASC
	) x
	INNER JOIN Person.Address AS A
	ON A.AddressID = ShipToAddressID
)

SELECT
	*
FROM Bottom10Customers_CTE
GO
----------------------------------------------------------------------------------------
--13

----------------------------------------------------------------------------------------
--14

----------------------------------------------------------------------------------------
--15

----------------------------------------------------------------------------------------
--16

----------------------------------------------------------------------------------------
--17

----------------------------------------------------------------------------------------
--18

----------------------------------------------------------------------------------------
--19

----------------------------------------------------------------------------------------
--20
----------------------------------------------------------------------------------------