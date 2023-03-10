SELECT	*
FROM	Files
WHERE	ProjectId = 148
ORDER BY Field2

--SELECT	ProjectID,
--		Status,
--		DateChanged,
--		Field1,
--		Field2,
--		DateCreated,
--		DateStarted,
--		ChangedBy
--FROM	Files
--WHERE	ProjectId = 83

--SELECT	DISTINCT ACTNUMBR_1 AS Account,
--		ACTNUMBR_1 AS Description
--FROM	LENSASQL001.PTS.dbo.GL00100 GL1
--		INNER JOIN LENSASQL001.PTS.dbo.GL00105 GL5 ON GL1.ACTINDX = GL5.ACTINDX
--WHERE	ACTIVE = 1
--UNION
--SELECT	DISTINCT ACTNUMBR_2 AS Account,
--		ACTNUMBR_2 AS Description
--FROM	LENSASQL001.PTS.dbo.GL00100
--WHERE	ACTIVE = 1
--UNION
SELECT	DISTINCT 150 AS ProjectId,
		1 AS Status,
		GETDATE() AS DateChanged,
		RTRIM(GL1.ACTNUMBR_3) AS Field1,
		RTRIM(GL5.ACTNUMST) + ' ' + RTRIM(GL1.ACTDESCR) AS Field2,
		GETDATE() AS DateCreated,
		GETDATE() AS DateStarted,
		114 AS ChangedBy
FROM	LENSASQL001.PTS.dbo.GL00100 GL1
		INNER JOIN LENSASQL001.PTS.dbo.GL00105 GL5 ON GL1.ACTINDX = GL5.ACTINDX
WHERE	GL1.ACTIVE = 1
		AND LEN(RTRIM(GL1.ACTNUMBR_3)) = 4


--SELECT	*
--FROM	LENSASQL001.PTS.dbo.GL00105