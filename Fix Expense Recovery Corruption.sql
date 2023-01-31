DECLARE	@Company Varchar(5)
SET @Company = 'IMC'

--UPDATE	ExpenseRecovery
--SET		ExpenseRecovery.Reference = REC.DistRef
--FROM	(

		SELECT	PUV.ProNumber AS ProNumber_AP,
				ISNULL(PUV.DriverId, EXR.DriverId) AS DriverId_AP,
				PMO.DEBITAMT,
				PMO.CRDTAMNT,
				CASE WHEN PMO.DistRef = '' THEN EXR.Reference ELSE PMO.DistRef END AS DistRef,
				GLA.ACTNUMST,
				EXR.*		
		FROM	ExpenseRecovery EXR
				LEFT JOIN Purchasing_Vouchers PUV ON EXR.Company = PUV.CompanyId AND EXR.VoucherNo = PUV.VoucherNumber
				LEFT JOIN IMC.dbo.PM10100 PMO ON EXR.VoucherNo = PMO.VCHRNMBR AND EXR.ItemNumber = PMO.DSTSQNUM
				LEFT JOIN IMC.dbo.GL00105 GLA ON EXR.GLAccount = GLA.ACTNUMST
		WHERE	EXR.Closed = 0
				AND CompanyId = @Company
				AND PMO.VCHRNMBR IS NOT NULL
				AND (PMO.DEBITAMT <> EXR.Expense
				OR EXR.ProNumber <> PUV.ProNumber)
		UNION
		SELECT	PUV.ProNumber AS ProNumber_AP,
				ISNULL(PUV.DriverId, EXR.DriverId) AS DriverId_AP,
				PMO.DEBITAMT,
				PMO.CRDTAMNT,
				CASE WHEN PMO.DistRef = '' THEN EXR.Reference ELSE PMO.DistRef END AS DistRef,
				GLA.ACTNUMST,
				EXR.*		
		FROM	ExpenseRecovery EXR
				LEFT JOIN Purchasing_Vouchers PUV ON EXR.Company = PUV.CompanyId AND EXR.VoucherNo = PUV.VoucherNumber
				LEFT JOIN IMC.dbo.PM30600 PMO ON EXR.VoucherNo = PMO.VCHRNMBR AND EXR.ItemNumber = PMO.DSTSQNUM
				LEFT JOIN IMC.dbo.GL00105 GLA ON EXR.GLAccount = GLA.ACTNUMST
		WHERE	EXR.Closed = 0
				AND CompanyId = @Company
				AND PMO.VCHRNMBR IS NOT NULL
				AND (PMO.DEBITAMT <> EXR.Expense
				OR EXR.ProNumber <> PUV.ProNumber)

--		) REC
--WHERE	ExpenseRecovery.ExpenseRecoveryId = REC.ExpenseRecoveryId

UPDATE	ExpenseRecovery
SET		ExpenseRecovery.Reference = 'IDV27103700165237'
WHERE	ExpenseRecovery.ExpenseRecoveryId = 26755
/*
SELECT	*
FROM	Purchasing_Vouchers
*/