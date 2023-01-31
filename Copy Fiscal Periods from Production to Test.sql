DECLARE	@Company	Varchar(5),
		@Query		Varchar(MAX)

DECLARE OOS_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(InterId)
FROM	DYNAMICS.dbo.View_AllCompanies

OPEN OOS_Companies 
FETCH FROM OOS_Companies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'INSERT INTO [' + @Company + '].[dbo].[SY40100]
           ([CLOSED]
           ,[SERIES]
           ,[ODESCTN]
           ,[FORIGIN]
           ,[PERIODID]
           ,[PERIODDT]
           ,[PERNAME]
           ,[PSERIES_1]
           ,[PSERIES_2]
           ,[PSERIES_3]
           ,[PSERIES_4]
           ,[PSERIES_5]
           ,[PSERIES_6]
           ,[YEAR1]
           ,[PERDENDT]
           ,[DEX_ROW_TS])
SELECT	[CLOSED]
		,[SERIES]
		,[ODESCTN]
		,[FORIGIN]
		,[PERIODID]
		,[PERIODDT]
		,[PERNAME]
		,[PSERIES_1]
		,[PSERIES_2]
		,[PSERIES_3]
		,[PSERIES_4]
		,[PSERIES_5]
		,[PSERIES_6]
		,[YEAR1]
		,[PERDENDT]
		,[DEX_ROW_TS]
FROM	PRISQL01P.' + @Company + '.dbo.SY40100
WHERE	YEAR1 = 2023
		AND CAST(YEAR1 AS Varchar) + CAST(PERIODID AS Varchar) NOT IN (SELECT CAST(YEAR1 AS Varchar) + CAST(PERIODID AS Varchar) FROM [' + @Company + '].[dbo].[SY40100])'

	EXECUTE(@Query)

	SET @Query = N'INSERT INTO [' + @Company + '].[dbo].[SY40101]
           ([YEAR1]
           ,[FSTFSCDY]
           ,[LSTFSCDY]
           ,[NUMOFPER]
           ,[HISTORYR]
           ,[DEX_ROW_TS])
SELECT	[YEAR1]
		,[FSTFSCDY]
		,[LSTFSCDY]
		,[NUMOFPER]
		,[HISTORYR]
		,[DEX_ROW_TS]
FROM	PRISQL01P.' + @Company + '.dbo.SY40101
WHERE	YEAR1 NOT IN (SELECT YEAR1 FROM [' + @Company + '].[dbo].[SY40101])'

	EXECUTE(@Query)

	PRINT @Company
	
	FETCH FROM OOS_Companies INTO @Company
END

CLOSE OOS_Companies
DEALLOCATE OOS_Companies

