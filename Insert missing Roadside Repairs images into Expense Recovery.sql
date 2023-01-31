DECLARE	@DocumentsPath		Varchar(100),
		@CategoryId			Int = 6,
		@DocumentId			Int = 0,
		@Fk_DocumentTypeId	Int = 22,
		@Company			Varchar(5),
		@RecordId			Varchar(15),
		@DocumentFile		Varchar(50),
		@DocFileName		Varchar(50),
		@Notes				Varchar(500) = Null,
		@CreatedBy			Varchar(25) = 'Automation',
		@CmdString			Varchar(1000)

SELECT	@DocumentsPath = RTRIM(VarC)
FROM	Parameters
WHERE	ParameterCode = 'DOCSLOCATION'

SELECT	EXR.ExpenseRecoveryId,
		EXR.Company,
		EXR.DocNumber,
		EXR.Vendor,
		EXR.Amount,
		109 AS ProjectId,
		RTRIM(CASE WHEN LEN(RTRIM(EXR.VendorId)) > 12 THEN LEFT(EXR.VendorId, dbo.AT('-', EXR.VendorId, 1) - 1) ELSE EXR.VendorId END) AS VendorId,
		VDX.Field2,
		VDX.FullFileName
INTO	#tmpData
FROM	View_ExpenseRecovery EXR
		INNER JOIN View_RSA_Invoices2 RSR ON EXR.Company = RSR.Company AND EXR.DocNumber = RSR.InvoiceNumber
		LEFT JOIN LENSASQL003.FB.dbo.View_DEXDocuments VDX ON VDX.ProjectId = 109 AND CAST(RSR.RepairNumber AS Varchar) = VDX.Field1
WHERE	EXR.Attachments = 0
		AND EXR.EffDate > DATEADD(dd, -60, GETDATE())

DECLARE curDocuments CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		RTRIM(DocNumber) AS DocNumber,
		FullFileName,
		CASE Field2 WHEN 'INV' THEN 22 WHEN 'PINV' THEN 23 ELSE 24 END AS DocumentTypeId
FROM	#tmpData

OPEN curDocuments 
FETCH FROM curDocuments INTO @Company, @RecordId, @DocumentFile, @Fk_DocumentTypeId

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @DocFileName = CAST(@CategoryId AS Varchar) + '_' + RTRIM(@Company) + '_' + @RecordId + '_' + dbo.FormatDateYMD(GETDATE(), 1, 1, 1) + '_' + CAST(@Fk_DocumentTypeId AS Varchar) + RIGHT(@DocumentFile, 4)
	SET @CmdString = 'COPY ' + @DocumentFile + ' ' + @DocumentsPath + @DocFileName + ' /y'
	
	EXECUTE Master.dbo.XP_CmdShell @CmdString

	IF @@ERROR = 0
		EXECUTE LENSASQL002.ILS_Documents.dbo.USP_Documents @DocumentId, @Fk_DocumentTypeId, @Company, @RecordId, @DocFileName, Null, Null, @CreatedBy

	FETCH FROM curDocuments INTO @Company, @RecordId, @DocumentFile, @Fk_DocumentTypeId
END

CLOSE curDocuments
DEALLOCATE curDocuments

DROP TABLE #tmpData