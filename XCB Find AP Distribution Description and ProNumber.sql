DECLARE	@Company		Varchar(5) = 'GLSO',
		@GLAccount		Varchar(15) = '0-00-2105', -- '0-88-1866',
		@Journal		Int = 3627405,
		@Query			Varchar(MAX)

DECLARE	@tblTmpData		Table (
RecordId				Int,
JournalNo				Int,
Reference				Varchar(50),
GL_Reference			Varchar(50),
AP_Reference			Varchar(50))

SET @Query = N'SELECT XCB.RecordId, XCB.JournalNo, XCB.Reference, GL2.REFRENCE, ISNULL(P2D.DistRef,P3D.DistRef) AS DistRef 
FROM	GP_XCB_Prepaid XCB
		LEFT JOIN ' + @Company + '.dbo.GL20000 GL2 ON XCB.JournalNo = GL2.JRNENTRY AND XCB.Sequence = GL2.SEQNUMBR
		LEFT JOIN ' + @Company + '.dbo.PM30200 P3H ON XCB.Vendor = P3H.VENDORID AND XCB.DocumentNo = P3H.DOCNUMBR
		LEFT JOIN ' + @Company + '.dbo.PM30600 P3D ON P3H.VENDORID = P3D.VENDORID AND P3H.VCHRNMBR = P3D.VCHRNMBR AND P3H.TRXSORCE = P3D.TRXSORCE AND P3D.DSTINDX = GL2.ACTINDX
		LEFT JOIN ' + @Company + '.dbo.PM20000 P2H ON XCB.Vendor = P2H.VENDORID AND XCB.DocumentNo = P2H.DOCNUMBR
		LEFT JOIN ' + @Company + '.dbo.PM10100 P2D ON P2H.VENDORID = P2D.VENDORID AND P2H.VCHRNMBR = P2D.VCHRNMBR AND P2H.TRXSORCE = P2D.TRXSORCE AND P2D.DSTINDX = GL2.ACTINDX
WHERE	XCB.Company = ''' + @Company + ''' 
		AND XCB.GLAccount = ''' + @GLAccount + ''' 
		AND XCB.Audit_Trial LIKE ''PM%''
		AND XCB.ProNumber = '''' 
UNION 
SELECT XCB.RecordId, XCB.JournalNo, XCB.Reference, GL2.REFRENCE, ISNULL(P2D.DistRef,P3D.DistRef) AS DistRef 
FROM	GP_XCB_Prepaid XCB
		LEFT JOIN ' + @Company + '.dbo.GL30000 GL2 ON XCB.JournalNo = GL2.JRNENTRY AND XCB.Sequence = GL2.SEQNUMBR
		LEFT JOIN ' + @Company + '.dbo.PM30200 P3H ON XCB.Vendor = P3H.VENDORID AND XCB.DocumentNo = P3H.DOCNUMBR
		LEFT JOIN ' + @Company + '.dbo.PM30600 P3D ON P3H.VENDORID = P3D.VENDORID AND P3H.VCHRNMBR = P3D.VCHRNMBR AND P3H.TRXSORCE = P3D.TRXSORCE AND P3D.DSTINDX = GL2.ACTINDX
		LEFT JOIN ' + @Company + '.dbo.PM20000 P2H ON XCB.Vendor = P2H.VENDORID AND XCB.DocumentNo = P2H.DOCNUMBR
		LEFT JOIN ' + @Company + '.dbo.PM10100 P2D ON P2H.VENDORID = P2D.VENDORID AND P2H.VCHRNMBR = P2D.VCHRNMBR AND P2H.TRXSORCE = P2D.TRXSORCE AND P2D.DSTINDX = GL2.ACTINDX
WHERE	XCB.Company = ''' + @Company + ''' 
		AND XCB.GLAccount = ''' + @GLAccount + ''' 
		AND XCB.Audit_Trial LIKE ''PM%''
		AND XCB.ProNumber ='''''

INSERT INTO @tblTmpData
EXECUTE(@Query)

UPDATE	GP_XCB_Prepaid
SET		GP_XCB_Prepaid.ProNumber = DATA.ProNumber,
		GP_XCB_Prepaid.Reference = RTRIM(IIF(DATA.SourceDescription = 1, DATA.GL_Reference, DATA.AP_Reference))
FROM	(
		SELECT	RecordId,
				JournalNo,
				Reference,
				GL_Reference,
				AP_Reference,
				CASE WHEN dbo.WithProNumber(GL_Reference) = 1 THEN dbo.FindProNumber(GL_Reference) 
					 WHEN dbo.WithProNumber(AP_Reference) = 1 THEN dbo.FindProNumber(AP_Reference) 
				ELSE '' END AS ProNumber,
				CASE WHEN dbo.WithProNumber(GL_Reference) = 1 THEN 1
					 WHEN dbo.WithProNumber(AP_Reference) = 1 THEN 2
				ELSE 0 END AS SourceDescription
		FROM	@tblTmpData
		) DATA
WHERE	GP_XCB_Prepaid.RecordId = DATA.RecordId
		AND DATA.SourceDescription > 0

/*
SELECT	*
FROM	GLSO.dbo.GL20000
WHERE	JRNENTRY = 3627405
		AND ACTINDX = 651

SELECT	PMD.*
FROM	GLSO.dbo.PM30200 PMH
		INNER JOIN GLSO.dbo.PM30600 PMD ON PMH.VENDORID = PMD.VENDORID AND PMH.VCHRNMBR = PMD.VCHRNMBR AND PMH.TRXSORCE = PMD.TRXSORCE
WHERE	PMH.VENDORID = '1034'
		AND PMH.DOCNUMBR = '22773A'
		AND PMD.DSTINDX = 651
*/