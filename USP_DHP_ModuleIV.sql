ALTER PROCEDURE USP_DHP_ModuleIV (@ApplicantId Int)
AS
SELECT 	WH.*,
	DO.DHP_DocumentId,
	DO.Description,
	DO.Code,
	AD.Response
FROM 	DHP_WorkHistory WH
	LEFT JOIN DHP_ApplicantDocuments AD ON WH.Fk_ApplicantId = AD.Fk_ApplicantId AND RTRIM(CAST(WH.DHP_WorkHistoryId AS Char(10))) = RTRIM(AD.SelectedItem) AND AD.Fk_DHP_DocumentId IN (5,10,11)
	LEFT JOIN DHP_Documents DO ON AD.Fk_DHP_DocumentId = DO.DHP_DocumentId
WHERE 	WH.Fk_ApplicantId = @ApplicantId
ORDER BY 
	WH.EntryId,
	DO.DHP_DocumentId

execute USP_DHP_ModuleIII 16