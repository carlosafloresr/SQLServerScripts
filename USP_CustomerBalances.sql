USE [GPCustom]
GO
/*
EXECUTE USP_CustomerBalances @Company = 'GSA'
EXECUTE USP_CustomerBalances @Company = 'GSA', @Customer = '20009', @Summary = 1
EXECUTE USP_CustomerBalances @Company = 'IMC', @Summary = 1, @SortByName = 1
EXECUTE USP_CustomerBalances @Company = 'IMC', @Customer = '4392', @Summary = 1
*/
ALTER PROCEDURE [dbo].[USP_CustomerBalances]
		@Company	Varchar(5),
		@Customer	Varchar(20) = Null,
		@Summary	Bit = 0,
		@SortByName	Bit = 1
AS
DECLARE	@Query		Varchar(MAX),
		@RunDate	Date = GETDATE()

DECLARE @curData TABLE 
		(Customer		char(15) NOT NULL,
		CustomerName	char(65) NOT NULL,
		DocNumber		char(21) NOT NULL,
		DocDate			datetime NOT NULL,
		DueDate			datetime NULL,
		DocAmount		numeric(20, 2) NOT NULL,
		[Current]		numeric(20, 2) NULL,
		Days31_60		numeric(20, 2) NULL,
		Days61_90		numeric(20, 2) NULL,
		Days91_180		numeric(20, 2) NULL,
		Days180More		numeric(20, 2) NULL,
		Balance			numeric(20, 2) NULL,
		CompanyName		varchar(75) NULL,
		TransType		Varchar(5) NULL,
		TransTypeId		Int,
		IsSummary		bit NULL)

IF @Customer = ''
	SET @Customer = Null

SET @Query = N'SELECT DATA.CUSTNMBR AS Customer,
		DATA.CUSTNAME AS CustomerName,
		DATA.DOCNUMBR AS DocNumber,
		DATA.DOCDATE AS DocDate,
		DATA.DUEDATE AS DueDate,
		DATA.ORTRXAMT AS DocAmount,
		DATA.[Current],
		DATA.[Days31_60],
		DATA.[Days61_90],
		DATA.[Days91_180],
		DATA.[Days180More],
		DATA.[Current] + DATA.[Days31_60] + DATA.[Days61_90] + DATA.[Days91_180] + DATA.[Days180More] AS Balance,
		CPY.CompanyName,
		DATA.TransType,
		DATA.RMDTYPAL,
		0 AS IsSummary
FROM	(
		SELECT	RTRIM(RM2.CUSTNMBR) AS CUSTNMBR,
				CUS.CUSTNAME,
				RTRIM(RM2.DOCNUMBR) AS DOCNUMBR,
				RM2.DOCDATE,
				RM2.DUEDATE,
				RM2.ORTRXAMT,
				SUM(CASE WHEN DATEDIFF(dd, RM2.DUEDATE, ''' + CAST(@RunDate AS Varchar) + ''') <= 30 THEN RM2.CURTRXAM ELSE 0 END) AS [Current],
				SUM(CASE WHEN DATEDIFF(dd, RM2.DUEDATE, ''' + CAST(@RunDate AS Varchar) + ''') BETWEEN 31 AND 60 THEN RM2.CURTRXAM ELSE 0 END) AS [Days31_60],
				SUM(CASE WHEN DATEDIFF(dd, RM2.DUEDATE, ''' + CAST(@RunDate AS Varchar) + ''') BETWEEN 61 AND 90 THEN RM2.CURTRXAM ELSE 0 END) AS [Days61_90],
				SUM(CASE WHEN DATEDIFF(dd, RM2.DUEDATE, ''' + CAST(@RunDate AS Varchar) + ''') BETWEEN 91 AND 180 THEN RM2.CURTRXAM ELSE 0 END) AS [Days91_180],
				SUM(CASE WHEN DATEDIFF(dd, RM2.DUEDATE, ''' + CAST(@RunDate AS Varchar) + ''') > 180 THEN RM2.CURTRXAM ELSE 0 END) AS [Days180More],
				CASE RM2.RMDTYPAL
					 WHEN 1 THEN ''SLS''
					 WHEN 7 THEN ''CRD''
					 WHEN 9 THEN ''PMT''
					 ELSE CAST(RM2.RMDTYPAL AS Varchar) END AS TransType,
				RM2.RMDTYPAL
		FROM	(
					SELECT	CUSTNMBR,
							DOCNUMBR,
							DOCDATE,
							DUEDATE,
							ORTRXAMT,
							CURTRXAM,
							RMDTYPAL
					FROM	(
							SELECT	OPE.CUSTNMBR,
									OPE.DOCNUMBR,
									OPE.RMDTYPAL,
									OPE.DOCDATE,
									CASE WHEN OPE.RMDTYPAL < 6 THEN OPE.DOCDATE ELSE CASE WHEN OPE.DUEDATE < ''01/01/1980'' THEN CASE WHEN DAY.Days = 0 THEN ''' + CAST(@RunDate AS Varchar) + ''' ELSE DATEADD(dd, DAY.Days, OPE.DOCDATE) END ELSE OPE.DUEDATE END END AS DUEDATE,
									OPE.ORTRXAMT * CASE WHEN OPE.RMDTYPAL > 6 THEN -1 ELSE 1 END AS ORTRXAMT,
									OPE.CURTRXAM * CASE WHEN OPE.RMDTYPAL > 6 THEN -1 ELSE 1 END AS CURTRXAM,
									BALANCE = OPE.CURTRXAM
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
									AND OPE.CURTRXAM <> 0 '
							
							IF @Customer IS NOT Null
								SET @Query = @Query + N'
								AND OPE.CUSTNMBR = ''' + RTRIM(@Customer) + ''' '

					SET @Query = @Query + N') DATA
					WHERE	ISNULL(BALANCE,0) <> 0
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

SELECT	*
INTO	#tmpARData
FROM	(
		SELECT	DATA.*,
				DataCounter = (SELECT COUNT(TEMP.Customer) FROM @curData TEMP WHERE TEMP.Customer = DATA.Customer)
		FROM	@curData DATA
		WHERE	@Summary = 0
		UNION
		SELECT	Customer,
				CustomerName,
				'CUSTOMER_SUMMARY' AS DocNumber,
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
				'SUM' AS TransType,
				20 AS TransTypeId,
				1 AS IsSummary,
				DataCounter = (SELECT COUNT(TEMP.Customer) FROM @curData TEMP WHERE TEMP.Customer = DATA.Customer)
		FROM	@curData DATA
		WHERE	@Summary = 1
		GROUP BY
				Customer,
				CustomerName,
				CompanyName
		) DATA

IF @SortByName = 1
BEGIN
	-- Sort by Customer Name
	SELECT	*
	FROM	#tmpARData
	ORDER BY
			CustomerName,
			IsSummary,
			TransTypeId,
			DocDate,
			DocNumber
END
ELSE
BEGIN
	-- Sort by Customer Number
	SELECT	*
	FROM	#tmpARData
	ORDER BY
			Customer,
			IsSummary,
			TransTypeId,
			DocDate,
			DocNumber
END

DROP TABLE #tmpARData