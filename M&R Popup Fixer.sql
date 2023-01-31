SET NOCOUNT ON

DECLARE @Invoice	Varchar(15),
		@FileId		Int,
		@DocumentId	Int,
		@FileName	Varchar(200),
		@FileScript	Varchar(150)

DECLARE @tblData	Table (
		[MRInvoices_DistributionId] [bigint] NOT NULL,
		[InvoiceNumber]				[varchar](15) NOT NULL,
		[GLAccount]					[varchar](15) NOT NULL,
		[Description]				[varchar](30) NOT NULL,
		[Amount]					[numeric](10, 2) NOT NULL,
		[PopUpId]					[int] NOT NULL,
		[UserId]					[varchar](25) NOT NULL,
		[RepCode]					[varchar](10))

INSERT INTO @tblData
SELECT	DET.*
FROM	MRInvoices_Distribution DET
		INNER JOIN MRInvoices_AP HDR ON DET.InvoiceNumber = HDR.InvoiceNumber
WHERE	--RIGHT(GLACCOUNT, 4) IN ('6302','6309','6629','6609','6619','6618','6612')
		DET.InvoiceNumber IN ('1785842',
'1785843',
'1785844',
'1785850',
'1785852',
'1785856',
'1785859',
'1785880',
'1785905',
'1785907',
'1785914',
'1785917',
'1785924',
'1785928',
'1785930',
'1785934',
'1785935',
'1785956',
'1785971',
'1785973',
'1785990',
'1786002',
'1786005',
'1786010',
'1786012',
'1786017',
'1786052',
'1786116',
'1786120',
'1786123',
'1786126',
'1786152',
'1786156',
'1786158',
'1786200')
		--AND CAST(DET.InvoiceNumber AS Int) > 1785371
		--AND HDR.Accepted = 1
		--AND DET.PopUpId = 0

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT InvoiceNumber
FROM	@tblData

OPEN curData 
FETCH FROM curData INTO @Invoice

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Invoice

	SELECT	@FileId		= FileId,
			@DocumentId	= DocumentID,
			@FileName	= FullFileName
	FROM	LENSASQL003.Fb.dbo.View_DEXDocuments 
	WHERE	ProjectID = 65 
			AND Field8 = '1000331'
			AND Field4 = @Invoice

	SET @FileScript = 'DEL ' + @FileName

	EXECUTE xp_cmdshell @FileScript

	IF @@ERROR = 0
	BEGIN
		DELETE	LENSASQL003.Fb.dbo.ExtendedProperties
		WHERE	ObjectID = @FileId
				AND PropertyKey = 'GL_Code_Entry'

		DELETE	LENSASQL003.Fb.dbo.DocumentRoute
		WHERE	DocumentID = @DocumentId

		DELETE	LENSASQL003.Fb.dbo.Documents
		WHERE	FileID = @FileId

		DELETE	LENSASQL003.Fb.dbo.Files
		WHERE	FileID = @FileId

		EXECUTE USP_InvoiceDetails @Invoice, 1, 1

		UPDATE	MRInvoices_AP 
		SET		Accepted = 0 
		WHERE	InvoiceNumber = @Invoice
	END

	FETCH FROM curData INTO @Invoice
END

CLOSE curData
DEALLOCATE curData

--SELECT	distinct DET.InvoiceNumber
--FROM	MRInvoices_Distribution DET
--		INNER JOIN MRInvoices_AP HDR ON DET.InvoiceNumber = HDR.InvoiceNumber
--WHERE	RIGHT(GLACCOUNT, 4) IN ('6302','6309','6629','6609','6619','6618','6612')
--		AND CAST(DET.InvoiceNumber AS Int) > 1785371
--		AND HDR.Accepted = 0
--		AND DET.PopUpId > 0