Oracle SQL Advanced Analytics
This repository features a collection of 5 Advanced SQL Queries developed on the standard Oracle HR Schema. The project demonstrates the ability to transform raw relational data into meaningful Business Intelligence (BI) through sophisticated analytical techniques.

Project Overview
The goal of this project is to showcase high-level SQL proficiency by solving complex organizational challenges. These include financial trend analysis, hierarchical reporting, salary benchmarking, and data quality auditing. Each query is optimized for performance and designed to provide actionable insights for HR managers and executives.

Technical Features
1. Evolutionary Salary Expenditure (Pivot Reporting)
Techniques: Common Table Expressions (WITH), PIVOT, EXTRACT.

Description: Normalizes hiring dates into decades and rotates the data into columns to show total salary expenditure trends from the 1980s to the present.

Business Value: Identifies historical growth phases and the long-term financial impact of employee seniority.

2. Comparative Cost Analysis (Logical Benchmarking)
Techniques: CASE WHEN, OVER(PARTITION BY), INLINE VIEW.

Description: Categorizes each employee as a 'HIGH', 'MEDIUM', or 'LOW' cost asset by comparing their salary against both their specific department average and the overall company average simultaneously.

Business Value: Supports salary review processes by identifying pay deviations based on internal market benchmarks.

3. Organizational Chart Reconstruction (Hierarchical Queries)
Techniques: CONNECT BY PRIOR, START WITH, SYS_CONNECT_BY_PATH.

Description: Rebuilds the entire corporate reporting structure starting from the CEO. It uses LPAD formatting to visually represent the "depth" of the organization.

Business Value: Essential for organizational audits, clarifying reporting lines, and identifying management spans of control.

4. Ranking and Budget Impact (Window Functions)
Techniques: RANK(), LEAD(), SUM() OVER.

Description: Generates a descending salary rank within each department. It calculates the percentage of the total department budget consumed by each individual and displays the salary gap between consecutive ranks.

Business Value: Highlights top earners and ensures a balanced distribution of financial resources across teams.

5. Data Quality and Audit (Exists & Filtering)
Techniques: EXISTS, NVL, ROWNUM, RPAD.

Description: Performs a "clean sweep" of the database by normalizing strings (names and emails), validating record integrity against active departments, and implementing result-set sampling for testing purposes.

Business Value: Ensures that exported data is "audit-ready" and compliant with corporate data governance standards.

Core Competencies Demonstrated
Performance Tuning: Strategic use of EXISTS and Inline Views to minimize server overhead and prevent "N+1" query problems.

Data Transformation: Proficiency in converting granular records into multidimensional reports using PIVOT and CASE logic.

Analytical Depth: Advanced use of Window Functions to perform complex calculations without losing row-level detail.

Data Integrity: Expert handling of NULL values and referential integrity to ensure 100% accurate reporting.

How to Use
The provided .sql file is compatible with any Oracle database instance containing the HR sample schema.

Open the script in Oracle SQL Developer or TOAD.

![Risultato di una Query]([Toad _For_Oracle.png](https://github.com/erriquezdaniele-svg/Oracle-SQL-HR-Advanced-Analysis/blob/main/Toad%20_For_Oracle.png))

Execute the queries to see the formatted output.

Review the inline SQL comments for detailed logic explanations.
