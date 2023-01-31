DECLARE @Company	Varchar(5) = 'AIS',
		@ProjectId	Int,
		@Query		Varchar(MAX)

DECLARE	@TblData TABLE 
		(
		FileId		Int Default Null, 
		CheckNumber Varchar(30) Default Null, 
		CheckDate	Char(10) Default Null
		)

SET @ProjectId = (SELECT ProjectId FROM LENSASQL001.GPCustom.dbo.DexCompanyProjects WHERE ProjectType = 'AP' AND Company = @Company)

SELECT	Field8 AS VendorId,
		LEFT(Field4, 21) AS InvoiceNumber,
		Field15,
		Field19,
		FileId
INTO	##tmpDEX
FROM	View_DEXDocuments
WHERE	ProjectID = @ProjectId
		AND Field8 <> 'UNKNOWN'
		AND Field4 <> ''
		AND Field19 = ''
		AND DateFiled > '01/01/2015'

IF @@ROWCOUNT > 0
BEGIN
	DELETE @TblData

	SET @Query = 'SELECT DX.FileId, RTRIM(PM.APFRDCNM) AS CheckNumber, CONVERT(Char(10), PM.DOCDATE, 101) AS CheckDate
		FROM	##tmpDEX DX
				INNER JOIN LENSASQL001.' + RTRIM(@Company) + '.dbo.PM20100 PM ON DX.VendorId = PM.VendorId AND DX.InvoiceNumber = PM.APTODCNM AND PM.DOCTYPE = 6
		UNION
		SELECT	DX.FileId, RTRIM(PM.APFRDCNM) AS CheckNumber, CONVERT(Char(10), PM.DOCDATE, 101) AS CheckDate
		FROM	##tmpDEX DX
				INNER JOIN LENSASQL001.' + RTRIM(@Company) + '.dbo.PM30300 PM ON DX.VendorId = PM.VendorId AND DX.InvoiceNumber = PM.APTODCNM AND PM.DOCTYPE = 6'

	INSERT INTO @TblData
	EXECUTE(@Query)

	UPDATE	Files
	SET		Field15 = DAT.CheckDate,
			Field19 = DAT.CheckNumber
	FROM	(
				SELECT	*
				FROM	@TblData
			) DAT
	WHERE	Files.FileId = DAT.FileId
END
ELSE
	PRINT'No records found!'

DROP TABLE ##tmpDEX


--USE FI
--GO

--DECLARE @ProjectId Int

--SET @ProjectId = (SELECT ProjectId FROM GPCustom.dbo.DexCompanyProjects WHERE ProjectType = 'AP' AND Company = DB_NAME())

--SELECT	Field8 AS VendorId,
--		LEFT(Field4, 21) AS InvoiceNumber,
--		Field15,
--		Field19,
--		FileId
--INTO	##tmpDEX
--FROM	[LENSADEX001\INDEXDATAFILES].FB.dbo.View_DEXDocuments
--WHERE	ProjectID = @ProjectId
--		AND Field8 <> 'UNKNOWN'
--		AND Field4 <> ''
--		AND Field19 = ''
--		AND DateFiled > '01/01/2015'

--UPDATE	[LENSADEX001\INDEXDATAFILES].FB.dbo.Files
--SET		Field15 = DAT.CheckDate,
--		Field19 = DAT.CheckNumber
--FROM	(
--		SELECT	DX.FileId, RTRIM(PM.APFRDCNM) AS CheckNumber, CONVERT(Char(10), PM.DOCDATE, 101) AS CheckDate
--		FROM	##tmpDEX DX
--				INNER JOIN PM20100 PM ON DX.VendorId = PM.VendorId AND DX.InvoiceNumber = PM.APTODCNM AND PM.DOCTYPE = 6
--		UNION
--		SELECT	DX.FileId, RTRIM(PM.APFRDCNM) AS CheckNumber, CONVERT(Char(10), PM.DOCDATE, 101) AS CheckDate
--		FROM	##tmpDEX DX
--				INNER JOIN PM30300 PM ON DX.VendorId = PM.VendorId AND DX.InvoiceNumber = PM.APTODCNM AND PM.DOCTYPE = 6
--		) DAT
--WHERE	Files.FileId = DAT.FileId

--DROP TABLE ##tmpDEX