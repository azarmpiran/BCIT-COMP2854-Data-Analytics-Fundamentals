--Assignment 6
--Azarm piran | A01195657
--SQLBook
------------------------------------------------------------------------------------
--1
--What is be probability/odds for clients to use an Overseas Card (OC) as PaymentType (Orders table)?
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	COUNT(*) AS [Total]
FROM Orders O
)
,
CTE_OC
AS
(
SELECT
	COUNT(*) AS [OC]
FROM Orders O
WHERE PaymentType = 'OC'
)
SELECT 
	((CTE_OC.OC * 1.00000) / Main_CTE.Total) AS [Probability of OC],
	((CTE_OC.OC * 1.00000) / Main_CTE.Total) / (1 - ((CTE_OC.OC * 1.00000) / Main_CTE.Total)) AS [Odds of OC]
FROM Main_CTE,CTE_OC
GO
------------------------------------------------------------------------------------
--2
--What is the probability of them using Visa OR MasterCard?
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	COUNT(*) AS [Total]
FROM Orders O
)
,
CTE_VI_MC
AS
(
SELECT
	COUNT(*) AS [VI_MC]
FROM Orders O
WHERE PaymentType = 'VI' OR PaymentType = 'MC'
)
SELECT 
	((CTE_VI_MC.[VI_MC] * 1.00000) / Main_CTE.Total) AS [Probability of VI or MC],
	((CTE_VI_MC.[VI_MC] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_VI_MC.[VI_MC] * 1.00000) / Main_CTE.Total)) AS [Odds of VI or MC]
FROM Main_CTE,CTE_VI_MC
GO
------------------------------------------------------------------------------------
--3
--How much PaymentType data is missing? (PaymentType ??) How would you account for that?
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	COUNT(*) AS [Total]
FROM Orders O
)
,
CTE_2
AS
(
SELECT
	COUNT(*) AS [??]
FROM Orders O
WHERE PaymentType = '??'
)
SELECT 
	((CTE_2.[??] * 1.00000) / Main_CTE.Total) AS [Probability of OC],
	((CTE_2.[??] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_2.[??] * 1.00000) / Main_CTE.Total)) AS [Odds of OC]
FROM Main_CTE,CTE_2
GO
------------------------------------------------------------------------------------
--4
--The probability of ordering the most popular product: 12820
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	SUM(NumUnits) AS [Total]
FROM OrderLines OL
)
,
CTE_Product
AS
(
SELECT
	SUM(NumUnits) AS [Total Orders per Product]
FROM OrderLines OL
WHERE ProductId = 12820
)
SELECT 
	((CTE_Product.[Total Orders per Product] * 1.00000) / Main_CTE.Total) AS [Probability of Ordering the most popular Product],
	((CTE_Product.[Total Orders per Product] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_Product.[Total Orders per Product] * 1.00000) / Main_CTE.Total)) AS [Odds of Ordering the most popular Product]
FROM CTE_Product,Main_CTE
GO
------------------------------------------------------------------------------------
--5
--The probability of ordering on each day of week | The sum of all probabilities is 1
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	COUNT(*) AS [Total]
FROM Orders O
)
,
CTE_Sat
AS
(	
SELECT
	COUNT(*) AS [Sat]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE DOW = 'Sat'
)
,
CTE_Sun
AS
(	
SELECT
	COUNT(*) AS [Sun]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE DOW = 'Sun'
)
,
CTE_Mon
AS
(	
SELECT
	COUNT(*) AS [Mon]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE DOW = 'Mon'
)
,
CTE_Tue
AS
(	
SELECT
	COUNT(*) AS [Tue]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE DOW = 'Tue'
)
,
CTE_Wed
AS
(	
SELECT
	COUNT(*) AS [Wed]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE DOW = 'Wed'
)
,
CTE_Thu
AS
(	
SELECT
	COUNT(*) AS [Thu]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE DOW = 'Thu'
)
,
CTE_Fri
AS
(	
SELECT
	COUNT(*) AS [Fri]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE DOW = 'Fri'
)
SELECT

	((CTE_Sat.[Sat] * 1.00000) / Main_CTE.Total) AS [Probability of Ordering on Saturday],
	((CTE_Sat.[Sat] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_Sat.[Sat] * 1.00000) / Main_CTE.Total)) AS [Odds of Ordering on Saturday],

	((CTE_Sun.[Sun] * 1.00000) / Main_CTE.Total) AS [Probability of Ordering on Sunday],
	((CTE_Sun.[Sun] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_Sun.[Sun] * 1.00000) / Main_CTE.Total)) AS [Odds of Ordering on Sunday],

	
	((CTE_Mon.[Mon] * 1.00000) / Main_CTE.Total) AS [Probability of Ordering on Monday],
	((CTE_Mon.[Mon] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_Mon.[Mon] * 1.00000) / Main_CTE.Total)) AS [Odds of Ordering on Monday],

	
	((CTE_Tue.[Tue] * 1.00000) / Main_CTE.Total) AS [Probability of Ordering on Tuesday],
	((CTE_Tue.[Tue] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_Tue.[Tue] * 1.00000) / Main_CTE.Total)) AS [Odds of Ordering on Tuesday],

	
	((CTE_Wed.[Wed] * 1.00000) / Main_CTE.Total) AS [Probability of Ordering on Wednesday],
	((CTE_Wed.[Wed] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_Wed.[Wed] * 1.00000) / Main_CTE.Total)) AS [Odds of Ordering on Wednesday],

	
	((CTE_Thu.[Thu] * 1.00000) / Main_CTE.Total) AS [Probability of Ordering on Thursday],
	((CTE_Thu.[Thu] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_Thu.[Thu] * 1.00000) / Main_CTE.Total)) AS [Odds of Ordering on Thursday],

	
	((CTE_Fri.[Fri] * 1.00000) / Main_CTE.Total) AS [Probability of Ordering on Friday],
	((CTE_Fri.[Fri] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_Fri.[Fri] * 1.00000) / Main_CTE.Total)) AS [Odds of Ordering on Friday]

FROM Main_CTE, CTE_Sat, CTE_Sun, CTE_Mon, CTE_Tue, CTE_Wed, CTE_Thu, CTE_Fri
GO
------------------------------------------------------------------------------------
--6
--The probability of ordering on each month of year
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	COUNT(*) AS [Total]
FROM Orders O
)
,
CTE_Jan
AS
(
SELECT
	COUNT(*) AS [Jan]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 1
)
,
CTE_Feb
AS
(
SELECT
	COUNT(*) AS [Feb]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 2
)
,
CTE_Mar
AS
(
SELECT
	COUNT(*) AS [Mar]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 3
)
,
CTE_Apr
AS
(
SELECT
	COUNT(*) AS [Apr]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 4
)
,
CTE_May
AS
(
SELECT
	COUNT(*) AS [May]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 5
)
,
CTE_Jun
AS
(
SELECT
	COUNT(*) AS [Jun]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 6
)
,
CTE_Jul
AS
(
SELECT
	COUNT(*) AS [Jul]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 7
)
,
CTE_Aug
AS
(
SELECT
	COUNT(*) AS [Aug]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 8
)
,
CTE_Sep
AS
(
SELECT
	COUNT(*) AS [Sep]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 9
)
,
CTE_Oct
AS
(
SELECT
	COUNT(*) AS [Oct]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 10
)
,
CTE_Nov
AS
(
SELECT
	COUNT(*) AS [Nov]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 11
)
,
CTE_Dec
AS
(
SELECT
	COUNT(*) AS [Dec]
FROM Orders O
LEFT JOIN Calendar C
ON C.Date = O.OrderDate
WHERE Month = 12
)
SELECT
	((CTE_Jan.Jan * 1.00000) / Main_CTE.Total) AS [Probability of Jan],

	((CTE_Feb.Feb * 1.00000) / Main_CTE.Total) AS [Probability of Feb],

	((CTE_Mar.Mar * 1.00000) / Main_CTE.Total) AS [Probability of Mar],

	((CTE_Apr.Apr * 1.00000) / Main_CTE.Total) AS [Probability of Apr],

	((CTE_May.May * 1.00000) / Main_CTE.Total) AS [Probability of May],

	((CTE_Jun.Jun * 1.00000) / Main_CTE.Total) AS [Probability of Jun],

	((CTE_Jul.Jul * 1.00000) / Main_CTE.Total) AS [Probability of Jul],

	((CTE_Aug.Aug * 1.00000) / Main_CTE.Total) AS [Probability of Aug],

	((CTE_Sep.Sep * 1.00000) / Main_CTE.Total) AS [Probability of Sep],

	((CTE_Oct.Oct * 1.00000) / Main_CTE.Total) AS [Probability of Oct],

	((CTE_Nov.Nov * 1.00000) / Main_CTE.Total) AS [Probability of Nov],

	((CTE_Dec.Dec * 1.00000) / Main_CTE.Total) AS [Probability of Dec]

FROM CTE_Jan, CTE_Feb, CTE_Mar, CTE_Apr, CTE_May, CTE_Jun, CTE_Jul, CTE_Aug, CTE_Sep, CTE_Oct, CTE_Nov, CTE_Dec, Main_CTE
GO
------------------------------------------------------------------------------------
--7
--The probability of ordering from a specific group product
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	SUM(NumUnits) AS [Total]
FROM OrderLines OL
)
,
CTE_Game
AS
(
SELECT
	SUM(NumUnits) AS [Game]
FROM OrderLines OL
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
WHERE GroupName = 'GAME'
)
,
CTE_Other
AS
(
SELECT
	SUM(NumUnits) AS [Other]
FROM OrderLines OL
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
WHERE GroupName = 'OTHER'
)
,
CTE_Book
AS
(
SELECT
	SUM(NumUnits) AS [Book]
FROM OrderLines OL
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
WHERE GroupName = 'BOOK'
)
,
CTE_Occasion
AS
(
SELECT
	SUM(NumUnits) AS [Occasion]
FROM OrderLines OL
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
WHERE GroupName = 'OCCASION'
)
,
CTE_NA
AS
(
SELECT
	SUM(NumUnits) AS [NA]
FROM OrderLines OL
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
WHERE GroupName = '#N/A'
)
,
CTE_Artwork
AS
(
SELECT
	SUM(NumUnits) AS [Artwork]
FROM OrderLines OL
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
WHERE GroupName = 'ARTWORK'
)
,
CTE_Apparel
AS
(
SELECT
	SUM(NumUnits) AS [Apparel]
FROM OrderLines OL
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
WHERE GroupName = 'APPAREL'
)
,
CTE_Freebie
AS
(
SELECT
	SUM(NumUnits) AS [Freebie]
FROM OrderLines OL
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
WHERE GroupName = 'FREEBIE'
)
,
CTE_Calendar
AS
(
SELECT
	SUM(NumUnits) AS [Calendar]
FROM OrderLines OL
LEFT JOIN Products P
ON P.ProductId = OL.ProductId
WHERE GroupName = 'CALENDAR'
)
SELECT
	((CTE_Apparel.Apparel * 1.00000) / Main_CTE.Total) AS [Probability of Apparel],

	((CTE_Artwork.Artwork * 1.00000) / Main_CTE.Total) AS [Probability of Artwork],

	((CTE_Book.Book * 1.00000) / Main_CTE.Total) AS [Probability of Book],

	((CTE_Calendar.Calendar * 1.00000) / Main_CTE.Total) AS [Probability of Calendar],

	((CTE_Freebie.Freebie * 1.00000) / Main_CTE.Total) AS [Probability of Freebie],

	((CTE_Game.Game * 1.00000) / Main_CTE.Total) AS [Probability of Game],

	((CTE_NA.NA * 1.00000) / Main_CTE.Total) AS [Probability of NA],

	((CTE_Occasion.Occasion * 1.00000) / Main_CTE.Total) AS [Probability of Occasion],

	((CTE_Other.Other * 1.00000) / Main_CTE.Total) AS [Probability of Other]

FROM Main_CTE, CTE_Apparel, CTE_Artwork, CTE_Book, CTE_Calendar, CTE_Freebie, CTE_Game, CTE_NA, CTE_Occasion, CTE_Other
GO
------------------------------------------------------------------------------------
--8
--The probability of an order being more than 1000
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	COUNT(*) AS [Total]
FROM Orders O
)
,
CTE_1000
AS
(
SELECT
	COUNT(*) AS [Orders more than 1000]
FROM Orders O
WHERE TotalPrice > 1000
)
SELECT 
	((CTE_1000.[Orders more than 1000] * 1.00000) / Main_CTE.Total) AS [Probability of Orders more than 1000],
	((CTE_1000.[Orders more than 1000] * 1.00000) / Main_CTE.Total) / (1 - ((CTE_1000.[Orders more than 1000] * 1.00000) / Main_CTE.Total)) AS [Odds of Orders more than 1000]
FROM CTE_1000,Main_CTE
GO
------------------------------------------------------------------------------------
--9
--Probability that an order has more than 5 lines in OrderLine table.
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	COUNT(*) AS [Total Orders]
FROM Orders O
)
,
CTE_OrderLine
AS
(
SELECT 
COUNT(*) AS [Number of Orders w OrderLine more than 5]
FROM
(
SELECT  
	OrderId,
	COUNT(OrderLineId) AS [Y] 
FROM OrderLines OL
GROUP BY OrderId
HAVING COUNT(OrderLineId) > 5
) AS [X]
)
SELECT 
	((CTE_OrderLine.[Number of Orders w OrderLine more than 5] * 1.00000) / Main_CTE.[Total Orders]) AS [Probability of an order has more than 5 lines],
	((CTE_OrderLine.[Number of Orders w OrderLine more than 5] * 1.00000) / Main_CTE.[Total Orders]) / (1 - ((CTE_OrderLine.[Number of Orders w OrderLine more than 5] * 1.00000) / Main_CTE.[Total Orders])) AS [Odds of an order has more than 5 lines]
FROM CTE_OrderLine,Main_CTE
GO
------------------------------------------------------------------------------------
--10
--The probability of an order has been ordered by a female or male
USE SQLBook
GO
WITH Main_CTE
AS
(
SELECT
	COUNT(*) AS [Total]
FROM Orders O
)
,
CTE_Male
AS
(
SELECT
	COUNT(*) AS [Male]
FROM Orders O
LEFT JOIN Customers C
ON C.CustomerId = O.CustomerId
WHERE Gender = 'M'
)
,
CTE_Female
AS
(
SELECT
	COUNT(*) AS [Female]
FROM Orders O
LEFT JOIN Customers C
ON C.CustomerId = O.CustomerId
WHERE Gender = 'F'
)
,
CTE_Unknown
AS
(
SELECT
	COUNT(*) AS [Unknown]
FROM Orders O
LEFT JOIN Customers C
ON C.CustomerId = O.CustomerId
WHERE Gender = ''
)

SELECT 
	((CTE_Male.Male * 1.00000) / Main_CTE.Total) AS [Probability of a customer to be male],
	((CTE_Female.Female * 1.00000) / Main_CTE.Total) AS [Probability of a customer to be female],
	((CTE_Unknown.Unknown * 1.00000) / Main_CTE.Total) AS [Probability of a customer to be unknown]
FROM Main_CTE,CTE_Male,CTE_Female,CTE_Unknown
GO
------------------------------------------------------------------------------------
