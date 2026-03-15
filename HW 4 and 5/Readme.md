<div align="center">

# 📊 CSCI 331 — Database and Data Modeling
### Homework 4 & 5 · Chapters 4 & 5: Subqueries & Table Expressions

> *Using T-SQL Subqueries and Table Expressions to answer complex business questions against the Northwinds2024Student database.*

</div>

---

## 🎯 Assignment Overview

This assignment covered **Chapters 4 and 5** from *T-SQL Fundamentals (4th Edition)* by Itzik Ben-Gan:

- **Chapter 4 — Subqueries:** Writing self-contained and correlated subqueries to filter, compare, and derive values dynamically from within a query.
- **Chapter 5 — Table Expressions:** Encapsulating query logic using derived tables, Common Table Expressions (CTEs), views, and inline table-valued functions.

All queries were developed and tested in **TSQLV6** and adapted for the **Northwinds2024Student** database running on SQL Server 2022 Developer Edition via Docker.

An additional query was completed implementing a **Federal Fiscal Year (FY) scalar function** applied to freight and order analysis.

---

## 📚 Concepts Learned

### 🔍 Chapter 4 — Subqueries

Subqueries are SELECT statements nested inside another query. They can appear in the `WHERE`, `FROM`, or `SELECT` clauses and fall into two categories:

#### Self-Contained Subqueries
Execute independently of the outer query. The inner query runs once and its result is used by the outer query.

```sql
-- Orders placed on the last day of activity
SELECT OrderId, OrderDate, CustomerId, EmployeeId
FROM [Sales].[Order]
WHERE OrderDate = (SELECT MAX(OrderDate) FROM [Sales].[Order]);
```

#### Correlated Subqueries
Reference columns from the outer query, causing the inner query to re-execute for each row of the outer query.

```sql
-- Each customer's orders on their personal last active day
SELECT CustomerId, OrderId, OrderDate, EmployeeId
FROM [Sales].[Order] AS O1
WHERE OrderDate = (
    SELECT MAX(OrderDate)
    FROM [Sales].[Order] AS O2
    WHERE O2.CustomerId = O1.CustomerId
);
```

#### IN vs EXISTS
Two common subquery predicates with important behavioral differences:

| Feature | `IN` | `EXISTS` |
|---------|------|----------|
| Execution | Evaluates full subquery first | Short-circuits on first match |
| NULL handling | ⚠️ `NOT IN` fails silently with NULLs | ✅ Safe — checks existence only |
| Best for | Small, static value lists | Correlated checks, large datasets |

**Key rule:** Never use `NOT IN` when the subquery might return NULLs — use `NOT EXISTS` instead.

---

### 🏗️ Chapter 5 — Table Expressions

Table expressions allow complex query logic to be encapsulated and reused. Four types were covered:

#### Derived Tables
Inline subqueries in the `FROM` clause. Used to materialize a column alias before it can be referenced in `WHERE`.

```sql
-- Fix for the 'endofyear' alias scoping error
SELECT orderid, orderdate, custid, empid, endofyear
FROM (
    SELECT OrderId, OrderDate, CustomerId, EmployeeId,
        DATEFROMPARTS(YEAR(OrderDate), 12, 31) AS endofyear
    FROM [Sales].[Order]
) AS D
WHERE orderdate = endofyear;
```

> **Why this works:** SQL's logical processing order evaluates `WHERE` before `SELECT`, so aliases defined in `SELECT` don't exist yet when `WHERE` runs. Wrapping in a derived table materializes the alias first.

#### Common Table Expressions (CTEs)
Named temporary result sets defined with `WITH`. Cleaner than nested derived tables for multi-step logic.

```sql
-- Return rows 11–20 using a CTE
WITH OrdersRN AS (
    SELECT OrderId, OrderDate, CustomerId, EmployeeId,
        ROW_NUMBER() OVER (ORDER BY OrderDate, OrderId) AS rownum
    FROM [Sales].[Order]
)
SELECT * FROM OrdersRN WHERE rownum BETWEEN 11 AND 20;
```

#### Views
Stored reusable queries that act like virtual tables. Created once and queried repeatedly without rewriting logic.

```sql
CREATE VIEW Sales.VEmpOrders AS
    SELECT O.EmployeeId, YEAR(O.OrderDate) AS orderyear, SUM(OD.Quantity) AS qty
    FROM [Sales].[Order] AS O
    INNER JOIN [Sales].[OrderDetail] AS OD ON O.OrderId = OD.OrderId
    GROUP BY O.EmployeeId, YEAR(O.OrderDate);
```

#### Inline Table-Valued Functions (TVFs) with CROSS APPLY
Parameterized functions that return a table. Combined with `CROSS APPLY` to evaluate per-row.

```sql
-- Top N products per supplier using CROSS APPLY
SELECT S.SupplierId, S.SupplierCompanyName, TP.productid, TP.productname, TP.unitprice
FROM Production.Supplier AS S
CROSS APPLY Production.TopProducts(S.SupplierId, 2) AS TP
ORDER BY S.SupplierId;
```

---

### 📅 Additional Query — Federal Fiscal Year (FY) Scalar Function

A scalar function was created to assign Federal Fiscal Year quarter labels to any given order date. The federal FY starts **October 1** and ends **September 30** of the following year.

| Month Range | FY Quarter |
|-------------|------------|
| Oct – Dec | Q1 |
| Jan – Mar | Q2 |
| Apr – Jun | Q3 |
| Jul – Sep | Q4 |

```sql
-- Usage: returns label like 'FY2023-Q1'
SELECT dbo.GetFYQuarter(OrderDate) AS FYQuarter,
       COUNT(*) AS TotalOrders,
       SUM(Freight) AS TotalFreight
FROM [Sales].[Order]
GROUP BY dbo.GetFYQuarter(OrderDate)
ORDER BY LEFT(dbo.GetFYQuarter(OrderDate), 6) DESC,
         RIGHT(dbo.GetFYQuarter(OrderDate), 2) ASC;
```

**Business value:** Aligns sales and freight reporting to the federal budget cycle — essential for government-aligned organizations using Northwinds-style databases.

---

## 📝 Query Summary

### Chapter 4 — Subqueries

| # | Question | Type | Tables |
|---|----------|------|--------|
| 1 | Orders placed on the last day of activity | Self-contained scalar subquery | `Sales.[Order]` |
| 3 | Employees with no orders on or after May 1, 2022 | `NOT IN` subquery | `HumanResources.Employee`, `Sales.[Order]` |
| 4 | Countries with customers but no employees | `NOT IN` subquery | `Sales.Customers`, `HumanResources.Employee` |
| 5 | Each customer's orders on their last active day | Correlated subquery | `Sales.[Order]` |
| 6 | Customers active in 2021 but not 2022 | Dual `IN` / `NOT IN` subqueries | `Sales.Customers`, `Sales.[Order]` |
| 9 | IN vs EXISTS — conceptual explanation | N/A | N/A |

### Chapter 5 — Table Expressions

| # | Question | Type | Tables |
|---|----------|------|--------|
| 1 | Fix alias scoping error — explain & solve | Derived table | `Sales.[Order]` |
| 2-1 | Max order date per employee | Aggregate query | `Sales.[Order]` |
| 2-2 | Orders matching max date per employee | Derived table join | `Sales.[Order]` |
| 3-1 | Row number per order by date/id | `ROW_NUMBER()` window function | `Sales.[Order]` |
| 3-2 | Return rows 11–20 by row number | CTE | `Sales.[Order]` |
| 5-1 | Total qty per employee per year | View | `Sales.[Order]`, `Sales.[OrderDetail]` |
| 6-1 | Top N products by unit price for a supplier | Inline TVF | `Production.Product` |
| 6-2 | Top 2 products per supplier | `CROSS APPLY` + TVF | `Production.Supplier` |
| ➕ | FY Quarter freight & order analysis | Scalar function | `Sales.[Order]` |

---

## 🗄️ Database Schema Reference

Key tables and columns used in this assignment:

```
Northwinds2024Student
│
├── Sales.[Order]
│   ├── OrderId
│   ├── OrderDate
│   ├── CustomerId
│   ├── EmployeeId
│   └── Freight
│
├── Sales.[OrderDetail]
│   ├── OrderId
│   └── Quantity
│
├── Sales.Customers
│   ├── CustomerId
│   ├── CustomerCompanyName
│   └── CustomerCountry
│
├── HumanResources.Employee
│   ├── EmployeeId
│   ├── EmployeeFirstName
│   ├── EmployeeLastName
│   └── EmployeeCountry
│
├── Production.Product
│   ├── ProductId
│   ├── ProductName
│   ├── UnitPrice
│   └── SupplierId
│
└── Production.Supplier
    ├── SupplierId
    └── SupplierCompanyName
```

---

## 🏆 NACE Career Readiness Competencies

| Competency | Application in This Assignment |
|---|---|
| 🧠 **Critical Thinking** | Chose between self-contained vs correlated subqueries; debugged alias scoping issues; reasoned through NULL behavior in `NOT IN` vs `NOT EXISTS` |
| 💬 **Communication** | Documented conceptual explanations (IN vs EXISTS, alias error); wrote the problem proposition for non-technical stakeholders |
| 💻 **Technology** | Built views, scalar functions, and inline TVFs; applied window functions; adapted queries across two database schemas |
| 🤝 **Teamwork** | Delegated tasks via the to-do list; tracked progress via the Gantt chart; consolidated individual contributions |
| 🎯 **Professionalism** | Followed naming conventions and submission format; disclosed LLM usage transparently per syllabus requirements |
| 🌱 **Career & Self-Development** | Cross-trained group members on advanced T-SQL features including CTEs and CROSS APPLY |

---

## 🛠️ Environment

| Tool | Version |
|------|---------|
| SQL Server | 2022 Developer Edition |
| Container | Docker |
| IDE | Azure Data Studio / SSMS |
| Database | Northwinds2024Student |
| Textbook | T-SQL Fundamentals, 4th Ed. — Itzik Ben-Gan |

---

<div align="center">

*Queens College, CUNY · Computer Science Department*
*CSCI 331 — Database and Data Modeling · Prof. Heller · Spring 2026*

</div>
