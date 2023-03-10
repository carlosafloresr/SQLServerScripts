USE [CollectIT]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindContainer]    Script Date: 8/10/2022 12:38:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindContainer 'AIS', 'PD-A11471A'
EXECUTE USP_FindContainer 'IMC', 'PDI15332'
EXECUTE USP_FindContainer 'OIS', 'PD-B09239'
*/
ALTER PROCEDURE [dbo].[USP_FindContainer]
	@Company	Varchar(5),
	@InvoiceNo	Varchar(20)
AS
SET NOCOUNT ON

DECLARE @tblData TABLE
		(Container		Varchar(25) Null,
		ProNumber		Varchar(25) Null,
		DeliveryDate	Date Null,
		ConsigneeName	Varchar(30) Null)

SET @InvoiceNo = RTRIM(@InvoiceNo)

IF @InvoiceNo NOT LIKE 'PD%'
BEGIN
	INSERT INTO @tblData
	SELECT	RTRIM(DET.Equipment) + ISNULL(DET.CheckDigit,'') AS Container
			,RTRIM(DET.BillToRef) AS ProNumber
			,DET.DeliveryDate
			,DET.ConsigneeName
	FROM	[findata-intg-ms.imcc.com].Integrations.dbo.FSI_ReceivedDetails DET
			INNER JOIN [findata-intg-ms.imcc.com].Integrations.dbo.FSI_ReceivedHeader HED ON DET.BatchId = HED.BatchId AND HED.Company = @Company
	WHERE	DET.VoucherNumber = @InvoiceNo
END
		
IF @@ROWCOUNT = 0
BEGIN
	IF @InvoiceNo LIKE 'PD%'
	BEGIN
		INSERT INTO @tblData
		SELECT	ISNULL(ChassisNumber, TrailerNumber),
				LEFT(REPLACE(CASE WHEN ISNULL(ProNumber, '') <> '' AND Notes2 IS Null THEN RTRIM(ProNumber)
					 WHEN ISNULL(ProNumber, '') <> '' AND Notes2 IS NOT Null THEN RTRIM(ProNumber) + '/' + RTRIM(REPLACE(REPLACE(Notes2, 'Reference Number', ''), ':', ''))
					 WHEN ISNULL(ProNumber, '') = '' AND Notes1 LIKE 'Pro Number%' AND Notes2 IS Null THEN RTRIM(REPLACE(REPLACE(REPLACE(Notes1, 'Pro Number', ''), 'Reference Number', ''), ':', ''))
					 ELSE ''
				END, ' ', ''), 25),
				FromDate,
				''
		FROM	[GPCustom].[dbo].[SalesInvoices]
		WHERE	CompanyId = @Company
				AND InvoiceNumber = @InvoiceNo
	END

	IF @@ROWCOUNT = 0 AND dbo.AT('-', @InvoiceNo, 1) > 0
	BEGIN
		DECLARE	@Query			Varchar(MAX),
				@Pro			Varchar(15),
				@Div			Varchar(2),
				@CompanyNumber	Varchar(2)

		SELECT	@CompanyNumber = CAST(CompanyNumber AS Varchar(3))
		FROM	GPCustom.dbo.Companies
		WHERE	CompanyId = @Company
		
		SET	@Query = 'SELECT DISTINCT Q.* FROM (SELECT A.tl_code AS Container, (B.div_code || ''-'' || B.pro)::varchar(12) AS ProNumber, A.ddate AS DeliveryDate, B.CnName FROM trk.move A' +
			' INNER JOIN trk.order B ON A.or_no = B.no WHERE '

		SET	@Div	= LEFT(@InvoiceNo, dbo.AT('-', @InvoiceNo, 1) - 1)
		SET	@Pro	= REPLACE(@InvoiceNo, @Div + '-', '')
		SET	@Query	= @Query + 'B.pro = ''' + @Pro + ''' AND B.div_code = ''' + @Div + ''''
		SET	@Query	= @Query + ' AND A.cmpy_no = ' + @CompanyNumber
		SET	@Query	= @Query + ') Q'
		SET	@Query	= N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''' + REPLACE(@Query, '''', '''''') + ''')'
		--PRINT @Query
		INSERT INTO @tblData 
		EXECUTE(@Query)
	END
END

SELECT	*
FROM	@tblData