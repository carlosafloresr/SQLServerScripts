SELECT	DB_NAME() AS Company
		,PMH.VchrNmbr AS VoucherNo
		,RTRIM(PMH.VendorId) + ' - ' + VND.VENDNAME AS Vendor
		,PUR.ProNumber
		,PMD.DistRef AS Reference
		,CASE WHEN PMD.DebitAmt > 0 THEN PMD.DebitAmt ELSE 0 END AS Expense
		,CASE WHEN PMD.CrdtAmnt > 0 THEN PMD.CrdtAmnt * -1 ELSE 0 END AS Recovery
		,PMH.DocNumbr
		,PMH.PostEddt
		,PMH.DocDate
		,PUR.TrailerNumber AS Trailer
		,PUR.ChassisNumber AS Chassis
		,Null AS FailureReason
		,EXA.Recovery AS Recoverable
		,PUR.DriverId
		,EXA.DriverType
		,EXA.RepairType
		,ACT.ActNumSt AS GLAccount
		,Null AS RecoveryAction
		,'Open' AS Status
		,Null AS Notes
		,PMD.DstSqNum AS ItemNumber
		,0 AS Closed
		,'AP' AS Source
		,ACT.ActNumbr_2 AS Division
		,'Open' AS StatusText
		,GETDATE() AS CreationDate
FROM	PM20000 PMH
		INNER JOIN PM10100 PMD ON PMH.VchrNmbr = PMD.VchrNmbr AND PMH.TRXSORCE = PMD.TRXSORCE
		INNER JOIN GL00105 ACT ON PMD.DstIndx = ACT.ActIndx
		INNER JOIN PM00200 VND ON PMH.VendorId = VND.VendorId
		INNER JOIN View_FiscalPeriod FIS ON PMH.PostEddt BETWEEN FIS.StartDate AND FIS.EndDate
		INNER JOIN GPCustom.dbo.ExpenseRecoveryAccounts EXA ON ACT.ActNumbr_3 = EXA.Account
		LEFT JOIN GPCustom.dbo.Purchasing_Vouchers PUR ON PMH.VchrNmbr = PUR.VoucherNumber AND PUR.Source = 'AP' AND PUR.CompanyId = DB_NAME()
		LEFT JOIN GPCustom.dbo.ExpenseRecovery EXR ON EXR.DocNumber = PMH.DOCNUMBR
WHERE	PMH.DOCTYPE <> 6
		AND EXR.DocNumber IS Null

/*
SELECT	*
FROM	GPCustom.dbo.Purchasing_Vouchers
WHERE	VoucherNumber = '00000000000020105'

SELECT	*
FROM	GPCustom.dbo.ExpenseRecoveryAccounts

SELECT	Year1
		,PerName
		,PeriodId
		,MAX(PeriodDt) AS StartDate
		,MAX(PerdEndt) AS EndDate
FROM	AIS..SY40100
WHERE	Closed = 0
		AND Year1 > 2010
		AND Series > 0
		AND PeriodId > 0


WHERE	VchrNmbr = '00000000000024722'

select	*
from	ExpenseRecoveryAccounts
*/