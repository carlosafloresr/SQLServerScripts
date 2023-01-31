SELECT	* --RTRIM(EmailCardAddress) AS EmailCardAddress
FROM	SY04906
WHERE	GPCustom.dbo.IsEmailAddressValid(EmailCardAddress) = 0
ORDER BY EmailCardAddress

DECLARE	@DEX_ROW_ID				int,
		@EmailCardAddress		varchar(151)

DECLARE	@tblData TABLE
		(EmailDictionaryID		smallint,
		EmailSeriesID			smallint,
		MODULE1					smallint,
		EmailCardID				char(25),
		EmailDocumentID			smallint,
		ADRSCODE				char(15),
		EmailCardAddress		varchar(151),
		EmailRecipientTypeTo	tinyint,
		EmailRecipientTypeCc	tinyint,
		EmailRecipientTypeBcc	tinyint,
		DEX_ROW_ID				int)

INSERT INTO @tblData
SELECT	*
FROM	SY04906
WHERE	GPCustom.dbo.IsEmailAddressValid(EmailCardAddress) = 0

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DEX_ROW_ID, REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(EmailCardAddress)), ' ', ''), '	', ''), ' ', '') AS EmailCardAddress
FROM	@tblData 

OPEN curData 
FETCH FROM curData INTO @DEX_ROW_ID, @EmailCardAddress

WHILE @@FETCH_STATUS = 0 
BEGIN
	UPDATE	@tblData
	SET		EmailCardAddress = @EmailCardAddress
	WHERE	DEX_ROW_ID = @DEX_ROW_ID

	BEGIN TRANSACTION

	DELETE SY04906 WHERE DEX_ROW_ID = @DEX_ROW_ID

	INSERT INTO [dbo].[SY04906]
			([EmailDictionaryID]
			,[EmailSeriesID]
			,[MODULE1]
			,[EmailCardID]
			,[EmailDocumentID]
			,[ADRSCODE]
			,[EmailCardAddress]
			,[EmailRecipientTypeTo]
			,[EmailRecipientTypeCc]
			,[EmailRecipientTypeBcc])
	SELECT	EmailDictionaryID
			,EmailSeriesID
			,MODULE1
			,EmailCardID
			,EmailDocumentID
			,ADRSCODE
			,EmailCardAddress
			,EmailRecipientTypeTo
			,EmailRecipientTypeCc
			,EmailRecipientTypeBcc
	FROM	@tblData
	WHERE	DEX_ROW_ID = @DEX_ROW_ID

	IF @@ERROR = 0
		COMMIT
	ELSE
		ROLLBACK

	FETCH FROM curData INTO @DEX_ROW_ID, @EmailCardAddress
END

CLOSE curData
DEALLOCATE curData

GO

