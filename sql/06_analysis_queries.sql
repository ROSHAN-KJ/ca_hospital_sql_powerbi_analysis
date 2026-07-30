--------------------------------------------------------------------------------
-- Project:      CA Hospital MySQL Analysis
-- Author:       Roshan Kumar
-- Description:  Advanced analytical queries designed to uncover financial, 
--               operational, and clinical insights from the healthcare data.
-- Dependencies: Requires 05_business_views.sql to be executed.
--------------------------------------------------------------------------------

USE ca_hospital;

-- =====================================================================
-- QUERY 1: FINANCIAL IMPACT OF DENIED CLAIMS
-- Highlights: Conditional Aggregation (SUM CASE WHEN)
-- =====================================================================
-- Identifies which insurance providers have the highest denial rates and 
-- the total dollar amount tied up in those denied claims.

SELECT 
    insurance_coverage,
    COUNT(claim_id) AS total_claims_submitted,
    SUM(CASE WHEN claim_outcome_flag = 'Denied' THEN 1 ELSE 0 END) AS total_denied_claims,
    ROUND(
        SUM(CASE WHEN claim_outcome_flag = 'Denied' THEN 1 ELSE 0 END) / COUNT(claim_id) * 100, 2
    ) AS denial_rate_percentage,
    SUM(CASE WHEN claim_outcome_flag = 'Denied' THEN total_charges ELSE 0 END) AS total_denied_dollars
FROM vw_revenue_cycle_denials
GROUP BY 
    insurance_coverage
ORDER BY 
    total_denied_dollars DESC;

-- =====================================================================
-- QUERY 2: AVERAGE LENGTH OF STAY (ALOS) BY DEPARTMENT
-- Highlights: Date Math, CTEs, and Grouping
-- =====================================================================
-- Analyzes operational efficiency by determining which departments hold 
-- patients the longest, separated by chronic vs. non-chronic patients.

WITH department_los AS (
    SELECT 
        department,
        chronic_flag,
        length_of_stay_days
    FROM vw_clinical_encounters
    WHERE 
        length_of_stay_days IS NOT NULL
)
SELECT 
    department,
    chronic_flag,
    COUNT(*) AS total_encounters,
    ROUND(AVG(length_of_stay_days), 2) AS avg_length_of_stay
FROM department_los
GROUP BY 
    department,
    chronic_flag
ORDER BY 
    avg_length_of_stay DESC;

-- =====================================================================
-- QUERY 3: PROVIDER CASELOAD AND REVENUE GENERATION
-- Highlights: Window Functions (DENSE_RANK), CTEs, String Concat
-- =====================================================================
-- Ranks the top 3 most utilized providers within each specialty and 
-- calculates their average billed amount per encounter.

WITH provider_stats AS (
    SELECT 
        pr.specialty,
        CONCAT(pr.first_name, ' ', pr.last_name) AS provider_name,
        COUNT(e.encounter_id) AS total_encounters,
        ROUND(AVG(c.total_charges), 2) AS avg_billed_per_encounter
    FROM providers_clean pr
    JOIN encounters_clean e 
        ON pr.provider_id = e.provider_id
    LEFT JOIN claims_and_billing_clean c 
        ON e.encounter_id = c.encounter_id
    GROUP BY 
        pr.specialty,
        pr.first_name,
        pr.last_name
),
ranked_providers AS (
    SELECT 
        specialty,
        provider_name,
        total_encounters,
        avg_billed_per_encounter,
        DENSE_RANK() OVER(
            PARTITION BY specialty 
            ORDER BY total_encounters DESC
        ) AS utilization_rank
    FROM provider_stats
)
SELECT * 
FROM ranked_providers
WHERE 
    utilization_rank <= 3
ORDER BY 
    specialty, 
    utilization_rank;

-- =====================================================================
-- QUERY 4: PATIENT READMISSION RISK (30-DAY WINDOW)
-- Highlights: LAG() Window Function, CTEs
-- =====================================================================
-- Calculates the days between a patient's discharge and their next 
-- admission to identify high-risk 30-day readmissions, filtering out 
-- overlapping encounters.

WITH patient_timeline AS (
    SELECT 
        patient_id,
        encounter_id,
        admission_date,
        discharge_date,
        LAG(discharge_date) OVER(
            PARTITION BY patient_id 
            ORDER BY admission_date
        ) AS previous_discharge_date
    FROM encounters_clean
    WHERE 
        discharge_date IS NOT NULL
)
SELECT 
    patient_id,
    encounter_id,
    admission_date,
    previous_discharge_date,
    DATEDIFF(admission_date, previous_discharge_date) AS days_since_last_discharge
FROM patient_timeline
WHERE 
    DATEDIFF(admission_date, previous_discharge_date) >= 0 
    AND DATEDIFF(admission_date, previous_discharge_date) <= 30
ORDER BY 
    days_since_last_discharge ASC;

-- =====================================================================
-- QUERY 5: POLYPHARMACY RISK (PATIENT SAFETY)
-- Highlights: COUNT(DISTINCT), GROUP_CONCAT, HAVING Clause
-- =====================================================================
-- Identifies encounters where a patient was prescribed more than 3 
-- distinct medications, listing the specific medications combined.

SELECT 
    m.encounter_id,
    COUNT(DISTINCT m.medication_name) AS unique_medications_prescribed,
    GROUP_CONCAT(DISTINCT m.medication_name SEPARATOR ', ') AS medication_list
FROM medications_clean m
GROUP BY 
    m.encounter_id
HAVING 
    COUNT(DISTINCT m.medication_name) > 3
ORDER BY 
    unique_medications_prescribed DESC;
    
    -- =====================================================================
-- QUERY 6: LAB TEST VOLUMES FOR CHRONIC PATIENTS
-- Highlights: CTEs, Window Functions, and Clinical Joins
-- =====================================================================
-- Identifies the top 3 most frequently ordered lab tests for patients 
-- with chronic conditions to understand resource utilization.

WITH chronic_encounters AS (
    SELECT DISTINCT encounter_id 
    FROM diagnoses_clean 
    WHERE chronic_flag IS NOT NULL AND chronic_flag != ''
),
lab_frequencies AS (
    SELECT 
        l.test_name,
        COUNT(l.test_id) AS total_tests_ordered,
        DENSE_RANK() OVER(ORDER BY COUNT(l.test_id) DESC) AS test_rank
    FROM lab_tests_clean l
    JOIN chronic_encounters c 
        ON l.encounter_id = c.encounter_id
    WHERE 
        l.test_name IS NOT NULL
    GROUP BY 
        l.test_name
)
SELECT 
    test_name,
    total_tests_ordered,
    test_rank
FROM lab_frequencies
WHERE 
    test_rank <= 3;

-- =====================================================================
-- QUERY 7: HIGH-VOLUME PROCEDURES & DEPARTMENTAL LOAD
-- Highlights: Multi-level Joins, Partitioning
-- =====================================================================
-- Finds the top 5 most frequently performed procedures within each 
-- department and calculates the total revenue generated by them.

WITH procedure_stats AS (
    SELECT 
        e.department,
        p.procedure_description,
        COUNT(p.procedure_id) AS procedure_count,
        SUM(c.total_charges) AS total_procedure_charges
    FROM procedures_clean p
    JOIN encounters_clean e 
        ON p.encounter_id = e.encounter_id
    LEFT JOIN claims_and_billing_clean c 
        ON e.encounter_id = c.encounter_id
    GROUP BY 
        e.department,
        p.procedure_description
),
ranked_procedures AS (
    SELECT 
        department,
        procedure_description,
        procedure_count,
        total_procedure_charges,
        DENSE_RANK() OVER(
            PARTITION BY department 
            ORDER BY procedure_count DESC
        ) AS procedure_rank
    FROM procedure_stats
    WHERE 
        department IS NOT NULL 
        AND procedure_description IS NOT NULL
)
SELECT * 
FROM ranked_procedures
WHERE 
    procedure_rank <= 5
ORDER BY 
    department, 
    procedure_rank;

-- =====================================================================
-- QUERY 8: SEASONAL ADMISSION TRENDS (TIME-SERIES)
-- Highlights: Date Extraction (DATE_FORMAT), Aggregation
-- =====================================================================
-- Tracks the volume of inpatient admissions and total billed revenue 
-- on a month-by-month basis to identify seasonal spikes.

SELECT 
    DATE_FORMAT(e.admission_date, '%Y-%m') AS admission_month,
    COUNT(e.encounter_id) AS total_admissions,
    ROUND(AVG(DATEDIFF(e.discharge_date, e.admission_date)), 2) AS avg_length_of_stay,
    SUM(c.total_charges) AS total_monthly_charges
FROM encounters_clean e
LEFT JOIN claims_and_billing_clean c 
    ON e.encounter_id = c.encounter_id
WHERE 
    e.encounter_type = 'Inpatients'
    AND e.admission_date IS NOT NULL
GROUP BY 
    DATE_FORMAT(e.admission_date, '%Y-%m')
ORDER BY 
    admission_month ASC;

-- =====================================================================
-- QUERY 9: DEMOGRAPHIC HEALTH DISPARITIES (AGE GROUPS)
-- Highlights: CASE WHEN (Bucket Creation), Cross-Tabulation
-- =====================================================================
-- Segments patients into age buckets to analyze how average length of 
-- stay and total encounters differ across demographics.

SELECT 
    CASE 
        WHEN p.age < 18 THEN '0-17 (Pediatric)'
        WHEN p.age BETWEEN 18 AND 35 THEN '18-35 (Young Adult)'
        WHEN p.age BETWEEN 36 AND 64 THEN '36-64 (Adult)'
        WHEN p.age >= 65 THEN '65+ (Senior)'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(e.encounter_id) AS total_encounters,
    ROUND(AVG(DATEDIFF(e.discharge_date, e.admission_date)), 2) AS avg_length_of_stay_days
FROM patients_clean p
JOIN encounters_clean e 
    ON p.patient_id = e.patient_id
GROUP BY 
    age_group
ORDER BY 
    total_encounters DESC;

-- =====================================================================
-- QUERY 10: FINANCIAL BURDEN OF HIGH-MEDICATION ENCOUNTERS
-- Highlights: CTEs, Subqueries, Financial Calculations
-- =====================================================================
-- Analyzes whether encounters with a high volume of prescribed medications 
-- result in a disproportionately higher out-of-pocket cost for patients.

WITH encounter_meds AS (
    SELECT 
        encounter_id,
        COUNT(medication_id) AS meds_prescribed
    FROM medications_clean
    GROUP BY 
        encounter_id
),
financial_burden AS (
    SELECT 
        CASE 
            WHEN em.meds_prescribed = 0 THEN '0 Meds'
            WHEN em.meds_prescribed BETWEEN 1 AND 3 THEN '1-3 Meds'
            WHEN em.meds_prescribed BETWEEN 4 AND 6 THEN '4-6 Meds'
            ELSE '7+ Meds'
        END AS medication_volume_category,
        COUNT(c.encounter_id) AS total_encounters,
        ROUND(AVG(c.total_charges), 2) AS avg_hospital_charge,
        ROUND(AVG(c.patient_responsibility), 2) AS avg_patient_out_of_pocket
    FROM claims_and_billing_clean c
    LEFT JOIN encounter_meds em 
        ON c.encounter_id = em.encounter_id
    GROUP BY 
        medication_volume_category
)
SELECT 
    medication_volume_category,
    total_encounters,
    avg_hospital_charge,
    avg_patient_out_of_pocket,
    ROUND((avg_patient_out_of_pocket / avg_hospital_charge) * 100, 2) AS out_of_pocket_percentage
FROM financial_burden
ORDER BY 
    avg_patient_out_of_pocket DESC;