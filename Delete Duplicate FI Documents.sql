DELETE	FI_Documents
WHERE	FI_Documents.FI_DocumentId IN (SELECT FI_DocumentId FROM (
	SELECT	Document
			,MAX(FI_DocumentId) AS FI_DocumentId
	FROM	FI_Documents
	WHERE	Document IN (SELECT Document FROM (
							SELECT	DISTINCT Document
									,DocType
									,DocNumber
									,Par_Type
									,Par_Doc
									,COUNT(Document) AS Counter
							FROM	FI_Documents
							GROUP BY
									Document
									,DocType
									,DocNumber
									,Par_Type
									,Par_Doc
							HAVING	COUNT(Document) > 1) RECS)
	GROUP BY Document) DUPS)
	
SELECT COUNT(*) AS Counter FROM FI_Documents

/*
SELECT * FROM FI_Documents
*/