SELECT	*
FROM	Files
WHERE	ProjectID IN (61,62,63,65,67,69,64,68)
		AND Field15 <> ''
		
UPDATE	Files
SET		Field15 = ''
WHERE	ProjectID IN (61,62,63,65,67,69,64,68)
		AND Field15 <> ''