-- SQL PROJECTS: Bank Churn Customers

-- Coniguration security file:
SELECT @@global.secure_file_priv;

-- Import the file:

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Bank_Churn.csv' 
INTO TABLE bank_churn 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES;

SELECT * FROM bank_churn
