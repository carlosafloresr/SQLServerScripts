/*
EXECUTE USP_FileBound_FileDelete 2286588
*/
ALTER PROCEDURE USP_FileBound_FileDelete
		@FileId		Bigint
AS
DECLARE	@FileName	Varchar(100),
		@Command	Varchar(500),
		@Result		Int

SET NOCOUNT ON

SELECT	@FileName = FullFileName
FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments
WHERE	FileID = @FileId

PRINT @FileName

EXECUTE XP_FileExist @FileName, @Result OUTPUT

IF @Result = 1
BEGIN
	SET @Command = 'DEL ' + @FileName

	EXECUTE @Result = XP_CmdShell @Command
	PRINT IIF(@Result = 1, 'File Deleted', 'Failed to delete file')

	IF @Result = 1
	BEGIN
		DELETE	PRIFBSQL01P.FB.dbo.ExtendedProperties
		WHERE	ObjectID = @FileId

		DELETE	PRIFBSQL01P.FB.dbo.Documents
		WHERE	FileID = @FileId

		DELETE	PRIFBSQL01P.FB.dbo.Files
		WHERE	FileID = @FileId
	END
END