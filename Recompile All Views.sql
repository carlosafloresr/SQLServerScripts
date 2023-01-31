SET NOCOUNT ON

DECLARE @SQL	Varchar(max) = '',
		@View	Varchar(50)

DECLARE curViews CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Name
FROM	sysobjects 
WHERE	type = 'V' 
		AND name LIKE 'view_%'

OPEN curViews 
FETCH FROM curViews INTO @View

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @SQL = 'EXEC sp_refreshview ' + @View
	
	BEGIN TRY  
		EXECUTE(@SQL)
		PRINT 'View [' + @View + '] Updated'
	END TRY  
	BEGIN CATCH  
		PRINT @View + ' - Error: ' + ERROR_MESSAGE() + '/' + CAST(ERROR_NUMBER() AS Varchar)

		IF ERROR_NUMBER() = 208
		BEGIN
			SET @SQL = 'DROP VIEW ' + @View
			EXECUTE(@SQL)
		END
	END CATCH

	FETCH FROM curViews INTO @View
END

CLOSE curViews
DEALLOCATE curViews