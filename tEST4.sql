DECLARE	@ApplicantId	Int,
	@ModuleId	Int

SET	@ApplicantId	= 16
SET 	@ModuleId 	= 1

SELECT 	DISTINCT DHP_Documents.*,
	CASE 
		WHEN LicenseState IS NOT Null THEN LicenseState + ' ' + RTRIM(LicenseNumber) + ' Exp. Date: ' + CONVERT(Char(10), ExpDate, 101)
		WHEN Employer IS NOT Null THEN Employer
	ELSE Null END AS NodeText,
	RTRIM(DHP_ApplicantDocuments.FullPath) + DHP_ApplicantDocuments.FileName AS PDFFile
FROM	DHP_Documents
	LEFT JOIN DHP_ApplicantLicenses ON DHP_Documents.ListLabel = DHP_ApplicantLicenses.LinkString AND Fk_DHP_ApplicantId = @ApplicantId
	LEFT JOIN DHP_WorkHistory ON DHP_Documents.ListLabel = DHP_WorkHistory.LinkString AND Fk_ApplicantId = @ApplicantId
	LEFT JOIN DHP_ApplicantDocuments APP1 ON DHP_Documents.DHP_DocumentId = DHP_ApplicantDocuments.Fk_DHP_DocumentId AND Fk_DHP_ApplicantId = @ApplicantId
WHERE	ModuleId <= @ModuleId