---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 04 - Subqueries
-- Homework 4
-- Haroon Ahmed
---------------------------------------------------------------------

---------------------------------------------------------------
-- CH4-1
-- Return all orders placed on the last day of activity in Orders
---------------------------------------------------------------
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = (SELECT MAX(orderdate) FROM Sales.Orders);


---------------------------------------------------------------
-- CH4-3
-- Return employees who did NOT place orders on or after May 1, 2016
---------------------------------------------------------------
SELECT E.empid, E.firstname, E.lastname
FROM HR.Employees AS E
WHERE NOT EXISTS
(
  SELECT 1
  FROM Sales.Orders AS O
  WHERE O.empid = E.empid
    AND O.orderdate >= '2016-05-01'
)
ORDER BY E.empid;


---------------------------------------------------------------
-- CH4-4
-- Return countries where there are customers but not employees
---------------------------------------------------------------
SELECT C.country
FROM Sales.Customers AS C
WHERE NOT EXISTS
(
  SELECT 1
  FROM HR.Employees AS E
  WHERE E.country = C.country
)
GROUP BY C.country
ORDER BY C.country;


---------------------------------------------------------------
-- CH4-5
-- For each customer, return all orders placed on customer's last day of activity
---------------------------------------------------------------
SELECT O.custid, O.orderid, O.orderdate, O.empid
FROM Sales.Orders AS O
WHERE O.orderdate =
(
  SELECT MAX(O2.orderdate)
  FROM Sales.Orders AS O2
  WHERE O2.custid = O.custid
)
ORDER BY O.custid, O.orderid;


---------------------------------------------------------------
-- CH4-6
-- Return customers who placed orders in 2015 but not in 2016
---------------------------------------------------------------
SELECT C.custid, C.companyname
FROM Sales.Customers AS C
WHERE EXISTS
(
  SELECT 1
  FROM Sales.Orders AS O
  WHERE O.custid = C.custid
    AND O.orderdate >= '2015-01-01'
    AND O.orderdate <  '2016-01-01'
)
AND NOT EXISTS
(
  SELECT 1
  FROM Sales.Orders AS O
  WHERE O.custid = C.custid
    AND O.orderdate >= '2016-01-01'
    AND O.orderdate <  '2017-01-01'
)
ORDER BY C.custid;


---------------------------------------------------------------
-- CH4-9
-- Explain the difference between IN and EXISTS
---------------------------------------------------------------
/*
IN:
- Compares a value to a set returned by a subquery.
- Works well with simple lists or non-correlated queries.
- NULL values can cause unexpected behavior.

EXISTS:
- Checks whether a subquery returns at least one row.
- Often used with correlated subqueries.
- Stops evaluating once a match is found, often making it faster.
*/