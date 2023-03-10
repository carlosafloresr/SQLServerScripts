USE [FI]
GO
/****** Object:  StoredProcedure [dbo].[USP_REPAR_Integration]    Script Date: 1/19/2023 11:31:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_REPAR_Integration '01/18/2023','IMCMR'
*/
ALTER PROCEDURE [dbo].[USP_REPAR_Integration]
		@IntDate		Date,
		@CompanyId		Varchar(5)
AS
SET NOCOUNT ON

DECLARE	@DatePortion	Varchar(15),
		@Company		Varchar(5),
		@BatchId		Varchar(25),
		@BatchGL		Varchar(25),
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
		@PostingDate	Date = GETDATE(),
		@ParCompany		Varchar(5) = @CompanyId,
		@Tires			Numeric(10,2),
		@WithGL			Bit = 0,
		@Intercompany	Bit = 0,
		@PstgDate		Date = dbo.DayFwdBack(@IntDate,'P','Saturday')

DECLARE	@tblAccounts	Table (
		AcctType		Varchar(10),
		Location		Varchar(15),
		Credit			Varchar(15),
		Debit			Varchar(15),
		Company			Varchar(5))

INSERT INTO @tblAccounts VALUES ('TAXES', 'HOUSTON', '0-00-2110', '0-00-1140', 'GIS')
INSERT INTO @tblAccounts VALUES ('LABOR', 'HOUSTON', '5-11-4016', '0-00-1140', 'GIS')
INSERT INTO @tblAccounts VALUES ('PARTS', 'HOUSTON', '5-11-4013', '0-00-1140', 'GIS')
INSERT INTO @tblAccounts VALUES ('TIRES', 'HOUSTON', '5-11-4018', '0-00-1140', 'GIS')
--INSERT INTO @tblAccounts VALUES ('TAXES', 'MEMREFURB', '3-00-2110', '0-00-1050', 'IMCCS')
--INSERT INTO @tblAccounts VALUES ('LABOR', 'MEMREFURB', '5-09-4016', '0-00-1050', 'IMCCS')
--INSERT INTO @tblAccounts VALUES ('PARTS', 'MEMREFURB', '5-09-4013', '0-00-1050', 'IMCCS')
INSERT INTO @tblAccounts VALUES ('TAXES', 'DALLAS', '3-03-2110', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('LABOR', 'DALLAS', '5-03-4016', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('PARTS', 'DALLAS', '5-03-4013', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('TAXES', 'FT.WORTH', '3-03-2110', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('LABOR', 'FT.WORTH', '5-19-4016', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('PARTS', 'FT.WORTH', '5-19-4013', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('TAXES', 'MEMPHIS', '3-00-2110', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('LABOR', 'MEMPHIS', '5-08-4016', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('PARTS', 'MEMPHIS', '5-08-4013', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('TAXES', 'NASHVILLE', '3-00-2110', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('LABOR', 'NASHVILLE', '5-07-4016', '0-00-1050', 'IMCMR')
INSERT INTO @tblAccounts VALUES ('PARTS', 'NASHVILLE', '5-07-4013', '0-00-1050', 'IMCMR')
--INSERT INTO @tblAccounts VALUES ('LABOR', 'HOUSTON', '00-00-4016', '00-00-1050', 'NDS')

DECLARE @tblDepotData	Table (
		acct_no			Varchar(20),
		inv_date		Date,
		rep_date		Date,
		inv_total		Numeric(10,2),
		labor			Numeric(10,2),
		labor_hour		Numeric(10,2),
		Tires			Numeric(10,2),
		NonTires		Numeric(10,2),
		parts			Numeric(10,2),
		sale_tax		Numeric(10,2),
		chassis			Varchar(25),
		container		Varchar(25),
		genset_no		Varchar(25))

DECLARE	@tblCustomers	Table (
		CustNmbr		Varchar(15),
		BatchBilling	Bit)

DECLARE	@tblBatches		Table (
		CustNmbr		Varchar(15),
		BatchTotal		Numeric(10,2),
		RowId			Varchar(5))

INSERT INTO @tblCustomers
SELECT	DISTINCT CustNmbr,
		CASE WHEN CUSTNMBR IN ('MEMTSR','NASTSR') OR @Company = 'GIS' THEN 0 ELSE BatchBilling END AS BatchBilling
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	CompanyId IN ('IMCMR','GIS')
		AND CustNmbr <> ''
ORDER BY CustNmbr
 
INSERT INTO @tblCustomers
SELECT	DISTINCT CustNmbr,
		CASE WHEN CUSTNMBR IN ('MEMTSR','NASTSR') THEN 0 ELSE BatchBilling END AS BatchBilling
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	CompanyId = 'FI'
		AND CustNmbr <> ''
		AND CustNmbr NOT IN (SELECT CustNmbr FROM @tblCustomers)
ORDER BY CustNmbr

UPDATE	PRISQL01P.GPCustom.dbo.CustomerMaster
SET		BatchBilling = 0
WHERE	CustNmbr = 'DALTRL'

IF @CompanyId = 'GIS'
BEGIN
	UPDATE	[FI].[staging].[MSR_Import]
	SET		BATCHID = REPLACE(BATCHID, 'REPAR', 'REPGL')
	WHERE	Company = @CompanyId
			AND import_date = @IntDate
			AND Intercompany = 1
END

SET @DatePortion	= dbo.PADL(MONTH(@IntDate), 2, '0') + dbo.PADL(DAY(@IntDate), 2, '0') + RIGHT(dbo.PADL(YEAR(@IntDate), 4, '0'), 2)

UPDATE	Staging.MSR_Import 
SET		Intercompany = 1
WHERE	Import_Date = @IntDate
		AND acct_no IN (SELECT DISTINCT Account FROM IntegrationsDB.Integrations.dbo.FSI_Intercompany_ARAP WHERE Company = 'FI' AND RecordType = 'C')

IF @CompanyId = 'GIS'
	UPDATE	Staging.MSR_Import
	SET		BatchId = IIF(Intercompany = 1, 'REPGL_','REPAR_') + @DatePortion
	WHERE	Import_Date = @IntDate
ELSE
	UPDATE	Staging.MSR_Import
	SET		BatchId = 'REPAR_' + @DatePortion
	WHERE	Import_Date = @IntDate

INSERT INTO @tblBatches
SELECT	MSR.acct_no,
		SUM(MSR.inv_total) AS BatchAmount,
		dbo.PADL(ROW_NUMBER() OVER(ORDER BY MSR.acct_no), 2, '0') AS RowNumber
FROM	Staging.MSR_Import MSR
		LEFT JOIN @tblCustomers CUS ON MSR.acct_no = CUS.CustNmbr
WHERE	MSR.Import_Date = @IntDate
		AND CUS.BatchBilling = 1
		AND MSR.inv_batch IN ('','B0')
GROUP BY MSR.acct_no

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
		CASE WHEN inv_total < 0 THEN 'C' ELSE 'I' END AS InvType,
		Company,
		Intercompany
FROM	(
		SELECT	MSR.inv_no,
				MSR.acct_no,
				MAX(MSR.inv_date) AS inv_date,
				SUM(MSR.inv_total) AS inv_total,
				SUM(MSR.sale_tax) AS sale_tax,
				SUM(MSR.parts) AS parts,
				SUM(MSR.labor) AS labor,
				MSR.TrnsDescrip,
				MSR.depot_loc,
				MSR.Company,
				MSR.Intercompany
		FROM	(
				SELECT	DISTINCT MSR.inv_no,
						MSR.acct_no,
						MSR.inv_date,
						MSR.inv_total,
						MSR.sale_tax,
						MSR.parts + MSR.consum AS parts,
						MSR.labor,
						RTRIM(MSR.inv_no) + '/' + CASE WHEN MSR.Container = '' THEN '' ELSE 'CO:' + RTRIM(MSR.Container) END +
						CASE WHEN MSR.chassis = '' THEN '' ELSE IIF(RTRIM(MSR.Container) = '', '', '/') + 'CH:' + RTRIM(MSR.chassis) END +
						CASE WHEN MSR.genset_no = '' THEN '' ELSE IIF(RTRIM(MSR.Container) = '' AND RTRIM(MSR.chassis) = '', '', '/') + 'GS:' + RTRIM(MSR.genset_no) END AS TrnsDescrip,
						MSR.depot_loc,
						ACT.Company,
						MSR.Intercompany
				FROM	Staging.MSR_Import MSR
						INNER JOIN @tblAccounts ACT ON MSR.depot_loc = ACT.Location AND ACT.AcctType = 'LABOR'
						LEFT JOIN @tblCustomers CUS ON MSR.acct_no = CUS.CustNmbr
				WHERE	MSR.Import_Date = @IntDate
						AND (MSR.Intercompany = 0 OR (ACT.Company = 'GIS' AND MSR.Intercompany = 1))
						AND MSR.inv_no <> ''
						AND (ISNULL(CUS.BatchBilling, 0) = 0
						OR MSR.inv_batch = 'B0')
				) MSR
				LEFT JOIN @tblCustomers CUS ON MSR.acct_no = CUS.CustNmbr
		GROUP BY
				MSR.inv_no,
				MSR.acct_no,
				MSR.depot_loc,
				MSR.TrnsDescrip,
				MSR.Company,
				MSR.Intercompany
		UNION
		SELECT	CASE WHEN MSR.inv_batch IN ('','B0') THEN 'B' + @DatePortion + '_' + ISNULL(BCH.RowId, 1) ELSE MSR.inv_batch END AS inv_batch,
				MSR.acct_no,
				MAX(MSR.inv_date) AS inv_date,
				SUM(MSR.inv_total) AS inv_total,
				SUM(MSR.sale_tax) AS sale_tax,
				SUM(MSR.parts + MSR.consum) AS parts,
				SUM(MSR.labor) AS labor,
				'Batch ' + CASE WHEN MSR.inv_batch = 'B0' THEN 'B' + @DatePortion ELSE MSR.inv_batch END AS TrnsDescrip,
				MSR.depot_loc,
				ACT.Company,
				0 AS Intercompany
		FROM	Staging.MSR_Import MSR
				INNER JOIN @tblAccounts ACT ON MSR.depot_loc = ACT.Location AND ACT.AcctType = 'LABOR'
				LEFT JOIN @tblCustomers CUS ON MSR.acct_no = CUS.CustNmbr
				LEFT JOIN @tblBatches BCH ON MSR.acct_no = BCH.CustNmbr
		WHERE	MSR.Import_Date = @IntDate
				AND (MSR.Intercompany = 0 OR (ACT.Company = 'GIS' AND MSR.Intercompany = 1))
				AND CUS.BatchBilling = 1
				AND MSR.inv_no <> ''
				AND MSR.inv_batch <> 'B0'
		GROUP BY
				MSR.inv_batch,
				MSR.acct_no,
				MSR.depot_loc,
				BCH.RowId,
				ACT.Company
		) DATA

SET @BatchId = 'REPAR' + '_' + @DatePortion
SET @BatchGL = 'REPGL' + '_' + @DatePortion

IF @CompanyId IS Null
BEGIN
	DELETE IntegrationsDB.Integrations.dbo.Integrations_AR WHERE BatchId = @BatchId AND Integration = @Integration
	DELETE IntegrationsDB.Integrations.dbo.ReceivedIntegrations WHERE BatchId = @BatchId AND Integration = @Integration

	DELETE IntegrationsDB.Integrations.dbo.Integrations_AR WHERE BatchId = @BatchGL AND Integration = @Integration
	DELETE IntegrationsDB.Integrations.dbo.ReceivedIntegrations WHERE BatchId = @BatchGL AND Integration = @Integration
END
ELSE
BEGIN
	DELETE IntegrationsDB.Integrations.dbo.Integrations_AR WHERE BatchId = @BatchId AND Integration = @Integration AND Company = @CompanyId
	DELETE IntegrationsDB.Integrations.dbo.ReceivedIntegrations WHERE BatchId = @BatchId AND Integration = @Integration AND Company = @CompanyId

	DELETE IntegrationsDB.Integrations.dbo.Integrations_AR WHERE BatchId = @BatchGL AND Integration = @Integration AND Company = @CompanyId
	DELETE IntegrationsDB.Integrations.dbo.ReceivedIntegrations WHERE BatchId = @BatchGL AND Integration = @Integration AND Company = @CompanyId
END

OPEN curData 
FETCH FROM curData INTO @inv_no, @acct_no, @inv_date, @inv_total, @sale_tax, @parts, @labor, 
						@TrnsDescrip, @depot_loc, @InvType, @Company, @Intercompany

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @DueDate		= DATEADD(dd, 30, @inv_date)
	SET @RMDTYPAL		= IIF(@InvType = 'I', 1, 7)
	SET @DISTTYPE		= IIF(@InvType = 'I', 2, 19)
	SET @DEBITAMT		= IIF(@InvType = 'I', @inv_total, 0)
	SET @CRDTAMNT		= IIF(@InvType = 'I', 0, @inv_total)
	SET @Integration	= IIF(@Intercompany = 0, 'REPAR', 'REPGL')

	SELECT	@ACTNUMST	= Debit
	FROM	@tblAccounts 
	WHERE	Location = @depot_loc
			AND AcctType = 'LABOR'
	
	IF @ParCompany IS Null OR (@ParCompany IS NOT Null AND @Company = @ParCompany)
	BEGIN
		PRINT @Company + ' / ' + @inv_no

		IF @Intercompany = 1
		BEGIN
			SET @WithGL = 1
			EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchGL, @PstgDate, @inv_no, @inv_date, 2,
							@UserId, @ACTNUMST, @CRDTAMNT, @DEBITAMT, @TrnsDescrip, Null, Null, Null, Null, Null, Null, Null, 0
		END
		ELSE
		BEGIN
			EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_AR @Integration, @Company, @BatchId, @inv_no, @TrnsDescrip, @acct_no, @inv_date, @DueDate,
							@inv_total, @inv_total, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @TrnsDescrip, 
							Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate
		END

		IF @sale_tax <> 0
		BEGIN
			PRINT 'Sales/Taxes'

			SET @DISTTYPE	= IIF(@InvType = 'I', 9, 3)
			SET @DEBITAMT	= IIF(@InvType = 'I', 0, @sale_tax)
			SET @CRDTAMNT	= IIF(@InvType = 'I', @sale_tax, 0)

			SELECT	@ACTNUMST	= Credit
			FROM	@tblAccounts 
			WHERE	Location = @depot_loc
					AND AcctType = 'TAXES'

			IF @Intercompany = 1
			BEGIN
				EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchGL, @PstgDate, @inv_no, @inv_date, 2,
								@UserId, @ACTNUMST, @CRDTAMNT, @DEBITAMT, @TrnsDescrip, Null, Null, Null, Null, Null, Null, Null, 0
			END
			ELSE
			BEGIN
				EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_AR @Integration, @Company, @BatchId, @inv_no, @TrnsDescrip, @acct_no, @inv_date, @DueDate,
								@inv_total, @inv_total, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @TrnsDescrip, 
								Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate
			END
		END
	
		IF @labor <> 0
		BEGIN
			PRINT 'Labor'

			SET @DISTTYPE	= IIF(@InvType = 'I', 9, 3)
			SET @DEBITAMT	= IIF(@InvType = 'I', 0, @labor)
			SET @CRDTAMNT	= IIF(@InvType = 'I', @labor, 0)

			SELECT	@ACTNUMST	= Credit
			FROM	@tblAccounts 
			WHERE	Location = @depot_loc
					AND AcctType = 'LABOR'

			IF @Intercompany = 1
			BEGIN
				EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchGL, @PstgDate, @inv_no, @inv_date, 2,
								@UserId, @ACTNUMST, @CRDTAMNT, @DEBITAMT, @TrnsDescrip, Null, Null, Null, Null, Null, Null, Null, 0
			END
			ELSE
			BEGIN
				EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_AR @Integration, @Company, @BatchId, @inv_no, @TrnsDescrip, @acct_no, @inv_date, @DueDate,
								@inv_total, @inv_total, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @TrnsDescrip, 
								Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate
			END
		END

		IF @parts <> 0 AND @Company = 'GIS'
		BEGIN
			DELETE @tblDepotData -- Clear temporal table

			INSERT INTO @tblDepotData
			EXECUTE USP_GIS_Invoice @inv_no

			SELECT	@Tires	= Tires,
					@parts	= NonTires
			FROM	@tblDepotData

			IF @Tires <> 0
			BEGIN
				SET @DISTTYPE	= IIF(@InvType = 'I', 9, 3)
				SET @DEBITAMT	= IIF(@InvType = 'I', 0, @Tires)
				SET @CRDTAMNT	= IIF(@InvType = 'I', @Tires, 0)

				SELECT	@ACTNUMST	= Credit
				FROM	@tblAccounts 
				WHERE	Location = @depot_loc
						AND AcctType = 'TIRES'

				IF @Intercompany = 1
				BEGIN
					EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchGL, @PstgDate, @inv_no, @inv_date, 2,
									@UserId, @ACTNUMST, @CRDTAMNT, @DEBITAMT, @TrnsDescrip, Null, Null, Null, Null, Null, Null, Null, 0
				END
				ELSE
				BEGIN
					EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_AR @Integration, @Company, @BatchId, @inv_no, @TrnsDescrip, @acct_no, @inv_date, @DueDate,
									@inv_total, @inv_total, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @TrnsDescrip, 
									Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate
				END
			END
		END

		IF @parts <> 0
		BEGIN
			SET @DISTTYPE	= IIF(@InvType = 'I', 9, 3)
			SET @DEBITAMT	= IIF(@InvType = 'I', 0, @parts)
			SET @CRDTAMNT	= IIF(@InvType = 'I', @parts, 0)

			SELECT	@ACTNUMST	= Credit
			FROM	@tblAccounts 
			WHERE	Location = @depot_loc
					AND AcctType = 'PARTS'

			IF @Intercompany = 1
			BEGIN
				EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchGL, @PstgDate, @inv_no, @inv_date, 2,
								@UserId, @ACTNUMST, @CRDTAMNT, @DEBITAMT, @TrnsDescrip, Null, Null, Null, Null, Null, Null, Null, 0
			END
			ELSE
			BEGIN
				EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_AR @Integration, @Company, @BatchId, @inv_no, @TrnsDescrip, @acct_no, @inv_date, @DueDate,
								@inv_total, @inv_total, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @TrnsDescrip, 
								Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate
			END
		END
	END

	FETCH FROM curData INTO @inv_no, @acct_no, @inv_date, @inv_total, @sale_tax, @parts, @labor, 
							@TrnsDescrip, @depot_loc, @InvType, @Company, @Intercompany
END

CLOSE curData
DEALLOCATE curData

PRINT @BatchId
PRINT @BatchGL

IF @@ERROR = 0
BEGIN
	INSERT INTO IntegrationsDB.Integrations.dbo.ReceivedIntegrations (Integration, Company, BatchId)
	SELECT	DISTINCT Integration, Company, BatchId
	FROM	IntegrationsDB.Integrations.dbo.Integrations_AR
	WHERE	Integration = 'REPAR'
			AND BatchId LIKE ('%' + @DatePortion)
			AND Company = @CompanyId

	IF @WithGL = 1
	BEGIN
		INSERT INTO IntegrationsDB.Integrations.dbo.ReceivedIntegrations (Integration, Company, BatchId)
		SELECT	DISTINCT Integration, Company, BatchId
		FROM	IntegrationsDB.Integrations.dbo.Integrations_GL
		WHERE	Integration = 'REPGL'
				AND BatchId LIKE ('%' + @DatePortion)
				AND Company = @CompanyId
	END

	IF NOT EXISTS(SELECT BatchId FROM BatchesReceived WHERE BatchId = @BatchId) AND EXISTS(SELECT TOP 1 Intercompany FROM staging.MSR_Import WHERE import_date = @IntDate AND Intercompany = 1)
	BEGIN
		INSERT INTO BatchesReceived (Company, BatchId)
		SELECT	DISTINCT Company, BatchId
		FROM	IntegrationsDB.Integrations.dbo.Integrations_AR
		WHERE	Integration = 'REPAR'
				AND BatchId LIKE ('%' + @DatePortion)
				AND Company = @CompanyId
		UNION
		SELECT	DISTINCT Company, BatchId
		FROM	IntegrationsDB.Integrations.dbo.Integrations_GL
		WHERE	Integration = 'REPGL'
				AND BatchId LIKE ('%' + @DatePortion)
				AND Company = @CompanyId
	END

	EXECUTE USP_IMCMR_FindLastBatch @CompanyId, 0
 END

/*
DELETE	Staging.MSR_Import
WHERE	Import_Date = '03/11/2020'

UPDATE	Staging.MSR_Import
SET		Inv_Batch = '1748491A'
WHERE	Inv_Batch = '1748491'

UPDATE	Staging.MSR_Import
SET		Inv_No = 'I1748491A'
WHERE	Inv_No = 'I1748491'

*/