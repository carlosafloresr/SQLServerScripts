USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_Inquiry]    Script Date: 11/18/2021 8:10:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_Inquiry 'PR', '57-182394', 'CFLORES'
EXECUTE USP_SWS_Inquiry 'CH', 'DCSZ703201', 'CFLORES'
EXECUTE USP_SWS_Inquiry 'CO', 'HLXU827082', 'CFLORES'
EXECUTE USP_SWS_Inquiry 'RF', '08541', 'CFLORES'
*/
ALTER PROCEDURE [dbo].[USP_SWS_Inquiry]
		@SearchType		Char(2),
		@SearchValue	Varchar(15),
		@UserId			Varchar(25) = Null
AS
SET NOCOUNT ON

DECLARE	@QueryBase		Varchar(MAX),
		@Alternative	Bit = 0,
		@Query			Varchar(MAX),
		@DataRows		Int,
		@OrderNumber	Int,
		@CombinedString Varchar(MAX),
		@AppData		Varchar(MAX),
		@FinancialView	Varchar(200),
		@Div_Code		Varchar(3) = '00',
		@Pro			Varchar(12) = '919191',
		@PureProNumber	Varchar(15)

DECLARE	@tblCompanies	Table (
		Company			Varchar(5),
		CompanyName		Varchar(100))

DECLARE @tblIntercpy	Table (
		Company			Varchar(5),
		Customer		Varchar(20))

DECLARE	@tblSWSData		Table (
		SourceTbl		Varchar(10),
		Company			Varchar(5),
		CompanyNumber	Smallint,
		OrderDate		Date,
		DeliveryDate	Date,
		ProNumber		Varchar(15),
		InvoiceDate		Date Null,
		Customer		Varchar(70),
		CustomerNumber	Varchar(15),
		CustomerName	Varchar(75),
		GPCustNumber	Varchar(20),
		BillToReference	Varchar(25),
		Container		Varchar(20),
		EquipmentCode	Varchar(10),
		InvoiceTotal	Numeric(10,2),
		AccrudAmount	Numeric(10,2),
		Weight			Numeric(10,2),
		OrderNumber		Int,
		CustomerReq		Varchar(100),
		CompanyCode		Varchar(5),
		RecordType		Varchar(15))

DECLARE	@tblSWSDataAlt	Table (
		SourceTbl		Varchar(10),
		Company			Varchar(5),
		CompanyNumber	Smallint,
		OrderDate		Date,
		DeliveryDate	Date,
		Div_Code		Varchar(3),
		Pro				Varchar(15),
		InvoiceDate		Date Null,
		Customer		Varchar(70),
		CustomerNumber	Varchar(15),
		CustomerName	Varchar(75),
		GPCustNumber	Varchar(20),
		BillToReference	Varchar(25),
		Container		Varchar(20),
		EquipmentCode	Varchar(10),
		InvoiceTotal	Numeric(10,2),
		AccrudAmount	Numeric(10,2),
		Weight			Numeric(10,2),
		OrderNumber		Int,
		CustomerReq		Varchar(100),
		CompanyCode		Varchar(5),
		RecordType		Varchar(15))

SET @FinancialView = (SELECT VarC FROM Parameters WHERE ParameterCode = 'PROFINANCIALVIEW' AND Company = 'ALL')

INSERT INTO @tblCompanies
EXECUTE Intranet.dbo.USP_UserCompanies @UserId

INSERT INTO @tblIntercpy
SELECT	DISTINCT Company, Account 
FROM	IntegrationsDB.Integrations.dbo.FSI_Intercompany_ARAP 
WHERE	RecordType = 'C' 
ORDER BY Company, Account

SET @QueryBase = N'SELECT INV.Type, INV.Cmpy_No, ORD.OrigDt, INV.DelDt, INV.Code, INV.InvDate, INV.BT_Code, INV.BTName, INV.BTRef, INV.Eq_Code, INV.Eqt_Code, INV.Total, INV.AcrudAmt, INV.Weight, INV.Or_No 
FROM TRK.Invoice INV 
LEFT JOIN TRK.Order ORD ON INV.Or_No = ORD.No AND INV.Cmpy_No = ORD.Cmpy_No 
WHERE '

IF @SearchType = 'PR'
BEGIN
	SET @PureProNumber = dbo.GetPureProNumber(@SearchValue)

	IF dbo.AT('-', @PureProNumber, 1) = 1
	BEGIN
		SET @Div_Code = dbo.PADL(LEFT(@PureProNumber, 1), '0', 1)
		SET @Pro = SUBSTRING(@PureProNumber, 3, 10)
	END
	ELSE
	BEGIN
		SET @Div_Code = LEFT(@PureProNumber, 2)
		SET @Pro = SUBSTRING(@PureProNumber, 4, 10)
	END
END

IF @SearchType = 'CO'
	SET @Query = @QueryBase + 'ORD.BillTl_Code = ''' + @SearchValue + ''''
	
IF @SearchType = 'CH'
	SET @Query = @QueryBase + 'ORD.BillCh_Code = ''' + @SearchValue + ''''

IF @SearchType = 'RF'
	SET @Query = @QueryBase + 'ORD.CRef = ''' + @SearchValue + ''''

IF @SearchType <> 'PR'
BEGIN
	INSERT INTO @tblSWSData (
			SourceTbl,
			CompanyNumber,
			OrderDate,
			DeliveryDate,
			ProNumber,
			InvoiceDate,
			CustomerNumber,
			CustomerName,
			BillToReference,
			Container,
			EquipmentCode,
			InvoiceTotal,
			AccrudAmount,
			Weight,
			OrderNumber)
	EXECUTE USP_QuerySWS_ReportData @Query
END

SET @DataRows = (SELECT COUNT(*) FROM @tblSWSData)

IF @DataRows = 0
BEGIN
	PRINT 'ALTERNATIVE'
	SET @Alternative = 1

	SET @QueryBase = N'SELECT Type, Cmpy_No, OrigDt, DelDt, Div_Code, Pro, BT_Code, CNName, CRef, BillTl_Code, BillTl_Size, TotChg, AccChg, Weight, No FROM TRK.Order WHERE '

	IF @SearchType = 'PR'
		SET @Query = @QueryBase + 'Div_Code = ''' + @Div_Code + ''' AND Pro = ''' + @Pro + ''''

	IF @SearchType = 'CO'
		SET @Query = @QueryBase + 'BillTl_Code = ''' + @SearchValue + ''''
	
	IF @SearchType = 'CH'
		SET @Query = @QueryBase + 'BillCh_Code = ''' + @SearchValue + ''''

	IF @SearchType = 'RF'
		SET @Query = @QueryBase + 'CRef = ''' + @SearchValue + ''''

	INSERT INTO @tblSWSDataAlt (
			SourceTbl,
			CompanyNumber,
			OrderDate,
			DeliveryDate,
			Div_Code,
			Pro,
			CustomerNumber,
			CustomerName,
			BillToReference,
			Container,
			EquipmentCode,
			InvoiceTotal,
			AccrudAmount,
			Weight,
			OrderNumber)
	EXECUTE USP_QuerySWS_ReportData @Query

	INSERT INTO @tblSWSData (
			SourceTbl,
			CompanyNumber,
			OrderDate,
			DeliveryDate,
			ProNumber,
			CustomerNumber,
			CustomerName,
			BillToReference,
			Container,
			EquipmentCode,
			InvoiceTotal,
			AccrudAmount,
			Weight,
			OrderNumber)
	SELECT	SourceTbl,
			CompanyNumber,
			OrderDate,
			DeliveryDate,
			CAST(CAST(Div_Code AS Int) AS Varchar) + '-' + Pro, 
			CustomerNumber,
			CustomerName,
			BillToReference,
			Container,
			EquipmentCode,
			InvoiceTotal,
			AccrudAmount,
			Weight,
			OrderNumber
	FROM	@tblSWSDataAlt

	SET @DataRows = (SELECT COUNT(*) FROM @tblSWSData)
END

UPDATE @tblSWSData SET RecordType = 'MAIN'

IF @SearchType = 'PR' AND @Alternative = 0
BEGIN
	SELECT @CombinedString = COALESCE(@CombinedString + ',', '') + CAST(OrderNumber AS Varchar) FROM @tblSWSData
	SET @Query = @QueryBase + 'INV.Or_No IN (' + @combinedString + ') AND INV.Code <> ''' + @SearchValue + ''''

	INSERT INTO @tblSWSData (
			SourceTbl,
			CompanyNumber,
			OrderDate,
			DeliveryDate,
			ProNumber,
			InvoiceDate,
			CustomerNumber,
			CustomerName,
			BillToReference,
			Container,
			EquipmentCode,
			InvoiceTotal,
			AccrudAmount,
			Weight,
			OrderNumber)
	EXECUTE USP_QuerySWS_ReportData @Query
	
	UPDATE @tblSWSData SET RecordType = 'RELATED' WHERE RecordType IS Null
END

UPDATE	@tblSWSData
SET		SourceTbl		= CASE WHEN SourceTbl = 'C' THEN 'CREDIT' WHEN SourceTbl = 'D' THEN 'DEBIT' ELSE 'INVOICE' END,
		Company			= CompanyAlias,
		CompanyCode		= CompanyId,
		GPCustNumber	= IIF(CompanyAccess IS Null, '', CustNumber),
		Customer		= IIF(CompanyAccess IS Null, '* NO ACCESS TO THIS COMPANY DATA *', CustomerFull),
		Container		= IIF(CompanyAccess IS Null, '', Container),
		CustomerReq		= RequiredDocuments,
		InvoiceTotal	= IIF(CompanyAccess IS Null, 0, Total),
		BillToReference	= IIF(CompanyAccess IS Null, '', BillToReference),
		AccrudAmount	= IIF(CompanyAccess IS Null, 0, AccrudAmount),
		OrderNumber		= IIF(Delivery_Date IS Null, 0, OrderNumber)
FROM	(
		SELECT	ISNULL(CPY.CompanyAlias, CPY.CompanyId) AS CompanyAlias,
				CPY.CompanyId,
				CASE WHEN CMA.SWSCustomerId IS Null OR CMA.SWSCustomerId = '' THEN CMA.CustNmbr ELSE CMA.SWSCustomerId END AS CustNumber,
				SWS.CustomerNumber + ' - ' + SWS.CustomerName AS CustomerFull,
				CMA.RequiredDocuments,
				SWS.InvoiceTotal AS Total,
				TCO.Company AS CompanyAccess,
				CPY.CompanyNumber AS CompanyNum,
				SWS.ProNumber AS Pro_Number,
				SWS.DeliveryDate AS Delivery_Date
		FROM	@tblSWSData SWS
				INNER JOIN View_CompanyAgents CPY ON SWS.CompanyNumber = CPY.CompanyNumber
				LEFT JOIN @tblCompanies TCO ON CPY.CompanyId = TCO.Company
				LEFT JOIN CustomerMaster CMA ON CPY.CompanyId = CMA.CompanyId AND (SWS.CustomerNumber = CMA.SWSCustomerId OR SWS.CustomerNumber = CMA.CustNmbr)
		) DATA
WHERE	CustomerNumber = CustNumber
		AND CompanyNumber = CompanyNum
		AND ProNumber = Pro_Number

DECLARE	@Company		Varchar(5),
		@CustomerNumber	Varchar(15),
		@InvoiceNumber	Varchar(15)

DECLARE	@tblGreatPlains	Table (
		Company			Varchar(5),
		CustomerNumber	Varchar(15),
		InvoiceNumber	Varchar(15),
		GP_Balance		Numeric(10,2),
		ApplyTo			Varchar(MAX))

DECLARE	@tblGPApplyTo	Table (
		ApplyDate		Date,
		ApplyTo			Varchar(MAX))

DECLARE curRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyCode,
		GPCustNumber,
		ProNumber
FROM	@tblSWSData

OPEN curRecords 
FETCH FROM curRecords INTO @Company, @CustomerNumber, @InvoiceNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT ''' + @Company + ''' AS Company, CUSTNMBR, DOCNUMBR, CURTRXAM, Null
	FROM	' + @Company + '.dbo.RM20101 
	WHERE	CUSTNMBR = ''' + @CustomerNumber + ''' 
			AND DOCNUMBR = ''' + @InvoiceNumber + '''
	UNION
	SELECT ''' + @Company + ''' AS Company, CUSTNMBR, DOCNUMBR, CURTRXAM, Null
	FROM	' + @Company + '.dbo.RM30101 
	WHERE	CUSTNMBR = ''' + @CustomerNumber + ''' 
			AND DOCNUMBR = ''' + @InvoiceNumber + ''''
		
	INSERT INTO @tblGreatPlains
	EXECUTE(@Query)

	SET @Query = N'SELECT APFRDCDT, RTRIM(APFRDCNM) + '' '' + CONVERT(Char(10), APFRDCDT, 101) + '' '' + FORMAT(APPTOAMT, ''$##,###,###.##'') AS AppData
	FROM	' + @Company + '.dbo.RM20201
	WHERE	APTODCNM = ''' + @InvoiceNumber + '''
			AND CUSTNMBR = ''' + @CustomerNumber + '''
	UNION
	SELECT	APFRDCDT, RTRIM(APFRDCNM) + '' '' + CONVERT(Char(10), APFRDCDT, 101) + '' '' + FORMAT(APPTOAMT, ''$##,###,###.##'') AS AppData
	FROM	' + @Company + '.dbo.RM30201
	WHERE	APTODCNM = ''' + @InvoiceNumber + '''
			AND CUSTNMBR = ''' + @CustomerNumber + ''' 
	ORDER BY APFRDCDT DESC'

	INSERT INTO @tblGPApplyTo
	EXECUTE(@Query)

	IF @@ROWCOUNT > 0
	BEGIN
		SET @CombinedString = Null
		SELECT @CombinedString = ISNULL(@CombinedString + CHAR(13), '') + ApplyTo FROM @tblGPApplyTo

		UPDATE	@tblGreatPlains
		SET		ApplyTo = @CombinedString
		WHERE	Company = @Company
				AND CustomerNumber = @CustomerNumber
				AND InvoiceNumber = @InvoiceNumber
	END

	DELETE @tblGPApplyTo

	FETCH FROM curRecords INTO @Company, @CustomerNumber, @InvoiceNumber
END

CLOSE curRecords
DEALLOCATE curRecords

SELECT	*,
		CASE WHEN OrderNumber > 0 THEN @FinancialView + '?divCode=' + dbo.PADL(LEFT(ProNumber, dbo.AT('-', ProNumber, 1) - 1), 2, '0') + '&pro=' + SUBSTRING(ProNumber, dbo.AT('-', ProNumber, 1) + 1, 13) + '&cmpyNo=' + CAST(CompanyNumber AS Varchar) ELSE '' END AS FinancialData, 
		ROW_NUMBER() OVER(ORDER BY CompanyId ASC) AS RowId
FROM	(
		SELECT	DISTINCT CPY.CompanyId,
				ISNULL(CPY.CompanyAlias, CPY.CompanyId) + ' - ' + CPY.CompanyName AS CompanyName,
				SWS.SourceTbl,
				SWS.ProNumber,
				SWS.OrderDate,
				SWS.DeliveryDate,
				SWS.InvoiceDate,
				SWS.Customer,
				SWS.GPCustNumber,
				SWS.BillToReference,
				SWS.Container,
				SWS.EquipmentCode,
				SWS.InvoiceTotal,
				SWS.AccrudAmount,
				SWS.Weight,
				IIF(LEFT(SWS.ProNumber, 1) in ('C','D') OR RIGHT(SWS.ProNumber, 1) in ('C','D') OR SWS.Customer LIKE '* No access%', 0, SWS.OrderNumber) AS OrderNumber,
				@DataRows AS DataRows,
				SWS.CompanyNumber,
				'INV ' + ISNULL(SWS.CustomerReq, '') AS CustomerReq,
				CASE WHEN GRP.InvoiceNumber IS Null AND CIN.Customer IS Null THEN 'NO' ELSE 'YES' END AS InGP,
				GRP.GP_Balance,
				SWS.RecordType,
				ISNULL(GRP.ApplyTo, '') AS ApplyTo
		FROM	@tblSWSData SWS
				INNER JOIN View_CompanyAgents CPY ON SWS.CompanyNumber = CPY.CompanyNumber
				LEFT JOIN @tblGreatPlains GRP ON SWS.CompanyCode = GRP.Company AND SWS.GPCustNumber = GRP.CustomerNumber AND SWS.ProNumber = GRP.InvoiceNumber
				LEFT JOIN @tblIntercpy CIN ON SWS.CompanyCode = CIN.Company AND SWS.GPCustNumber = CIN.Customer
		) DATA
ORDER BY 
		CompanyId,
		RecordType,
		OrderDate DESC,
		ProNumber

RETURN @@ROWcount

/*
EXECUTE USP_SWS_Inquiry_Moves 1, 104166733
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Move INV WHERE INV.Or_No = 103725359'
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Order WHERE billtl_code = ''MAGU523399'''
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Order WHERE billch_code = ''AIMZ402506'''
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Order WHERE no = 104220801'
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Order WHERE BT_Code = ''MATNAV'' ORDER BY '
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Invoice WHERE Code = ''16-59417-A'''
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Invoice WHERE Or_No = 103725359'
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Invoice WHERE BT_Code = ''MATNAV'' AND InvDate > ''01/01/2020'' ORDER BY InvDate DESC LIMIT 100'
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.order WHERE CRef = ''19U201922-001'''
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.OrVnPay where adate > ''01-01-2019'' limit 100 ' -- WHERE Or_No = 103725359'
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.orchrg WHERE Or_No = 103725359'
EXECUTE USP_QuerySWS 'SELECT * FROM Public.DMEqStatus WHERE refcode = ''7750452'''
*/

-- SELECT * FROM CUSTOMERMASTER WHERE COMPANYID = 'PTS' AND CustNmbr = '248'