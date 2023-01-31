SELECT	VM.VendorId
		,PM.VendName
		,VM.HireDate
		,VM.TerminationDate 
FROM	VendorMaster VM
		INNER JOIN IMC.dbo.PM00200 PM ON PM.VendorId = VM.VendorId
WHERE	VM.Company = 'IMC' 
ORDER BY VM.VendorId