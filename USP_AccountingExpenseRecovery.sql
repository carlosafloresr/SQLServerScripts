USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AccountingExpenseRecovery]    Script Date: 8/5/2022 8:34:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AccountingExpenseRecovery 'GIS', '01/31/2016', '02/27/2016', '0', '00', '1105'
EXECUTE USP_AccountingExpenseRecovery 'AIS', '07/01/2018', '07/28/2018', '0', '00', '6221,6223,6230,6234'
EXECUTE USP_AccountingExpenseRecovery 'IMC', '12/04/2020', '12/31/2022', '1', '08', '6000-6003'
EXECUTE USP_AccountingExpenseRecovery 'AIS', '05/01/2016', '05/28/2016', Null, Null, '1105'
*/
ALTER PROCEDURE [dbo].[USP_AccountingExpenseRecovery]
		@Company	Varchar(5),
		@DateIni	Date,
		@DateEnd	Date,
		@Product	Varchar(500),
		@Division	Varchar(500),
		@Account	Varchar(500)
AS
SET NOCOUNT ON

DECLARE	@Query		Varchar(MAX)

DECLARE @ReportData TABLE 
		(CompanyId			varchar(5) NOT NULL,
		CompanyName			varchar(50) NOT NULL,
		JRNENTRY			int NOT NULL,
		ACTINDX				int NOT NULL,
		Acct1				char(3) NOT NULL,
		Acct2				char(3) NOT NULL,
		Acct3				char(5) NOT NULL,
		Account				varchar(13) NULL,
		AcctDescription		char(51) NOT NULL,
		ACTALIAS			char(51) NOT NULL,
		Category			char(31) NULL,
		SOURCDOC			char(11) NOT NULL,
		Reference			char(31) NOT NULL,
		EffDate				date NULL,
		TrxDate				date NULL,
		VoucherNum			varchar(30) NULL,
		DOCNUMBER			char(21) NOT NULL,
		Vendor				varchar(99) NULL,
		CRDTAMNT			numeric(19, 5) NOT NULL,
		DEBITAMT			numeric(19, 5) NOT NULL,
		Amount				numeric(19, 5) NOT NULL,
		GPYEAR				smallint NOT NULL,
		PERIODID			smallint NOT NULL,
		ORTRXTYP			smallint NOT NULL,
		SERIES				smallint NOT NULL,
		Source				varchar(2) NULL,
		ProNumber			varchar(20) NULL,
		TrailerNumber		varchar(15) NULL,
		ChassisNumber		varchar(15) NULL,
		SEQNUMBR			int NULL)

IF @Product = ''
	SET @Product = Null

IF @Division = ''
	SET @Division = Null

IF @Account = ''
	SET @Account = Null

IF PATINDEX('%''%', @Product) = 0
BEGIN
	IF PATINDEX('%,%', @Product) = 0
		SET @Product = '''' + @Product + ''''
	ELSE
		SET @Product = '''' + REPLACE(@Product, ',', ''',''') + ''''
END

IF PATINDEX('%''%', @Division) = 0
BEGIN
	IF PATINDEX('%,%', @Division) = 0
		SET @Division = '''' + @Division + ''''
	ELSE
		SET @Division = '''' + REPLACE(@Division, ',', ''',''') + ''''
END

IF PATINDEX('%''%', @Account) = 0
BEGIN
	IF PATINDEX('%,%', @Account) = 0
		SET @Account = '''' + @Account + ''''
	ELSE
		SET @Account = '''' + REPLACE(@Account, ',', ''',''') + ''''
END

SET @Query	= N'SELECT	COM.CompanyId, CompanyName,
		JRNENTRY,
		ACTINDX,
		Acct1, 
		Acct2, 
		Acct3, 
		Account,
		AcctDescription, 
		CASE WHEN ACTALIAS = '''' THEN AcctDescription ELSE ACTALIAS END AS ACTALIAS,
		Category,
		SOURCDOC,
		Reference,
		EffDate,
		TrxDate,
		VoucherNum,
		DOCNUMBER,
		Vendor,
		CRDTAMNT,
		DEBITAMT,
		DEBITAMT - CRDTAMNT AS Amount,
		GPYEAR,
		PERIODID,
		ORTRXTYP,
		SERIES,
		Source,
		ProNumber,
		TrailerNumber,
		ChassisNumber,
		SEQNUMBR
FROM	( '
SET @Query = @Query + 'SELECT	GL.JRNENTRY,
				GL.ACTINDX,
				AC.ACTNUMBR_1 AS Acct1, 
				AC.ACTNUMBR_2 AS Acct2, 
				AC.ACTNUMBR_3 AS Acct3, 
				RTRIM(AC.ACTNUMBR_1) + ''-'' + RTRIM(AC.ACTNUMBR_2) + ''-'' + AC.ACTNUMBR_3 AS Account,
				AC.ACTDESCR AS AcctDescription, 
				AC.ACTALIAS,
				CASE WHEN AC.USRDEFS1 = '''' THEN NULL ELSE AC.USRDEFS1 END AS Category,
				GL.SOURCDOC,
				GL.DSCRIPTN AS Reference,
				CAST(GL.TRXDATE AS Date) AS EffDate,
				CAST(CASE WHEN GL.ORPSTDDT < ''01/01/1980'' THEN GL.TRXDATE ELSE GL.ORPSTDDT END AS Date) AS TrxDate,
				CASE WHEN GL.ORTRXTYP = 0 OR GL.SERIES = 2 THEN CAST(GL.JRNENTRY AS Varchar) ELSE GL.ORCTRNUM END AS VoucherNum,
				GL.ORDOCNUM AS DOCNUMBER,
				CASE WHEN GL.ORTRXTYP = 0 OR GL.SERIES = 2 THEN ''General Ledger'' ELSE RTRIM(GL.ORMSTRID) + '' - '' + GL.ORMSTRNM END AS Vendor,
				GL.CRDTAMNT,
				GL.DEBITAMT,
				GL.OPENYEAR AS GPYEAR,
				GL.PERIODID,
				GL.ORTRXTYP,
				GL.SERIES,
				CASE WHEN GL.ORTRXTYP = 0 OR GL.SERIES = 2 THEN ''GL''
					 WHEN GL.ORTRXTYP = 5 AND GL.SERIES <> 4 THEN ''GL''
					 WHEN GL.ORTRXTYP = 5 AND GL.SERIES = 4 THEN ''PM''
					 WHEN GL.ORTRXTYP = 1 THEN ''PM''
					 WHEN GL.ORTRXTYP = 3 THEN ''AR''
					 WHEN GL.ORTRXTYP = 4 THEN ''AR''
					 END AS Source,
				PV.ProNumber,
				UPPER(PV.TrailerNumber) AS TrailerNumber,
				UPPER(PV.ChassisNumber) AS ChassisNumber,
				GL.SEQNUMBR
		FROM 	' + RTRIM(@Company) + '.dbo.GL20000 GL
				INNER JOIN ' + RTRIM(@Company) + '.dbo.GL00100 AC ON GL.ACTINDX = AC.ACTINDX
				LEFT JOIN GPCustom.dbo.Purchasing_Vouchers PV ON CASE WHEN GL.ORTRXTYP = 0 THEN CAST(GL.JRNENTRY AS Varchar) ELSE GL.ORCTRNUM END = PV.VoucherNumber AND CASE WHEN GL.ORTRXTYP = 0 THEN ''GL'' WHEN GL.ORTRXTYP = 1 THEN ''AP'' ELSE ''AR'' END = CASE WHEN PV.Source = ''SOP'' THEN ''AR'' ELSE PV.Source END AND PV.CompanyId = ''' + RTRIM(@Company) + '''
		WHERE 	GL.Voided = 0
				AND GL.TRXDATE BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' '

IF @Product IS NOT Null
BEGIN
	IF PATINDEX('%-%', @Product) > 0
		SET @Query = @Query + ' AND AC.ACTNUMBR_1 BETWEEN ' + LEFT(@Product, PATINDEX('%-%', @Product) - 1) + ''' AND ''' + RIGHT(@Product, LEN(@Product) - PATINDEX('%-%', @Product))
	ELSE
		SET @Query = @Query + ' AND AC.ACTNUMBR_1 IN (' + @Product + ')'
END

IF @Division IS NOT Null
BEGIN
	IF PATINDEX('%-%', @Division) > 0
		SET @Query = @Query + ' AND AC.ACTNUMBR_2 BETWEEN ' + LEFT(@Division, PATINDEX('%-%', @Division) - 1) + ''' AND ''' + RIGHT(@Division, LEN(@Division) - PATINDEX('%-%', @Division))
	ELSE
		SET @Query = @Query + ' AND AC.ACTNUMBR_2 IN (' + @Division + ')'
END

IF @Account IS NOT Null
BEGIN
	IF PATINDEX('%-%', @Account) > 0
		SET @Query = @Query + ' AND AC.ACTNUMBR_3 BETWEEN ' + LEFT(@Account, PATINDEX('%-%', @Account) - 1) + ''' AND ''' + RIGHT(@Account, LEN(@Account) - PATINDEX('%-%', @Account))
	ELSE
		SET @Query = @Query + ' AND AC.ACTNUMBR_3 IN (' + @Account + ')'
END

SET @Query = @Query + ' UNION
		SELECT	GL.JRNENTRY,
				GL.ACTINDX,
				AC.ACTNUMBR_1 AS Acct1, 
				AC.ACTNUMBR_2 AS Acct2, 
				AC.ACTNUMBR_3 AS Acct3, 
				RTRIM(AC.ACTNUMBR_1) + ''-'' + RTRIM(AC.ACTNUMBR_2) + ''-'' + AC.ACTNUMBR_3 AS Account,
				AC.ACTDESCR AS AcctDescription, 
				AC.ACTALIAS,
				CASE WHEN AC.USRDEFS1 = '''' THEN NULL ELSE AC.USRDEFS1 END AS Category,
				GL.SOURCDOC,
				GL.DSCRIPTN AS Reference,
				CAST(GL.TRXDATE AS Date) AS EffDate,
				CAST(CASE WHEN GL.ORPSTDDT < ''01/01/1980'' THEN GL.TRXDATE ELSE GL.ORPSTDDT END AS Date) AS TrxDate,
				CASE WHEN GL.ORTRXTYP = 0 OR GL.SERIES = 2 THEN CAST(GL.JRNENTRY AS Varchar) ELSE GL.ORCTRNUM END AS VoucherNum,
				GL.ORDOCNUM AS DOCNUMBER,
				CASE WHEN GL.ORTRXTYP = 0 OR GL.SERIES = 2 THEN ''General Ledger'' ELSE RTRIM(GL.ORMSTRID) + '' - '' + GL.ORMSTRNM END AS Vendor,
				GL.CRDTAMNT,
				GL.DEBITAMT,
				GL.HSTYEAR AS GPYEAR,
				GL.PERIODID,
				GL.ORTRXTYP,
				GL.SERIES,
				CASE WHEN GL.ORTRXTYP = 0 OR GL.SERIES = 2 THEN ''GL''
					 WHEN GL.ORTRXTYP = 5 AND GL.SERIES <> 4 THEN ''GL''
					 WHEN GL.ORTRXTYP = 5 AND GL.SERIES = 4 THEN ''PM''
					 WHEN GL.ORTRXTYP = 1 THEN ''PM''
					 WHEN GL.ORTRXTYP = 3 THEN ''AR''
					 WHEN GL.ORTRXTYP = 4 THEN ''AR''
					 END AS Source,
				PV.ProNumber,
				UPPER(PV.TrailerNumber) AS TrailerNumber,
				UPPER(PV.ChassisNumber) AS ChassisNumber,
				GL.SEQNUMBR
		FROM 	' + RTRIM(@Company) + '.dbo.GL30000 GL
				INNER JOIN ' + RTRIM(@Company) + '.dbo.GL00100 AC ON GL.ACTINDX = AC.ACTINDX
				LEFT JOIN GPCustom.dbo.Purchasing_Vouchers PV ON CASE WHEN GL.ORTRXTYP = 0 THEN CAST(GL.JRNENTRY AS Varchar) ELSE GL.ORCTRNUM END = PV.VoucherNumber AND CASE WHEN GL.ORTRXTYP = 0 THEN ''GL'' WHEN GL.ORTRXTYP = 1 THEN ''AP'' ELSE ''AR'' END = CASE WHEN PV.Source = ''SOP'' THEN ''AR'' ELSE PV.Source END AND PV.CompanyId = ''' + RTRIM(@Company) + '''
		WHERE 	GL.Voided = 0 
				AND GL.TRXDATE BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' '

IF @Product IS NOT Null
BEGIN
	IF PATINDEX('%-%', @Product) > 0
		SET @Query = @Query + ' AND AC.ACTNUMBR_1 BETWEEN ' + LEFT(@Product, PATINDEX('%-%', @Product) - 1) + ''' AND ''' + RIGHT(@Product, LEN(@Product) - PATINDEX('%-%', @Product))
	ELSE
		SET @Query = @Query + ' AND AC.ACTNUMBR_1 IN (' + @Product + ')'
END

IF @Division IS NOT Null
BEGIN
	IF PATINDEX('%-%', @Division) > 0
		SET @Query = @Query + ' AND AC.ACTNUMBR_2 BETWEEN ' + LEFT(@Division, PATINDEX('%-%', @Division) - 1) + ''' AND ''' + RIGHT(@Division, LEN(@Division) - PATINDEX('%-%', @Division))
	ELSE
		SET @Query = @Query + ' AND AC.ACTNUMBR_2 IN (' + @Division + ')'
END

IF @Account IS NOT Null
BEGIN
	IF PATINDEX('%-%', @Account) > 0
		SET @Query = @Query + ' AND AC.ACTNUMBR_3 BETWEEN ' + LEFT(@Account, PATINDEX('%-%', @Account) - 1) + ''' AND ''' + RIGHT(@Account, LEN(@Account) - PATINDEX('%-%', @Account))
	ELSE
		SET @Query = @Query + ' AND AC.ACTNUMBR_3 IN (' + @Account + ')'
END

SET @Query = @Query + ') DAT 
		INNER JOIN GPCustom.dbo.Companies COM ON COM.CompanyId = ''' + RTRIM(@Company) + ''' 
ORDER BY Account, EffDate, VoucherNum'

--PRINT @Query

INSERT INTO @ReportData
EXECUTE(@Query)

SELECT	RD.*,
		AccountBalance = (SELECT SUM(BL.DEBITAMT - BL.CRDTAMNT) FROM @ReportData BL WHERE BL.Account = RD.Account),
		DivisionBalance = (SELECT SUM(BL.DEBITAMT - BL.CRDTAMNT) FROM @ReportData BL WHERE BL.Acct1 = RD.Acct1 AND BL.Acct2 = RD.Acct2),
		ReportBalance = (SELECT SUM(BL.DEBITAMT - BL.CRDTAMNT) FROM @ReportData BL),
		CategoryBalance = ISNULL((SELECT SUM(BL.DEBITAMT - BL.CRDTAMNT) FROM @ReportData BL WHERE BL.Acct2 = RD.Acct2 AND BL.Category = RD.Category), 0),
		DivisionAccounts = (SELECT COUNT(BL.Account) FROM (SELECT DISTINCT Acct1, Acct2, Account FROM @ReportData) BL WHERE BL.Acct1 = RD.Acct1 AND BL.Acct2 = RD.Acct2)
FROM	@ReportData RD
ORDER BY RD.Account, RD.EffDate, RD.VoucherNum