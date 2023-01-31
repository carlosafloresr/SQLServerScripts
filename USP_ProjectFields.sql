/*
EXECUTE FB.dbo.USP_ProjectFields 165
*/
ALTER PROCEDURE USP_ProjectFields
	@ProjectID	Int
AS
SELECT	CAST(FieldNumber AS Int) AS FieldId,
		'Field' + CAST(FieldNumber AS Varchar) AS FieldNumber
		,[FieldName]
		,[Required]
FROM	[FB].[dbo].[FileFields]
WHERE	ProjectID = @ProjectID
ORDER BY 1