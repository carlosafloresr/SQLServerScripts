DECLARE	@ProjectId		Smallint,
		@ProjectName	Varchar(100),
		@Update			Bit = 0

SELECT	@ProjectId		= ProjectId,
		@ProjectName	= ProjectName
FROM	priFBSQL01p.FB.dbo.Projects
WHERE	ProjectName LIKE ('%' + DB_NAME() +  ' Vendor%')

SELECT	@ProjectId AS ProjectId,
		@ProjectName AS ProjectName,
		1 AS Status,
		VND.VendorId AS Field1,
		VND.VendName AS Field2,
		VND.VendorId AS Field3,
		GETDATE() AS DateChanged,
		GETDATE() AS DateStarted,
		114 AS ChangedBy,
		InFileBound = IIF(DAT.Field1 IS Null, 'NO', IIF(VND.VendName <> DAT.Field2, 'YES CHANGED', 'YES'))
INTO	#tmpData
FROM	PM00200 VND
		LEFT JOIN (
					SELECT	ProjectID,
							Status,
							Field1,
							Field2
					FROM	priFBSQL01p.FB.dbo.Files
					WHERE	ProjectId = @ProjectId
					) DAT ON VND.VENDORID = DAT.Field1
WHERE	VND.VNDCLSID <> 'DRV'
ORDER BY 5

IF @Update = 0
	SELECT	*
	FROM	#tmpData
ELSE
BEGIN
	UPDATE	priFBSQL01p.FB.dbo.Files
	SET		Files.Field2		= DATA.Field2,
			Files.DateChanged	= GETDATE()
	FROM	#tmpData DATA
	WHERE	Files.ProjectId = DATA.ProjectId
			AND Files.Field1 = DATA.Field1
			AND DATA.InFileBound = 'YES CHANGED'

	INSERT INTO priFBSQL01p.FB.dbo.Files
			(ProjectID,
			Status,
			DateChanged,
			Field1,
			Field2,
			Field3,
			DateCreated,
			DateStarted,
			ChangedBy)
	SELECT	ProjectId,
			[Status],
			DateChanged,
			Field1,
			Field2,
			Field3,
			DateChanged,
			DateStarted,
			ChangedBy
	FROM	#tmpData
	WHERE	InFileBound = 'NO'
END

DROP TABLE #tmpData