--------------------------------------------------------------------------------
-- Project:      CA Hospital MySQL Analysis
-- Author:       Roshan Kumar
-- Description:  Creates denormalized Master Views for BI and reporting tools 
--               (e.g., Tableau, PowerBI) to act as a single source of truth.
-- Dependencies: Requires 04_cleaning_and_transformation.sql to be executed.
--------------------------------------------------------------------------------

USE ca_hospital;

-- =====================================================================
-- VIEW 1: MASTER CLINICAL ENCOUNTERS
-- =====================================================================
-- Combines patient demographics, provider details, and clinical outcomes.

DROP VIEW IF EXISTS vw_clinical_encounters;

CREATE VIEW vw_clinical_encounters AS
SELECT 
    e.encounter_id,
    e.admission_date,
    e.discharge_date,
    e.encounter_type,
    e.department,
    e.admission_source,
    DATEDIFF(e.discharge_date, e.admission_date) AS length_of_stay_days,
    p.patient_id,
    p.age AS patient_age_at_admission,
    p.gender,
    p.marital_status,
    pr.provider_id,
    CONCAT(pr.first_name, ' ', pr.last_name) AS provider_name,
    pr.specialty,
    d.icd_10_code,
    d.diagnosis_description,
    d.chronic_flag
FROM encounters_clean e
LEFT JOIN patients_clean p 
    ON e.patient_id = p.patient_id
LEFT JOIN providers_clean pr 
    ON e.provider_id = pr.provider_id
LEFT JOIN diagnoses_clean d 
    ON e.encounter_id = d.encounter_id;

-- =====================================================================
-- VIEW 2: REVENUE CYCLE AND DENIALS
-- =====================================================================
-- Tracks the financial lifecycle of a hospital bill, including denial status.

DROP VIEW IF EXISTS vw_revenue_cycle_denials;

CREATE VIEW vw_revenue_cycle_denials AS
SELECT 
    c.billing_id,
    c.claim_id,
    c.encounter_id,
    c.billing_date,
    c.insurance_coverage,
    c.total_charges,
    c.patient_responsibility,
    c.claim_status,
    d.denial_id,
    d.denial_code,
    d.denial_reason,
    d.denial_date,
    d.appeal_status,
    CASE 
        WHEN d.denial_id IS NOT NULL THEN 'Denied'
        ELSE 'Clean Claim'
    END AS claim_outcome_flag
FROM claims_and_billing_clean c
LEFT JOIN denials_clean d 
    ON c.claim_id = d.claim_id;