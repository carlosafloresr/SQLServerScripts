DECLARE	@BatchId		Varchar(25) = '9FSI20201211_1509'

DECLARE @Company		Varchar(5) = (SELECT Company FROM FSI_ReceivedHeader WHERE BatchId = @BatchId),
		@Query			Varchar(1000)

DECLARE	@tblParameters	Table (Company Varchar(5), ParameterCode Varchar(50), VarC Varchar(100))
DECLARE @tblVendors		Table (VendorId Varchar(15), VendName Varchar(100))
DECLARE	@tblInterCpy	Table (RecordId Int, CreditAcct Varchar(20), DebitAcct Varchar(20))

SET @Query = N'SELECT VENDORID, VENDNAME FROM PRISQL01P.' + @Company + '.dbo.PM00200'

INSERT INTO @tblParameters
SELECT	Company, ParameterCode, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters
WHERE	ParameterCode IN ('FSIVENDORCREACCT','FSIVENDORPREPAYDEBACCT','PIERPASS_ACCT_DEBIT','FSIVENDORDEBACCT','PIERPASS_ACCT_CREDIT','FSIACCRUDDEBIT','FSIACCRUDCREDIT')
		AND Company = @Company

INSERT INTO @tblVendors
EXECUTE(@Query)

INSERT INTO @tblInterCpy
SELECT	FSI_ReceivedSubDetailId, AccountNumber, InterAccount
FROM	View_FSI_Intercompany
WHERE	OriginalBatchId = @BatchId

SELECT	FSI.Company,
		FSI.BatchId,
		FSI.InvoiceNumber,
		FSI.VendorId,
		FSI.Amount,
		FSI.PrepayReference,
		FSI.TransType,
		FSI.TransTypeId,
		FSI.RecordId
INTO	#tmpData
FROM	View_FSI_NonSale FSI
WHERE	FSI.BatchId = @BatchId

SELECT	LEFT(FSI.BatchId, 15) AS BatchId,
		FSI.InvoiceNumber,
		FSI.VendorId,
		VendorName = (SELECT UPPER(RTRIM(VND.VENDNAME)) FROM @tblVendors VND WHERE VND.VENDORID = FSI.VENDORID),
		FSI.Amount,
		FSI.PrepayReference AS Reference,
		FSI.TransType,
		--FSI.TransTypeId,
		CASE WHEN FSI.TransTypeId = 1 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIVENDORCREACCT')
			 WHEN FSI.TransTypeId = 3 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIVENDORPREPAYDEBACCT')
		     WHEN FSI.TransTypeId = 4 THEN FIN.CreditAcct 
			 WHEN FSI.TransTypeId = 5 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'PIERPASS_ACCT_CREDIT')
			 WHEN FSI.TransTypeId = 7 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIACCRUDDEBIT')
		ELSE '' END AS CreditAccount,
		CASE WHEN FSI.TransTypeId = 1 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIVENDORDEBACCT')
			 WHEN FSI.TransTypeId = 3 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIVENDORDEBACCT')
		     WHEN FSI.TransTypeId = 4 THEN FIN.DebitAcct 
			 WHEN FSI.TransTypeId = 5 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'PIERPASS_ACCT_DEBIT')
			 WHEN FSI.TransTypeId = 7 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIACCRUDCREDIT')
		ELSE '' END AS DebitAccount,
		CASE WHEN FSI.TransTypeId IN (2,4) THEN 'TIP'
			 WHEN FSI.TransTypeId IN (3,5,6,7) THEN 'FSIG'
			 ELSE 'FSIP' END AS IntegrationType
FROM	#tmpData FSI
		LEFT JOIN @tblInterCpy FIN ON FSI.RecordId = FIN.RecordId
--WHERE	FSI.TransTypeId <> 1
ORDER BY 10, FSI.TransType, FSI.InvoiceNumber

DROP TABLE #tmpData