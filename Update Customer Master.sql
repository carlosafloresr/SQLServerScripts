UPDATE	CustomerMaster
SET		Hold = 0,
		Changed = 1,
		Trasmitted = 0
WHERE	CompanyId = 'NDS'
		AND CustNmbr = '229592 '