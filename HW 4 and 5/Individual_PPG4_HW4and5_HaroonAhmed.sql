---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 04 - Subqueries - Required Exercises
-- Group: PPG_4
-- Database: Northwinds2024Student
---------------------------------------------------------------------

-- ===========================================================
-- Question 1
-- Write a query that returns all orders placed on the last day of
-- activity that can be found in the Orders table
-- Tables involved: Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT OrderId AS orderid, OrderDate AS orderdate, CustomerId AS custid, EmployeeId AS empid
FROM Sales.[Order]
WHERE OrderDate = (SELECT MAX(OrderDate) FROM Sales.[Order]);

-- ===========================================================
-- Question 3
-- Write a query that returns employees
-- who did not place orders on or after May 1st, 2022
-- Tables involved: HumanResources.Employee and Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT E.EmployeeId AS empid, E.EmployeeFirstName AS firstname, E.EmployeeLastName AS lastname
FROM HumanResources.Employee AS E
WHERE E.EmployeeId NOT IN (
    SELECT O.EmployeeId
    FROM Sales.[Order] AS O
    WHERE O.OrderDate >= '20220501'
);

-- ===========================================================
-- Question 4
-- Write a query that returns countries where there are customers
-- but not employees
-- Tables involved: Sales.Customers and HumanResources.Employee
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT DISTINCT C.CustomerCountry AS country
FROM Sales.Customers AS C
WHERE C.CustomerCountry NOT IN (
    SELECT DISTINCT E.EmployeeCountry
    FROM HumanResources.Employee AS E
)
ORDER BY country;

-- ===========================================================
-- Question 5
-- Write a query that returns for each customer
-- all orders placed on the customer's last day of activity
-- Tables involved: Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT O.CustomerId AS custid, O.OrderId AS orderid, O.OrderDate AS orderdate, O.EmployeeId AS empid
FROM Sales.[Order] AS O
WHERE O.OrderDate = (
    SELECT MAX(O2.OrderDate)
    FROM Sales.[Order] AS O2
    WHERE O2.CustomerId = O.CustomerId
)
ORDER BY O.CustomerId, O.OrderId;

-- ===========================================================
-- Question 6
-- Write a query that returns customers
-- who placed orders in 2021 but not in 2022
-- Tables involved: Sales.Customers and Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT C.CustomerId AS custid, C.CustomerCompanyName AS companyname
FROM Sales.Customers AS C
WHERE C.CustomerId IN (
    SELECT DISTINCT O.CustomerId
    FROM Sales.[Order] AS O
    WHERE YEAR(O.OrderDate) = 2021
)
AND C.CustomerId NOT IN (
    SELECT DISTINCT O.CustomerId
    FROM Sales.[Order] AS O
    WHERE YEAR(O.OrderDate) = 2022
)
ORDER BY C.CustomerId;

-- ===========================================================
-- Question 9
-- Explain the difference between IN and EXISTS
-- ===========================================================

/*
IN vs EXISTS:

IN:
  - Checks whether a value matches any value in a subquery result set.
  - The subquery is fully evaluated first, then each row in the outer
    query is compared against the returned list.
  - Does NOT handle NULLs well: if the subquery returns any NULL values,
    "NOT IN" will return no rows (due to three-valued logic in SQL).
  - Example:
      SELECT CustomerId FROM Sales.Customers
      WHERE CustomerId IN (SELECT CustomerId FROM Sales.[Order]);

EXISTS:
  - Checks for the existence of at least one row in the subquery result.
  - Returns TRUE as soon as the first matching row is found (short-circuits),
    making it potentially more efficient for large datasets.
  - Handles NULLs correctly because it only checks for row existence,
    not value equality.
  - Example:
      SELECT CustomerId FROM Sales.Customers AS C
      WHERE EXISTS (
          SELECT 1 FROM Sales.[Order] AS O
          WHERE O.CustomerId = C.CustomerId
      );

Summary:
  - Use IN for simple value-list comparisons (especially with small subqueries).
  - Use EXISTS when checking row existence, especially with correlated subqueries
    or when NULLs may be present.
*/


---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 05 - Table Expressions - Required Exercises
-- Group: PPG_4
-- Database: Northwinds2024Student
---------------------------------------------------------------------

-- ===========================================================
-- Question 1
-- The following query attempts to filter orders placed on the last
-- day of the year but throws: Invalid column name 'endofyear'.
-- Explain the problem and provide a valid solution.
-- ===========================================================

/*
PROBLEM:
  Column aliases defined in the SELECT clause (like 'endofyear') cannot
  be referenced in the WHERE clause of the same query. SQL processes the
  WHERE clause BEFORE the SELECT clause logically, so the alias does not
  yet exist when the filter is evaluated.

SOLUTION:
  Wrap the original query in a derived table so that the alias
  'endofyear' is materialized before being filtered against.
*/

USE Northwinds2024Student;
GO

-- Valid solution using a derived table:
SELECT orderid, orderdate, custid, empid, endofyear
FROM (
    SELECT
        OrderId    AS orderid,
        OrderDate  AS orderdate,
        CustomerId AS custid,
        EmployeeId AS empid,
        DATEFROMPARTS(YEAR(OrderDate), 12, 31) AS endofyear
    FROM Sales.[Order]
) AS D
WHERE orderdate = endofyear;

-- ===========================================================
-- Question 2-1
-- Write a query that returns the maximum order date for each employee
-- Tables involved: Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT EmployeeId AS empid, MAX(OrderDate) AS maxorderdate
FROM Sales.[Order]
GROUP BY EmployeeId
ORDER BY EmployeeId;

-- ===========================================================
-- Question 2-2
-- Encapsulate query from 2-1 in a derived table and join with
-- Sales.[Order] to return orders with the max order date per employee
-- Tables involved: Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT O.EmployeeId AS empid, O.OrderDate AS orderdate, O.OrderId AS orderid, O.CustomerId AS custid
FROM Sales.[Order] AS O
INNER JOIN (
    SELECT EmployeeId, MAX(OrderDate) AS maxorderdate
    FROM Sales.[Order]
    GROUP BY EmployeeId
) AS MaxDates
    ON O.EmployeeId = MaxDates.EmployeeId
    AND O.OrderDate = MaxDates.maxorderdate
ORDER BY O.EmployeeId;

-- ===========================================================
-- Question 3-1
-- Write a query that calculates a row number for each order
-- based on orderdate, orderid ordering
-- Tables involved: Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT
    OrderId    AS orderid,
    OrderDate  AS orderdate,
    CustomerId AS custid,
    EmployeeId AS empid,
    ROW_NUMBER() OVER (ORDER BY OrderDate, OrderId) AS rownum
FROM Sales.[Order];

-- ===========================================================
-- Question 3-2
-- Return rows with row numbers 11 through 20 using a CTE
-- based on the row number definition in exercise 3-1
-- Tables involved: Sales.[Order]
-- ===========================================================

USE Northwinds2024Student;
GO

WITH OrdersRN AS (
    SELECT
        OrderId    AS orderid,
        OrderDate  AS orderdate,
        CustomerId AS custid,
        EmployeeId AS empid,
        ROW_NUMBER() OVER (ORDER BY OrderDate, OrderId) AS rownum
    FROM Sales.[Order]
)
SELECT orderid, orderdate, custid, empid, rownum
FROM OrdersRN
WHERE rownum BETWEEN 11 AND 20;

-- ===========================================================
-- Question 5-1
-- Create a view that returns the total qty
-- for each employee and year
-- Tables involved: Sales.[Order] and Sales.OrderDetail
-- ===========================================================

USE Northwinds2024Student;
GO

DROP VIEW IF EXISTS Sales.VEmpOrders;
GO

CREATE VIEW Sales.VEmpOrders AS
    SELECT
        O.EmployeeId             AS empid,
        YEAR(O.OrderDate)        AS orderyear,
        SUM(OD.Quantity)         AS qty
    FROM Sales.[Order] AS O
    INNER JOIN Sales.OrderDetail AS OD
        ON O.OrderId = OD.OrderId
    GROUP BY O.EmployeeId, YEAR(O.OrderDate);
GO

-- Verify:
SELECT * FROM Sales.VEmpOrders ORDER BY empid, orderyear;

-- ===========================================================
-- Question 6-1
-- Create an inline function that accepts a supplier id and
-- a requested number of products, returning the @n products
-- with the highest unit prices from that supplier
-- Tables involved: Production.Product (Northwinds)
-- ===========================================================

USE Northwinds2024Student;
GO

DROP FUNCTION IF EXISTS Production.TopProducts;
GO

CREATE FUNCTION Production.TopProducts
    (@supid AS INT, @n AS INT)
RETURNS TABLE
AS
RETURN
    SELECT TOP (@n)
        ProductId   AS productid,
        ProductName AS productname,
        UnitPrice   AS unitprice
    FROM Production.Product
    WHERE SupplierId = @supid
    ORDER BY UnitPrice DESC;
GO

-- Verify:
SELECT * FROM Production.TopProducts(5, 2);

-- ===========================================================
-- Question 6-2
-- Using CROSS APPLY and the function from 6-1,
-- return for each supplier the two most expensive products
-- ===========================================================

USE Northwinds2024Student;
GO

SELECT
    S.SupplierId   AS supplierid,
    S.SupplierCompanyName AS companyname,
    TP.productid,
    TP.productname,
    TP.unitprice
FROM Production.Supplier AS S
CROSS APPLY Production.TopProducts(S.SupplierId, 2) AS TP
ORDER BY S.SupplierId;

-- Cleanup (uncomment when done):
-- DROP VIEW IF EXISTS Sales.VEmpOrders;
-- DROP FUNCTION IF EXISTS Production.TopProducts;


---------------------------------------------------------------------
-- Additional Query: Scalar Function for Federal Fiscal Year (FY) Quarters
-- FY starts October 1 (anchor month) and ends September 30 of YYYY+1
-- Analyze Total Orders and Total Freight for each FY Quarter
-- Ordered Newest to Oldest
-- Tables involved: Sales.[Order]
---------------------------------------------------------------------

USE Northwinds2024Student;
GO

DROP FUNCTION IF EXISTS dbo.GetFYQuarter;
GO

CREATE FUNCTION dbo.GetFYQuarter (@orderdate AS DATE)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @month INT = MONTH(@orderdate);
    DECLARE @year  INT = YEAR(@orderdate);
    DECLARE @fy    INT;
    DECLARE @q     INT;

    -- Determine FY year: if month >= 10, FY = current year + 1; else FY = current year
    IF @month >= 10
        SET @fy = @year + 1;
    ELSE
        SET @fy = @year;

    -- Determine FY quarter
    -- Q1: Oct, Nov, Dec  (months 10, 11, 12)
    -- Q2: Jan, Feb, Mar  (months 1, 2, 3)
    -- Q3: Apr, May, Jun  (months 4, 5, 6)
    -- Q4: Jul, Aug, Sep  (months 7, 8, 9)
    IF @month IN (10, 11, 12)      SET @q = 1;
    ELSE IF @month IN (1, 2, 3)    SET @q = 2;
    ELSE IF @month IN (4, 5, 6)    SET @q = 3;
    ELSE                           SET @q = 4;

    RETURN 'FY' + CAST(@fy AS NVARCHAR(4)) + '-Q' + CAST(@q AS NVARCHAR(1));
END;
GO

-- Analysis query using the scalar function on Sales.[Order]
SELECT
    dbo.GetFYQuarter(OrderDate)  AS FYQuarter,
    COUNT(*)                     AS TotalOrders,
    SUM(Freight)                 AS TotalFreight
FROM Sales.[Order]
GROUP BY dbo.GetFYQuarter(OrderDate)
ORDER BY
    LEFT(dbo.GetFYQuarter(OrderDate), 6) DESC,   -- FY year portion e.g. FY2022
    RIGHT(dbo.GetFYQuarter(OrderDate), 2) ASC;   -- Quarter portion e.g. Q1