---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 06 - Set Operators - Exercises Completed
-- Haroon Ahmed
-- Group: PPG_4
-- Database: Northwinds2024Student
---------------------------------------------------------------------

-- ===========================================================
-- Question 1
-- Explain the difference between the UNION ALL and UNION operators.
-- In what cases are they equivalent?
-- When they are equivalent, which one should you use?
-- ===========================================================

/*
UNION vs UNION ALL comes down to one thing: duplicate handling.

UNION removes duplicate rows from the final result. To do this, SQL
Server has to sort or hash the combined rows and compare them -- which
costs extra time and resources, especially on large result sets.

UNION ALL skips that step entirely. It just stacks the two result sets
on top of each other and returns everything, duplicates and all. Because
there is no deduplication pass, it is always faster than UNION.

They produce identical results when the two input sets share no common
rows -- for instance, pulling orders from two completely separate date
windows, or combining data from tables that by design cannot overlap.

In those cases, UNION ALL is the right choice. There is no reason to
pay the performance cost of duplicate elimination when you already know
no duplicates exist. Using UNION in that scenario does extra work for
no benefit. UNION should only be used when removing duplicates is an
actual requirement of the query.
*/

-- ===========================================================
-- Question 2
-- Write a query that generates a virtual auxiliary table of 10 numbers
-- in the range 1 through 10
-- Tables involved: no table
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT 1 AS n
UNION ALL SELECT 2
UNION ALL SELECT 3
UNION ALL SELECT 4
UNION ALL SELECT 5
UNION ALL SELECT 6
UNION ALL SELECT 7
UNION ALL SELECT 8
UNION ALL SELECT 9
UNION ALL SELECT 10;

-- ===========================================================
-- Question 3
-- Write a query that returns customer and employee pairs
-- that had order activity in January 2022 but not in February 2022
-- Tables involved: Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT custid, empid
FROM (
    SELECT CustomerId AS custid, EmployeeId AS empid
    FROM [Sales].[Order]
    WHERE OrderDate >= '20220101' AND OrderDate < '20220201'

    EXCEPT

    SELECT CustomerId AS custid, EmployeeId AS empid
    FROM [Sales].[Order]
    WHERE OrderDate >= '20220201' AND OrderDate < '20220301'
) AS O
ORDER BY custid, empid;

-- ===========================================================
-- Question 4
-- Write a query that returns customer and employee pairs
-- that had order activity in both January 2022 and February 2022
-- Tables involved: Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT CustomerId AS custid, EmployeeId AS empid
FROM [Sales].[Order]
WHERE OrderDate >= '20220101' AND OrderDate < '20220201'

INTERSECT

SELECT CustomerId AS custid, EmployeeId AS empid
FROM [Sales].[Order]
WHERE OrderDate >= '20220201' AND OrderDate < '20220301'

ORDER BY custid, empid;

-- ===========================================================
-- Question 5
-- Write a query that returns customer and employee pairs
-- that had order activity in both January 2022 and February 2022
-- but not in 2021
-- Tables involved: Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

(
    SELECT CustomerId AS custid, EmployeeId AS empid
    FROM [Sales].[Order]
    WHERE OrderDate >= '20220101' AND OrderDate < '20220201'

    INTERSECT

    SELECT CustomerId AS custid, EmployeeId AS empid
    FROM [Sales].[Order]
    WHERE OrderDate >= '20220201' AND OrderDate < '20220301'
)

EXCEPT

SELECT CustomerId AS custid, EmployeeId AS empid
FROM [Sales].[Order]
WHERE OrderDate >= '20210101' AND OrderDate < '20220101'

ORDER BY custid, empid;

-- ===========================================================
-- Question 6 (Optional, Advanced)
-- Add logic to guarantee Employee rows appear before Supplier rows,
-- sorted within each segment by country, region, city
-- Tables involved: HumanResources.Employee and Production.Supplier
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT country, region, city
FROM (
    SELECT 1 AS sortcol,
        EmployeeCountry AS country,
        EmployeeRegion  AS region,
        EmployeeCity    AS city
    FROM HumanResources.Employee

    UNION ALL

    SELECT 2 AS sortcol,
        SupplierCountry AS country,
        SupplierRegion  AS region,
        SupplierCity    AS city
    FROM Production.Supplier
) AS D
ORDER BY sortcol, country, region, city;
