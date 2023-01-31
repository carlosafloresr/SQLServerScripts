DECLARE	@FileName		Varchar(120) = 'IREC_4446_EFT_20210930_030130'

SET NOCOUNT ON

DECLARE @tblAcctAlias	Table (
		Company			Varchar(5),
		Alias			Varchar(5))

INSERT INTO @tblAcctAlias VALUES ('ABS','ABS')
INSERT INTO @tblAcctAlias VALUES ('AIS','AIS')
INSERT INTO @tblAcctAlias VALUES ('DNJ','DNJ')
INSERT INTO @tblAcctAlias VALUES ('GIS','GIS')
INSERT INTO @tblAcctAlias VALUES ('GLSO','IMCNA')
INSERT INTO @tblAcctAlias VALUES ('GSA','GSA')
INSERT INTO @tblAcctAlias VALUES ('HMIS','H&M')
INSERT INTO @tblAcctAlias VALUES ('IILS','IMCC')
INSERT INTO @tblAcctAlias VALUES ('IMC','IMCG')
INSERT INTO @tblAcctAlias VALUES ('IMCC','IMCH')
INSERT INTO @tblAcctAlias VALUES ('OIS','OIS')
INSERT INTO @tblAcctAlias VALUES ('PDS','PDS')
INSERT INTO @tblAcctAlias VALUES ('PTS','PTS')
INSERT INTO @tblAcctAlias VALUES ('RCCL','RCCL')

DECLARE	@Company		Varchar(5) = (SELECT TOP 1 RTRIM(COMPANY_CODE) FROM PRISQL004P.Integrations.dbo.IREC_Files WHERE FILENAME = @FileName),
		@CompanyId		Varchar(5),
		@Integration	Varchar(10) = 'LCKBX',
		@BatchId		Varchar(15) = 'CH' + SUBSTRING(RIGHT(RTRIM(@FileName), 15), 3, 13),
		@IntApp			Varchar(10) = 'CASHAR',
		@BatchApp		Varchar(15) = 'LB' + SUBSTRING(RIGHT(RTRIM(@FileName), 15), 3, 13),
		@WriteOffAmnt	Numeric(12,2) = 5,
		@DebAccount		Varchar(15),
		@CrdAccount		Varchar(15),
		@Query			Varchar(MAX)

DECLARE @tblCustomers	Table (CustomerId Varchar(15), ParentId Varchar(15))

DECLARE @tblIntData		Table (
		Company			Varchar(5),
		BatchId			Varchar(15),
		PaymentDate		Date,
		PaymentNumber	Varchar(30),
		DepositAmount	Numeric(12,2),
		CustomerNumber	Varchar(15) Null,
		ParentCode		Varchar(15) Null,
		DocumentNumber	Varchar(30) Null,
		PaymentAmount	Numeric(12,2) Null,
		DocumentAmount	Numeric(12,2) Null,
		DifferenceAmnt	Numeric(12,2))

DECLARE @tblInt_Cash	Table (
		Integration		varchar(10) NOT NULL,
		Company			varchar(5) NOT NULL,
		BACHNUMB		varchar(50) NOT NULL,
		CUSTNMBR		varchar(50) NULL,
		DOCNUMBR		varchar(21) NOT NULL,
		DOCDATE			date NOT NULL,
		ORTRXAMT		numeric(10, 2) NOT NULL,
		GLPOSTDT		date NOT NULL,
		CSHRCTYP		smallint NOT NULL,
		CHEKBKID		varchar(15) NOT NULL,
		CHEKNMBR		varchar(21) NOT NULL,
		CRCARDID		varchar(15) NOT NULL,
		TRXDSCRN		varchar(31) NOT NULL,
		RMDTYPAL		int NULL,
		ACTNUMST		varchar(75) NULL,
		DISTTYPE		int NULL,
		DEBITAMT		money NULL,
		CRDTAMNT		money NULL,
		DistRef			varchar(30) NULL)

DECLARE @tblInt_ApplyTo	Table (
		Integration		varchar(10) NOT NULL,
		Company			varchar(5) NOT NULL,
		BatchId			varchar(20) NOT NULL,
		CustomerVendor	varchar(20) NOT NULL,
		ApplyFrom		varchar(30) NOT NULL,
		ApplyTo			varchar(30) NOT NULL,
		ApplyAmount		numeric(10, 2) NOT NULL,
		WriteOffAmnt	numeric(10, 2) NOT NULL,
		RecordType		char(2) NOT NULL,
		Processed		bit NOT NULL,
		Notes			varchar(200) NULL,
		ToCreate		bit NOT NULL)

SET @CompanyId	= (SELECT Company FROM @tblAcctAlias WHERE Alias = @Company)
SET @DebAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@CompanyId, 'ALL') AND ParameterCode = 'CASHGLACCOUNTCRD')
SET @CrdAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@CompanyId, 'ALL') AND ParameterCode = 'CASHGLACCOUNTDEB')

SET @Query = N'SELECT RTRIM(CUSTNMBR), RTRIM(CPRCSTNM) FROM ' + @CompanyId + '.dbo.RM00101'

INSERT INTO @tblCustomers
EXECUTE(@Query)

INSERT INTO @tblIntData
SELECT	IREC.COMPANY_CODE,
		@BatchId AS BatchId,
		IREC.PAYMENT_DATE,
		IREC.PAYMENT_NUMBER,
		IREC.DEPOSIT_AMOUNT,
		IIF(IREC.CUSTOMER_NUMBER = '', FSI.CustomerNumber, IREC.CUSTOMER_NUMBER) AS CUSTOMER_NUMBER,
		CUST.ParentId,
		IREC.REFERENCE_FIELD,
		IREC.PAYMENT_AMOUNT,
		FSI.InvoiceTotal,
		CAST(ISNULL(FSI.InvoiceTotal - IREC.PAYMENT_AMOUNT, IREC.PAYMENT_AMOUNT) AS Numeric(12,2)) AS DifferenceAmount
FROM	PRISQL004P.Integrations.dbo.IREC_Files IREC
		LEFT JOIN @tblAcctAlias ALI ON IREC.COMPANY_CODE = ALI.Alias
		LEFT JOIN PRISQL004P.Integrations.dbo.View_Integration_FSI FSI ON ALI.Company = FSI.Company AND IREC.REFERENCE_FIELD = FSI.InvoiceNumber
		LEFT JOIN @tblCustomers CUST ON IIF(IREC.CUSTOMER_NUMBER = '', FSI.CustomerNumber, IREC.CUSTOMER_NUMBER) = CUST.CustomerId
WHERE	IREC.FILENAME = @FileName
ORDER BY IREC.COMPANY_CODE, IREC.PAYMENT_NUMBER, 5

--SELECT	DATA.*,
--		Test = (SELECT MAX(CustomerNumber) FROM @tblIntData TMP WHERE TMP.Company = DATA.Company AND TMP.PaymentNumber = DATA.PaymentNumber AND TMP.CustomerNumber <> '')
--FROM	@tblIntData DATA

INSERT INTO @tblInt_Cash
SELECT	DISTINCT @Integration AS Integration,
		Company,
		BatchId,
		IIF(ParentCode = '', CustomerNumber, ParentCode) AS Customer,
		PaymentNumber,
		PaymentDate,
		DepositAmount,
		GETDATE(),
		0 AS CSHRCTYP,
		'BOA DEPOSIT' AS CHEKBKID,
		PaymentNumber AS CHEKNMBR,
		'' AS CRCARDID,
		'CHK:' + CAST(PaymentNumber AS Varchar) AS TRXDSCRN,
		9 AS RMDTYPAL,
		@DebAccount AS ACTNUMST,
		1 AS DISTTYPE,
		DepositAmount AS DEBITAMT,
		0 AS CRDTAMNT,
		'CHK:' + PaymentNumber AS DISTREF
FROM	@tblIntData
WHERE	ISNULL(CustomerNumber,'') <> ''
UNION
SELECT	DISTINCT @Integration AS Integration,
		'IMCH' AS Company,
		BatchId,
		'UNMATCH' AS Customer,
		PaymentNumber,
		PaymentDate,
		DepositAmount,
		GETDATE(),
		0 AS CSHRCTYP,
		'BOA DEPOSIT' AS CHEKBKID,
		PaymentNumber AS CHEKNMBR,
		'' AS CRCARDID,
		'CHK:' + CAST(PaymentNumber AS Varchar) AS TRXDSCRN,
		9 AS RMDTYPAL,
		@DebAccount AS ACTNUMST,
		1 AS DISTTYPE,
		DepositAmount AS DEBITAMT,
		0 AS CRDTAMNT,
		'CHK:' + PaymentNumber AS DISTREF
FROM	@tblIntData
WHERE	ISNULL(CustomerNumber,'') = ''
UNION	-- CREDITS
SELECT	DISTINCT @Integration AS Integration,
		Company,
		BatchId,
		IIF(ParentCode = '', CustomerNumber, ParentCode) AS Customer,
		PaymentNumber,
		PaymentDate,
		DepositAmount,
		GETDATE(),
		0 AS CSHRCTYP,
		'BOA DEPOSIT' AS CHEKBKID,
		PaymentNumber AS CHEKNMBR,
		'' AS CRCARDID,
		'CHK:' + CAST(PaymentNumber AS Varchar) AS TRXDSCRN,
		9 AS RMDTYPAL,
		@CrdAccount AS ACTNUMST,
		9 AS DISTTYPE,
		0 AS DEBITAMT,
		DepositAmount AS CRDTAMNT,
		'CHK:' + PaymentNumber AS DISTREF
FROM	@tblIntData
WHERE	ISNULL(CustomerNumber,'') <> ''
UNION
SELECT	DISTINCT @Integration AS Integration,
		'IMCH' AS Company,
		BatchId,
		'UNMATCH' AS Customer,
		PaymentNumber,
		PaymentDate,
		DepositAmount,
		GETDATE(),
		0 AS CSHRCTYP,
		'BOA DEPOSIT' AS CHEKBKID,
		PaymentNumber AS CHEKNMBR,
		'' AS CRCARDID,
		'CHK:' + CAST(PaymentNumber AS Varchar) AS TRXDSCRN,
		9 AS RMDTYPAL,
		@CrdAccount AS ACTNUMST,
		9 AS DISTTYPE,
		0 AS DEBITAMT,
		DepositAmount AS CRDTAMNT,
		'CHK:' + PaymentNumber AS DISTREF
FROM	@tblIntData
WHERE	ISNULL(CustomerNumber,'') = ''

INSERT INTO @tblInt_ApplyTo
SELECT	@IntApp AS Integration,
		Company,
		@BatchApp AS BatchId,
		CustomerNumber,
		PaymentNumber,
		DocumentNumber,
		CASE WHEN DifferenceAmnt = 0 THEN PaymentAmount
		WHEN DifferenceAmnt < 0 THEN DocumentAmount
		WHEN DifferenceAmnt > 0 THEN PaymentAmount END AS ApplyAmount,
		IIF(DifferenceAmnt > 0 AND DifferenceAmnt <= @WriteOffAmnt, DifferenceAmnt, 0) AS WriteOffAmnt,
		'AR' AS RecordType,
		0 AS Processed,
		Null AS Note,
		0 AS ToCreate
FROM	@tblIntData
WHERE	ISNULL(CustomerNumber,'') <> ''

SELECT	*
FROM	@tblIntData

SELECT	*
FROM	@tblInt_ApplyTo