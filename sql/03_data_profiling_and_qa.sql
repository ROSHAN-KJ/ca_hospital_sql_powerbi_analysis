--------------------------------------------------------------------------------
-- Project:      CA Hospital MySQL Analysis
-- Author:       Roshan Kumar
-- Description:  Quality Assurance script. Executes validation checks for duplicates,
--               orphan records, and missing values across all schemas.
-- Dependencies: Requires 02_staging_setup.sql to be executed first.
--------------------------------------------------------------------------------

USE ca_hospital;

-- =====================================================================
-- CLAIMS AND BILLING QA
-- =====================================================================
SELECT 
    c.claim_id, 
    d.claim_id
FROM claims_and_billing1 c
LEFT JOIN denials d 
    ON c.claim_id = d.claim_id;

SELECT 
    claim_id, 
    COUNT(*)
FROM claims_and_billing1
GROUP BY 
    claim_id
HAVING 
    COUNT(*) > 1;

SELECT 
    COUNT(*) 
FROM claims_and_billing1;

SELECT 
    COUNT(DISTINCT claim_id) 
FROM claims_and_billing1;

SELECT * 
FROM claims_and_billing1 
LIMIT 5;

DESCRIBE claims_and_billing1;

SELECT * 
FROM claims_and_billing1
WHERE encounter_id = (
    SELECT 
        encounter_id
    FROM claims_and_billing1
    GROUP BY 
        encounter_id
    HAVING 
        COUNT(*) > 1
    LIMIT 1
);

SELECT 
    COUNT(*) 
FROM (
    SELECT 
        encounter_id, 
        COUNT(*) AS cnt
    FROM claims_and_billing1
    GROUP BY 
        encounter_id
    HAVING 
        COUNT(*) > 1
) x;

SELECT 
    COUNT(*) 
FROM claims_and_billing1
WHERE TRIM(claim_id) = '';

SELECT 
    SUM(claim_id IS NULL OR claim_id = '') AS missing_claim_id,
    SUM(encounter_id IS NULL OR encounter_id = '') AS missing_encounter_id,
    SUM(total_charges IS NULL OR total_charges = '') AS missing_total_charges,
    SUM(insurance_coverage IS NULL OR insurance_coverage = '') AS missing_insurance_coverage,
    SUM(patient_responsibility IS NULL OR patient_responsibility = '') AS missing_patient_responsibility,
    SUM(claim_status IS NULL OR claim_status = '') AS missing_claim_status,
    SUM(billing_date IS NULL OR billing_date = '') AS missing_billing_date
FROM claims_and_billing1;

SELECT 
    total_charges, 
    insurance_coverage, 
    patient_responsibility
FROM claims_and_billing1 
LIMIT 10;

SELECT 
    billing_date, 
    COUNT(*)
FROM claims_and_billing1
GROUP BY 
    billing_date
ORDER BY 
    COUNT(*) DESC 
LIMIT 20;

SELECT 
    billing_date
FROM claims_and_billing1
WHERE 
    billing_date IS NOT NULL 
LIMIT 20;

SELECT 
    insurance_coverage, 
    COUNT(*)
FROM claims_and_billing1 
GROUP BY 
    insurance_coverage;

SELECT 
    MIN(total_charges), 
    MAX(total_charges), 
    MIN(patient_responsibility), 
    MAX(patient_responsibility)
FROM claims_and_billing1;

SELECT * 
FROM claims_and_billing1 
ORDER BY 
    encounter_id;

-- =====================================================================
-- DENIALS QA
-- =====================================================================
DESCRIBE denials1;

SELECT * 
FROM denials1;

SELECT 
    denial_id, 
    COUNT(*)
FROM denials1
GROUP BY 
    denial_id
HAVING 
    COUNT(*) > 1;

SELECT 
    claim_id, 
    COUNT(*) AS count
FROM denials1
GROUP BY 
    claim_id
HAVING 
    count > 1;

SELECT 
    *, 
    COUNT(*) AS duplicate_count
FROM denials1
GROUP BY 
    denial_id, 
    claim_id, 
    denial_code, 
    denial_reason, 
    denial_date, 
    appeal_status
HAVING 
    duplicate_count > 1;

SELECT 
    denial_id, 
    COUNT(*) AS cnt
FROM denials1
WHERE 
    denial_id IS NOT NULL
GROUP BY 
    denial_id
HAVING 
    cnt > 1;

SELECT 
    COUNT(*) 
FROM denials1 
WHERE TRIM(denial_id) = '';

SELECT 
    appeal_status, 
    COUNT(*) AS count 
FROM denials1 
GROUP BY 
    appeal_status;

SELECT 
    denial_date 
FROM denials1;

SELECT 
    COUNT(*) 
FROM denials1 
WHERE TRIM(appeal_status) = '';

SELECT 
    denial_date 
FROM denials1 
WHERE 
    denial_date = '' 
    OR denial_date IS NULL;

-- =====================================================================
-- DIAGNOSES QA
-- =====================================================================
DESCRIBE diagnoses1;

SELECT * 
FROM diagnoses1;

SELECT 
    diagnosis_id, 
    COUNT(*) AS count 
FROM diagnoses1 
WHERE 
    diagnosis_id IS NOT NULL 
GROUP BY 
    diagnosis_id 
HAVING 
    count > 1;

SELECT 
    COUNT(*) 
FROM diagnoses1 
WHERE TRIM(diagnosis_id) = '';

SELECT * 
FROM diagnoses1 
WHERE diagnosis_id IN (
    SELECT 
        diagnosis_id 
    FROM diagnoses1 
    GROUP BY 
        diagnosis_id 
    HAVING 
        COUNT(*) > 1
) 
ORDER BY 
    diagnosis_id;

SELECT 
    encounter_id, 
    COUNT(*) 
FROM diagnoses1 
GROUP BY 
    encounter_id 
HAVING 
    COUNT(*) > 1;

SELECT * 
FROM diagnoses1 
WHERE 
    TRIM(encounter_id) = '' 
    OR encounter_id IS NULL;

SELECT 
    diagnosis_id, 
    encounter_id, 
    icd_10_code, 
    diagnosis_description, 
    chronic_flag, 
    COUNT(*) AS dup_cnt
FROM diagnoses1
GROUP BY 
    diagnosis_id, 
    encounter_id, 
    icd_10_code, 
    diagnosis_description, 
    chronic_flag
HAVING 
    COUNT(*) > 1;

SELECT 
    SUM(encounter_id IS NULL OR TRIM(encounter_id) = '') AS blank_encouter_id,
    SUM(diagnosis_id IS NULL OR TRIM(diagnosis_id) = '') AS blank_diagnosis_id,
    SUM(icd_10_code IS NULL OR TRIM(icd_10_code) = '') AS blank_icd_10_code,
    SUM(diagnosis_description IS NULL OR TRIM(diagnosis_description) = '') AS blank_diagnosis_description,
    SUM(chronic_flag IS NULL OR TRIM(chronic_flag) = '') AS blank_chronic_flag
FROM diagnoses1;

SELECT 
    icd_10_code, 
    COUNT(DISTINCT diagnosis_description) AS diag_count
FROM diagnoses1 
GROUP BY 
    icd_10_code 
HAVING 
    diag_count > 1;

SELECT 
    chronic_flag, 
    COUNT(*) 
FROM diagnoses1 
GROUP BY 
    chronic_flag;

SELECT * 
FROM diagnoses1;

SELECT 
    diagnosis_description, 
    COUNT(*) 
FROM diagnoses1 
GROUP BY 
    diagnosis_description;

-- =====================================================================
-- ENCOUNTERS QA
-- =====================================================================
DESCRIBE encounters1;

SELECT 
    e.provider_id, 
    p.provider_id, 
    p.first_name
FROM encounters e
LEFT JOIN providers p 
    ON e.provider_id = p.provider_id;

SELECT 
    encounter_id, 
    COUNT(*) 
FROM encounters1 
GROUP BY 
    encounter_id 
HAVING 
    COUNT(*) > 1;

SELECT 
    COUNT(*) 
FROM encounters1 
WHERE 
    encounter_id IS NULL 
    OR TRIM(encounter_id) = '';

SELECT 
    patient_id, 
    COUNT(*) AS cnt 
FROM encounters1 
GROUP BY 
    patient_id;

SELECT 
    provider_id, 
    COUNT(*) AS cnt 
FROM encounters1 
GROUP BY 
    provider_id 
HAVING 
    cnt > 1;

SELECT * 
FROM encounters1;

SELECT 
    COUNT(*) 
FROM (
    SELECT DISTINCT * 
    FROM encounters1
) AS e;

SELECT 
    SUM(encounter_id IS NULL OR TRIM(encounter_id) = '') AS blank_encounter_id,
    SUM(patient_id IS NULL OR TRIM(patient_id) = '') AS blank_patient_id,
    SUM(provider_id IS NULL OR TRIM(provider_id) = '') AS blank_provider_id,
    SUM(department IS NULL OR TRIM(department) = '') AS blank_department,
    SUM(admission_date IS NULL OR TRIM(admission_date) = '') AS blank_admission_date,
    SUM(discharge_date IS NULL OR TRIM(discharge_date) = '') AS blank_discharge_date,
    SUM(encounter_type IS NULL OR TRIM(encounter_type) = '') AS blank_encounter_type,
    SUM(admission_source IS NULL OR TRIM(admission_source) = '') AS blank_admission_source
FROM encounters1;

SELECT 
    admission_source, 
    COUNT(*) AS cnt 
FROM encounters1 
GROUP BY 
    admission_source;

SELECT 
    encounter_type, 
    COUNT(*) AS cnt
FROM encounters1 
WHERE 
    discharge_date IS NULL 
    OR TRIM(discharge_date) = '' 
GROUP BY 
    encounter_type;

SELECT 
    encounter_type, 
    COUNT(*), 
    SUM(discharge_date IS NULL OR TRIM(discharge_date) = '')
FROM encounters1 
GROUP BY 
    encounter_type;

SELECT 
    admission_source, 
    COUNT(*) 
FROM encounters1 
GROUP BY 
    admission_source;

SELECT 
    encounter_type, 
    COUNT(*), 
    SUM(admission_source IS NULL OR TRIM(admission_source) = '')
FROM encounters1 
GROUP BY 
    encounter_type;

SELECT 
    admission_source, 
    COUNT(*) AS count
FROM encounters1 
WHERE 
    encounter_type = 'Inpatients' 
GROUP BY 
    admission_source;

SELECT 
    admission_date, 
    discharge_date 
FROM encounters1 
LIMIT 10;

-- =====================================================================
-- LAB TESTS QA
-- =====================================================================
DESCRIBE lab_tests1;

SELECT 
    test_id, 
    COUNT(*) 
FROM lab_tests1 
GROUP BY 
    test_id 
HAVING 
    COUNT(*) > 1;

SELECT 
    encounter_id, 
    COUNT(*) AS count 
FROM lab_tests1 
GROUP BY 
    encounter_id 
HAVING 
    count > 1;

SELECT 
    test_id, 
    encounter_id, 
    COUNT(*) AS count 
FROM lab_tests1 
GROUP BY 
    test_id, 
    encounter_id 
HAVING 
    count > 1;

SELECT 
    COUNT(*) AS total_rows 
FROM lab_tests1;

SELECT 
    COUNT(*) 
FROM (
    SELECT DISTINCT * 
    FROM lab_tests1
) AS x;

SELECT 
    SUM(test_id IS NULL OR TRIM(test_id) = '') AS blank_test_id,
    SUM(encounter_id IS NULL OR TRIM(encounter_id) = '') AS blank_encounter_id,
    SUM(test_name IS NULL OR TRIM(test_name) = '') AS blank_test_name,
    SUM(result_value IS NULL OR TRIM(result_value) = '') AS blank_result_value,
    SUM(reference_range IS NULL OR TRIM(reference_range) = '') AS blank_reference_range,
    SUM(test_date IS NULL OR TRIM(test_date) = '') AS blank_test_date
FROM lab_tests1;

SELECT * 
FROM lab_tests1;

SELECT 
    test_name, 
    COUNT(*) AS count 
FROM lab_tests1 
GROUP BY 
    test_name 
ORDER BY 
    count DESC;

SELECT 
    test_date 
FROM lab_tests1;

-- =====================================================================
-- MEDICATIONS QA
-- =====================================================================
SELECT * 
FROM medications1;

SELECT 
    medication_id, 
    encounter_id, 
    COUNT(*) AS count 
FROM medications1 
GROUP BY 
    medication_id, 
    encounter_id 
HAVING 
    count > 1;

SELECT 
    COUNT(*) AS total_rows 
FROM medications1;

SELECT 
    COUNT(*) AS unique_rows 
FROM (
    SELECT DISTINCT * 
    FROM medications1
) AS m;

SELECT 
    SUM(medication_id IS NULL OR TRIM(medication_id) = '') AS blank_medication_id,
    SUM(encounter_id IS NULL OR TRIM(encounter_id) = '') AS blank_encounter_id,
    SUM(medication_name IS NULL OR TRIM(medication_name) = '') AS blank_medication_name,
    SUM(dosage IS NULL OR TRIM(dosage) = '') AS blank_dosage,
    SUM(route IS NULL OR TRIM(route) = '') AS blank_route,
    SUM(frequency IS NULL OR TRIM(frequency) = '') AS blank_frequency,
    SUM(duration IS NULL OR TRIM(duration) = '') AS blank_duration,
    SUM(administration_date IS NULL OR TRIM(administration_date) = '') AS blank_administration_date
FROM medications1;

SELECT * 
FROM medications1 
WHERE medication_id IN (
    SELECT 
        medication_id 
    FROM medications1 
    GROUP BY 
        medication_id 
    HAVING 
        COUNT(*) > 1
) 
ORDER BY 
    medication_id, 
    encounter_id;

SELECT 
    medication_name, 
    COUNT(*) 
FROM medications1 
GROUP BY 
    medication_name;

SELECT 
    route, 
    COUNT(*) 
FROM medications1 
GROUP BY 
    route;

SELECT 
    frequency, 
    COUNT(*) 
FROM medications1 
GROUP BY 
    frequency;

SELECT DISTINCT 
    dosage 
FROM medications1 
LIMIT 20;

SELECT 
    duration, 
    COUNT(*) 
FROM medications1 
GROUP BY 
    duration;

SELECT 
    administration_date 
FROM medications1;

-- =====================================================================
-- PATIENTS QA
-- =====================================================================
DESCRIBE patients1;

SELECT 
    patient_id, 
    COUNT(*) AS count 
FROM patients1 
GROUP BY 
    patient_id 
HAVING 
    count > 1;

SELECT 
    COUNT(*) 
FROM patients1 
WHERE 
    patient_id IS NULL 
    OR TRIM(patient_id) = '';

SELECT 
    COUNT(*) AS total_rows 
FROM patients1;

SELECT 
    COUNT(*) AS unique_rows 
FROM (
    SELECT DISTINCT * 
    FROM patients1
) p;

SELECT * 
FROM patients1;

SELECT 
    SUM(patient_id IS NULL OR TRIM(patient_id) = '') AS blank_pt_id,
    SUM(first_name IS NULL OR TRIM(first_name) = '') AS blank_first_name,
    SUM(last_name IS NULL OR TRIM(last_name) = '') AS blank_last_name,
    SUM(date_of_birth IS NULL OR TRIM(date_of_birth) = '') AS blank_date_of_birth,
    SUM(age IS NULL OR TRIM(age) = '') AS blank_age,
    SUM(marital_status IS NULL OR TRIM(marital_status) = '') AS blank_marital_status,
    SUM(gender IS NULL OR TRIM(gender) = '') AS blank_gender,
    SUM(ethnicity IS NULL OR TRIM(ethnicity) = '') AS blank_ethnicity,
    SUM(state IS NULL OR TRIM(state) = '') AS blank_state,
    SUM(zip_code IS NULL OR TRIM(zip_code) = '') AS blank_zip_code
FROM patients1;

SELECT 
    gender, 
    COUNT(*) 
FROM patients1 
GROUP BY 
    gender;

SELECT 
    marital_status, 
    COUNT(*) 
FROM patients1 
GROUP BY 
    marital_status;

SELECT 
    ethnicity, 
    COUNT(*) 
FROM patients1 
GROUP BY 
    ethnicity;

SELECT 
    state, 
    COUNT(*) 
FROM patients1 
GROUP BY 
    state;

SELECT 
    state, 
    zip_code, 
    COUNT(*)
FROM patients1 
WHERE 
    TRIM(state) = '' 
    OR state IS NULL 
GROUP BY 
    state, 
    zip_code;

SELECT * 
FROM patients1;

SELECT * 
FROM patients1 
WHERE 
    AGE IS NOT NULL 
    AND TRIM(age) <> '' 
    AND age NOT REGEXP '^[0-9]+$';

SELECT 
    patient_id, 
    age, 
    TIMESTAMPDIFF(YEAR, date_of_birth, '2025-01-01') AS calc_age
FROM patients1 
WHERE 
    age <> TIMESTAMPDIFF(YEAR, date_of_birth, '2025-01-01');

SELECT 
    COUNT(*) 
FROM patients1 
WHERE 
    last_name IS NULL 
    OR TRIM(last_name) = '';

SELECT 
    first_name, 
    last_name, 
    date_of_birth, 
    COUNT(*)
FROM patients1 
GROUP BY 
    first_name, 
    last_name, 
    date_of_birth 
HAVING 
    COUNT(*) > 1;

SELECT * 
FROM patients1 
WHERE 
    first_name = 'Mitchell' 
    AND last_name = 'Kennedy' 
    AND date_of_birth = '1975-11-22';

SELECT 
    patient_id, 
    COUNT(DISTINCT CONCAT(first_name, ' ', last_name)) AS name_count
FROM patients1 
GROUP BY 
    patient_id 
HAVING 
    COUNT(DISTINCT CONCAT(first_name, ' ', last_name)) > 1;

-- =====================================================================
-- PROCEDURES QA
-- =====================================================================
SELECT * 
FROM procedures1;

SELECT 
    procedure_id, 
    COUNT(*) AS count 
FROM procedures1 
GROUP BY 
    procedure_id 
HAVING 
    count > 1;

SELECT 
    encounter_id, 
    COUNT(*) AS count 
FROM procedures1 
GROUP BY 
    encounter_id 
HAVING 
    count > 1;

SELECT 
    encounter_id, 
    procedure_id, 
    COUNT(*) AS count 
FROM procedures1 
GROUP BY 
    encounter_id, 
    procedure_id 
HAVING 
    count > 1;

SELECT 
    SUM(procedure_id IS NULL OR TRIM(procedure_id) = '') AS blank_procedure_id,
    SUM(encounter_id IS NULL OR TRIM(encounter_id) = '') AS blank_encounter_id
FROM procedures1;

SELECT 
    COUNT(*) AS total_rows 
FROM procedures1;

SELECT 
    COUNT(*) AS unique_rows 
FROM (
    SELECT DISTINCT * 
    FROM procedures1
) AS p;
    
SELECT
    SUM(procedure_id IS NULL OR TRIM(procedure_id) = '') AS blank_procedure_id,
    SUM(encounter_id IS NULL OR TRIM(encounter_id) = '') AS blank_encounter_id,
    SUM(procedure_code IS NULL OR TRIM(procedure_code) = '') AS blank_procedure_code,
    SUM(procedure_description IS NULL OR TRIM(procedure_description) = '') AS blank_procedure_description,
    SUM(procedure_date IS NULL OR TRIM(procedure_date) = '') AS blank_procedure_date
FROM procedures1;

SELECT 
    procedure_code, 
    COUNT(DISTINCT procedure_description) AS description_count
FROM procedures1 
GROUP BY 
    procedure_code 
HAVING 
    COUNT(DISTINCT procedure_description) > 1;

SELECT 
    procedure_date 
FROM procedures1;

SELECT 
    procedure_description, 
    COUNT(*) 
FROM procedures1 
GROUP BY 
    procedure_description;

-- =====================================================================
-- PROVIDERS QA
-- =====================================================================
SELECT * 
FROM providers1;

SELECT 
    provider_id, 
    COUNT(*) AS count 
FROM providers1 
GROUP BY 
    provider_id 
HAVING 
    count > 1;

SELECT 
    COUNT(*) 
FROM providers1 
WHERE 
    first_name IS NULL 
    OR TRIM(first_name) = '';

SELECT 
    first_name, 
    last_name, 
    COUNT(*) 
FROM providers1 
GROUP BY 
    first_name, 
    last_name 
HAVING 
    COUNT(*) > 1;

SELECT * 
FROM providers1 
WHERE 
    first_name = 'Brian' 
    AND last_name = 'Jones';

SELECT 
    provider_id, 
    COUNT(DISTINCT CONCAT(first_name, ' ', last_name)) AS name_count
FROM providers1 
GROUP BY 
    provider_id 
HAVING 
    COUNT(DISTINCT CONCAT(first_name, ' ', last_name)) > 1;