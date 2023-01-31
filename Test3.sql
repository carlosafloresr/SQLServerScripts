DECLARE	@ApplicantId	Int,
	@ModuleId	Int

SET	@ApplicantId	= 16
SET 	@ModuleId 	= 1

SELECT	DHP_Documents.DHP_DocumentId AS DocumentId,
		DHP_Documents.ModuleId,
		DHP_ApplicantDocuments.Fk_ApplicantId AS DHP_ApplicantId,
		DHP_ApplicantDocuments.DHP_ApplicantDocumentId AS ApplicantDocumentId,
		View_DHP_Applicants.FullName,
		DHP_Documents.Code AS ShortName, 
		DHP_Documents.Description, 
		DHP_Documents.DisplayText, 
		DHP_Documents.ScannerRequired, 
		DHP_Documents.ListValues, 
		DHP_Documents.ControlType, 
		DHP_Documents.Inactive,
		DHP_ApplicantDocuments.FileName,
		DHP_ApplicantDocuments.FullPath,
		RTRIM(DHP_ApplicantDocuments.FullPath) + DHP_ApplicantDocuments.FileName AS PDFFile,
		DHP_ApplicantDocuments.Notes,
		ISNULL(DHP_ApplicantDocuments.Response, '') AS Answer,
		DHP_Documents.SaveField1, 
		DHP_Documents.SaveField2, 
		DHP_Documents.ListQuery,
		DHP_Documents.ListLabel,
		DHP_Documents.InPolicyLimits,
		--NodeText,
		DHP_Documents.DocumentSort,
		DHP_ApplicantDocuments.SelectedItem,
		DHP_Documents.DriverType 
	FROM	View_DHP_Documents_Linked DHP_Documents
		LEFT JOIN View_DHP_Applicants ON View_DHP_Applicants.DHP_ApplicantId = @ApplicantId
		INNER JOIN DHP_ApplicantDocuments ON DHP_Documents.DHP_DocumentId = DHP_ApplicantDocuments.Fk_DHP_DocumentId AND DHP_ApplicantDocuments.Fk_ApplicantId = @ApplicantId
	WHERE	ModuleId <= @ModuleId
	ORDER BY DocumentSort