SET NOCOUNT ON

DECLARE	@Company			Varchar(5) = 'AIS',
		@RecordId			Varchar(30) = 'EXPRPT071622',
		@DocumentsPath		Varchar(100),
		@CategoryId			Int = 6,
		@DocumentId			Int = 0,
		@Fk_DocumentTypeId	Int = 22,
		@DocumentFile		Varchar(400),
		@FilePath			Varchar(200),
		@DocFileName		Varchar(400),
		@JustFileName		Varchar(400),
		@Notes				Varchar(500) = Null,
		@CreatedBy			Varchar(25) = 'Automation', 
		@CmdString			Varchar(3000),
		@DEXFileName		Varchar(400),
		@DoesExists			Bit

SELECT	@DocumentsPath = RTRIM(VarC)
FROM	Parameters
WHERE	ParameterCode = 'DOCSLOCATION'

SELECT	DISTINCT EXR.Company,
		EXR.DocNumber,
		EXR.Vendor,
		EXR.Amount,
		DEX.ProjectId,
		EXR.VendorId,
		VDX.Field8,
		VDX.FullFileName,
		@DocumentsPath + 'CAT' + CAST(@CategoryId AS Varchar) + '\' + RTRIM(EXR.DocNumber) AS FilePath,
		@DocumentsPath + 'CAT' + CAST(@CategoryId AS Varchar) + '\' + RTRIM(EXR.DocNumber) + '\' + CAST(@CategoryId AS Varchar) + '_' + RTRIM(EXR.Company) + '_' + RTRIM(EXR.DocNumber) + '_' + dbo.FormatDateYMD(GETDATE(), 1, 1, 1) + '_' + CAST(22 AS Varchar) + RIGHT(RTRIM(VDX.FullFileName), 4) AS FileLocation,
		VDX.DocumentId AS DEXFileName
INTO	#tmpData
FROM	View_ExpenseRecovery EXR
		INNER JOIN DexCompanyProjects DEX ON EXR.Company = DEX.Company AND DEX.ProjectType = 'AP'
		LEFT JOIN PRIFBSQL01P.FB.dbo.View_DEXDocuments VDX ON DEX.ProjectId = VDX.ProjectId AND EXR.DocNumber = VDX.Field4 AND EXR.VendorId = VDX.Field8
WHERE	EXR.VoucherNo LIKE 'IDV%'
		--AND EXR.Attachments = 0
		AND EXR.EffDate > DATEADD(dd, -90, GETDATE())
		AND VDX.FullFileName IS NOT Null
		AND (@RecordId IS Null
		OR (EXR.DocNumber IS NOT Null AND EXR.DocNumber = @RecordId AND EXR.Company = @Company))

DECLARE curDocuments CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		RTRIM(DocNumber) AS DocNumber,
		FileLocation,
		FilePath,
		DEXFileName,
		FullFileName
FROM	#tmpData

OPEN curDocuments 
FETCH FROM curDocuments INTO @Company, @RecordId, @DocumentFile, @FilePath, @JustFileName, @DEXFileName

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @DocFileName = CAST(@CategoryId AS Varchar) + '_' + RTRIM(@Company) + '_' + @RecordId + '_' + dbo.FormatDateYMD(GETDATE(), 1, 1, 1) + '_' + CAST(@Fk_DocumentTypeId AS Varchar) + RIGHT(@DocumentFile, 4)
	SET @CmdString = 'COPY ' + @DEXFileName + ' ' + @DocumentFile + ' /y'

	IF dbo.CheckIfFileExists(@DocFileName) = 0
	BEGIN
		EXECUTE dbo.USP_CheckIfDirectoryExists @FilePath, @DoesExists OUT

		IF @DoesExists = 0
			EXECUTE Master.dbo.xp_create_subdir @FilePath
	
		EXECUTE Master.dbo.XP_CmdShell @CmdString
		print @CmdString
		IF @@ERROR = 0
		BEGIN
			--PRINT 'Record Id: ' + @RecordId + ' for Document ' + @JustFileName

			DELETE	[ACCTSRVCS-OLTP-MS.IMCC.COM].ILS_Documents.dbo.Documents 
			WHERE	Fk_DocumentTypeId = @Fk_DocumentTypeId 
					AND Company = @Company
					AND RecordId = @RecordId
					AND DocumentFile = @JustFileName

			EXECUTE [ACCTSRVCS-OLTP-MS.IMCC.COM].ILS_Documents.dbo.USP_Documents @DocumentId, @Fk_DocumentTypeId, @Company, @RecordId, @DocFileName, Null, Null, @CreatedBy
		END
	END

	FETCH FROM curDocuments INTO @Company, @RecordId, @DocumentFile, @FilePath, @JustFileName, @DEXFileName
END

CLOSE curDocuments
DEALLOCATE curDocuments

DROP TABLE #tmpData