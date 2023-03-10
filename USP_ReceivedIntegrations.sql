ALTER PROCEDURE [dbo].[USP_ReceivedIntegrations]
	@Integration	varchar(5),
	@Company		varchar(5),
	@BatchId		varchar(30),
	@Status			int,
	@EmailAddress	varchar(50) = Null,
	@Email			varchar(max) = Null,
	@Subject		varchar(50) = Null,
	@ReceivedOn		datetime = Null
AS
IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE BatchId = @BatchId AND Company = @Company)
BEGIN
	UPDATE	ReceivedIntegrations
	SET		Email			= CASE WHEN @Email IS Null THEN Email ELSE @Email END,
			EmailAddress	= CASE WHEN @EmailAddress IS Null THEN EmailAddress ELSE @EmailAddress END,
			Subject			= CASE WHEN @Subject IS Null THEN Subject ELSE @Subject END,
			Status			= @Status
	WHERE	BatchId			= @BatchId 
			AND Company		= @Company
END
ELSE
BEGIN
	INSERT INTO ReceivedIntegrations
		   (Integration,
			BatchId,
			Company,
			ReceivedOn,
			Email,
			EmailAddress,
			Subject,
			Status)
	VALUES (@Integration,
			@BatchId,
			@Company,
			ISNULL(@ReceivedOn, GETDATE()),
			@Email,
			@EmailAddress,
			@Subject,
			@Status)
END