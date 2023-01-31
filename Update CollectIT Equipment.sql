SET NOCOUNT ON

DECLARE	@InvoiceId		Int,
		@ProNumber		Varchar(30),
		@EquipmentNo	Varchar(20),
		@EquipmentNo2	Varchar(20),
		@CheckDigit		Char(1),
		@CompanyNumber	Varchar(3),
		@Query			Varchar(Max)

DECLARE	@tblEquipment	Table (EquipmentNo Varchar(15), CheckDigit Char(1))

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CS_Invoice.InvoiceId
		,RTRIM(CS_Invoice.InvoiceNum) AS ProNumber
		,RTRIM(UF_Invoice.EquipmentNo) AS EquipmentNo
		,CAST(COM.CompanyNumber AS Varchar(3)) AS CompanyNumber
FROM	CS_Invoice
		INNER JOIN CS_Enterprise ON CS_Invoice.EnterpriseId = CS_Enterprise.EnterpriseId
		INNER JOIN UF_Invoice ON UF_Invoice.InvoiceId = CS_Invoice.InvoiceId
		INNER JOIN GPCustom.dbo.Companies COM ON CS_Enterprise.EnterpriseNumber = COM.CompanyId
WHERE	--CS_Invoice.PaymentStatus = 2
		LEN(RTRIM(UF_Invoice.EquipmentNo)) > 11
		--AND CS_Invoice.InvoiceNum IN ('95-143657')

OPEN curData 
FETCH FROM curData INTO @InvoiceId, @ProNumber, @EquipmentNo, @CompanyNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblEquipment
	PRINT @EquipmentNo

	SET @Query = N'SELECT Eq_Code, EqChkDig FROM TRK.Invoice WHERE Cmpy_No = ' + @CompanyNumber + ' AND Code = ''' + RTRIM(@ProNumber) + ''''
	
	INSERT INTO @tblEquipment
	EXECUTE USP_QuerySWS @Query

	SELECT	@EquipmentNo2 = RTRIM(EquipmentNo) + CheckDigit 
	FROM	@tblEquipment
		
	IF @EquipmentNo <> @EquipmentNo2
	BEGIN
		UPDATE	UF_Invoice
		SET		EquipmentNo = @EquipmentNo2
		WHERE	InvoiceId = @InvoiceId
	END

	FETCH FROM curData INTO @InvoiceId, @ProNumber, @EquipmentNo, @CompanyNumber
END

CLOSE curData
DEALLOCATE curData
