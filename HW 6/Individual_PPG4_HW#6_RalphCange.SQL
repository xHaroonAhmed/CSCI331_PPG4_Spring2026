---------------------------------------------------------------------
-- Ralph Cange 3/14/2026
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 06 - Set Operators
-- Exercises
-- ? Itzik Ben-Gan 
---------------------------------------------------------------------


-- 1
-- Explain the difference between the UNION ALL and UNION operators
-- In what cases are they equivalent?
-- When they are equivalent, which one should you use?

-- The difference between UNION ALL and UNION operators is that UNION 
-- will combine the results of two queries but ignores duplicates while
-- UNION ALL will combine the queries including duplicates found in both queries.

-- Both operators are equivalent when there are no row duplicates

-- In the case when both operators are same, I would just use the UNION operator.
-- Even though UNION ALL will result in the same query if there are no duplicates,
-- I just see no point in using the operator if im not looking for duplicates.


-- 2
-- Write a query that generates a virtual auxiliary table of 10 numbers
-- in the range 1 through 10
-- Tables involved: no table

 
 SELECT 1 as num
 UNION SELECT 2
 UNION SELECT 3
 UNION SELECT 4
 UNION SELECT 5
 UNION SELECT 6
 UNION SELECT 7
 UNION SELECT 8
 UNION SELECT 9
 UNION SELECT 10;


 -- 3
-- Write a query that returns customer and employee pairs 
-- that had order activity in January 2016 but not in February 2016
-- Tables involved: Northwinds2024Student database, Orders table

USE Northwinds2024Student
GO

SELECT custid, empid
FROM(
SELECT N1.CustomerId AS custid, N1.EmployeeId as empid, N1.Orderdate AS DATE 
FROM [Sales].[Order] AS N1
WHERE N1.Orderdate > '2022-01-01'  AND Orderdate < '2022-01-30'
EXCEPT
SELECT N2.CustomerId AS custid, N2.EmployeeId as empid, N2.Orderdate AS DATE
FROM [Sales].[Order] AS N2
WHERE N2.Orderdate > '2022-02-01' AND Orderdate < '2022-02-28'
) AS O
ORDER BY custid, empid;

-- 4
-- Write a query that returns customer and employee pairs 
-- that had order activity in both January 2016 and February 2016
-- Tables involved: Northwinds2024Student database, Orders table

USE Northwinds2024Student
GO


SELECT N1.CustomerId AS custid, N1.EmployeeId as empid
FROM [Sales].[Order] AS N1
WHERE N1.Orderdate >= '2022-01-01' AND Orderdate <= '2022-02-01'
INTERSECT
SELECT N2.CustomerId AS custid, N2.EmployeeId as empid
FROM [Sales].[Order] AS N2
WHERE N2.Orderdate >= '2022-02-01' AND Orderdate <= '2022-03-01'
ORDER BY custid, empid;

-- 5
-- Write a query that returns customer and employee pairs 
-- that had order activity in both January 2016 and February 2016
-- but not in 2015
-- Tables involved: Northwinds2024Student database, Orders table

USE Northwinds2024Student
GO

(SELECT N1.CustomerId AS custid, N1.EmployeeId as empid
FROM [Sales].[Order] AS N1
WHERE N1.Orderdate >= '2022-01-01' AND Orderdate <= '2022-02-01'
INTERSECT
SELECT N2.CustomerId AS custid, N2.EmployeeId as empid
FROM [Sales].[Order] AS N2
WHERE N2.Orderdate >= '2022-02-01' AND Orderdate <= '2022-03-01'
)
EXCEPT 
SELECT N3.CustomerId AS custid, N3.EmployeeId as empid
FROM [Sales].[Order] AS N3
WHERE N3.Orderdate >= '2021-01-01' AND Orderdate <= '2021-12-31'
ORDER BY custid, empid;

-- 6 (Optional, Advanced)
-- You are given the following query:
--SELECT country, region, city
--FROM HR.Employees


--UNION ALL


--SELECT country, region, city
--FROM Production.Suppliers;


-- You are asked to add logic to the query 
-- such that it would guarantee that the rows from Employees
-- would be returned in the output before the rows from Suppliers,
-- and within each segment, the rows should be sorted
-- by country, region, city
-- Tables involved: Northwinds2024Student database, Employees and Suppliers tables

DECLARE 
@employees INT = 1;
DECLARE
@suppliers INT = 2;

BEGIN

SELECT col, country, region, city
FROM
(SELECT @employees AS col, HR.EmployeeCountry as country, HR.EmployeeRegion as  region, HR.EmployeeCity as city
FROM HumanResources.Employee as HR


UNION ALL


SELECT @suppliers AS col,SupplierCountry, SupplierRegion, SupplierCity
FROM Production.Supplier) AS O
ORDER BY col;

END;




