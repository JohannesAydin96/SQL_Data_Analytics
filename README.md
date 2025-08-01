# SQL_Data_Analytics
# 📊 SQL Data Analytics

This repository contains two SQL-based data projects focused on cleaning and analyzing a global layoffs dataset. Each project follows a structured approach to prepare the data and uncover valuable insights.

---

## 🧹 Project 1: Data Cleaning

A complete data cleaning pipeline performed in SQL to prepare raw layoff data for analysis.

### Key Steps:
- Removed duplicate records using `ROW_NUMBER()` and CTEs.
- Standardized company, industry, and country names.
- Converted the `date` column from text to SQL `DATE` type.
- Handled null and blank values across key fields.
- Deleted rows with insufficient data and dropped temporary columns.

### Tools Used:
- MySQL / SQL
- String functions (e.g., `TRIM`, `LIKE`)
- Window functions
- CTEs (Common Table Expressions)

### Outcome:
A clean, reliable dataset ready for further analysis and dashboarding.

---

## 🔎 Project 2: Exploratory Data Analysis (EDA)

This project focuses on identifying patterns, trends, and significant events in the layoffs dataset using SQL queries.

### Analysis Includes:
- Companies with the highest layoffs (including full shutdowns).
- Layoff totals grouped by **company**, **industry**, **country**, and **year**.
- Monthly and rolling layoffs to understand trends over time.
- Top companies with the most layoffs each year using window functions.

### Tools Used:
- MySQL / SQL
- Aggregation (`SUM`, `GROUP BY`)
- Time-based functions
- CTEs and rolling calculations

### Outcome:
Clear insights into how different sectors and regions were affected by layoffs over time, with queries ready for visualization in BI tools.

---

## 📁 Dataset
The data used in this repository comes from publicly available layoff records and has been structured for SQL-based analysis.

---

## ✅ Author
**Johannes Aydin**  
[GitHub Profile](https://github.com/JohannesAydin96)

---

