USE [Integrations]
GO

ALTER PROCEDURE USP_Integrations_XML
			@Integration	varchar(5),
			@Company		varchar(5),
			@BatchId		varchar(25),
			@RecordId		bigint = Null,
			@Subject		varchar(200) = Null,
			@EmailTo		varchar(200) = Null,
			@HTML			varchar(max) = Null,
			@XML			text = Null,
			@WithErrors		bit = 0,
			@DeleteBatch	bit = 0
AS
IF @DeleteBatch = 1
BEGIN
	DELETE [Integrations_XML]
	WHERE	Integration = @Integration 
			AND Company = @Company 
			AND BatchId = @BatchId 

	DELETE [Integrations_XML_Records]
	WHERE	Integration = @Integration 
			AND Company = @Company 
			AND BatchId = @BatchId 
			AND RecordId = @RecordId
END
ELSE
BEGIN
	IF @RecordId IS Null OR @RecordId = 0
	BEGIN
		INSERT INTO [Integrations_XML]
				([Integration]
				,[Company]
				,[BatchId]
				,[Subject]
				,[EmailTo])
		VALUES
				(@Integration
				,@Company
				,@BatchId
				,@Subject
				,@EmailTo)
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Integration FROM Integrations_XML_Records WHERE Integration = @Integration AND Company = @Company AND BatchId = @BatchId AND RecordId = @RecordId)
		BEGIN
			UPDATE	[Integrations_XML_Records]
			SET		[HTML]			= CASE WHEN @HTML IS Null AND [HTML] IS NOT Null THEN [HTML] ELSE @HTML END,
					[XML]			= CASE WHEN @XML IS Null AND [XML] IS NOT Null THEN [XML] ELSE @XML END,
					[WithErrors]	= @WithErrors
			WHERE	Integration = @Integration 
					AND Company = @Company 
					AND BatchId = @BatchId 
					AND RecordId = @RecordId
		END
		ELSE
		BEGIN
			INSERT INTO [Integrations_XML_Records]
				   ([Integration]
				   ,[Company]
				   ,[BatchId]
				   ,[RecordId]
				   ,[HTML]
				   ,[XML]
				   ,[WithErrors])
			 VALUES
				   (@Integration
				   ,@Company
				   ,@BatchId
				   ,@RecordId
				   ,@HTML
				   ,@XML
				   ,@WithErrors)
		END
	END
END