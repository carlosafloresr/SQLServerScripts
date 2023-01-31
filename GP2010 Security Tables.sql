SELECT * FROM SY09000 -- Task master 
SELECT * FROM SY09100 -- Role master 
SELECT * FROM SY09200 -- Alternate or modified form and report ID master 
SELECT * FROM SY10500 -- Role assignment master 
SELECT * FROM SY10550 -- DEFAULTUSER task ID assignment master 
SELECT * FROM SY10600 -- Tasks assignments master 
SELECT * FROM SY10700 -- Operations assignments master 
SELECT * FROM SY10750 -- DEFAULTUSER task assignment 
SELECT * FROM SY10800 -- Alternate or modified form and report ID assignment master

SELECT * FROM SY10500 WHERE SECURITYROLEID = 'AR APPLY SALES'

SELECT * FROM SY10600 WHERE SECURITYTASKID LIKE 'TRX_SALES_016%'