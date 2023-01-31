DECLARE	@DocumentId	Int,
		@DocFile	Varchar(150)

DECLARE @tblDocuments Table
		(Company	Varchar(6),
		DocNumber	Varchar(50),
		DocFile		Varchar(150),
		DocumentId	Int,
		FileExists	Bit)

INSERT INTO @tblDocuments
SELECT	EXR.Company,
		EXR.DocNumber,
		DOC.DocumentFile,
		DOC.DocumentId,
		DOC.FileExists
FROM	LENSASQL001.GPCustom.dbo.ExpenseRecovery EXR
		INNER JOIN View_Documents DOC ON EXR.Company = DOC.Company AND EXR.DocNumber = DOC.RecordId AND DOC.FileExists = 0
WHERE	EXR.Vendor LIKE '%Frederick%'

DECLARE curDocuments CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DocumentId,
		DocFile
FROM	@tblDocuments

OPEN curDocuments 
FETCH FROM curDocuments INTO @DocumentId, @DocFile

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF dbo.CheckIfFileExists(@DocFile) > 0
	BEGIN
		UPDATE	@tblDocuments
		SET		FileExists = 1
		WHERE	DocumentId = @DocumentId

		UPDATE	Documents
		SET		FileExists = 1
		WHERE	DocumentId = @DocumentId
	END

	FETCH FROM curDocuments INTO @DocumentId, @DocFile
END

CLOSE curDocuments
DEALLOCATE curDocuments

SELECT	*
FROM	@tblDocuments
