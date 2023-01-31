--select * from PM00201 order by vendorid
--SELECT * FROM PM00202 WHERE Year1 = 2006 AND HistType = 1 AND VENDORID = 311 ORDER BY VendorID, PeriodID

SELECT 	PM00202.VendorID,
	PM00200.VendName,
	PM00200.TxIDNmbr,
	PM00200.Address1,
	PM00200.Address2,
	PM00200.City,
	PM00200.State,
	PM00200.ZipCode,
	PM00200.UserDef1,
	Year1,
	SUM(AmtpDlif) AS AmtpDlif
FROM 	PM00202
	INNER JOIN PM00200 ON PM00202.VendorID = PM00200.VendorID
WHERE 	Year1 = 2006 AND 
	HistType = 1 AND
	PM00200.Ten99Type > 1
GROUP BY 
	PM00202.VendorID,
	PM00200.VendName,
	PM00200.TxIDNmbr,
	PM00200.Address1,
	PM00200.Address2,
	PM00200.City,
	PM00200.State,
	PM00200.ZipCode,
	PM00200.UserDef1,
	Year1
HAVING SUM(AmtpDlif) > 599.99
ORDER BY PM00202.VendorID

--SELECT * FROM PM00200 WHERE VENDORID IN (110,172,326)