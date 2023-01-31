SET NOCOUNT ON

DECLARE @InvoiceNumber	Varchar(20), 
		@Amount			Numeric(10,2),
		@RunType		Char(1) = 'D'

DECLARE @tblData		Table (
		InvoiceNumber	Varchar(20), 
		Amount			Numeric(10,2))

DECLARE @tblRecords		Table (
		BatchId			Varchar(25),
		InvoiceNumber	Varchar(20),
		VendorId		Varchar(12),
		Amount			Numeric(10,2),
		Missing			Numeric(10,2),
		TotalAmount		Numeric(10,2),
		RecordId		Int)

DECLARE @tblFinals		Table (
		BatchId			Varchar(25),
		InvoiceNumber	Varchar(20),
		VendorId		Varchar(12),
		Amount			Numeric(10,2),
		RecordId		Int)

INSERT INTO @tblData VALUES ('57-179953',140)
INSERT INTO @tblData VALUES ('57-181020',137.5)
INSERT INTO @tblData VALUES ('57-181163',140)
INSERT INTO @tblData VALUES ('57-181219',290)
INSERT INTO @tblData VALUES ('57-181418',297.12)
INSERT INTO @tblData VALUES ('57-181606',355)
INSERT INTO @tblData VALUES ('57-182310',125)
INSERT INTO @tblData VALUES ('57-182319',140)
INSERT INTO @tblData VALUES ('57-182320',280)
INSERT INTO @tblData VALUES ('95-101344',490)
INSERT INTO @tblData VALUES ('95-101345',490)
INSERT INTO @tblData VALUES ('95-101346',475)
INSERT INTO @tblData VALUES ('95-101347',295)
INSERT INTO @tblData VALUES ('95-101378',140)
INSERT INTO @tblData VALUES ('95-101403',215)
INSERT INTO @tblData VALUES ('95-101424',125)
INSERT INTO @tblData VALUES ('95-101438',280)
INSERT INTO @tblData VALUES ('95-101441',410)
INSERT INTO @tblData VALUES ('95-101444',312.12)
INSERT INTO @tblData VALUES ('95-101462',140)
INSERT INTO @tblData VALUES ('95-101463',240)
INSERT INTO @tblData VALUES ('95-101465',215)
INSERT INTO @tblData VALUES ('95-101479',352.5)
INSERT INTO @tblData VALUES ('95-101484',90)
INSERT INTO @tblData VALUES ('C57-173335',-25)
INSERT INTO @tblData VALUES ('C95-100650',-175)
INSERT INTO @tblData VALUES ('D57-174009',240)
INSERT INTO @tblData VALUES ('D57-174127',480)
INSERT INTO @tblData VALUES ('D57-174128',420)
INSERT INTO @tblData VALUES ('D57-174134',420)
INSERT INTO @tblData VALUES ('D57-174135',420)
INSERT INTO @tblData VALUES ('D57-174137',420)
INSERT INTO @tblData VALUES ('D57-174149',420)
INSERT INTO @tblData VALUES ('D57-174634',420)
INSERT INTO @tblData VALUES ('D57-174650',210)
INSERT INTO @tblData VALUES ('D57-174663',270)
INSERT INTO @tblData VALUES ('D57-174664',270)
INSERT INTO @tblData VALUES ('D57-174665',300)
INSERT INTO @tblData VALUES ('D57-174879',420)
INSERT INTO @tblData VALUES ('D57-174881',420)
INSERT INTO @tblData VALUES ('D57-174883A',420)
INSERT INTO @tblData VALUES ('D95-101051',54)
INSERT INTO @tblData VALUES ('D95-101119',110)
INSERT INTO @tblData VALUES ('D95-101360',175)

DECLARE curRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	@tblData

OPEN curRecords 
FETCH FROM curRecords INTO @InvoiceNumber, @Amount

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Amount

	INSERT INTO @tblRecords
	SELECT	BatchId,
			InvoiceNumber,
			RecordCode,
			ChargeAmount1,
			@Amount AS MissingAmount,
			TotalAmount = (SELECT SUM(ChargeAmount1) FROM View_Integration_FSI_Full WHERE RecordType = 'VND' AND PrePay = 1 AND ICB_AP = 0 AND InvoiceNumber = @InvoiceNumber),
			FSI_ReceivedSubDetailId
	FROM	View_Integration_FSI_Full
	WHERE	RecordType = 'VND'
			AND PrePay = 1
			AND ICB_AP = 0
			AND InvoiceNumber = @InvoiceNumber

	IF @@ROWCOUNT = 1
		INSERT INTO @tblFinals
		SELECT	BatchId,
				InvoiceNumber,
				VendorId,
				Amount,
				RecordId
		FROM	@tblRecords
	ELSE
		IF EXISTS(SELECT BatchId FROM @tblRecords WHERE Amount = Missing)
			INSERT INTO @tblFinals
			SELECT	BatchId,
					InvoiceNumber,
					VendorId,
					Amount,
					RecordId
			FROM	@tblRecords
			WHERE	Amount = Missing
		ELSE
			IF EXISTS(SELECT BatchId FROM @tblRecords WHERE TotalAmount = Missing)
				INSERT INTO @tblFinals
				SELECT	BatchId,
						InvoiceNumber,
						VendorId,
						Amount,
						RecordId
				FROM	@tblRecords
				WHERE	TotalAmount = Missing
			ELSE
				IF (SELECT COUNT(*) FROM @tblRecords) > 0
					SELECT	BatchId,
							InvoiceNumber,
							VendorId,
							Amount,
							Missing,
							TotalAmount
					FROM	@tblRecords

	DELETE @tblRecords
							    
	FETCH FROM curRecords INTO @InvoiceNumber, @Amount
END

CLOSE curRecords
DEALLOCATE curRecords

IF @RunType = 'I'
BEGIN
	DELETE FSI_PayablesRecords WHERE RecordId IN (SELECT RecordId FROM @tblFinals)
	UPDATE FSI_ReceivedSubDetails SET Processed = 0, Verification = Null WHERE FSI_ReceivedSubDetailId IN (SELECT RecordId FROM @tblFinals)
	UPDATE ReceivedIntegrations SET [Status] = 0 WHERE Integration = 'FSIG' AND BatchId IN (SELECT DISTINCT BatchId FROM @tblFinals)
END
ELSE
BEGIN
	SELECT	*
	FROM	@tblFinals
END
