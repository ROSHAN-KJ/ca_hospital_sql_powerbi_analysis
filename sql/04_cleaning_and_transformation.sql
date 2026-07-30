--------------------------------------------------------------------------------
-- Project:      CA Hospital MySQL Analysis
-- Author:       Roshan Kumar
-- Description:  Applies strict DDL and DML operations to resolve duplicates, 
--               cast datatypes, and finalize production-ready _clean tables.
-- Dependencies: Requires 03_data_profiling_and_qa.sql to be executed first.
--------------------------------------------------------------------------------

USE ca_hospital;

-- =====================================================================
-- CLAIMS AND BILLING CLEANING
-- =====================================================================

TRUNCATE TABLE claims_and_billing1;

INSERT INTO claims_and_billing1
SELECT DISTINCT * 
FROM claims_and_billing;

DROP TABLE claims_and_billing1;

CREATE TABLE claims_and_billing1 AS
SELECT DISTINCT * 
FROM claims_and_billing;

UPDATE claims_and_billing1
SET 
    claim_id = NULL 
WHERE 
    TRIM(claim_id) = '';

UPDATE claims_and_billing1
SET 
    billing_date = NULL
WHERE 
    TRIM(billing_date) = '';

UPDATE claims_and_billing1
SET 
    billing_date = STR_TO_DATE(billing_date, '%d-%m-%Y %H:%i')
WHERE 
    billing_date IS NOT NULL;

ALTER TABLE claims_and_billing1 
    MODIFY billing_date DATE,
    MODIFY total_charges DECIMAL(10,2),
    MODIFY patient_responsibility DECIMAL(10,2),
    ADD COLUMN billing_id INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE claims_and_billing1 
    MODIFY COLUMN billing_id INT NOT NULL AUTO_INCREMENT FIRST;

ALTER TABLE claims_and_billing1 
    RENAME TO claims_and_billing_clean;

-- =====================================================================
-- DENIALS CLEANING
-- =====================================================================

ALTER TABLE denials1 
    MODIFY denial_id VARCHAR(50) NOT NULL, 
    ADD PRIMARY KEY (denial_id);

UPDATE denials1 
SET 
    appeal_status = NULL 
WHERE 
    TRIM(appeal_status) = '';

UPDATE denials1 
SET 
    denial_date = STR_TO_DATE(denial_date, '%d-%m-%Y') 
WHERE 
    denial_date IS NOT NULL;

ALTER TABLE denials1 
    MODIFY denial_date DATE;

ALTER TABLE denials1 
    RENAME TO denials_clean;

UPDATE denials_clean 
SET 
    denial_reason = 'Non-covered charges.' 
WHERE 
    denial_reason = 'Non-covered charges';

-- =====================================================================
-- DIAGNOSES CLEANING
-- =====================================================================

ALTER TABLE diagnoses1 
    MODIFY encounter_id VARCHAR(50) NOT NULL, 
    ADD PRIMARY KEY (encounter_id);

ALTER TABLE diagnoses1 
    RENAME TO diagnoses_clean;

-- =====================================================================
-- ENCOUNTERS CLEANING
-- =====================================================================

ALTER TABLE encounters1 
    MODIFY encounter_id VARCHAR(50) NOT NULL, 
    ADD PRIMARY KEY (encounter_id);

UPDATE encounters1 
SET 
    admission_source = NULL 
WHERE 
    TRIM(admission_source) = '';

UPDATE encounters1 
SET 
    discharge_date = NULL 
WHERE 
    TRIM(discharge_date) = '';

UPDATE encounters1 
SET 
    admission_date = STR_TO_DATE(admission_date, '%d-%m-%Y') 
WHERE 
    admission_date IS NOT NULL;

ALTER TABLE encounters1 
    MODIFY admission_date DATE;

UPDATE encounters1 
SET 
    discharge_date = STR_TO_DATE(discharge_date, '%d-%m-%Y') 
WHERE 
    discharge_date IS NOT NULL;

ALTER TABLE encounters1 
    MODIFY discharge_date DATE;

ALTER TABLE encounters1 
    RENAME TO encounters_clean;

-- =====================================================================
-- LAB TESTS CLEANING
-- =====================================================================

ALTER TABLE lab_tests1 
    MODIFY test_id VARCHAR(50) NOT NULL, 
    MODIFY encounter_id VARCHAR(50) NOT NULL, 
    ADD PRIMARY KEY (test_id, encounter_id);

UPDATE lab_tests1 
SET 
    test_date = STR_TO_DATE(test_date, '%d-%m-%Y') 
WHERE 
    test_date IS NOT NULL;

ALTER TABLE lab_tests1 
    MODIFY test_date DATE;

ALTER TABLE lab_tests1 
    RENAME TO lab_tests_clean;

-- =====================================================================
-- MEDICATIONS CLEANING
-- =====================================================================

ALTER TABLE medications1 
    ADD COLUMN medication_record_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

UPDATE medications1 
SET 
    administration_date = STR_TO_DATE(administration_date, '%d-%m-%Y') 
WHERE 
    administration_date IS NOT NULL;

ALTER TABLE medications1 
    MODIFY administration_date DATE;

ALTER TABLE medications1 
    RENAME TO medications_clean;

-- =====================================================================
-- PATIENTS CLEANING
-- =====================================================================

ALTER TABLE patients1 
    MODIFY patient_id VARCHAR(50) NOT NULL, 
    ADD PRIMARY KEY (patient_id);

UPDATE patients1 
SET 
    state = NULL, 
    zip_code = NULL 
WHERE 
    TRIM(state) = '' 
    AND TRIM(zip_code) = '';

ALTER TABLE patients1 
    MODIFY age INT;

UPDATE patients1 
SET 
    date_of_birth = STR_TO_DATE(date_of_birth, '%d-%m-%Y') 
WHERE 
    date_of_birth IS NOT NULL;

ALTER TABLE patients1 
    MODIFY date_of_birth DATE;

UPDATE patients1 
SET 
    first_name = TRIM(first_name), 
    last_name = TRIM(last_name);

UPDATE patients1
SET 
    first_name = CONCAT(
        UPPER(LEFT(LOWER(first_name), 1)), 
        SUBSTRING(LOWER(first_name), 2)
    ),
    last_name = CONCAT(
        UPPER(LEFT(LOWER(last_name), 1)), 
        SUBSTRING(LOWER(last_name), 2)
    );

ALTER TABLE patients1 
    RENAME TO patients_clean;

-- =====================================================================
-- PROCEDURES CLEANING
-- =====================================================================

ALTER TABLE procedures1 
    MODIFY procedure_id VARCHAR(50) NOT NULL, 
    MODIFY encounter_id VARCHAR(50) NOT NULL, 
    ADD PRIMARY KEY(procedure_id, encounter_id);

UPDATE procedures1 
SET 
    procedure_date = STR_TO_DATE(procedure_date, '%d-%m-%Y') 
WHERE 
    procedure_date IS NOT NULL;

ALTER TABLE procedures1 
    MODIFY procedure_date DATE;

ALTER TABLE procedures1 
    RENAME TO procedures_clean;

-- =====================================================================
-- PROVIDERS CLEANING
-- =====================================================================

ALTER TABLE providers1 
    MODIFY provider_id VARCHAR(50) NOT NULL, 
    ADD PRIMARY KEY (provider_id);

UPDATE providers1 
SET 
    first_name = TRIM(first_name), 
    last_name = TRIM(last_name);

UPDATE providers1
SET 
    first_name = CONCAT(
        UPPER(LEFT(LOWER(first_name), 1)), 
        SUBSTRING(LOWER(first_name), 2)
    ),
    last_name = CONCAT(
        UPPER(LEFT(LOWER(last_name), 1)), 
        SUBSTRING(LOWER(last_name), 2)
    );

ALTER TABLE providers1 
    RENAME TO providers_clean;