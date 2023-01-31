SET NOCOUNT OFF

DECLARE	@Company	Varchar(5) = DB_NAME(),
		@Query		Varchar(MAX),
		@Action		Char(1) = 'C' -- C=Compare, U=Update

IF @Action = 'C'
BEGIN
	SET	@Query = N'SELECT	PM1.VENDORID,
							PM1.VENDNAME AS CurrentName,
							PM2.VENDNAME AS BackupName,
							PM1.VNDCHKNM AS CurrentCheckName,
							PM2.VNDCHKNM AS BackupCheckName
					FROM	PM00200 PM1
							INNER JOIN SECSASQL001U.' + @Company + '.dbo.PM00200 PM2 ON PM1.VendorId = PM2.VendorId
					WHERE	PM1.VNDCHKNM <> PM2.VNDCHKNM'
END
ELSE
BEGIN
	SET	@Query = N'UPDATE	PM00200
					SET		PM00200.VNDCHKNM = DATA.BackupCheckName
					FROM	(
								SELECT	PM1.VENDORID,
										PM1.VENDNAME AS CurrentName,
										PM2.VENDNAME AS BackupName,
										PM1.VNDCHKNM AS CurrentCheckName,
										PM2.VNDCHKNM AS BackupCheckName
								FROM	PM00200 PM1
										INNER JOIN SECSASQL001U.' + @Company + '.dbo.PM00200 PM2 ON PM1.VendorId = PM2.VendorId
								WHERE	PM1.VNDCHKNM <> PM2.VNDCHKNM
							) DATA
					WHERE	PM00200.VENDORID = DATA.VENDORID
							AND PM00200.VNDCHKNM <> DATA.BackupName'
END

EXECUTE(@Query)