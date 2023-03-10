PRINT GPCustom.dbo.DriverBalance('GIS','G8688','12/31/2009')

SELECT * FROM PM30200 WHERE VendorId = 'G8688' AND DocNumbr = 'DPYG9890091212025'
SELECT * FROM PM30300 WHERE VendorId = 'G9890' AND ApToDcnm = 'DPYG9890091212025'

SELECT * FROM PM20000 WHERE VendorId = 'G9890' AND VchrNmbr = '00000000000019303'
SELECT * FROM PM30200 WHERE VendorId = 'G9890' AND VchrNmbr = '00000000000019303'

SELECT * FROM PM30300 WHERE DocDate = '12/17/2009' AND ApFrDcnm = '' ORDER BY VendorId, ApToDcnm

SELECT	VendorId
		,DocDate
		,VchrNmbr AS VoucherNumber
		,ApFrDcnm AS ApplyFrom
		,ApToDcnm AS ApplyTo
		,ApplDAmt
FROM	PM30300 
WHERE	DocDate = '12/17/2009' 
		AND ApFrDcnm = '' 
ORDER BY VendorId, ApToDcnm