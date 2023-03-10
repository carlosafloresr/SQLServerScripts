/*
EXECUTE USP_FindDocuments 6, 'AIS', '847885'
EXECUTE USP_FindDocuments 7, 'IMC'

SELECT * FROM ILS_Documents.dbo.View_DocumentInput WHERE Fk_DocumentId = 1 ORDER BY DocumentInputId
SELECT * FROM ILS_Documents.dbo.View_Documents WHERE CategoryId = 3

-- TRUNCATE TABLE Documents
*/

CREATE PROCEDURE [dbo].[USP_FindAllRecords]
		@CategoryId	Int,
		@Company	Varchar(5)
AS
SELECT	DISTINCT RecordId
		,RTRIM(RecordText) + ': ' + RecordId AS Description
FROM	View_Documents
WHERE	CategoryId = @CategoryId
		AND Company = @Company