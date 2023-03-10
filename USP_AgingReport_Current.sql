USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AgingReport]    Script Date: 3/3/2020 11:37:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AgingReport @Company = 'OIS', @RunDate = '12/01/2019'
EXECUTE USP_AgingReport @Company = 'OIS', @Customer = '21833', @RunDate = '02/25/2020'
*/
ALTER PROCEDURE [dbo].[USP_AgingReport]
	@Company	Varchar(5),
	@Customer	Varchar(20) = Null,
	@RunDate	Date,
	@Summary	Bit = 0
AS
DECLARE	@Query Varchar(MAX)

DECLARE @curData TABLE 
	(Customer		char(15) NOT NULL,
	CustomerName	char(65) NOT NULL,
	DocNumber		char(21) NOT NULL,
	DocDate			datetime NOT NULL,
	DueDate			datetime NOT NULL,
	DocAmount		numeric(20, 2) NOT NULL,
	[Current]		numeric(20, 2) NULL,
	Days31_60		numeric(20, 2) NULL,
	Days61_90		numeric(20, 2) NULL,
	Days91_180		numeric(20, 2) NULL,
	Days180More		numeric(20, 2) NULL,
	Balance			numeric(20, 2) NULL,
	CompanyName		varchar(75) NULL,
	IsSummary		bit NULL)

IF @Customer = ''
	SET @Customer = Null

SET @Query = N'SELECT RTRIM(DATA.CUSTNMBR) AS Customer,
		RTRIM(DATA.CUSTNAME) AS CustomerName,
		RTRIM(DATA.DOCNUMBR) AS DocNumber,
		CAST(DATA.DOCDATE AS Date) AS DocDate,
		CAST(DATA.DUEDATE AS Date) AS DueDate,
		DATA.ORTRXAMT AS DocAmount,
		DATA.[Current],
		DATA.[Days31_60],
		DATA.[Days61_90],
		DATA.[Days91_180],
		DATA.[Days180More],
		DATA.[Current] + DATA.[Days31_60] + DATA.[Days61_90] + DATA.[Days91_180] + DATA.[Days180More] AS Balance,
		CPY.CompanyName,
		0 AS IsSummary
FROM	(
		SELECT	RM2.CUSTNMBR,
				CUS.CUSTNAME,
				RM2.DOCNUMBR,
				RM2.DOCDATE,
				RM2.DUEDATE,
				RM2.ORTRXAMT,
				SUM(CASE WHEN DATEDIFF(dd, RM2.DOCDATE, ''' + CAST(@RunDate AS Varchar) + ''') <= 30 THEN RM2.CURTRXAM ELSE 0 END) AS [Current],
				SUM(CASE WHEN DATEDIFF(dd, RM2.DOCDATE, ''' + CAST(@RunDate AS Varchar) + ''') BETWEEN 31 AND 60 THEN RM2.CURTRXAM ELSE 0 END) AS [Days31_60],
				SUM(CASE WHEN DATEDIFF(dd, RM2.DOCDATE, ''' + CAST(@RunDate AS Varchar) + ''') BETWEEN 61 AND 90 THEN RM2.CURTRXAM ELSE 0 END) AS [Days61_90],
				SUM(CASE WHEN DATEDIFF(dd, RM2.DOCDATE, ''' + CAST(@RunDate AS Varchar) + ''') BETWEEN 91 AND 180 THEN RM2.CURTRXAM ELSE 0 END) AS [Days91_180],
				SUM(CASE WHEN DATEDIFF(dd, RM2.DOCDATE, ''' + CAST(@RunDate AS Varchar) + ''') > 180 THEN RM2.CURTRXAM ELSE 0 END) AS [Days180More]
		FROM	(
					SELECT	CUSTNMBR,
							DOCNUMBR,
							DOCDATE,
							DUEDATE,
							ORTRXAMT,
							ORTRXAMT - ISNULL(BALANCE,0) AS CURTRXAM,
							RMDTYPAL
					FROM	(
							SELECT	HIS.CUSTNMBR,
									HIS.DOCNUMBR,
									HIS.RMDTYPAL,
									HIS.DOCDATE,
									--CASE WHEN HIS.RMDTYPAL > 6 THEN ''' + CAST(@RunDate AS Varchar) + ''' ELSE HIS.DUEDATE END AS DUEDATE,
									CASE WHEN HIS.RMDTYPAL < 6 THEN HIS.DOCDATE ELSE CASE WHEN HIS.DUEDATE < ''01/01/1980'' THEN CASE WHEN DAY.Days = 0 THEN ''' + CAST(@RunDate AS Varchar) + ''' ELSE DATEADD(dd, DAY.Days, HIS.DOCDATE) END ELSE HIS.DUEDATE END END AS DUEDATE,
									HIS.ORTRXAMT * CASE WHEN HIS.RMDTYPAL > 6 THEN -1 ELSE 1 END AS ORTRXAMT,
									HIS.CURTRXAM * CASE WHEN HIS.RMDTYPAL > 6 THEN -1 ELSE 1 END AS CURTRXAM,
									BALANCE = CASE WHEN HIS.RMDTYPAL > 6 THEN -1 ELSE 1 END * (SELECT SUM(HAP.APPTOAMT) FROM ' + RTRIM(@Company) + '.dbo.RM30201 HAP WHERE HAP.CUSTNMBR = HIS.CUSTNMBR AND (HAP.APTODCNM = HIS.DOCNUMBR OR HAP.APFRDCNM = HIS.DOCNUMBR) AND HAP.GLPOSTDT <= ''' + CAST(@RunDate AS Varchar) + ''')
							FROM	' + RTRIM(@Company) + '.dbo.RM30101 HIS
									INNER JOIN (
												SELECT	CUSTNMBR,
														ISNULL(PAYT.DUEDTDS, 0) AS Days
												FROM	' + RTRIM(@Company) + '.dbo.RM00101 CUST
														LEFT JOIN ' + RTRIM(@Company) + '.dbo.SY03300 PAYT ON CUST.PYMTRMID = PAYT.PYMTRMID '
												
												IF @Customer IS NOT Null
													SET @Query = @Query + N'
													WHERE	CUST.CUSTNMBR = ''' + RTRIM(@Customer) + ''' '

												SET @Query = @Query + N') DAY ON HIS.CUSTNMBR = DAY.CUSTNMBR
							WHERE	HIS.VOIDSTTS = 0
									AND HIS.DOCDATE <= ''' + CAST(@RunDate AS Varchar) + ''''
							
							IF @Customer IS NOT Null
								SET @Query = @Query + N'AND HIS.CUSTNMBR = ''' + RTRIM(@Customer) + ''' '

							SET @Query = @Query + N'
							UNION
							SELECT	OPE.CUSTNMBR,
									OPE.DOCNUMBR,
									OPE.RMDTYPAL,
									OPE.DOCDATE,
									--CASE WHEN OPE.RMDTYPAL > 6 THEN ''' + CAST(@RunDate AS Varchar) + ''' ELSE OPE.DUEDATE END AS DUEDATE,
									CASE WHEN OPE.RMDTYPAL < 6 THEN OPE.DOCDATE ELSE CASE WHEN OPE.DUEDATE < ''01/01/1980'' THEN CASE WHEN DAY.Days = 0 THEN ''' + CAST(@RunDate AS Varchar) + ''' ELSE DATEADD(dd, DAY.Days, OPE.DOCDATE) END ELSE OPE.DUEDATE END END AS DUEDATE,
									OPE.ORTRXAMT * CASE WHEN OPE.RMDTYPAL > 6 THEN -1 ELSE 1 END AS ORTRXAMT,
									OPE.CURTRXAM * CASE WHEN OPE.RMDTYPAL > 6 THEN -1 ELSE 1 END AS CURTRXAM,
									BALANCE = CASE WHEN OPE.RMDTYPAL > 6 THEN -1 ELSE 1 END * (SELECT SUM(APPTOAMT) FROM (SELECT HAP.APPTOAMT FROM ' + RTRIM(@Company) + '.dbo.RM30201 HAP WHERE HAP.CUSTNMBR = OPE.CUSTNMBR AND (HAP.APTODCNM = OPE.DOCNUMBR OR HAP.APFRDCNM = OPE.DOCNUMBR) AND HAP.GLPOSTDT <= ''' + CAST(@RunDate AS Varchar) + ''' UNION SELECT OAP.APPTOAMT FROM ' + RTRIM(@Company) + '.dbo.RM20201 OAP WHERE OAP.CUSTNMBR = OPE.CUSTNMBR AND (OAP.APTODCNM = OPE.DOCNUMBR OR OAP.APFRDCNM = OPE.DOCNUMBR) AND OAP.GLPOSTDT <= ''' + CAST(@RunDate AS Varchar) + ''') TMP)
							FROM	' + RTRIM(@Company) + '.dbo.RM20101 OPE
									INNER JOIN (
												SELECT	CUSTNMBR,
														ISNULL(PAYT.DUEDTDS, 0) AS Days
												FROM	' + RTRIM(@Company) + '.dbo.RM00101 CUST
														LEFT JOIN ' + RTRIM(@Company) + '.dbo.SY03300 PAYT ON CUST.PYMTRMID = PAYT.PYMTRMID '
												
												IF @Customer IS NOT Null
													SET @Query = @Query + N'
													WHERE	CUST.CUSTNMBR = ''' + RTRIM(@Customer) + ''' '

												SET @Query = @Query + N') DAY ON OPE.CUSTNMBR = DAY.CUSTNMBR
							WHERE	OPE.VOIDSTTS = 0
									AND OPE.DOCDATE <= ''' + CAST(@RunDate AS Varchar) + ''''
							
							IF @Customer IS NOT Null
								SET @Query = @Query + N'AND OPE.CUSTNMBR = ''' + RTRIM(@Customer) + ''' '

					SET @Query = @Query + N') DATA
					WHERE	ORTRXAMT - ISNULL(BALANCE,0) <> 0
				) RM2
				INNER JOIN ' + RTRIM(@Company) + '.dbo.RM00101 CUS ON RM2.CUSTNMBR = CUS.CUSTNMBR
		GROUP BY
				RM2.CUSTNMBR,
				CUS.CUSTNAME,
				RM2.DOCNUMBR,
				RM2.DOCDATE,
				RM2.DUEDATE,
				RM2.ORTRXAMT,
				RM2.RMDTYPAL
		) DATA
		LEFT JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = ''' + RTRIM(@Company) + '''
ORDER BY
		DATA.CUSTNAME,
		DATA.DUEDATE,
		DATA.DOCNUMBR'
PRINT @Query
INSERT INTO @curData
EXECUTE(@Query)

SELECT	DATA.*,
		DataCounter = (SELECT COUNT(TEMP.Customer) FROM @curData TEMP WHERE TEMP.Customer = DATA.Customer),
		SALI.PortDischargeDate
FROM	@curData DATA
		LEFT JOIN SalesInvoices SALI ON DATA.Customer = SALI.CustomerId AND SALI.CompanyId = @Company AND DATA.DocNumber = SALI.InvoiceNumber
UNION
SELECT	Customer,
		CustomerName,
		MAX(DocNumber) AS DocNumber,
		MIN(DocDate) AS DocDate,
		MIN(DueDate) AS DueDate,
		SUM(DocAmount) AS DocAmount,
		SUM([Current]) AS [Current],
		SUM(Days31_60) AS Days31_60,
		SUM(Days61_90) AS Days61_90,
		SUM(Days91_180) AS Days91_180,
		SUM(Days180More) AS Days180More,
		SUM(Balance) AS Balance,
		CompanyName,
		1 AS IsSummary,
		DataCounter = (SELECT COUNT(TEMP.Customer) FROM @curData TEMP WHERE TEMP.Customer = DATA.Customer),
		Null AS PortDischargeDate
FROM	@curData DATA
GROUP BY
		Customer,
		CustomerName,
		CompanyName
UNION
SELECT	'ZZZZZZ' AS Customer,
		'ZZZZZZ' AS CustomerName,
		Null AS DocNumber,
		Null AS DocDate,
		Null AS DueDate,
		SUM(DocAmount) AS DocAmount,
		SUM([Current]) AS [Current],
		SUM(Days31_60) AS Days31_60,
		SUM(Days61_90) AS Days61_90,
		SUM(Days91_180) AS Days91_180,
		SUM(Days180More) AS Days180More,
		SUM(Balance) AS Balance,
		CompanyName,
		-1 AS IsSummary,
		CASE WHEN @Customer IS Null THEN 1 ELSE 0 END AS DataCounter,
		Null AS PortDischargeDate
FROM	@curData DATA
GROUP BY
		CompanyName
ORDER BY
		Customer,
		CustomerName,
		IsSummary DESC,
		DueDate,
		DocDate,
		DocNumber