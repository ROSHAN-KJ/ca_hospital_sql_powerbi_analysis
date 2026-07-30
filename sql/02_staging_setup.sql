--------------------------------------------------------------------------------
-- Project:      CA Hospital MySQL Analysis
-- Author:       Roshan Kumar
-- Description:  Creates isolated staging tables to prepare for data cleaning, 
--               leaving original raw tables untouched.
-- Dependencies: Requires 01_ddl_and_ingestion.sql to be executed first.
--------------------------------------------------------------------------------

USE ca_hospital;

CREATE TABLE claims_and_billing1 LIKE claims_and_billing;
INSERT INTO claims_and_billing1 
SELECT * FROM claims_and_billing;

CREATE TABLE denials1 LIKE denials;
INSERT INTO denials1 
SELECT * FROM denials;

CREATE TABLE diagnoses1 LIKE diagnoses;
INSERT INTO diagnoses1 
SELECT * FROM diagnoses;

CREATE TABLE encounters1 LIKE encounters;
INSERT INTO encounters1 
SELECT * FROM encounters;

CREATE TABLE lab_tests1 LIKE lab_tests;
INSERT INTO lab_tests1 
SELECT * FROM lab_tests;

CREATE TABLE medications1 LIKE medications;
INSERT INTO medications1 
SELECT * FROM medications;

CREATE TABLE patients1 LIKE patients;
INSERT INTO patients1 
SELECT * FROM patients;

CREATE TABLE procedures1 LIKE procedures;
INSERT INTO procedures1 
SELECT * FROM procedures;

CREATE TABLE providers1 LIKE providers;
INSERT INTO providers1 
SELECT * FROM providers;