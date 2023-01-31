USE IMCMR
GO

DECLARE @ProjectId		Int,
		@ProjectName	Varchar(100),
		@Update			Bit = 1

SELECT	@ProjectId		= ProjectId,
		@ProjectName	= ProjectName
FROM	priFBSQL01p.FB.dbo.Projects
WHERE	--ProjectName LIKE ('%' + DB_NAME() +  ' Department%') OR
		ProjectName LIKE ('%' + DB_NAME() +  ' GL%')

IF @ProjectId IS Null
	PRINT 'Company not mapped to a DEX project'
ELSE
BEGIN
	SELECT	DISTINCT *
	INTO	#tmpData
	FROM	(
			SELECT	DISTINCT @ProjectId AS ProjectId,
					1 AS Status,
					GETDATE() AS DateChanged,
					RTRIM(ACTNUMBR_1) AS Field1,
					RTRIM(ACTNUMBR_1) AS Field2,
					GETDATE() AS DateCreated,
					GETDATE() AS DateStarted,
					114 AS ChangedBy
			FROM	GL00100
			UNION
			SELECT	DISTINCT @ProjectId AS ProjectId,
					1 AS Status,
					GETDATE() AS DateChanged,
					RTRIM(ACTNUMBR_3) AS Field1,
					RTRIM(ACTNUMBR_3) + ' ' + RTRIM(ACTDESCR) AS Field2,
					GETDATE() AS DateCreated,
					GETDATE() AS DateStarted,
					114 AS ChangedBy
			FROM	GL00100
			) DATA
	ORDER BY 1,2

	IF @Update = 0
		SELECT	DISTINCT @ProjectName AS ProjectName,
				TMP.*,
				InFileBound = IIF(DEX.Field1 IS Null, 'NO', 'YES')
		FROM	#tmpData TMP
				LEFT JOIN priFBSQL01p.FB.dbo.Files DEX ON TMP.ProjectId = DEX.ProjectId AND TMP.Field1 = DEX.Field1
		ORDER BY TMP.FIELD1
	ELSE
	BEGIN
		--UPDATE	priFBSQL01p.FB.dbo.Files
		--SET		Files.Field2		= DATA.Field2,
		--		Files.DateChanged	= GETDATE()
		--FROM	#tmpData DATA
		--WHERE	Files.ProjectId = DATA.ProjectId
		--		AND Files.Field1 = DATA.Field1
		--		AND RTRIM(Files.Field1) + '-' + RTRIM(Files.Field2) <> RTRIM(DATA.Field1) + '-' + RTRIM(DATA.Field2)

		INSERT INTO priFBSQL01p.FB.dbo.Files
				(ProjectID,
				Status,
				DateChanged,
				Field1,
				Field2,
				DateCreated,
				DateStarted,
				ChangedBy)
		SELECT	*
		FROM	#tmpData
		WHERE	RTRIM(Field1) + '-' + RTRIM(Field2) NOT IN (SELECT RTRIM(Field1) + '-' + RTRIM(Field2) FROM priFBSQL01p.FB.dbo.Files WHERE ProjectId = @ProjectId)
	END

	DROP TABLE #tmpData
END
GO