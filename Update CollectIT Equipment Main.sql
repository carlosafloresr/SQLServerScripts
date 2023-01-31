SET NOCOUNT ON

DECLARE	@InvoiceId		Int,
		@Company		Varchar(5),
		@ProNumber		Varchar(30),
		@EquipmentNo	Varchar(20),
		@CheckDigit		Char(1),
		@CompanyNumber	Varchar(3),
		@Query			Varchar(Max)

DECLARE @tblData TABLE
		(Container		Varchar(25) Null,
		ProNumber		Varchar(25) Null,
		DeliveryDate	Date Null,
		ConsigneeName	Varchar(30) Null)

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CS_Invoice.InvoiceId
		,RTRIM(CS_Invoice.InvoiceNum) AS ProNumber
		,RTRIM(UF_Invoice.EquipmentNo) AS EquipmentNo
		,CAST(COM.CompanyNumber AS Varchar(3)) AS CompanyNumber,
		COM.CompanyId
FROM	CS_Invoice
		INNER JOIN CS_Enterprise ON CS_Invoice.EnterpriseId = CS_Enterprise.EnterpriseId
		INNER JOIN UF_Invoice ON UF_Invoice.InvoiceId = CS_Invoice.InvoiceId
		INNER JOIN GPCustom.dbo.Companies COM ON CS_Enterprise.EnterpriseNumber = COM.CompanyId
WHERE	LEN(RTRIM(UF_Invoice.EquipmentNo)) = 0
		AND COM.CompanyId = 'AIS'

OPEN curData 
FETCH FROM curData INTO @InvoiceId, @ProNumber, @EquipmentNo, @CompanyNumber, @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblData

	INSERT INTO @tblData
	SELECT	RTRIM(DET.Equipment) + ISNULL(DET.CheckDigit,'') AS Container
			,RTRIM(DET.BillToRef) AS ProNumber
			,DET.DeliveryDate
			,DET.ConsigneeName
	FROM	IntegrationsDB.Integrations.dbo.FSI_ReceivedDetails DET
			INNER JOIN IntegrationsDB.Integrations.dbo.FSI_ReceivedHeader HED ON DET.BatchId = HED.BatchId AND HED.Company = @Company
	WHERE	DET.VoucherNumber = @ProNumber
		
	IF @@ROWCOUNT = 0
	BEGIN
		IF dbo.AT('PD', @ProNumber, 1) > 0
		BEGIN
			INSERT INTO @tblData
			SELECT	ISNULL(ChassisNumber, TrailerNumber),
					ProNumber,
					FromDate,
					Null
			FROM	[GPCustom].[dbo].[SalesInvoices]
			WHERE	CompanyId = @Company
					AND InvoiceNumber = @ProNumber
		END

		IF @@ROWCOUNT = 0 AND dbo.AT('-', @ProNumber, 1) > 0
		BEGIN
			DECLARE	@Pro	Varchar(15),
					@Div	Varchar(2)

			SELECT	@CompanyNumber = CAST(CompanyNumber AS Varchar(3))
			FROM	GPCustom.dbo.Companies
			WHERE	CompanyId = @Company
		
			SET	@Query = 'SELECT DISTINCT Q.* FROM (SELECT A.tl_code AS Container, (B.div_code || ''-'' || B.pro)::varchar(12) AS ProNumber, A.ddate AS DeliveryDate, B.CnName FROM trk.move A' +
				' INNER JOIN trk.order B ON A.or_no = B.no WHERE '

			SET	@Div	= LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1)
			SET	@Pro	= REPLACE(@ProNumber, @Div + '-', '')
			SET	@Query	= @Query + 'B.pro = ''' + @Pro + ''' AND B.div_code = ''' + @Div + ''''
			SET	@Query	= @Query + ' AND A.cmpy_no = ' + @CompanyNumber
			SET	@Query	= @Query + ') Q'
			SET	@Query	= N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''' + REPLACE(@Query, '''', '''''') + ''')'
			
			INSERT INTO @tblData 
			EXECUTE(@Query)
		END
	END
		
	IF (SELECT COUNT(*) FROM @tblData) > 0
	BEGIN
		--PRINT @ProNumber
		SET @EquipmentNo =  (SELECT TOP 1 Container FROM @tblData)

		UPDATE	UF_Invoice
		SET		EquipmentNo = @EquipmentNo
		WHERE	InvoiceId = @InvoiceId
	END

	FETCH FROM curData INTO @InvoiceId, @ProNumber, @EquipmentNo, @CompanyNumber, @Company
END

CLOSE curData
DEALLOCATE curData
