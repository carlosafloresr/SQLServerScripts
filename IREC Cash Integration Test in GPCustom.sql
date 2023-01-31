SET NOCOUNT ON

DECLARE @tblAcctAlias	Table (
		Company			Varchar(5),
		Alias			Varchar(5))

DECLARE @tblCustomers	Table (CustomerId Varchar(15), ParentId Varchar(15), DocBalance Numeric(10,2))

DECLARE @Query			Varchar(MAX),
		@Company		Varchar(5),
		@CustomerId		Varchar(15),
		@DocumentNum	Varchar(30),
		@NationalId		Varchar(15),
		@DocBalance		Numeric(10,2),
		@BatchId		Varchar(15),
		@FileName		Varchar(120) = 'IREC_4446_EFT_20210930_030130'

SET @BatchId = 'CH' + REPLACE(LEFT(RIGHT(@FileName, 15), 13), '_', '')

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
		DifferenceAmnt	Numeric(12,2),
		Found			Bit)

INSERT INTO @tblIntData
SELECT	ALI.Company,
		'' AS BatchId,
		IREC.PAYMENT_DATE,
		IREC.PAYMENT_NUMBER,
		IREC.DEPOSIT_AMOUNT,
		RTRIM(IREC.CUSTOMER_NUMBER),
		NULL,
		RTRIM(IREC.REFERENCE_FIELD),
		IREC.PAYMENT_AMOUNT,
		0,
		0 AS DifferenceAmount,
		0 AS Found
FROM	PRISQL004P.Integrations.dbo.IREC_Files IREC
		LEFT JOIN @tblAcctAlias ALI ON IREC.COMPANY_CODE = ALI.Alias
WHERE	IREC.FILENAME = @FileName

DECLARE curChkData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company, CustomerNumber, DocumentNumber
FROM	@tblIntData

OPEN curChkData 
FETCH FROM curChkData INTO @Company, @CustomerId, @DocumentNum

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblCustomers

	SET @Query = N'SELECT RTRIM(CUSTNMBR), RTRIM(CPRCSTNM), CURTRXAM FROM ' + @Company + '.dbo.RM20101 WHERE CUSTNMBR = ''' + @CustomerId + ''' AND DOCNUMBR = ''' + @DocumentNum + ''''

	INSERT INTO @tblCustomers
	EXECUTE(@Query)

	IF (SELECT COUNT(*) FROM @tblCustomers) > 0
	BEGIN
		SELECT	@NationalId	= ParentId,
				@DocBalance	= DocBalance
		FROM	@tblCustomers

		UPDATE	@tblIntData
		SET		ParentCode = IIF(ParentCode IS Null, @NationalId, ParentCode),
				DocumentAmount = @DocBalance,
				DifferenceAmnt = @DocBalance - PaymentAmount,
				Found = 1
		WHERE	Company = @Company
				AND CustomerNumber = @CustomerId
				AND DocumentNumber = @DocumentNum
	END		

	FETCH FROM curChkData INTO @Company, @CustomerId, @DocumentNum
END

CLOSE curChkData
DEALLOCATE curChkData

SELECT	@BatchId AS BatchId,
		* 
FROM	@tblIntData

/*
SELECT TOP 100 * FROM AIS.dbo.RM20101 WHERE DOCNUMBR IN ('45-163779','39-172445','45-163088')
*/