
/*Ralph Cange

Chapter 4 HW 
  PPG 4





/* 1.
USE Northwinds2024Student

SELECT  OrderId AS orderid, Orderdate AS orderdate ,CustomerId AS custid, EmployeeId as empid
FROM [Sales].[Order] AS O1
WHERE orderdate = '2022-05-06'
AND EXISTS
(SELECT * FROM [Sales].[Order] AS O2
WHERE O1.CustomerId = O2.CustomerId)
ORDER BY orderid DESC;*/


/* 2.
USE Northwinds2024Student
SELECT O.CustomerId AS custid, O.OrderId as orderid, O.Orderdate AS orderdate, O.EmployeeId as empid
FROM Sales.[Order] AS O
WHERE O.CustomerId = 71
AND EXISTS(
SELECT *  FROM Sales.[Order] AS O1
WHERE O1.CustomerId = O.CustomerId)

Order BY custid, orderid;*/

/*
USE Northwinds2024Student
SELECT O.CustomerId AS custid, O.OrderId as orderid, O.Orderdate AS orderdate, O.EmployeeId as empid
FROM [Sales].[Order] AS O
WHERE CustomerId = (
    SELECT TOP 1 CustomerId
    FROM [Sales].[Order]
    GROUP BY CustomerId
    ORDER BY COUNT(*) DESC
)
ORDER BY custid, orderid;*/
 /*3.
 USE Northwinds2024Student
SELECT E.EmployeeId, E.EmployeeLastName, E.EmployeeFirstName
FROM HumanResources.Employee AS E
WHERE E.EmployeeId NOT IN
(
SELECT O.EmployeeId FROM Sales.[Order] AS O
WHERE orderdate >= '2022-05-01'
)
*/
/*4.
USE Northwinds2024Student
SELECT DISTINCT C.CustomerCountry AS country
FROM Sales.Customers AS C
WHERE C.CustomerCountry NOT IN (
    SELECT DISTINCT E.EmployeeCountry 
    FROM HumanResources.Employee AS E
)
ORDER BY country;*/


USE Northwinds2024Student

SELECT O.CustomerId, O.OrderId, O.Orderdate, O.EmployeeId
FROM Sales.[Order] AS O
WHERE O.Orderdate = (
    SELECT MAX(orderdate)
    FROM Sales.[Order] AS O2
    WHERE O2.Customerid = O.Customerid
    )
ORDER BY O.CustomerId, O.Orderid;

/* 6.
USE Northwinds2024Student

SELECT C.CustomerId, C.CustomerCompanyName, C.CustomerCountry
FROM Sales.Customers AS C
WHERE C.CustomerId IN (
    SELECT DISTINCT O.CustomerId
    FROM Sales.[Order] AS O
    WHERE YEAR(O.orderdate) = 2021
)
AND C.CustomerId NOT IN (
    SELECT DISTINCT O.CustomerId
    FROM Sales.[Order] AS O
    WHERE YEAR(O.orderdate) = 2022
)
ORDER BY C.CustomerId;*/

/* 7.
USE Northwinds2024Student;

SELECT CustomerId, CustomerCompanyName
FROM Sales.Customers
WHERE CustomerId IN (
    SELECT DISTINCT CustomerId
    FROM Sales.[Order]
    WHERE OrderId IN (
        SELECT OrderId
        FROM Sales.OrderDetail
        WHERE productid = 12
    )
)
ORDER BY custid;
*/

/* 8.
USE NorthWinds2024Student;
SELECT 
    O1.CustomerId AS custid, 
    O1.OrderDate AS ordermonth, 
    COUNT(*) AS qty,
    (
        SELECT COUNT(*)
        FROM [Northwinds2024Student].[Sales].[Order] AS O2
        WHERE O2.CustomerId = O1.CustomerId
        AND O2.OrderDate <= O1.OrderDate
    ) AS runqty
FROM [Northwinds2024Student].[Sales].[Order] AS O1
GROUP BY O1.CustomerId, O1.OrderDate
ORDER BY O1.CustomerId, O1.OrderDate;
*/

/* 9.
Explain the difference between IN and EXISTS

The IN predicate

*/
