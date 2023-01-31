ALTER TRIGGER TRG_INS_ReceivedIntegrations ON ReceivedIntegrations AFTER INSERT,UPDATE
AS
IF UPDATE(Status)
BEGIN
	DECLARE	@Integration	Varchar(5),
			@BatchId		Varchar(30),
			@EmailAddress	Varchar(50),
			@Email			Varchar(Max),
			@Status			Int

	SELECT	@Integration	= Integration,
			@BatchId		= BatchId,
			@EmailAddress	= EmailAddress,
			@Email			= Email,
			@Status			= Status
	FROM	Inserted

	PRINT @Status
END