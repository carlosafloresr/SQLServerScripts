USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_TIP_Transactions]    Script Date: 4/23/2018 10:43:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_TIP_Transactions 'GSA', '243', 'GLSO', '1565', 0
EXECUTE USP_TIP_Transactions 'GSA', '243', 'GLSO', '1565', 0, 'CFLORES'
EXECUTE USP_TIP_Transactions 'GSA', '243', 'GLSO', '1565', 1, 'CFLORES'
EXECUTE USP_TIP_Transactions 'NONE', '', 'NONE', ''
*/
ALTER PROCEDURE [dbo].[USP_TIP_Transactions]
		@MainCompany	Varchar(5),
		@VendorId		Varchar(20),
		@SubCompany		Varchar(5),
		@CustomerId		Varchar(20),
		@JustExceptions	Bit = 0,
		@UserId			Varchar(15) = Null
AS
DECLARE	@Query			Varchar(Max),
		@ValidParams	Bit = 1,
		@CompanyAlias1	Varchar(5),
		@CompanyAlias2	Varchar(5),
		@DatePortion	Varchar(10),
		@ARBatchId		Varchar(15),
		@StrTime		Varchar(20),
		@Integration	Char(5) = 'TIPAR'

SET @StrTime		= CONVERT(VARCHAR, GETDATE(), 114)
SET @DatePortion	= dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(dbo.PADL(YEAR(GETDATE()), 4, '0'), 2) + SUBSTRING(@StrTime, 1, dbo.AT(':', @StrTime, 1) - 1) + SUBSTRING(@StrTime, dbo.AT(':', @StrTime, 1) + 1, dbo.AT(':', @StrTime, 2) - 1 - dbo.AT(':', @StrTime, 1))
SET @ARBatchId		= @Integration + @DatePortion
SET @CompanyAlias1	= (SELECT ISNULL(CompanyAlias, CompanyId) AS Alias FROM Companies WHERE CompanyId = @MainCompany)
SET @CompanyAlias2	= (SELECT ISNULL(CompanyAlias, CompanyId) AS Alias FROM Companies WHERE CompanyId = @SubCompany)

IF NOT EXISTS(SELECT CompanyId FROM Companies WHERE CompanyId = @MainCompany)
	SET @ValidParams = 0

IF NOT EXISTS(SELECT CompanyId FROM Companies WHERE CompanyId = @SubCompany)
	SET @ValidParams = 0

DECLARE	@tblData Table (
		Ap_Company		Varchar(5),
		Ap_VendorId		Varchar(25),
		Ap_Document		Varchar(30),
		Ap_DocDate		Date,
		Ap_DocAmount	Numeric(10,2),
		Ap_BatchNumber	Varchar(30),
		Ap_Description	Varchar(30),
		Ar_Company		Varchar(5),
		Ar_CustomerId	Varchar(25) Null,
		Ar_Document		Varchar(30) Null,
		Ar_DocDate		Date Null,
		Ar_BatchNumber	Varchar(30) Null,
		Ar_DocAmount	Numeric(10,2) Null,
		Ar_Description	Varchar(30) Null,
		IsMatch			Char(1) Null,
		Difference		Numeric(10,2) Null,
		Approved		Bit Null,
		KeyWord			Varchar(50) Null)

DECLARE	@tblGPAR		Table (CustomerId Varchar(15), Document Varchar(25), Balance Numeric(10,2), DataTable Char(1))

IF @ValidParams = 1
BEGIN
	DELETE	TIP_Transactions
	WHERE	AP_Company = @MainCompany 
			AND AR_Company = @SubCompany 
			AND VendorId = @VendorId 
			AND CustomerId = @CustomerId
			AND BatchDate < CAST(GETDATE() AS Date)

	DELETE	TIP_Transactions_Assigned
	WHERE	AP_Company = @MainCompany 
			AND AR_Company = @SubCompany 
			AND VendorId = @VendorId 
			AND CustomerId = @CustomerId
			AND CreatedOn < CAST(GETDATE() AS Date)

	IF EXISTS(SELECT TOP 1 VendorId FROM TIP_Transactions WHERE AP_Company = @MainCompany AND AR_Company = @SubCompany AND VendorId = @VendorId AND CustomerId = @CustomerId AND BatchDate = CAST(GETDATE() AS Date))
	BEGIN
		SET	@Query = N'SELECT CUSTNMBR, DOCNUMBR, CURTRXAM, ''O'' AS DataTable FROM ' + RTRIM(@SubCompany) + '.dbo.RM20101 WHERE CustNmbr = ''' + RTRIM(@CustomerId) + '''
		UNION 
		SELECT CUSTNMBR, DOCNUMBR, DOCAMNT AS CURTRXAM, ''W'' AS DataTable FROM ' + RTRIM(@SubCompany) + '.dbo.RM10301 WHERE CustNmbr = ''' + RTRIM(@CustomerId) + ''''

		INSERT INTO @tblGPAR
		EXECUTE(@Query)

		SELECT	TIP.AP_Company
				,TIP.AR_Company
				,TIP.VendorId
				,TIP.CustomerId
				,TIP.Ar_CustomerId
				,TIP.Ar_Document
				,TIP.Ar_DocDate
				,TIP.Ar_BatchNumber
				,TIP.Ar_DocAmount
				,TIP.Ar_Description
				--,CASE WHEN IsMatch = 'N' THEN TIP.IsMatch WHEN (SELECT COUNT(ITB.Company) FROM ILSINT02.Integrations.dbo.Integrations_ApplyTo ITB WHERE ITB.Company = @SubCompany AND ITB.Integration = @Integration AND ITB.CustomerVendor = @CustomerId AND ITB.RecordType = 'AR' AND ITB.ApplyTo = TIP.Ar_Document) > 0 THEN 'I' ELSE 'Y' END AS IsMatch
				,CASE WHEN IsMatch = 'N' THEN TIP.IsMatch WHEN ITB.DataTable = 'W' THEN 'I' ELSE 'Y' END AS IsMatch
				,TIP.Difference
				,TIP.Approved
				,TIP.KeyWord
				,TIP.UserId
				,TIP.BatchDate
				,TMP.CustomerId
				,TMP.Document
				,TMP.Balance
				,ITB.ApplyTo
				,ITB.ApplyFrom
				,ISNULL(ITB.DataTable,'U') AS DataTable
		FROM	TIP_Transactions TIP
				LEFT JOIN @tblGPAR TMP ON TIP.Ar_CustomerId = TMP.CustomerId AND TIP.Ar_Document = TMP.Document
				LEFT JOIN (
							SELECT	ITB.ApplyTo,
									ITB.ApplyFrom,
									ISNULL(TMP.DataTable, 'P') AS DataTable
							FROM	ILSINT02.Integrations.dbo.Integrations_ApplyTo ITB 
									LEFT JOIN @tblGPAR TMP ON ITB.CustomerVendor = TMP.CustomerId AND ITB.ApplyFrom = TMP.Document
							WHERE	ITB.Company = @SubCompany 
									AND ITB.Integration = @Integration 
									AND ITB.CustomerVendor = @CustomerId 
									AND ITB.RecordType = 'AR'
							) ITB ON TIP.Ar_Document = ITB.ApplyTo
		WHERE	TIP.AP_Company = @MainCompany 
				AND TIP.AR_Company = @SubCompany 
				AND TIP.VendorId = @VendorId 
				AND TIP.CustomerId = @CustomerId
				AND TIP.BatchDate = CAST(GETDATE() AS Date)
				AND ISNULL(ITB.DataTable,'U') <> 'O'
				--AND ISNULL(TMP.Balance, 1) > 0
		ORDER BY 6, 10
	END
	ELSE
	BEGIN
		SET	@Query = N'SELECT DISTINCT ''' + RTRIM(@MainCompany) + ''' ,AP.VendorId,
				AP.DOCNUMBR,
				AP.DocDate,
				CASE WHEN AP.DOCTYPE < 5 THEN 1 ELSE -1 END * AP.DocAmnt AS DocAmnt,
				AP.BachNumb,
				AP.TrxDscrn,
				''' + RTRIM(@SubCompany) + ''',
				AR.CustNmbr,
				AR.DOCNUMBR,
				AR.DocDate,
				AR.BachNumb,
				AR.OrTrxAmt,
				AR.TrxDscrn,
				CASE WHEN (CASE WHEN AP.DOCTYPE < 5 THEN 1 ELSE -1 END * AP.DocAmnt) - AR.OrTrxAmt = 0 THEN ''Y'' ELSE ''N'' END AS Match,
				(CASE WHEN AP.DOCTYPE < 5 THEN 1 ELSE -1 END * AP.DocAmnt) - AR.OrTrxAmt AS Difference,
				0 AS Approved,
				''' + RTRIM(@MainCompany) + '_'' + RTRIM(AP.VendorId) + ''_'' + RTRIM(AR.DOCNUMBR)
		FROM	' + RTRIM(@MainCompany) + '.dbo.PM20000 AP
				INNER JOIN ' + RTRIM(@SubCompany) + '.dbo.RM20101 AR ON LEFT(AP.DOCNUMBR, 9) = LEFT(AR.DOCNUMBR, 9) AND AR.CustNmbr = ''' + RTRIM(@CustomerId) + '''  
		WHERE	AP.VendorId = ''' + RTRIM(@VendorId) + ''' 
				AND AR.BachNumb NOT LIKE ''%TIPAR%''
				AND AP.BachNumb NOT LIKE ''%TIPAP%''
				AND AR.CURTRXAM > 0 
		ORDER BY 6'

		-- INNER JOIN ' + RTRIM(@SubCompany) + '.dbo.RM20101 AR ON (LEFT(AP.DOCNUMBR, 9) = LEFT(AR.DOCNUMBR, 9) OR AP.TrxDscrn = AR.TrxDscrn) AND AR.CustNmbr = ''' + RTRIM(@CustomerId) + '''  

		INSERT INTO @tblData
		EXECUTE(@Query)
	
		UPDATE	@tblData
		SET		Approved = IIF(Difference = 0.00, 1, 0)

		IF @JustExceptions = 1
			SELECT	@CompanyAlias1 AS AP_Company,
					Ap_VendorId,
					Ap_Document,
					Ap_DocDate,
					Ap_DocAmount,
					Ap_BatchNumber,
					Ap_Description,
					@CompanyAlias2 AS AR_Company,
					Ar_CustomerId,
					Ar_Document,
					Ar_DocDate,
					Ar_BatchNumber,
					Ar_DocAmount,
					Ar_Description,
					Difference,
					CAST(0 AS Bit) AS Approved,
					KeyWord
			FROM	@tblData
			WHERE	Difference <> 0
			ORDER BY 2,6
		ELSE
			INSERT INTO TIP_Transactions
			SELECT	@MainCompany AS AP_Company,
					@SubCompany AS AR_Company,
					@VendorId AS VendorId,
					@CustomerId AS CustomerId,
					Ar_CustomerId,
					Ar_Document,
					Ar_DocDate,
					Ar_BatchNumber,
					Ar_DocAmount,
					Ar_Description,
					IIF((SELECT SUM(Ap_DocAmount) FROM @tblData DET WHERE DET.Ar_CustomerId = DAT.Ar_CustomerId AND LEFT(DET.Ar_Document, 9) = LEFT(DAT.Ar_Document, 9)) - DAT.Ar_DocAmount = 0, 'Y', 'N') AS IsMatch,
					ABS((SELECT SUM(Ap_DocAmount) FROM @tblData DET WHERE DET.Ar_CustomerId = DAT.Ar_CustomerId AND LEFT(DET.Ar_Document, 9) = LEFT(DAT.Ar_Document, 9)) - DAT.Ar_DocAmount) AS Difference,
					CAST(0 AS Bit) AS Approved, --IIF((SELECT SUM(Ap_DocAmount) FROM @tblData DET WHERE DET.Ar_CustomerId = DAT.Ar_CustomerId AND LEFT(DET.Ar_Document, 9) = LEFT(DAT.Ar_Document, 9)) - DAT.Ar_DocAmount = 0, 1, 0) ,
					KeyWord,
					@UserId AS UserId,
					CAST(GETDATE() AS Date) AS BatchDate
			FROM	(
					SELECT	DISTINCT DATA.Ar_CustomerId,
							DATA.Ar_Document,
							DATA.Ar_DocDate,
							DATA.Ar_BatchNumber,
							DATA.Ar_DocAmount,
							DATA.Ar_Description,
							0 AS DIFFERENCE,
							DATA.KeyWord
					FROM	@tblData DATA
					) DAT
			ORDER BY 6, 10

			SELECT	*
			FROM	TIP_Transactions 
			WHERE	AP_Company = @MainCompany 
					AND AR_Company = @SubCompany 
					AND VendorId = @VendorId 
					AND CustomerId = @CustomerId
					AND BatchDate = CAST(GETDATE() AS Date)
			ORDER BY 6, 10
		END
END
ELSE
	SELECT	DATA.Ar_CustomerId,
			DATA.Ar_Document,
			DATA.Ar_DocDate,
			DATA.Ar_BatchNumber,
			DATA.Ar_DocAmount,
			DATA.Ar_Description,
			DATA.IsMatch,
			DATA.Difference,
			DATA.Approved,
			DATA.KeyWord,
			@UserId AS UserId,
			CAST(GETDATE() AS Date) AS BatchDate
	FROM	@tblData DATA