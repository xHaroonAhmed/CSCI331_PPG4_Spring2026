




/* Ralph Cange
Chapter 5 HW
1.

USE Northwinds2024Student
SELECT OrderId AS orderid, OrderDate AS orderdate, CustomerId AS custid, EmployeeId AS empid,
    DATEFROMPARTS(YEAR(OrderDate), 12, 31) AS endofyear
FROM [Sales].[Order]
WHERE OrderDate <> DATEFROMPARTS(YEAR(OrderDate), 12, 31);
GO

SINCE where happens before select the endofyear row didnt exist which can be fixed by declaring it the select clause*/

/* 2-1.
USE Northwinds2024Student
SELECT EmployeeId AS empid,MAX(OrderDate) AS maxorderdate
FROM [Sales].[Order]
GROUP BY EmployeeId
ORDER BY EmployeeId;*/

/* 2-2.
USE Northwinds2024Student


SELECT TOP (10) OrderId AS orderid, OrderDate AS orderdate, CustomerId AS custid, EmployeeId AS empid,
    ROW_NUMBER() OVER (ORDER BY OrderDate, OrderId) AS rownum
FROM [Sales].[Order]
ORDER BY rownum;*/

