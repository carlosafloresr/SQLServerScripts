DECLARE	@Content	Varchar(MAX),
		@DocumentId	Int,
		@FileId		Int,
		@RunDate	Datetime,
		@ProjectId	Int
		
SET		@Rundate	= '08/16/2011'
SET		@ProjectId	= 66

SELECT	DOC.DocumentId
		,DOC.FileID
		,DOC.Contents
		,DOC.DateFiled
		,DOC.BatchDate
		,FIL.ProjectID
		,FIL.*
		,VND.VendorId
		,VND.VendName
		,CAST(Null AS Varchar(30)) AS InvoiceNumber
		,CAST(Null AS Datetime) AS InvoiceDate
		,CAST(Null AS Numeric(18,2)) AS InvoiceAmount
		--,VND.USERDEF2
		--,RTRIM(LEFT(CASE WHEN USERDEF2 = '' THEN CASE WHEN PHNUMBR1 = '' OR PHNUMBR1 = '00000000000000' THEN REPLACE(REPLACE(RTRIM(VENDNAME), '"', ''), '#', '') ELSE dbo.FORMATPHONENUMBER(PHNUMBR1) END ELSE USERDEF2 END, 50)) AS Keyword
INTO	#tmpDocuments
FROM	Documents DOC
		LEFT JOIN Files FIL ON DOC.FileID = FIL.FileID
		LEFT JOIN ILSGP01.AIS.dbo.PM00200 VND ON VND.VendStts = 1 AND VND.VndClsId <> 'DRV' AND PATINDEX('%' + RTRIM(LEFT(CASE WHEN USERDEF2 = '' THEN CASE WHEN PHNUMBR1 = '' OR PHNUMBR1 = '00000000000000' THEN REPLACE(REPLACE(RTRIM(VENDNAME), '"', ''), '#', '') ELSE dbo.FORMATPHONENUMBER(PHNUMBR1) END ELSE USERDEF2 END, 50)) + '%', DOC.Contents) > 0
WHERE	CONVERT(Char(10), DateFiled, 101) = @Rundate
		AND FIL.ProjectID = @ProjectId
		AND Contents <> ''
ORDER BY DOC.DocumentID

DECLARE Documents CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	#tmpDocuments

OPEN Documents
FETCH FROM Documents INTO @DocumentId, @Content

WHILE @@FETCH_STATUS = 0 
BEGIN

	FETCH FROM Documents INTO @DocumentId, @Content
END
CLOSE Documents
DEALLOCATE Documents

DROP TABLE #tmpDocuments