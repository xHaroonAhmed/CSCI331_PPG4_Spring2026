---------------------------------------------------------------------
-- Chapter 04 - Subqueries - Required Exercises
-- Group: PPG_4
-- Database: TSQLV6
---------------------------------------------------------------------

-- ===========================================================
-- Question 1
-- Write a query that returns all orders placed on the last day of
-- activity that can be found in the Orders table
-- Tables involved: Sales.Orders
-- ===========================================================

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = (SELECT MAX(orderdate) FROM Sales.Orders);

-- ===========================================================
-- Question 3
-- Write a query that returns employees
-- who did not place orders on or after May 1st, 2016
-- Tables involved: HR.Employees and Sales.Orders
-- ===========================================================

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE empid NOT IN (
    SELECT empid
    FROM Sales.Orders
    WHERE orderdate >= '20160501'
);

-- ===========================================================
-- Question 4
-- Write a query that returns countries where there are customers
-- but not employees
-- Tables involved: Sales.Customers and HR.Employees
-- ===========================================================

SELECT DISTINCT country
FROM Sales.Customers
WHERE country NOT IN (
    SELECT country
    FROM HR.Employees
);

-- ===========================================================
-- Question 5
-- Write a query that returns for each customer
-- all orders placed on the customer's last day of activity
-- Tables involved: Sales.Orders
-- ===========================================================

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
WHERE orderdate = (
    SELECT MAX(orderdate)
    FROM Sales.Orders AS O2
    WHERE O2.custid = O1.custid
)
ORDER BY custid;

-- ===========================================================
-- Question 6
-- Write a query that returns customers
-- who placed orders in 2015 but not in 2016
-- Tables involved: Sales.Customers and Sales.Orders
-- ===========================================================

SELECT custid, companyname
FROM Sales.Customers
WHERE custid IN (
    SELECT custid FROM Sales.Orders
    WHERE YEAR(orderdate) = 2015
)
AND custid NOT IN (
    SELECT custid FROM Sales.Orders
    WHERE YEAR(orderdate) = 2016
);

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
      SELECT custid FROM Sales.Customers
      WHERE custid IN (SELECT custid FROM Sales.Orders);

EXISTS:
  - Checks for the existence of at least one row in the subquery result.
  - Returns TRUE as soon as the first matching row is found (short-circuits),
    making it potentially more efficient for large datasets.
  - Handles NULLs correctly because it only checks for row existence,
    not value equality.
  - Example:
      SELECT custid FROM Sales.Customers AS C
      WHERE EXISTS (
          SELECT 1 FROM Sales.Orders AS O
          WHERE O.custid = C.custid
      );

Summary:
  - Use IN for simple value-list comparisons (especially with small subqueries).
  - Use EXISTS when checking row existence, especially with correlated subqueries
    or when NULLs may be present.
*/


---------------------------------------------------------------------
-- Chapter 05 - Table Expressions - Required Exercises
-- Group: PPG_4
-- Database: TSQLV6
---------------------------------------------------------------------

-- ===========================================================
-- Question 1
-- The following query attempts to filter orders placed on the last
-- day of the year but throws error: Invalid column name 'endofyear'.
-- Explain the problem and provide a valid solution.
-- ===========================================================

/*
PROBLEM:
  Column aliases defined in the SELECT clause (like 'endofyear') cannot
  be referenced in the WHERE clause of the same query. This is because
  SQL processes the WHERE clause BEFORE the SELECT clause logically,
  so the alias does not yet exist when the filter is evaluated.

SOLUTION:
  Wrap the original query in a derived table (or use a CTE), so that
  the alias 'endofyear' is materialized before being filtered against.
*/

-- Valid solution using a derived table:
SELECT orderid, orderdate, custid, empid, endofyear
FROM (
    SELECT orderid, orderdate, custid, empid,
        DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
    FROM Sales.Orders
) AS D
WHERE orderdate = endofyear;

-- ===========================================================
-- Question 2-1
-- Write a query that returns the maximum order date for each employee
-- Tables involved: Sales.Orders
-- ===========================================================

SELECT empid, MAX(orderdate) AS maxorderdate
FROM Sales.Orders
GROUP BY empid;

-- ===========================================================
-- Question 2-2
-- Encapsulate query from 2-1 in a derived table and join with
-- Sales.Orders to return orders with the max order date per employee
-- Tables involved: Sales.Orders
-- ===========================================================

SELECT O.empid, O.orderdate, O.orderid, O.custid
FROM Sales.Orders AS O
INNER JOIN (
    SELECT empid, MAX(orderdate) AS maxorderdate
    FROM Sales.Orders
    GROUP BY empid
) AS MaxDates
    ON O.empid = MaxDates.empid
    AND O.orderdate = MaxDates.maxorderdate
ORDER BY O.empid;

-- ===========================================================
-- Question 3-1
-- Write a query that calculates a row number for each order
-- based on orderdate, orderid ordering
-- Tables involved: Sales.Orders
-- ===========================================================

SELECT orderid, orderdate, custid, empid,
    ROW_NUMBER() OVER (ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders;

-- ===========================================================
-- Question 3-2
-- Return rows with row numbers 11 through 20 using a CTE
-- based on the row number definition in exercise 3-1
-- Tables involved: Sales.Orders
-- ===========================================================

WITH OrdersRN AS (
    SELECT orderid, orderdate, custid, empid,
        ROW_NUMBER() OVER (ORDER BY orderdate, orderid) AS rownum
    FROM Sales.Orders
)
SELECT orderid, orderdate, custid, empid, rownum
FROM OrdersRN
WHERE rownum BETWEEN 11 AND 20;

-- ===========================================================
-- Question 5-1
-- Create a view that returns the total qty
-- for each employee and year
-- Tables involved: Sales.Orders and Sales.OrderDetails
-- ===========================================================

DROP VIEW IF EXISTS Sales.VEmpOrders;
GO

CREATE VIEW Sales.VEmpOrders AS
    SELECT
        O.empid,
        YEAR(O.orderdate) AS orderyear,
        SUM(OD.qty) AS qty
    FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
        ON O.orderid = OD.orderid
    GROUP BY O.empid, YEAR(O.orderdate);
GO

-- Verify:
SELECT * FROM Sales.VEmpOrders ORDER BY empid, orderyear;

-- ===========================================================
-- Question 6-1
-- Create an inline function that accepts a supplier id and
-- a requested number of products, returning the @n products
-- with the highest unit prices from that supplier
-- Tables involved: Production.Products
-- ===========================================================

DROP FUNCTION IF EXISTS Production.TopProducts;
GO

CREATE FUNCTION Production.TopProducts
    (@supid AS INT, @n AS INT)
RETURNS TABLE
AS
RETURN
    SELECT TOP (@n) productid, productname, unitprice
    FROM Production.Products
    WHERE supplierid = @supid
    ORDER BY unitprice DESC;
GO

-- Verify:
SELECT * FROM Production.TopProducts(5, 2);

-- ===========================================================
-- Question 6-2
-- Using CROSS APPLY and the function from 6-1,
-- return for each supplier the two most expensive products
-- ===========================================================

SELECT S.supplierid, S.companyname, TP.productid, TP.productname, TP.unitprice
FROM Production.Suppliers AS S
CROSS APPLY Production.TopProducts(S.supplierid, 2) AS TP
ORDER BY S.supplierid;

-- Cleanup
-- DROP VIEW IF EXISTS Sales.VEmpOrders;
-- DROP FUNCTION IF EXISTS Production.TopProducts;


---------------------------------------------------------------------
-- Additional Query: Scalar Function for Federal Fiscal Year (FY) Quarters
-- FY starts October 1 (anchor month) and ends September 30 of YYYY+1
-- Analyze Total Orders and Total Freight per FY Quarter (Newest to Oldest)
-- Tables involved: Sales.Orders
---------------------------------------------------------------------

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
    -- Q1: Oct, Nov, Dec  (months 10,11,12)
    -- Q2: Jan, Feb, Mar  (months 1,2,3)
    -- Q3: Apr, May, Jun  (months 4,5,6)
    -- Q4: Jul, Aug, Sep  (months 7,8,9)
    IF @month IN (10, 11, 12)      SET @q = 1;
    ELSE IF @month IN (1, 2, 3)    SET @q = 2;
    ELSE IF @month IN (4, 5, 6)    SET @q = 3;
    ELSE                           SET @q = 4;

    RETURN 'FY' + CAST(@fy AS NVARCHAR(4)) + '-Q' + CAST(@q AS NVARCHAR(1));
END;
GO

-- Query using the scalar function on Sales.Orders
SELECT
    dbo.GetFYQuarter(orderdate)  AS FYQuarter,
    COUNT(*)                     AS TotalOrders,
    SUM(freight)                 AS TotalFreight
FROM Sales.Orders
GROUP BY dbo.GetFYQuarter(orderdate)
ORDER BY
    -- Sort newest FY first, then by quarter within FY
    LEFT(dbo.GetFYQuarter(orderdate), 6) DESC,  -- FY year portion e.g. FY2016
    RIGHT(dbo.GetFYQuarter(orderdate), 2) ASC;  -- Q portion e.g. Q1