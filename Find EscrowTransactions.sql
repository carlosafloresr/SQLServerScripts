-- SELECT * FROM [GPCustom].[dbo].[EscrowTransactions] WHERE EnteredBy = 'ILSRecovery'
DECLARE	@CompanyId				Varchar(5), 
		@Fk_EscrowModuleId		Int,
		@EnteredDate			Datetime
		
SET		@CompanyId				= DB_NAME()
SET		@Fk_EscrowModuleId		= 3
SET		@EnteredDate			= GETDATE()

--INSERT INTO GPCustom..EscrowTransactions
--		(Source
--		,VoucherNumber
--		,ItemNumber
--		,CompanyId
--		,Fk_EscrowModuleId
--		,AccountNumber
--		,AccountType
--		,VendorId
--		,DriverId
--		,Division
--		,Amount
--		,ClaimNumber
--		,DriverClass
--		,AccidentType
--		,Status
--		,DMSubmitted
--		,DeductionPlan
--		,Comments
--		,ProNumber
--		,TransactionDate
--		,PostingDate
--		,EnteredBy
--		,EnteredOn
--		,ChangedBy
--		,ChangedOn
--		,Void)
SELECT	'AP' AS Source
		,REC.VchrNmbr AS VoucherNumber
		,REC.DstSqNum AS ItemNumber
		,@CompanyId AS Company
		,@Fk_EscrowModuleId AS Fk_EscrowModuleId
		,REC.AcctNumber AS AccountNumber
		,REC.DistType AS AccountType
		,REC.VendorId
		,Null AS DriverId
		,DRV.Division
		,CASE WHEN REC.CrdtAmnt > 0 AND ESA.Increase = 'C' THEN 1 ELSE -1 END * (REC.CrdtAmnt + REC.DebitAmt) AS Amount
		,Null AS ClaimNumber
		,Null AS DriverClass
		,Null AS AccidentType
		,Null AS Status
		,Null AS DMSubmitted
		,Null AS DeductionPlan
		,REC.DistRef AS Comments
		,Null AS ProNumber
		,REC.PstgDate AS TransactionDate
		,REC.PstgDate AS PostingDate
		,'ILSRecovery' AS EnteredBy
		,@EnteredDate AS EnteredOn
		,'ILSRecovery' AS ChangedBy
		,@EnteredDate AS ChangedOn
		,0 AS Void
FROM	(SELECT	PMH.VchrNmbr
				,APT.DstSqNum
				,APT.DistType
				,APT.CrdtAmnt
				,APT.DebitAmt
				,APT.PstgDate
				,APT.DistRef
				,APT.VendorId
				,GLA.ActNumst AS AcctNumber
				,GLA.ActIndx
		FROM	PM30600 APT
				INNER JOIN PM30200 PMH ON APT.VchrNmbr = PMH.VchrNmbr
				INNER JOIN PM00200 VND ON APT.VendorId = VND.VendorId
				INNER JOIN GL00105 GLA ON APT.DstIndx = GLA.ActIndx
		--WHERE	VND.VndClsId = 'DRV'
		UNION
		SELECT	PMH.VchrNmbr
				,APT.DstSqNum
				,APT.DistType
				,APT.CrdtAmnt
				,APT.DebitAmt
				,APT.PstgDate
				,APT.DistRef
				,APT.VendorId
				,GLA.ActNumst AS AcctNumber
				,GLA.ActIndx
		FROM	PM10100 APT
				INNER JOIN PM30200 PMH ON APT.VchrNmbr = PMH.VchrNmbr
				INNER JOIN PM00200 VND ON APT.VendorId = VND.VendorId
				INNER JOIN GL00105 GLA ON APT.DstIndx = GLA.ActIndx
		--WHERE	VND.VndClsId = 'DRV'
		) REC
		LEFT JOIN GPCustom..View_EscrowTransactions EST ON REC.VchrNmbr = EST.VoucherNumber AND REC.AcctNumber = EST.AccountNumber AND REC.VendorId = EST.VendorId
		LEFT JOIN GPCustom..VendorMaster DRV ON REC.VendorId = DRV.VendorId AND DRV.Company = @CompanyId
		INNER JOIN GPCustom..EscrowAccounts ESA ON ESA.CompanyId = @CompanyId AND REC.AcctNumber = ESA.AccountNumber AND ESA.Fk_EscrowModuleId = @Fk_EscrowModuleId
WHERE	EST.EscrowTransactionId IS Null
		AND REC.VendorId = 'N10022'
		AND MONTH(REC.PstgDate) = 9
		--AND REC.PstgDate = '9/28/2010'
		--AND REC.PstgDate BETWEEN '06/01/2010' AND '06/30/2010'
ORDER BY REC.VendorId, REC.PstgDate DESC

/*
SELECT * FROM GL00105 WHERE ActNumst = '0-00-2795'

SELECT	*
FROM	PM30600
WHERE	VendorId = 'N10022'
		and DstIndx = 64
		--AND LEFT(VchrNmbr, 4) = 'OOS_'
ORDER BY VchrNmbr

SELECT	*
FROM	AIS..PM30200
WHERE	VendorId = 'A0441'
		AND VchrNmbr = 'OOS_0422100338'
ORDER BY VchrNmbr

SELECT	*
FROM	AIS..PM20000
WHERE	VendorId = 'A0441'
ORDER BY VchrNmbr

SELECT	*
FROM	GPCustom..EscrowTransactions 
WHERE	CompanyId = 'AIS' 
		AND AccountNumber = '0-00-2790'
		AND VendorId = 'A0441'
ORDER BY PostingDate DESC

SELECT	VchrNmbr
		,CrdtAmnt
		,DebitAmt
		,PstgDate
		,DistRef
FROM	AIS..PM30600
WHERE	DstIndx = 248
		AND VendorId = 'A0441'
UNION
SELECT	VchrNmbr
		,CrdtAmnt
		,DebitAmt
		,PstgDate
		,DistRef
FROM	AIS..PM10100
WHERE	DstIndx = 248
		AND VendorId = 'A0441'
ORDER BY PstgDate DESC	
********************************************************************************
SELECT	PMH.DocNumbr AS VchrNmbr
				,APT.DstSqNum
				,APT.DistType
				,APT.CrdtAmnt
				,APT.DebitAmt
				,APT.PstgDate
				,APT.DistRef
				,APT.VendorId
				,GLA.ActNumst AS AcctNumber
				,GLA.ActIndx
		FROM	PM30600 APT
				INNER JOIN PM30200 PMH ON APT.VchrNmbr = PMH.VchrNmbr
				INNER JOIN PM00200 VND ON APT.VendorId = VND.VendorId
				INNER JOIN GL00105 GLA ON APT.DstIndx = GLA.ActIndx
		WHERE	VND.VndClsId = 'DRV'
		UNION
		SELECT	PMH.DocNumbr AS VchrNmbr
				,APT.DstSqNum
				,APT.DistType
				,APT.CrdtAmnt
				,APT.DebitAmt
				,APT.PstgDate
				,APT.DistRef
				,APT.VendorId
				,GLA.ActNumst AS AcctNumber
				,GLA.ActIndx
		FROM	PM10100 APT
				INNER JOIN PM30200 PMH ON APT.VchrNmbr = PMH.VchrNmbr
				INNER JOIN PM00200 VND ON APT.VendorId = VND.VendorId
				INNER JOIN GL00105 GLA ON APT.DstIndx = GLA.ActIndx
		WHERE	VND.VndClsId = 'DRV'

*/