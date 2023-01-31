SET NOCOUNT ON

DECLARE	@DocumentsPath		Varchar(100),
		@CategoryId			Int = 6,
		@DocumentId			Int = 0,
		@Fk_DocumentTypeId	Int = 22,
		@Company			Varchar(5),
		@RecordId			Varchar(15),
		@DocumentFile		Varchar(50),
		@DocFileName		Varchar(50),
		@DocDirectory		Varchar(50),
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
		DEX.ProjectId, 
		EXR.VendorId,
		VDX.Field8,
		VDX.FullFileName
INTO	#tmpData
FROM	View_ExpenseRecovery EXR
		INNER JOIN DexCompanyProjects DEX ON EXR.Company = DEX.Company AND DEX.ProjectType = 'AP'
		LEFT JOIN PRIFBSQL01P.FB.dbo.View_DEXDocuments VDX ON DEX.ProjectId = VDX.ProjectId AND EXR.DocNumber = VDX.Field4 AND EXR.VendorId = VDX.Field8
WHERE	EXR.VoucherNo LIKE 'IDV%'
		AND EXR.Attachments = 0
		AND EXR.EffDate > DATEADD(dd, -30, GETDATE())
		AND VDX.FullFileName IS NOT Null

DECLARE curDocuments CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		RTRIM(DocNumber) AS DocNumber,
		FullFileName
FROM	#tmpData

OPEN curDocuments 
FETCH FROM curDocuments INTO @Company, @RecordId, @DocumentFile

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF dbo.CheckIfFileExists(@DocumentFile) = 1
	BEGIN
		SET @DocFileName = CAST(@CategoryId AS Varchar) + '_' + RTRIM(@Company) + '_' + @RecordId + '_' + dbo.FormatDateYMD(GETDATE(), 1, 1, 1) + '_' + CAST(@Fk_DocumentTypeId AS Varchar) + RIGHT(@DocumentFile, 4)
		SET @DocDirectory = @DocumentsPath + 'CAT6\' + @Company + '\' + RTRIM(@RecordId) + '\'
		SET @CmdString = 'COPY ' + @DocumentFile + ' ' + @DocDirectory + @DocFileName + ' /y'

		EXECUTE master.sys.xp_create_subdir @DocDirectory
	
		PRINT @CmdString

		EXECUTE Master.dbo.XP_CmdShell @CmdString

		IF @@ERROR = 0
			EXECUTE LENSASQL002.ILS_Documents.dbo.USP_Documents @DocumentId, @Fk_DocumentTypeId, @Company, @RecordId, @DocFileName, Null, Null, @CreatedBy
	END
	ELSE
		PRINT 'Not Found: ' + @DocumentFile + ' for Company ' + @Company + ' and Document ' + @RecordId

	FETCH FROM curDocuments INTO @Company, @RecordId, @DocumentFile
END

CLOSE curDocuments
DEALLOCATE curDocuments

/*
SELECT	*
FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments
WHERE	ProjectId = 61
		AND Field4 = '3438'
*/

DROP TABLE #tmpData