CREATE PROCEDURE USP_FI_Data_DeleteDuplicateDocuments
AS
SELECT	DISTINCT Document
		,DocType
		,DocNumber
		,Par_Type
		,Par_Doc
		,RTRIM(Document) + RTRIM(DocType) + RTRIM(DocNumber) + RTRIM(Par_Type) + RTRIM(Par_Doc) AS UniqueId
		,COUNT(Document) AS Counter
INTO	#TmpDuplicates1
FROM	FI_Documents
GROUP BY
		Document
		,DocType
		,DocNumber
		,Par_Type
		,Par_Doc
HAVING	COUNT(Document) > 1

SELECT	MIN(FI_DocumentId) AS FI_DocumentId
		,RTRIM(Document) + RTRIM(DocType) + RTRIM(DocNumber) + RTRIM(Par_Type) + RTRIM(Par_Doc) AS UniqueId
INTO	#TmpDuplicates2
FROM	FI_Documents
WHERE	RTRIM(Document) + RTRIM(DocType) + RTRIM(DocNumber) + RTRIM(Par_Type) + RTRIM(Par_Doc) IN (SELECT UniqueId FROM #TmpDuplicates1)
GROUP BY
		RTRIM(Document) + RTRIM(DocType) + RTRIM(DocNumber) + RTRIM(Par_Type) + RTRIM(Par_Doc)

DELETE	FI_Documents
FROM	#TmpDuplicates2
WHERE	RTRIM(Document) + RTRIM(DocType) + RTRIM(DocNumber) + RTRIM(Par_Type) + RTRIM(Par_Doc) = UniqueId
		AND FI_Documents.FI_DocumentId > #TmpDuplicates2.FI_DocumentId

DROP TABLE #TmpDuplicates1
DROP TABLE #TmpDuplicates2

/*
SELECT	Document 
FROM	(
		
*/