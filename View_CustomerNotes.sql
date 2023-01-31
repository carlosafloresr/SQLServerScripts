create VIEW View_CustomerNotes
AS
SELECT	CustNmbr
		,NoteDate
		,Note
FROM	(
		SELECT	CustNmbr
				,Date1 AS NoteDate
				,Note_Display_String AS Note
				,ROW_NUMBER() OVER (PARTITION BY CustNmbr ORDER BY Date1 DESC) AS RowNumber
		FROM	CN00100
		WHERE	CustNmbr <> ''
		) NOTES
WHERE	RowNumber = 1

/*
SELECT * FROM View_CustomerNotes
*/