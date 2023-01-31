/*
EXECUTE USP_ExpenseRecovery_MissingFiles
*/
CREATE PROCEDURE USP_ExpenseRecovery_MissingFiles
AS
SELECT	EXR.Company,
		EXR.DocNumber,
		DOC.DocumentFile,
		DOC.DocumentId,
		DOC.FileExists
FROM	ExpenseRecovery EXR
		INNER JOIN LENSASQL002.ILS_Documents.dbo.View_Documents DOC ON EXR.Company = DOC.Company AND EXR.DocNumber = DOC.RecordId AND DOC.FileExists = 0
WHERE	EXR.Vendor LIKE '%Frederick%'