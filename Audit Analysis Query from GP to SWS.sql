IF EXISTS(SELECT object_id FROM tempdb.sys.objects WHERE name like '#tmpInvoices%')
	DROP TABLE #tmpInvoices

IF EXISTS(SELECT object_id FROM tempdb.sys.objects WHERE name like '#tmpSWS%')
	DROP TABLE ##tmpSWS

SELECT	RTRIM(CUSTNMBR) AS CustomerNo,
		RTRIM(DOCNUMBR) AS DocumentNo,
		DOCDATE AS DocumentDate,
		CAST(ORTRXAMT AS Numeric(10,2)) AS PaidAmount,
		CAST(0 AS Numeric(10,2)) AS Freight,
		CAST(0 AS Numeric(10,2)) AS Fuel,
		CAST(0 AS Numeric(10,2)) AS Accessorial,
		CAST(0 AS Numeric(10,2)) AS SWS_Total,
		CAST(0 AS Numeric(10,2)) AS [Difference],
		CAST(Null AS Varchar(10)) AS Source_LPCode,
		CAST(Null AS Varchar(10)) AS Destination_LPCode,
		CAST(Null AS Varchar(10)) AS RateTable,
		CAST(0 AS Bit) AS IsEDI,
		CAST('' AS Varchar(250)) AS Accs_Codes
INTO	#tmpInvoices
FROM	(
		SELECT	CUSTNMBR,
				DOCNUMBR,
				DOCDATE,
				ORTRXAMT
		FROM	IMC.dbo.RM20101
		WHERE	RMDTYPAL = 1
				AND DOCDATE > GETDATE() - 60
				AND ORTRXAMT = CURTRXAM
				AND LEFT(DOCNUMBR, 1) NOT IN ('C', 'D', 'S')
				AND dbo.AT('-', DOCNUMBR, 1) IN (1,2,3)
				AND dbo.AT('-', DOCNUMBR, 2) = 0
				AND LEFT(CUSTNMBR, 2) <> 'PD'
		UNION
		SELECT	CUSTNMBR,
				DOCNUMBR,
				DOCDATE,
				ORTRXAMT
		FROM	IMC.dbo.RM30101
		WHERE	RMDTYPAL = 1
				AND DOCDATE > GETDATE() - 60
				AND ORTRXAMT = CURTRXAM
				AND LEFT(DOCNUMBR, 1) NOT IN ('C', 'D', 'S')
				AND dbo.AT('-', DOCNUMBR, 1) IN (2,3)
				AND dbo.AT('-', DOCNUMBR, 2) = 0
				AND LEFT(CUSTNMBR, 2) <> 'PD'
		) DATA
--WHERE	CUSTNMBR = 'E119D'
ORDER BY CUSTNMBR, DOCDATE, DOCNUMBR

DECLARE	@Company		Varchar(3) = '1',
		@CustomerNo		Varchar(15),
		@DocumentAmount	Numeric(10,2),
		@Division		Varchar(2),
		@ProNumber		Varchar(12),
		@Pro			Varchar(10),
		@Query			Varchar(2000),
		@Accessorials	Numeric(10,2),
		@OrderNo		Int,
		@Concepts		Varchar(250) = '',
		@Code			Varchar(15),
		@Description	Varchar(40),
		@Total			Numeric(10,2)

DECLARE	@Order TABLE (Code Varchar(10), [Description] Varchar(250), Total Numeric(10,2))

DECLARE Invoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT CustomerNo,
		PaidAmount,
		DocumentNo,
		dbo.PADL(LEFT(DocumentNo, dbo.AT('-', DocumentNo, 1) - 1), 2, '0') AS Division,
		REPLACE(DocumentNo, LEFT(DocumentNo, dbo.AT('-', DocumentNo, 1)), '') AS Pro
FROM	#tmpInvoices

OPEN Invoices 
FETCH FROM Invoices INTO @CustomerNo, @DocumentAmount, @ProNumber, @Division, @Pro

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT totchg AS charge, ratetbl AS rate, Shlp_code AS source, Cnlp_code AS destination, E204_No AS EdiNumber, AccChg, FrtChg, FscAmt, No FROM TRK.Order WHERE Cmpy_No = ''1'' AND Div_Code = ''' + RTRIM(@Division) + ''' AND Pro = ''' + @Pro + ''''
	EXECUTE USP_QuerySWS @Query, '##tmpSWS'

	SELECT	@Accessorials	= AccChg,
			@OrderNo		= [No]
	FROM	##tmpSWS

	IF @Accessorials <> 0
	BEGIN
		SET	@Query = N'SELECT T300_Code, Description, Total FROM TRK.OrChrg WHERE Cmpy_No = ''' + @Company + ''' AND Or_No = ' + CAST(@OrderNo AS Varchar) + ' AND Total <> 0 ORDER BY Seq'
		
		DELETE @Order
		INSERT INTO @Order (Code, [Description], Total)
		EXECUTE USP_QuerySWS @Query

		DECLARE Accessorials CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	Code,
				[Description],
				Total
		FROM	@Order

		OPEN Accessorials 
		FETCH FROM Accessorials INTO @Code, @Description, @Total

		SET @Concepts = ''

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			SET @Concepts = @Concepts + CASE WHEN @Concepts = '' THEN '' ELSE '/' END + REPLACE(RTRIM(@Code) + '-' + RTRIM(LEFT(@Description, 12)) + ':$' + CAST(@Total AS Varchar), '-:', ':')

			FETCH FROM Accessorials INTO @Code, @Description, @Total
		END

		CLOSE Accessorials
		DEALLOCATE Accessorials
	END
	ELSE
		SET @Concepts = ''

	UPDATE	#tmpInvoices
	SET		SWS_Total			= DATA.Charge,
			Freight				= DATA.FrtChg,
			Fuel				= DATA.FscAmt,
			Accessorial			= DATA.AccChg,
			[Difference]		= DATA.Charge - @DocumentAmount,
			Source_LPCode		= DATA.Source,
			Destination_LPCode	= DATA.Destination,
			IsEDI				= CASE WHEN DATA.EdiNumber > 0 THEN 1 ELSE 0 END,
			RateTable			= DATA.Rate,
			Accs_Codes			= @Concepts
	FROM	(SELECT	* FROM ##tmpSWS) DATA
	WHERE	CustomerNo		= @CustomerNo
			AND DocumentNo	= @ProNumber

	DROP TABLE ##tmpSWS

	FETCH FROM Invoices INTO @CustomerNo, @DocumentAmount, @ProNumber, @Division, @Pro
END

CLOSE Invoices
DEALLOCATE Invoices

SELECT	CustomerNo,
		DocumentNo,
		DocumentDate,
		PaidAmount,
		Freight,
		Fuel,
		Accessorial,
		SWS_Total,
		[Difference],
		Source_LPCode,
		Destination_LPCode,
		RateTable,
		Accs_Codes
FROM	#tmpInvoices
WHERE	IsEDI = 0

DROP TABLE #tmpInvoices

-- SELECT * FROM IMC.dbo.RM20101 WHERE DOCNUMBR = '4770CH-0110'

--SELECT	*
--FROM	IMC.dbo.RM20101
--WHERE	DOCNUMBR = '13-107608'