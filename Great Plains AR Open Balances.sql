/*
EXECUTE USP_GP_AR_OpenBalances 'AIS', '14000'
EXECUTE USP_GP_AR_OpenBalances 'GIS', ''
*/
ALTER PROCEDURE USP_GP_AR_OpenBalances
		@CompanyId		Varchar(5),
		@CustomerId		Varchar(15)
AS
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@CompanyNumber	Int,
		@CompanyName	Varchar(100),
		@CustomerNumber	Varchar(15),
		@CompanyAlias	Varchar(10),
		@DocumentNumber	Varchar(20),
		@Trailer		Varchar(15),
		@Chassis		Varchar(15),
		@UserId			Varchar(25) = 'NONE'

SELECT	@CompanyNumber	= CompanyNumber,
		@CompanyName	= CompanyName,
		@CompanyAlias	= ISNULL(CompanyAlias, CompanyId)
FROM	GPCustom.dbo.View_CompanyAgents 
WHERE	CompanyId = @CompanyId

DECLARE	@tblSWS			Table (
		ReferenceNum	Varchar(70),
		TrailerNumber	Varchar(25),
		ChassisNumber	Varchar(25))

DECLARE @tblOpenItems	Table (
		CustomerId		Varchar(15),
		CustomerName	Varchar(75),
		NationalId		Varchar(15),
		NationalName	Varchar(75),
		DocumentNumber	Varchar(20),
		DocumentDate	Date,
		DueDate			Date,
		PostDate		Date,
		DocumentAmount	Numeric(10,2),
		Balance			Numeric(10,2),
		Description		Varchar(30),
		Reference		Varchar(70),
		PayTerm			Varchar(20),
		Trailer			Varchar(25),
		Chassis			Varchar(25))

IF @CustomerId <> ''
BEGIN
	SET @Query = N'SELECT RTRIM(OPN.CUSTNMBR) AS CUSTNMBR,
			RTRIM(CTM.CUSTNAME) AS CUSTNAME,
			CASE WHEN OPN.CPRCSTNM = '''' THEN Null ELSE RTRIM(OPN.CPRCSTNM) END AS CPRCSTNM,
			RTRIM(MST.CUSTNAME) AS CPRCSTNAME,
			RTRIM(OPN.DOCNUMBR) AS DOCNUMBR,
			CAST(OPN.DOCDATE AS Date) AS DOCDATE,
			CAST(OPN.DUEDATE AS Date) AS DUEDATE,
			CAST(OPN.POSTDATE AS Date) AS POSTDATE,
			CAST(OPN.ORTRXAMT AS Numeric(10,2)) AS ORTRXAMT,
			CAST(OPN.CURTRXAM AS Numeric(10,2)) AS CURTRXAM,
			OPN.TRXDSCRN,
			ARC.Reference,
			OPN.PYMTRMID,
			ISNULL(ARC.Trailer, SAL.TrailerNumber),
			ISNULL(ARC.Chassis, SAL.ChassisNumber)
	FROM	' + @CompanyId + '.dbo.RM20101 OPN
			INNER JOIN ' + @CompanyId + '.dbo.RM00101 CTM ON OPN.CUSTNMBR = CTM.CUSTNMBR
			LEFT JOIN ' + @CompanyId + '.dbo.RM00101 MST ON OPN.CPRCSTNM = MST.CUSTNMBR
			LEFT JOIN GP_AR_OpenBalances ARC ON ARC.CompanyId = ''' + @CompanyId + ''' AND ARC.CustomerId = OPN.CUSTNMBR AND ARC.DocumentNumber = OPN.DOCNUMBR AND LEFT(OPN.DOCNUMBR, 2) NOT IN (''PD'',''DM'')
			LEFT JOIN SalesInvoices SAL ON SAL.CompanyId = ''' + @CompanyId + ''' AND SAL.CustomerId = OPN.CUSTNMBR AND SAL.InvoiceNumber = OPN.DOCNUMBR AND LEFT(OPN.DOCNUMBR, 2) IN (''PD'',''DM'')
	WHERE	(OPN.CUSTNMBR = ''' + @CustomerId + ''' OR OPN.CPRCSTNM = ''' + @CustomerId + ''') 
			AND OPN.RMDTYPAL < 9
	ORDER BY
			OPN.CUSTNMBR,
			OPN.DOCDATE,
			OPN.DOCNUMBR'

	PRINT @Query

	INSERT INTO @tblOpenItems
	EXECUTE(@Query)

	DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	CustomerId,
			DocumentNumber
	FROM	@tblOpenItems
	WHERE	LEFT(DocumentNumber, 2) NOT IN ('PD','DM')
			AND Trailer IS Null

	OPEN curData 
	FETCH FROM curData INTO @CustomerNumber, @DocumentNumber

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		DELETE @tblSWS

		SET @Query = N'SELECT ORD.CRef, ORD.Trailer_EqMast_Id, ORD.Chassis_EqMast_Id FROM TRK.Invoice INV INNER JOIN TRK.Order ORD ON INV.Or_No = ORD.No WHERE INV.Code = ''' + @DocumentNumber + ''''

		INSERT INTO @tblSWS
		EXECUTE USP_QuerySWS @Query

		IF @@ROWCOUNT > 0
			UPDATE	@tblOpenItems
			SET		Reference	= DATA.ReferenceNum,
					Trailer		= CASE WHEN GPCustom.dbo.AT('-', DATA.TrailerNumber, 6) = 1 THEN '' ELSE REPLACE(SUBSTRING(DATA.TrailerNumber, GPCustom.dbo.AT('-', DATA.TrailerNumber, 5) + 1, 11), '-', '') END,
					Chassis		= CASE WHEN GPCustom.dbo.AT('-', DATA.ChassisNumber, 6) = 1 THEN '' ELSE REPLACE(REPLACE(SUBSTRING(DATA.ChassisNumber, GPCustom.dbo.AT('-', DATA.ChassisNumber, 5) + 1, 11), '-', ''), 'CHASSIS','') END
			FROM	@tblSWS DATA
			WHERE	CustomerId = @CustomerNumber
					AND DocumentNumber = @DocumentNumber

		FETCH FROM curData INTO @CustomerNumber, @DocumentNumber
	END

	CLOSE curData
	DEALLOCATE curData

	DELETE	GP_AR_OpenBalances 
	WHERE	@CompanyId + CustomerId + DocumentNumber NOT IN (SELECT	@CompanyId + CustomerId + DocumentNumber FROM @tblOpenItems)
			AND CompanyId = @CompanyId 
			AND (CustomerId = @CustomerId
			OR NationalId = @CustomerId)

	UPDATE	GP_AR_OpenBalances
	SET		Balance = DATA.Balance
	FROM	@tblOpenItems DATA
	WHERE	GP_AR_OpenBalances.CompanyId = @CompanyId 
			AND GP_AR_OpenBalances.CustomerId = DATA.CustomerId 
			AND GP_AR_OpenBalances.DocumentNumber = DATA.DocumentNumber

	INSERT INTO dbo.GP_AR_OpenBalances
			([Company]
			,[CompanyName]
			,[CustomerId]
			,[CustomerName]
			,[NationalId]
			,[NationalName]
			,[DocumentNumber]
			,[DocumentDate]
			,[DueDate]
			,[PostDate]
			,[DocumentAmount]
			,[Balance]
			,[Description]
			,[Reference]
			,[PayTerm]
			,[Trailer]
			,[Chassis]
			,[CompanyId]
			,[UserId])
	SELECT	@CompanyAlias AS Company,
			@CompanyName AS CompanyName,
			CustomerId,
			CustomerName,
			NationalId,
			NationalName,
			DocumentNumber,
			DocumentDate,
			DueDate,
			PostDate,
			DocumentAmount,
			Balance,
			Description,
			Reference,
			PayTerm,
			Trailer,
			Chassis,
			@CompanyId AS CompanyId,
			@UserId as UserId
	FROM	@tblOpenItems
	WHERE	@CompanyId + CustomerId + DocumentNumber NOT IN (SELECT	CompanyId + CustomerId + DocumentNumber 
															FROM	GP_AR_OpenBalances 
															WHERE	CompanyId = @CompanyId 
																	AND (CustomerId = @CustomerId
																	OR NationalId = @CustomerId))
END

EXECUTE USP_GP_AR_OpenBalances_Result @CompanyId, @CustomerId
