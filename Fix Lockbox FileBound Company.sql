SELECT	*
FROM	View_DEXDocuments
WHERE	ProjectID = 161
		AND Field1 = 'IMCG'
		AND Field2 = 'LCKBX012420120000'

/*
UPDATE	Files
SET		Field1 = 'IMCG'
WHERE	ProjectID = 161
		AND Field1 = ''



DELETE	Documents
WHERE	FileID IN (
SELECT	FileID
FROM	Files
WHERE	ProjectID = 161
		AND Field1 = 'AIS'
		AND Field2 = 'LCKBX012720120000')

DELETE	Files
WHERE	ProjectID = 161
		AND Field1 = 'AIS'
		AND Field2 = 'LCKBX012720120000'
*/