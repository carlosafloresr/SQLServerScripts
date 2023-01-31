/*
EXECUTE USP_REPAR_Integration '01/11/2018'
*/
ALTER PROCEDURE USP_REPAR_Integration
		@IntDate		Date
AS
SET NOCOUNT ON

DECLARE	@DatePortion	Varchar(15),
		@Company		Varchar(5),
		@BatchId		Varchar(25),
		@Integration	Varchar(5) = 'REPAR',
		@inv_no			Varchar(12),
		@acct_no		Varchar(12),
		@inv_date		Date,
		@inv_total		Numeric(10,2),
		@sale_tax		Numeric(10,2),
		@parts			Numeric(10,2),
		@labor			Numeric(10,2),
		@TrnsDescrip	Varchar(25),
		@depot_loc		Varchar(10),
		@DueDate		Date,
		@InvType		Char(1),
		@RMDTYPAL		Int, 
		@DISTTYPE		Int, 
		@ACTNUMST		Varchar(15), 
		@DEBITAMT		Numeric(10,2), 
		@CRDTAMNT		Numeric(10,2),
		@UserId			Varchar(20) = 'SALES INT',
		@PostingDate	Date = GETDATE()

DECLARE	@tblAccounts	Table (
		AcctType		Varchar(10),
		Location		Varchar(15),
		Credit			Varchar(15),
		Debit			Varchar(15),
		Company			Varchar(5))

INSERT INTO @tblAccounts VALUES ('TAXES', 'MEMREFURB', '3-00-2110', '0-00-1050', 'IMCCS')
INSERT INTO @tblAccounts VALUES ('LABOR', 'MEMREFURB', '5-09-4016', '0-00-1050', 'IMCCS')
INSERT INTO @tblAccounts VALUES ('PARTS', 'MEMREFURB', '5-09-4013', '0-00-1050', 'IMCCS')
INSERT INTO @tblAccounts VALUES ('TAXES', 'DALLAS', '3-03-2110', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('LABOR', 'DALLAS', '5-03-4016', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('PARTS', 'DALLAS', '5-07-4013', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('TAXES', 'FT.WORTH', '3-03-2110', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('LABOR', 'FT.WORTH', '5-19-4016', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('PARTS', 'FT.WORTH', '5-19-4013', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('TAXES', 'MEMPHIS', '3-00-2110', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('LABOR', 'MEMPHIS', '5-08-4016', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('PARTS', 'MEMPHIS', '5-08-4013', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('TAXES', 'NASHVILLE', '3-00-2110', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('LABOR', 'NASHVILLE', '5-07-4016', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('PARTS', 'NASHVILLE', '5-07-4013', '0-00-1050', 'IMCMR')

DECLARE	@tblCustomers	Table (
		CustNmbr		Varchar(15),
		BatchBilling	Bit)

INSERT INTO @tblCustomers
SELECT	CustNmbr,
		BatchBilling
FROM	LENSASQL001.GPCustom.dbo.CustomerMaster
WHERE	CompanyId = 'FI'

SET @DatePortion	= dbo.PADL(MONTH(@IntDate), 2, '0') + dbo.PADL(DAY(@IntDate), 2, '0') + RIGHT(dbo.PADL(YEAR(@IntDate), 4, '0'), 2)

UPDATE	Staging.MSR_Import 
SET		Intercompany = 1
WHERE	Import_Date = @IntDate
		AND acct_no IN (SELECT Account FROM ILSINT02.Integrations.dbo.FSI_Intercompany_ARAP WHERE Company = 'FI' AND RecordType = 'C')

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	inv_no,
		acct_no,
		inv_date,
		ABS(inv_total) AS inv_total,
		ABS(sale_tax) AS sale_tax,
		ABS(parts) AS parts,
		ABS(labor) AS labor,
		TrnsDescrip,
		depot_loc,
		CASE WHEN inv_total < 0 THEN 'C' ELSE 'I' END AS InvType
FROM	(
		SELECT	MSR.inv_no,
				MSR.acct_no,
				MSR.inv_date,
				MSR.inv_total,
				MSR.sale_tax,
				MSR.parts + MSR.consum AS parts,
				MSR.labor,
				CASE WHEN MSR.Container = '' THEN '' ELSE 'CO:' + RTRIM(MSR.Container) END +
				CASE WHEN MSR.chassis = '' THEN '' ELSE IIF(RTRIM(MSR.Container) = '', '', '/') + 'CH:' + RTRIM(MSR.chassis) END +
				CASE WHEN MSR.genset_no = '' THEN '' ELSE IIF(RTRIM(MSR.Container) = '' AND RTRIM(MSR.chassis) = '', '', '/') + 'GS:' + RTRIM(MSR.genset_no) END AS TrnsDescrip,
				MSR.depot_loc
		FROM	Staging.MSR_Import MSR
				LEFT JOIN @tblCustomers CUS ON MSR.acct_no = CUS.CustNmbr
		WHERE	MSR.Import_Date = @IntDate
				AND MSR.Intercompany = 0
				AND CUS.BatchBilling = 0
		UNION
		SELECT	CASE WHEN MSR.inv_batch = 'B0' THEN 'B' + @DatePortion ELSE MSR.inv_batch END AS inv_batch,
				MSR.acct_no,
				MAX(MSR.inv_date) AS inv_date,
				SUM(MSR.inv_total) AS inv_total,
				SUM(MSR.sale_tax) AS sale_tax,
				SUM(MSR.parts + MSR.consum) AS parts,
				SUM(MSR.labor) AS labor,
				'Batch ' + CASE WHEN MSR.inv_batch = 'B0' THEN 'B' + @DatePortion ELSE MSR.inv_batch END AS TrnsDescrip,
				MSR.depot_loc
		FROM	Staging.MSR_Import MSR
				LEFT JOIN @tblCustomers CUS ON MSR.acct_no = CUS.CustNmbr
		WHERE	MSR.Import_Date = @IntDate
				AND MSR.Intercompany = 0
				AND CUS.BatchBilling = 1
		GROUP BY
				MSR.inv_batch,
				MSR.acct_no,
				MSR.depot_loc
		) DATA

SET @BatchId = @Integration + '_' + @DatePortion

OPEN curData 
FETCH FROM curData INTO @inv_no, @acct_no, @inv_date, @inv_total, @sale_tax, @parts, @labor, @TrnsDescrip, @depot_loc, @InvType

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @DueDate	= DATEADD(dd, 30, @inv_date)
	SET @RMDTYPAL	= IIF(@InvType = 'I', 1, 7)
	SET @DISTTYPE	= IIF(@InvType = 'I', 2, 19)
	SET @DEBITAMT	= IIF(@InvType = 'I', @inv_total, 0)
	SET @CRDTAMNT	= IIF(@InvType = 'I', 0, @inv_total)

	SELECT	@Company	= Company,
			@ACTNUMST	= Debit
	FROM	@tblAccounts 
	WHERE	Location = @depot_loc
			AND AcctType = 'TAXES'

	EXECUTE ILSINT02.Integrations.dbo.USP_Integrations_AR @Integration, @Company, @BatchId, @inv_no, @TrnsDescrip, @acct_no, @inv_date, @DueDate,
					@inv_total, @inv_total, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @TrnsDescrip, 
					Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate

	IF @sale_tax <> 0
	BEGIN
		SET @DISTTYPE	= IIF(@InvType = 'I', 9, 3)
		SET @DEBITAMT	= IIF(@InvType = 'I', 0, @sale_tax)
		SET @CRDTAMNT	= IIF(@InvType = 'I', @sale_tax, 0)

		SELECT	@Company	= Company,
				@ACTNUMST	= Credit
		FROM	@tblAccounts 
		WHERE	Location = @depot_loc
				AND AcctType = 'TAXES'

		EXECUTE ILSINT02.Integrations.dbo.USP_Integrations_AR @Integration, @Company, @BatchId, @inv_no, @TrnsDescrip, @acct_no, @inv_date, @DueDate,
						@inv_total, @inv_total, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @TrnsDescrip, 
						Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate
	END

	IF @labor <> 0
	BEGIN
		SET @DISTTYPE	= IIF(@InvType = 'I', 9, 3)
		SET @DEBITAMT	= IIF(@InvType = 'I', 0, @labor)
		SET @CRDTAMNT	= IIF(@InvType = 'I', @labor, 0)

		SELECT	@Company	= Company,
				@ACTNUMST	= Credit
		FROM	@tblAccounts 
		WHERE	Location = @depot_loc
				AND AcctType = 'LABOR'

		EXECUTE ILSINT02.Integrations.dbo.USP_Integrations_AR @Integration, @Company, @BatchId, @inv_no, @TrnsDescrip, @acct_no, @inv_date, @DueDate,
						@inv_total, @inv_total, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @TrnsDescrip, 
						Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate
	END

	IF @parts <> 0
	BEGIN
		SET @DISTTYPE	= IIF(@InvType = 'I', 9, 3)
		SET @DEBITAMT	= IIF(@InvType = 'I', 0, @parts)
		SET @CRDTAMNT	= IIF(@InvType = 'I', @parts, 0)

		SELECT	@Company	= Company,
				@ACTNUMST	= Credit
		FROM	@tblAccounts 
		WHERE	Location = @depot_loc
				AND AcctType = 'PARTS'

		EXECUTE ILSINT02.Integrations.dbo.USP_Integrations_AR @Integration, @Company, @BatchId, @inv_no, @TrnsDescrip, @acct_no, @inv_date, @DueDate,
						@inv_total, @inv_total, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @TrnsDescrip, 
						Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate
	END

	FETCH FROM curData INTO @inv_no, @acct_no, @inv_date, @inv_total, @sale_tax, @parts, @labor, @TrnsDescrip, @depot_loc, @InvType
END

CLOSE curData
DEALLOCATE curData

IF @@ERROR = 0
BEGIN
	INSERT INTO ILSINT02.Integrations.dbo.ReceivedIntegrations (Integration, Company, BatchId)
	SELECT	DISTINCT Integration, Company, BatchId
	FROM	ILSINT02.Integrations.dbo.Integrations_AR
	WHERE	Integration = 'REPAR'
			AND BatchId = @BatchId

	INSERT INTO BatchesReceived (BatchDate, IntercompanyImages) VALUES (@IntDate, 0)
END