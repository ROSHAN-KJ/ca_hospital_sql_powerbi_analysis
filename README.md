# 🏥 California Hospital SQL Analysis & Revenue Cycle Intelligence

**Author:** Roshan Kumar  
**GitHub:** [ROSHAN-KJ](https://github.com/ROSHAN-KJ)

[![Author](https://img.shields.io/badge/Author-Roshan%20Kumar-blue.svg)](https://github.com/ROSHAN-KJ)
[![SQL Dialect](https://img.shields.io/badge/MySQL-8.0-orange.svg)](https://www.mysql.com/)
[![Domain](https://img.shields.io/badge/Domain-Healthcare%20Analytics-success.svg)](https://fhir.org)

> ⚠️ **HIPAA & Data Privacy Disclaimer:** All datasets utilized in this project are 100% synthetic and generated strictly for demonstration and portfolio purposes. No real Protected Health Information (PHI) or personally identifiable information is included.

---

## 📌 Project Overview
This project showcases an end-to-end data engineering and analytics pipeline built on a relational healthcare database (**9 tables, 126,000+ rows**). The objective was to ingest raw, messy CSVs, enforce relational integrity, build enterprise-grade Business Intelligence (BI) master views, and execute advanced analytical queries to uncover actionable insights regarding **revenue cycle bottlenecks, patient safety risks, and operational efficiencies**.

---

## 🚀 How to Run Locally (Data Ingestion)
This project utilizes MySQL's `LOAD DATA INFILE` for highly optimized bulk loading of large datasets. To replicate this database on your local machine:

1. **Verify Privileges:** Ensure your MySQL server allows local file loading by running `SHOW VARIABLES LIKE 'secure_file_priv';`.
2. **Update Paths:** Open `sql/01_ddl_and_ingestion.sql` and update the generic file paths (e.g., `'C:/path/to/your/data/raw/patients.csv'`) to the exact absolute path where you saved the `data/raw/` folder on your computer.
3. **Execute in Order:** Run the SQL scripts in numerical order (01 through 06) to properly build the schema, keys, and views.

---

## 🗂️ Repository Structure

```text
ca_hospital_MySQL_analysis/
│
├── data/
│   └── raw/                    # Original 9 unedited CSV datasets
│
├── docs/                       # Project documentation & Excel Data Dictionary
│
├── sql/                        # Modular SQL pipeline scripts
│   ├── 01_ddl_and_ingestion.sql
│   ├── 02_primary_keys.sql
│   ├── 03_foreign_keys.sql
│   ├── 04_cleaning_and_transformation.sql
│   ├── 05_business_views.sql
│   └── 06_analysis_queries.sql
│
├── images/                     # Query result visualizations for README
│   ├── financial_denials.png
│   ├── alos_by_department.png
│   └── seasonal_trends.png
│
└── README.md                   # Project documentation
```

---

## 🔍 At a Glance: Key SQL Concepts Demonstrated
To solve complex business questions, this project utilizes modern **MySQL 8.0** syntax. 
* 💡 **Window Functions:** Used `DENSE_RANK()` to evaluate provider caseloads and `LAG()` to calculate 30-day readmission risks.
* ⏳ **Common Table Expressions (CTEs):** Structured multi-step aggregations for departmental performance and patient pharmacy risk.
* 📈 **Conditional Aggregation:** Utilized `SUM(CASE WHEN...)` to pivot revenue cycle data and calculate insurance denial rates.

---

## 📊 Key Insights & Query Results

### 1. Financial Impact of Denied Claims
Analyzed denial rates by insurance provider to identify where revenue is bottlenecked and calculated the total dollar amount locked in rejected claims.  
![Financial Denials](images/financial_denials.png)

### 2. Departmental Length of Stay (ALOS)
Evaluated operational capacity by tracking average patient holding times across departments, segmented by chronic vs. non-chronic condition flags.  
![ALOS by Department](images/alos_by_department.png)

### 3. Seasonal Admission Trends
Extracted time-series data to track month-over-month inpatient volume spikes, aligning staffing and resource distribution with financial revenue.  
![Seasonal Trends](images/seasonal_trends.png)

---

## 🛠️ Technical Skills Highlighted
* **Database Architecture:** DDL, Relational Modeling, PK/FK Constraints, Denormalized Views.
* **Data Cleaning & Prep:** Type casting (`STR_TO_DATE`), String manipulation (`CONCAT`), Deduplication (`DISTINCT`).
* **Advanced Analytics:** Cross-tabulation, demographic bucketing, financial ROI calculations, and time-series extraction.
