---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 05 - Table Expressions
-- Homework 4
-- Haroon Ahmed
---------------------------------------------------------------------

---------------------------------------------------------------
-- CH5-1
-- Alias in SELECT cannot be used in WHERE; provide valid solution(s)
---------------------------------------------------------------

-- Fix 1: Repeat expression
SELECT orderid, orderdate, custid, empid,
       DATEFROMPARTS(YEAR(orderdate),12,31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> DATEFROMPARTS(YEAR(orderdate),12,31);


-- Fix 2: Use a CTE
WITH OrdersCTE AS
(
    SELECT orderid, orderdate, custid, empid,
           DATEFROMPARTS(YEAR(orderdate),12,31) AS endofyear
    FROM Sales.Orders
)
SELECT *
FROM OrdersCTE
WHERE orderdate <> endofyear;


---------------------------------------------------------------
-- CH5-2-1
-- Return maximum order date for each employee
---------------------------------------------------------------
SELECT empid, MAX(orderdate) AS maxorderdate
FROM Sales.Orders
GROUP BY empid
ORDER BY empid;


---------------------------------------------------------------
-- CH5-2-2
-- Return orders with the maximum order date for each employee
---------------------------------------------------------------
SELECT O.empid, O.orderdate, O.orderid, O.custid
FROM Sales.Orders O
JOIN
(
    SELECT empid, MAX(orderdate) AS maxorderdate
    FROM Sales.Orders
    GROUP BY empid
) M
ON O.empid = M.empid
AND O.orderdate = M.maxorderdate
ORDER BY O.empid;


---------------------------------------------------------------
-- CH5-3-1
-- Calculate row number for each order
---------------------------------------------------------------
SELECT orderid, orderdate, custid, empid,
       ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders;


---------------------------------------------------------------
-- CH5-3-2
-- Return rows with row numbers 11–20
---------------------------------------------------------------
WITH OrdersRowNum AS
(
    SELECT orderid, orderdate, custid, empid,
           ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum
    FROM Sales.Orders
)
SELECT *
FROM OrdersRowNum
WHERE rownum BETWEEN 11 AND 20
ORDER BY rownum;


---------------------------------------------------------------
-- EXTRA REQUIRED QUESTION
-- Fiscal Year Quarter Function
---------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.FYQuarterLabel(@d DATE)
RETURNS VARCHAR(12)
AS
BEGIN

    DECLARE @fy INT =
        CASE WHEN MONTH(@d) >= 10
        THEN YEAR(@d) + 1
        ELSE YEAR(@d)
        END;

    DECLARE @quarter INT =
        CASE
            WHEN MONTH(@d) IN (10,11,12) THEN 1
            WHEN MONTH(@d) IN (1,2,3) THEN 2
            WHEN MONTH(@d) IN (4,5,6) THEN 3
            ELSE 4
        END;

    RETURN CONCAT('FY', @fy, ' Q', @quarter);

END;
GO


---------------------------------------------------------------
-- FY Quarter Analysis
---------------------------------------------------------------
WITH QuarterData AS
(
    SELECT
        dbo.FYQuarterLabel(orderdate) AS FYQuarter,
        freight
    FROM Sales.Orders
)

SELECT
    FYQuarter,
    COUNT(*) AS total_orders,
    SUM(COALESCE(freight,0)) AS total_freight
FROM QuarterData
GROUP BY FYQuarter
ORDER BY FYQuarter DESC;