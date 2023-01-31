UPDATE	GP_XCB_Prepaid
SET		GP_XCB_Prepaid.Reference = RTRIM(DATA.DSCRIPTN),
		GP_XCB_Prepaid.ProNumber = DATA.GLProNumber
FROM	(
		SELECT	XCB.RecordId,
				XCB.JournalNo,
				XCB.Reference,
				GL.DSCRIPTN,
				dbo.FindProNumber(GL.DSCRIPTN) AS GLProNumber,
				XCB.ProNumber
		FROM	GP_XCB_Prepaid XCB
				INNER JOIN GLSO.dbo.GL20000 GL ON XCB.JournalNo = GL.JRNENTRY AND XCB.Sequence = GL.SEQNUMBR AND GL.ACTINDX = 650
		WHERE	XCB.GLAccount = '0-88-1866'
		UNION
		SELECT	XCB.RecordId,
				XCB.JournalNo,
				XCB.Reference,
				GL.DSCRIPTN,
				dbo.FindProNumber(GL.DSCRIPTN) AS GLProNumber,
				XCB.ProNumber
		FROM	GP_XCB_Prepaid XCB
				INNER JOIN GLSO.dbo.GL30000 GL ON XCB.JournalNo = GL.JRNENTRY AND XCB.Sequence = GL.SEQNUMBR AND GL.ACTINDX = 650
		WHERE	XCB.GLAccount = '0-88-1866'
		) DATA
WHERE	GP_XCB_Prepaid.RecordId = DATA.RecordId
		AND DATA.GLProNumber <> ''
		AND DATA.GLProNumber <> DATA.ProNumber