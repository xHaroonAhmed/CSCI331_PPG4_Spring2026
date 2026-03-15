<div align="center">

# 📊 CSCI 331 — Database and Data Modeling
### Homework 6 · Chapter 6: Set Operators in T-SQL


> *Applying T-SQL Set Operators to extract actionable business insights from the Northwinds2024Student database.*

</div>

---

## 🎯 Assignment Overview

This assignment focused on **Chapter 6: Set Operators** from *T-SQL Fundamentals (4th Edition)* by Itzik Ben-Gan. Set operators allow us to combine, compare, and subtract result sets from multiple SELECT statements — a powerful toolset for business intelligence and data analysis scenarios.

All queries were developed and tested in **TSQLV6** and then adapted to run against the **Northwinds2024Student** database hosted on SQL Server 2022 Developer Edition via Docker.

---

## 📚 Concepts Learned

### 🔀 UNION and UNION ALL

| Operator | Behavior | Duplicate Handling | Performance |
|----------|----------|-------------------|-------------|
| `UNION` | Combines two result sets | ❌ Removes duplicates | Slower — requires deduplication pass |
| `UNION ALL` | Combines two result sets | ✅ Keeps all rows | Faster — no extra sorting/hashing |

**Key insight:** When the two input sets are guaranteed to have no overlapping rows (mutually exclusive by definition), `UNION ALL` and `UNION` produce identical results. In these cases, always use `UNION ALL` — there is no reason to pay the performance cost of deduplication when duplicates cannot exist.

---

### 🔁 INTERSECT

Returns only the rows that appear in **both** result sets. Think of it as finding the overlap between two populations.

```sql
-- Pairs active in BOTH January AND February
SELECT CustomerId, EmployeeId FROM [Sales].[Order]
WHERE OrderDate >= '20220101' AND OrderDate < '20220201'

INTERSECT

SELECT CustomerId, EmployeeId FROM [Sales].[Order]
WHERE OrderDate >= '20220201' AND OrderDate < '20220301';
```

**Business use case:** Identifying loyal customers or consistent employees who were active across multiple time periods.

---

### ➖ EXCEPT

Returns rows from the **first** result set that do **not** appear in the second. Think of it as subtraction between two sets.

```sql
-- Pairs active in January but NOT in February
SELECT CustomerId, EmployeeId FROM [Sales].[Order]
WHERE OrderDate >= '20220101' AND OrderDate < '20220201'

EXCEPT

SELECT CustomerId, EmployeeId FROM [Sales].[Order]
WHERE OrderDate >= '20220201' AND OrderDate < '20220301';
```

**Business use case:** Finding customers or employee pairs that dropped off — useful for churn analysis and follow-up targeting.

---

### ⚙️ Operator Precedence & Combining Operators

When chaining multiple set operators, **`INTERSECT` has higher precedence than `UNION` and `EXCEPT`**. To control evaluation order explicitly, use parentheses.

```sql
-- Correct: INTERSECT evaluated first, then EXCEPT applied to the result
(
    SELECT ... INTERSECT SELECT ...
)
EXCEPT
SELECT ...;
```

Without the parentheses in Q5, the query would evaluate incorrectly — the `EXCEPT` would apply to only the second `SELECT` rather than the full `INTERSECT` result.

---

### 📋 Derived Tables for Controlled Ordering

Set operator queries do not allow `ORDER BY` on individual `SELECT` statements. To sort a combined result while controlling which segment appears first, we inject a synthetic sort column inside a derived table:

```sql
SELECT country, region, city
FROM (
    SELECT 1 AS sortcol, EmployeeCountry, EmployeeRegion, EmployeeCity
    FROM HumanResources.Employee

    UNION ALL

    SELECT 2 AS sortcol, SupplierCountry, SupplierRegion, SupplierCity
    FROM Production.Supplier
) AS D
ORDER BY sortcol, country, region, city;
```

This guarantees Employees appear before Suppliers, with each group sorted alphabetically by location.

---

### 🔢 Virtual Tables Without a Base Table

T-SQL allows generating result sets purely from literal values — no `FROM` clause needed. This is useful for creating auxiliary number sequences, lookup tables, or test data on the fly:

```sql
SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 -- ... up to 10
```

---

## 📝 Query Summary

| # | Question | Operator | Tables |
|---|----------|----------|--------|
| 1 | UNION vs UNION ALL — conceptual explanation | N/A | N/A |
| 2 | Generate virtual numbers table (1–10) | `UNION ALL` | None |
| 3 | Customer/employee pairs: Jan 2022 only, not Feb 2022 | `EXCEPT` | `Sales.[Order]` |
| 4 | Customer/employee pairs: active in both Jan & Feb 2022 | `INTERSECT` | `Sales.[Order]` |
| 5 | Jan & Feb 2022 pairs, excluding any 2021 activity | `INTERSECT` + `EXCEPT` | `Sales.[Order]` |
| 6 *(Optional)* | Employees before Suppliers, sorted by location | `UNION ALL` + derived table | `HumanResources.Employee`, `Production.Supplier` |

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
│   └── EmployeeId
│
├── HumanResources.Employee
│   ├── EmployeeCountry
│   ├── EmployeeRegion
│   └── EmployeeCity
│
└── Production.Supplier
    ├── SupplierId
    ├── SupplierCompanyName
    ├── SupplierCountry
    ├── SupplierRegion
    └── SupplierCity
```

---

## 🏆 NACE Career Readiness Competencies

This assignment developed the following competencies as defined by the National Association of Colleges and Employers (NACE):

| Competency | Application in This Assignment |
|---|---|
| 🧠 **Critical Thinking** | Selected the appropriate set operator for each business scenario; reasoned through operator precedence and date boundary edge cases |
| 💬 **Communication** | Wrote clear technical explanations for conceptual questions; documented query logic for non-technical audiences |
| 💻 **Technology** | Applied T-SQL set operators in a production-style database environment; adapted queries from TSQLV6 to Northwinds2024Student |
| 🤝 **Teamwork** | Coordinated schema validation with group members; cross-referenced approaches to ensure consistency across individual submissions |
| 🎯 **Professionalism** | Followed submission format requirements; maintained code documentation standards throughout |

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
