USE [ILS_Documents]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDocuments]    Script Date: 7/18/2022 4:36:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindDocuments 6, 'AIS', 'EXPRPT071622'
EXECUTE USP_FindDocuments 7, 'IMC', '10001'

SELECT * FROM ILS_Documents.dbo.View_DocumentInput WHERE Fk_DocumentId = 1 ORDER BY DocumentInputId
SELECT * FROM ILS_Documents.dbo.View_Documents WHERE CategoryId = 3

-- TRUNCATE TABLE Documents
*/

ALTER PROCEDURE [dbo].[USP_FindDocuments]
		@CategoryId	Int,
		@Company	Varchar(5),
		@RecordId	Varchar(15) = Null
AS
IF @RecordId IS Null
BEGIN
	SELECT	DISTINCT DocumentId
			,'NO' + CAST(DocumentId AS Varchar(10)) AS Node
			,'CH' + CAST(DocumentTypeId AS Varchar(10)) AS Parent
			,RTRIM(CreatedByName) + ' ' + CONVERT(Char(26), CreatedOn, 0) AS Description
			,DocumentFile
			,HttpDocumentFile
			,'R_' + RTRIM(RecordId) +  + '_2' AS SortBy
			,Notes
			,2 AS Icon
			,RecordId
			,CategoryId
			,DocumentTypeId
			,CreatedBy
	FROM	View_Documents
	WHERE	CategoryId = @CategoryId
			AND Company = @Company
	UNION
	SELECT	0
			,'CH' + CAST(DocumentTypeId AS Varchar(10))
			,'R' + RTRIM(RecordId)
			,DocumentType
			,'Blank.aspx'
			,'Blank.aspx'
			,'R_' + RTRIM(RecordId) + '_1' AS SortBy
			,Null
			,1
			,RecordId
			,CategoryId
			,DocumentTypeId
			,Null
	FROM	(SELECT	DISTINCT DocumentTypeId
					,DocumentType
					,RecordId
					,CategoryId
			FROM	View_Documents
			WHERE	CategoryId = @CategoryId
					AND Company = @Company) RECS
	UNION
	SELECT	0
			,'R' + RTRIM(RecordId)
			,'root'
			,RTRIM(RecordText) + ': ' + RecordId
			,'Blank.aspx'
			,'R_' + RTRIM(RecordId) + '_0' AS SortBy
			,Null
			,Null
			,0
			,RecordId
			,CategoryId
			,Null AS DocumentTypeId
			,Null
	FROM	(SELECT	DISTINCT RecordId, RecordText, CategoryId, DocumentTypeId
			FROM	View_Documents
			WHERE	CategoryId = @CategoryId
					AND Company = @Company) RECS
	ORDER BY 6,1
END
ELSE
BEGIN
	SELECT	DISTINCT DocumentId
			,'NO' + CAST(DocumentId AS Varchar(10)) AS Node
			,'CH' + CAST(DocumentTypeId AS Varchar(10)) AS Parent
			,RTRIM(CreatedByName) + ' ' + CONVERT(Char(26), CreatedOn, 0) AS Description
			,DocumentFile
			,HttpDocumentFile
			,'P' + CAST(DocumentTypeId AS Varchar(10)) + '_2' AS SortBy
			,Notes
			,2 AS Icon
			,RecordId
			,CategoryId
			,DocumentTypeId
			,CreatedBy
	FROM	View_Documents
	WHERE	CategoryId = @CategoryId
			AND Company = @Company
			AND RecordId = @RecordId
			AND dbo.CheckIfFileExists(DocumentFile) = 1
	UNION
	SELECT	0
			,'CH' + CAST(DocumentTypeId AS Varchar(10))
			,'root'
			,DocumentType
			,'Blank.aspx'
			,'CH' + CAST(DocumentTypeId AS Varchar(10)) + '_1' AS SortBy
			,'P' + CAST(DocumentTypeId AS Varchar(10)) + '_1'
			,Null
			,1
			,RecordId
			,CategoryId
			,DocumentTypeId
			,Null
	FROM	(SELECT	DISTINCT DocumentTypeId
					,DocumentType
					,RecordId
					,CategoryId
			FROM	View_Documents
			WHERE	CategoryId = @CategoryId
					AND Company = @Company
					AND RecordId = @RecordId) RECS
	ORDER BY 7,6,1
END