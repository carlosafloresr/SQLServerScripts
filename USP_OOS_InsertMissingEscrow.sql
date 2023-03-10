/*
EXECUTE USP_OOS_InsertMissingEscrow 'AIS', 'OOSAIS_040220'
*/
CREATE PROCEDURE USP_OOS_InsertMissingEscrow
		@Company	Varchar(5),
		@BatchId	Varchar(25)
AS
DECLARE	@Query		Varchar(MAX)

DECLARE @tblData Table (
		Source				char(2) NOT NULL,
		VoucherNumber		varchar(22) NOT NULL,
		ItemNumber			int NULL,
		CompanyId			varchar(5) NOT NULL,
		Fk_EscrowModuleId	int NOT NULL,
		AccountNumber		varchar(15) NOT NULL,
		AccountType			int NOT NULL,
		VendorId			varchar(10) NOT NULL,
		DriverId			varchar(10) NULL,
		Amount				numeric(10,2) NOT NULL,
		Comments			varchar(1000) NULL,
		TransactionDate		datetime NOT NULL,
		PostingDate			datetime NULL,
		BatchId				varchar(25),
		EnteredBy			varchar(25) NOT NULL,
		EnteredOn			datetime NOT NULL,
		ChangedBy			varchar(25) NOT NULL,
		ChangedOn			datetime NOT NULL)

--INSERT INTO @tblData
SET @Query = N'SELECT DISTINCT *
FROM	(
		SELECT	DISTINCT ''AP'' AS Source,
				COALESCE(PM.VchrNmbr, P1.VchrNmbr, TR.Voucher) AS VchrNmbr,
				COALESCE(PD.DSTSQNUM, P2.DSTSQNUM) AS DSTSQNUM,
				TR.Company AS Company,
				EA.Fk_EscrowModuleId,
				TR.CreditAccount,
				COALESCE(PD.DISTTYPE, P2.DISTTYPE,6) AS DISTTYPE,
				TR.VendorId,
				TR.DedAmount,
				TR.Description,
				ISNULL(PM.DOCDATE, P1.DOCDATE) AS DOCDATE,
				ISNULL(PM.PSTGDATE, P1.PSTGDATE) AS PSTGDATE,
				TR.BatchId,
				TR.Trans_CreatedBy AS EnteredBy,
				TR.Trans_CreatedOn AS EnteredOn,
				TR.Trans_CreatedBy,
				TR.Trans_CreatedOn
		FROM	GPCustom.dbo.View_OOS_Transactions TR
				INNER JOIN GPCustom.dbo.EscrowAccounts EA ON TR.CreditAccount = EA.AccountNumber AND EA.CompanyId = ''' + @Company + ''' AND EA.Fk_EscrowModuleId <> 10
				LEFT JOIN ''' + @Company + '''.dbo.PM30200 PM ON (TR.Invoice = PM.DocNumbr OR TR.Invoice = PM.VCHRNMBR) AND TR.VendorId = PM.VendorId
				LEFT JOIN ''' + @Company + '''.dbo.PM30600 PD ON PM.VchrNmbr = PD.VchrNmbr AND PM.TrxSorce = PD.TrxSorce AND TR.CrdAcctIndex = PD.DstIndx AND TR.CreditAmount = PD.CrdtAmnt
				LEFT JOIN ''' + @Company + '''.dbo.PM20000 P1 ON (TR.Invoice = P1.DocNumbr OR TR.Invoice = P1.VCHRNMBR) AND TR.VendorId = P1.VendorId
				LEFT JOIN ''' + @Company + '''.dbo.PM10100 P2 ON P1.VchrNmbr = P2.VchrNmbr AND P1.TrxSorce = P2.TrxSorce AND TR.CrdAcctIndex = P2.DstIndx AND TR.CreditAmount = P2.CrdtAmnt
				LEFT JOIN ''' + @Company + '''.dbo.PM10000 PT ON (TR.Invoice = PT.DocNumbr OR TR.Invoice = PT.VCHRNMBR) AND TR.VendorId = PT.VendorId
				LEFT JOIN ''' + @Company + '''.dbo.PM10100 PZ ON PT.VchrNmbr = PZ.VchrNmbr AND PT.BCHSOURC = PZ.TrxSorce AND TR.CrdAcctIndex = PZ.DstIndx AND TR.CreditAmount = PZ.CrdtAmnt
		WHERE	TR.BatchId = ''' + @BatchId + '''
				AND COALESCE(PM.VchrNmbr, P1.VchrNmbr) IS NOT NULL
				AND TR.CrdAccounts = 1
		UNION
		SELECT	DISTINCT ''AP'' AS Source,
				COALESCE(PM.VchrNmbr, P1.VchrNmbr, TR.Voucher) AS VchrNmbr,
				COALESCE(PD.DSTSQNUM, P2.DSTSQNUM) AS DSTSQNUM,
				TR.Company AS Company,
				EA.Fk_EscrowModuleId,
				TR.CreditAccount,
				COALESCE(PD.DISTTYPE, P2.DISTTYPE, 6) AS DISTTYPE,
				TR.VendorId,
				TR.DedAmount,
				TR.Description,
				ISNULL(PM.DOCDATE, P1.DOCDATE) AS DOCDATE,
				ISNULL(PM.PSTGDATE, P1.PSTGDATE) AS PSTGDATE,
				TR.BatchId,
				TR.Trans_CreatedBy,
				TR.Trans_CreatedOn,
				TR.Trans_CreatedBy,
				TR.Trans_CreatedOn
		FROM	GPCustom.dbo.View_OOS_Transactions TR
				INNER JOIN GPCustom.dbo.EscrowAccounts EA ON TR.CreditAccount = EA.AccountNumber AND EA.CompanyId = ''' + @Company + ''' AND EA.Fk_EscrowModuleId <> 10
				LEFT JOIN ''' + @Company + '''.dbo.PM30200 PM ON (TR.Invoice = PM.DocNumbr OR TR.Invoice = PM.VCHRNMBR) AND TR.VendorId = PM.VendorId
				LEFT JOIN ''' + @Company + '''.dbo.PM30600 PD ON PM.VchrNmbr = PD.VchrNmbr AND PM.TrxSorce = PD.TrxSorce AND TR.CrdAcctIndex2 = PD.DstIndx AND TR.CreditAmount2 = PD.CrdtAmnt
				LEFT JOIN ''' + @Company + '''.dbo.PM20000 P1 ON (TR.Invoice = P1.DocNumbr OR TR.Invoice = P1.VCHRNMBR) AND TR.VendorId = P1.VendorId
				LEFT JOIN ''' + @Company + '''.dbo.PM10100 P2 ON P1.VchrNmbr = P2.VchrNmbr AND P1.TrxSorce = P2.TrxSorce AND TR.CrdAcctIndex2 = P2.DstIndx AND TR.CreditAmount2 = P2.CrdtAmnt
				LEFT JOIN ''' + @Company + '''.dbo.PM10000 PT ON (TR.Invoice = PT.DocNumbr OR TR.Invoice = PT.VCHRNMBR) AND TR.VendorId = PT.VendorId
				LEFT JOIN ''' + @Company + '''.dbo.PM10100 PZ ON PT.VchrNmbr = PZ.VchrNmbr AND PT.BCHSOURC = PZ.TrxSorce AND TR.CrdAcctIndex2 = PZ.DstIndx AND TR.CreditAmount2 = PZ.CrdtAmnt
		WHERE	TR.BatchId = ''' + @BatchId + '''
				AND COALESCE(PM.VchrNmbr, P1.VchrNmbr) IS NOT NULL
				AND TR.CrdAccounts = 2
		) DATA
ORDER BY Vendorid'

INSERT INTO GPCustom.dbo.EscrowTransactions
           (Source
           ,VoucherNumber
           ,ItemNumber
           ,CompanyId
           ,Fk_EscrowModuleId
           ,AccountNumber
           ,AccountType
           ,VendorId
		   ,DriverId
           ,Amount
           ,Comments
           ,TransactionDate
           ,PostingDate
           ,BatchId
           ,EnteredBy
           ,EnteredOn
           ,ChangedBy
           ,ChangedOn)
SELECT	T1.*
FROM	@tblData T1
		LEFT JOIN GPCustom.dbo.EscrowTransactions T2 ON T1.CompanyId = T2.CompanyId AND T1.VoucherNumber = T2.VoucherNumber AND T1.AccountNumber = T2.AccountNumber AND T1.VendorId = T2.VendorId AND T1.Amount = T2.Amount
WHERE	T2.CompanyId IS NULL
ORDER BY VendorId, Comments

SELECT * FROM @tblData
