--------------------------------------------------------------------------------
-- Project:      CA Hospital MySQL Analysis
-- Author:       Roshan Kumar
-- Description:  Creates database, sets up raw table schemas, and handles 
--               initial data ingestion from CSV files.
-- Dependencies: None. (Ensure MySQL secure_file_priv allows local infile).
--------------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS ca_hospital;
USE ca_hospital;

-- =====================================================================
-- 1. TABLE CREATION
-- =====================================================================

CREATE TABLE patients (
    patient_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth VARCHAR(50),
    gender VARCHAR(20),
    race VARCHAR(50),
    ethnicity VARCHAR(50),
    zip_code VARCHAR(20)
);

CREATE TABLE providers (
    provider_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    specialty VARCHAR(100),
    department VARCHAR(100)
);

CREATE TABLE encounters (
    encounter_id VARCHAR(50),
    patient_id VARCHAR(50),
    provider_id VARCHAR(50),
    admission_date VARCHAR(50),
    discharge_date VARCHAR(50),
    encounter_type VARCHAR(50),
    admission_source VARCHAR(100)
);

CREATE TABLE diagnoses (
    diagnosis_id VARCHAR(50),
    encounter_id VARCHAR(50),
    icd_10_code VARCHAR(20),
    diagnosis_description VARCHAR(255),
    diagnosis_type VARCHAR(50)
);

CREATE TABLE procedures (
    procedure_id VARCHAR(50),
    encounter_id VARCHAR(50),
    procedure_code VARCHAR(20),
    procedure_description VARCHAR(255),
    procedure_date VARCHAR(50)
);

CREATE TABLE medications (
    medication_id VARCHAR(50),
    encounter_id VARCHAR(50),
    medication_name VARCHAR(255),
    dosage VARCHAR(100),
    route VARCHAR(50),
    administration_date VARCHAR(50)
);

CREATE TABLE lab_tests (
    test_id VARCHAR(50),
    encounter_id VARCHAR(50),
    test_name VARCHAR(255),
    result_value VARCHAR(100),
    reference_range VARCHAR(100),
    test_date VARCHAR(50)
);

CREATE TABLE claims_and_billing (
    claim_id VARCHAR(50),
    encounter_id VARCHAR(50),
    total_charges VARCHAR(50),
    insurance_coverage VARCHAR(50),
    patient_responsibility VARCHAR(50),
    claim_status VARCHAR(50),
    billing_date VARCHAR(50)
);

CREATE TABLE denials (
    denial_id VARCHAR(50),
    claim_id VARCHAR(50),
    denial_reason VARCHAR(255),
    denial_date VARCHAR(50),
    appeal_status VARCHAR(50)
);

-- =====================================================================
-- 2. SCHEMA MODIFICATIONS FOR INGESTION
-- =====================================================================

ALTER TABLE denials
    ADD COLUMN denial_code VARCHAR(10) AFTER claim_id;

ALTER TABLE diagnoses
    RENAME COLUMN diagnosis_type TO chronic_flag;

ALTER TABLE encounters
    ADD COLUMN department VARCHAR(100) AFTER provider_id;

ALTER TABLE medications
    ADD COLUMN frequency VARCHAR(50) AFTER route, 
    ADD COLUMN duration VARCHAR(50) AFTER frequency;

ALTER TABLE patients
    ADD COLUMN age VARCHAR(5) AFTER date_of_birth, 
    ADD COLUMN state VARCHAR(20) AFTER ethnicity, 
    RENAME COLUMN race TO marital_status;

ALTER TABLE patients
    MODIFY COLUMN marital_status VARCHAR(50) AFTER age;

-- =====================================================================
-- 3. BULK DATA INGESTION (LOAD DATA INFILE)
-- =====================================================================

LOAD DATA INFILE '/path/to/data/raw/claims_and_billing.csv'
INTO TABLE ca_hospital.claims_and_billing
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(
    @dummy_billing_id,      
    @dummy_patient_id,      
    encounter_id,           
    insurance_coverage,     
    @dummy_payment_method,  
    claim_id,               
    billing_date,           
    total_charges,          
    patient_responsibility, 
    claim_status,           
    @dummy_denial_reason    
);

LOAD DATA INFILE '/path/to/data/raw/denials.csv'
INTO TABLE ca_hospital.denials
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(
    claim_id,      
    denial_id,      
    denial_code,           
    denial_reason,     
    @dummy_denied_amount,  
    denial_date,               
    @dummy_appeal_filed,           
    appeal_status,          
    @appeal_resolution_date, 
    @dummy_final_outcome           
);

LOAD DATA INFILE '/path/to/data/raw/diagnoses.csv'
INTO TABLE ca_hospital.diagnoses
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(
    diagnosis_id,
    encounter_id,
    icd_10_code,
    diagnosis_description,
    @dummy_primary_flag,
    chronic_flag
);

LOAD DATA INFILE '/path/to/data/raw/encounters.csv'
INTO TABLE ca_hospital.encounters
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(
    encounter_id,
    patient_id,
    provider_id,
    admission_date,
    encounter_type,
    department,
    @dummy_reason_for_visit,
    @dummy_diagnosis_code,
    admission_source,
    discharge_date,
    @dummy_length_of_stay,
    @dummy_status,
    @dummy_readmitted_flag    
);

LOAD DATA INFILE '/path/to/data/raw/lab_tests.csv'
INTO TABLE ca_hospital.lab_tests
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(
    @dummy_lab_id,
    encounter_id,
    test_name,
    test_id,
    @dummy_specimen_type,
    result_value,
    @dummy_units,
    reference_range,
    test_date,
    @dummy_status
);

LOAD DATA INFILE '/path/to/data/raw/medications.csv'
INTO TABLE ca_hospital.medications
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(
    medication_id,
    encounter_id,
    medication_name,
    dosage,
    route,
    frequency,
    duration,
    administration_date,
    @dummy_prescriber_id,
    @dummy_cost
);

LOAD DATA INFILE '/path/to/data/raw/patients.csv'
INTO TABLE ca_hospital.patients
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(
    patient_id,
    first_name,
    last_name,
    date_of_birth,
    age,
    gender,
    ethnicity,
    @dummy_insurance_type,
    marital_status,
    @dummy_address,
    @dummy_city,
    state,
    zip_code,
    @dummy_phone,
    @dummy_email,
    @dummy_registration_date
);

LOAD DATA INFILE '/path/to/data/raw/procedures.csv'
INTO TABLE ca_hospital.procedures
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(
    procedure_id,
    encounter_id,
    procedure_code,
    procedure_description,
    procedure_date,
    @dummy_provider_id,
    @dummy_procedure_cost
);

LOAD DATA INFILE '/path/to/data/raw/providers.csv'
INTO TABLE ca_hospital.providers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(
    provider_id,
    @name,
    department,
    specialty,
    @dummy_npi,
    @dummy_inhouse,
    @dummy_location,
    @dummy_years_experience,
    @dummy_contact_info,
    @dummy_email
)
SET 
    first_name = SUBSTRING_INDEX(@name, ' ', 1),
    last_name = SUBSTRING_INDEX(@name, ' ', -1);