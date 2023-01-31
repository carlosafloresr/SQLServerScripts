/*
="INSERT INTO @tblJournals (JournalNumber) VALUES ("&B2&")"
*/
DECLARE	@AccountNumber	Varchar(12) = '0-01-2794'
DECLARE	@tblJournals	Table (JournalNumber Int)

INSERT INTO @tblJournals (JournalNumber) VALUES (761188)


--INSERT INTO GPCustom.dbo.EscrowTransactions (Source, VoucherNumber, ItemNumber, CompanyId, Fk_EscrowModuleId, AccountNumber, AccountType, VendorId, Amount, Comments, TransactionDate, PostingDate, EnteredBy, EnteredOn, ChangedBy, ChangedOn, BatchId)
SELECT	'AP' AS Source,
		VCHRNMBR AS VoucherNumber,
		DSTSQNUM AS ItemNumber,
		DB_NAME() AS CompanyId,
		3 AS Fk_EscrowModuleId,
		ACTNUMST AS AccountNumber,
		DISTTYPE AS AccountType,
		VendorId,
		CAST(CRDTAMNT - DEBITAMT AS Numeric(10,2)) AS Amount,
		DistRef,
		DocDate,
		PostEddt,
		PTDUSRID,
		DEX_ROW_TS,
		PTDUSRID,
		DEX_ROW_TS,
		Bachnumb
--INTO	tmp_HMIS_EscrowTransactions
FROM	(
		SELECT	PM3.VCHRNMBR,
				PM3.VendorId,
				PM3.DocDate,
				PM3.DocNumbr,
				PM3.Bachnumb,
				PM3.DocAmnt,
				PM3.TrxDscrn,
				PM3.PostEddt,
				GL5.ACTNUMST,
				PM6.DSTSQNUM,
				PM6.DISTTYPE,
				PM6.CRDTAMNT,
				PM6.DEBITAMT,
				CASE WHEN PM6.DistRef = '' THEN PM3.TrxDscrn ELSE PM6.DistRef END AS DistRef,
				PM3.PTDUSRID,
				PM3.DEX_ROW_TS,
				GL2.JRNENTRY,
				GL2.ACTINDX
		FROM	GL20000 GL2
				INNER JOIN GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX AND GL5.ACTNUMST = @AccountNumber
				INNER JOIN PM30200 PM3 ON GL2.ORDOCNUM = PM3.DOCNUMBR AND GL2.ORMSTRID = PM3.VENDORID --AND PM3.VOIDED = 0
				INNER JOIN PM30600 PM6 ON PM3.VENDORID = PM6.VENDORID AND PM3.VCHRNMBR = PM6.VCHRNMBR AND GL2.ACTINDX = PM6.DSTINDX
		WHERE	GL2.VOIDED = 0
				AND GL2.JRNENTRY IN (SELECT JournalNumber FROM @tblJournals)
				AND RTRIM(PM3.VendorId) + '-' + RTRIM(PM3.VCHRNMBR) NOT IN (SELECT RTRIM(VendorId) + '-' + RTRIM(VoucherNumber) FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = DB_NAME())
		UNION
		SELECT	PM3.VCHRNMBR,
				PM3.VendorId,
				PM3.DocDate,
				PM3.DocNumbr,
				PM3.Bachnumb,
				PM3.DocAmnt,
				PM3.TrxDscrn,
				PM3.PostEddt,
				GL5.ACTNUMST,
				PM6.DSTSQNUM,
				PM6.DISTTYPE,
				PM6.CRDTAMNT,
				PM6.DEBITAMT,
				CASE WHEN PM6.DistRef = '' THEN PM3.TrxDscrn ELSE PM6.DistRef END AS DistRef,
				PM3.PTDUSRID,
				PM3.DEX_ROW_TS,
				GL2.JRNENTRY,
				GL2.ACTINDX
		FROM	GL20000 GL2
				INNER JOIN GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX AND GL5.ACTNUMST = @AccountNumber
				INNER JOIN PM20000 PM3 ON GL2.ORDOCNUM = PM3.DOCNUMBR AND GL2.ORMSTRID = PM3.VENDORID --AND PM3.VOIDED = 0
				INNER JOIN PM10100 PM6 ON PM3.VENDORID = PM6.VENDORID AND PM3.VCHRNMBR = PM6.VCHRNMBR AND GL2.ACTINDX = PM6.DSTINDX
		WHERE	GL2.VOIDED = 0
				AND GL2.JRNENTRY IN (SELECT JournalNumber FROM @tblJournals)
				AND RTRIM(PM3.VendorId) + '-' + RTRIM(PM3.VCHRNMBR) NOT IN (SELECT RTRIM(VendorId) + '-' + RTRIM(VoucherNumber) FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = DB_NAME())
	) DATA
ORDER BY VendorId, DocNumbr