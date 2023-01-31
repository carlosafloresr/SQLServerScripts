SELECT * FROM AP_OpenBalances WHERE Company = 'IMCT'

-- DELETE AR_OpenBalances WHERE Company = 'IMCT'


SELECT	* 
FROM	AP_OpenBalances 
WHERE	Company = 'IMCT' AND
		VendorId NOT IN (SELECT VendorId FROM IMCT.dbo.PM00200)
ORDER BY VendorId

UPDATE AP_OpenBalances SET COMPANY = 'IMCT'

TRUNCATE TABLE AP_OpenBalances
DELETE AP_OpenBalances WHERE CRDTACCT = '0-00-2050'

UPDATE AP_OpenBalances SET Ten99Amnt = 0 WHERE Ten99Amnt IS NULL
UPDATE AP_OpenBalances SET BachNumb = 'AP_OpnItms_' + RIGHT(RTRIM(CrdtAcct), 4), DocType = CASE WHEN PrchAmnt < 0 THEN 5 ELSE 1 END WHERE Company = 'IMC'
UPDATE AP_OpenBalances SET VendorId = 'RCCL-TMD' WHERE VendorId = 'RCCL'
SELECT sum(abs(docamt)) FROM AP_OpenBalances WHERE CRDTACCT = '0-00-2050' WHERE VendorId NOT IN (select VendorId from imc.dbo.PM00200)