DECLARE	@AccountNumber	Varchar(20),
		@InvoiceNumber	Varchar(25),
		@Documents		Varchar(3000),
		@Document		Varchar(200),
		@DocumentType	Char(3),
		@Workorder		Varchar(10),
		@Chassis		Varchar(12),
		@Container		Varchar(12),
		@InvoiceDate	Date,
		@ProjectId		Int,
		@Counter		Int,
		@Item			Int = 1

DECLARE	@MissingDocuments TABLE
		(AccountNumber	Varchar(20),
		InvoiceNumber	Varchar(25),
		Document		Varchar(200),
		DocumentType	Char(3),
		ProjectId		Int,
		Workorder		Varchar(10),
		Chassis			Varchar(12),
		Container		Varchar(12),
		InvoiceDate		Date)

DECLARE curDEXAP CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	FRS.AccountNumber, 
		FRS.InvoiceNumber, 
		FRS.Documents,
		107 AS ProjectId,
		Workorder, 
		Chassis, 
		Container, 
		InvoiceDate
FROM	FRS_Integrations FRS
		LEFT JOIN [LENSADEX001\INDEXDATAFILES].FB.dbo.View_DEXDocuments DEX ON DEX.ProjectId = 107 AND FRS.AccountNumber = DEX.Field8 AND FRS.InvoiceNumber = DEX.Field4
WHERE	FRS.IntegrationType = 'AP'
		AND DEX.Field4 IS Null

OPEN curDEXAP
FETCH FROM curDEXAP INTO @AccountNumber, @InvoiceNumber, @Documents, @ProjectId, @Workorder, @Chassis, @Container, @InvoiceDate

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Counter = dbo.OCCURS('|', @Documents)

	WHILE @Item <= @Counter
	BEGIN
		IF @Item = 1
			SET @Document = SUBSTRING(@Documents, 1, dbo.AT('|', @Documents, @Item) - 1)
		ELSE
			SET @Document = SUBSTRING(@Documents, dbo.AT('|', @Documents, @Item - 1) + 1, dbo.AT('|', @Documents, @Item) - dbo.AT('|', @Documents, @Item - 1) - 1)

		SET @DocumentType = SUBSTRING(@Document, dbo.AT('/', @Document, 8) + 1, 3)
		SET @Item = @Item + 1

		INSERT INTO @MissingDocuments 
				(AccountNumber, InvoiceNumber, Document, DocumentType, ProjectId, Workorder, Chassis, Container, InvoiceDate) 
		VALUES 
				(@AccountNumber, @InvoiceNumber, @Document, @DocumentType, @ProjectId, @Workorder, @Chassis, @Container, @InvoiceDate)
	END

	FETCH FROM curDEXAP INTO @AccountNumber, @InvoiceNumber, @Documents, @ProjectId, @Workorder, @Chassis, @Container, @InvoiceDate
END	

CLOSE curDEXAP
DEALLOCATE curDEXAP

DECLARE curFRSDocs CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	FRS.AccountNumber, 
		FRS.InvoiceNumber, 
		FRS.Documents,
		117 AS ProjectId,
		Workorder, 
		Chassis, 
		Container, 
		InvoiceDate
FROM	FRS_Integrations FRS
		LEFT JOIN [LENSADEX001\INDEXDATAFILES].FB.dbo.View_DEXDocuments DEX ON DEX.ProjectId = 117 AND FRS.Workorder = DEX.Field1 AND FRS.InvoiceNumber = DEX.Field6
WHERE	FRS.IntegrationType = 'AP'
		AND DEX.Field1 IS Null

OPEN curFRSDocs
FETCH FROM curFRSDocs INTO @AccountNumber, @InvoiceNumber, @Documents, @ProjectId, @Workorder, @Chassis, @Container, @InvoiceDate

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Counter = dbo.OCCURS('|', @Documents)

	WHILE @Item <= @Counter
	BEGIN
		IF @Item = 1
			SET @Document = SUBSTRING(@Documents, 1, dbo.AT('|', @Documents, @Item) - 1)
		ELSE
			SET @Document = SUBSTRING(@Documents, dbo.AT('|', @Documents, @Item - 1) + 1, dbo.AT('|', @Documents, @Item) - dbo.AT('|', @Documents, @Item - 1) - 1)

		SET @DocumentType = SUBSTRING(@Document, dbo.AT('/', @Document, 8) + 1, 3)
		SET @Item = @Item + 1

		INSERT INTO @MissingDocuments 
				(AccountNumber, InvoiceNumber, Document, DocumentType, ProjectId, Workorder, Chassis, Container, InvoiceDate) 
		VALUES 
				(@AccountNumber, @InvoiceNumber, @Document, @DocumentType, @ProjectId, @Workorder, @Chassis, @Container, @InvoiceDate)
	END

	FETCH FROM curFRSDocs INTO @AccountNumber, @InvoiceNumber, @Documents, @ProjectId, @Workorder, @Chassis, @Container, @InvoiceDate
END	

CLOSE curFRSDocs
DEALLOCATE curFRSDocs

SELECT	*
FROM	@MissingDocuments