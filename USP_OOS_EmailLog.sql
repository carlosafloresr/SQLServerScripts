ALTER PROCEDURE USP_OOS_EmailLog
		@Company			Varchar(5),
		@VendorId			Varchar(12),
		@WeekendingDate		Date,
		@EmailSent			Bit,
		@Message			Varchar(200)
AS
DECLARE	@RecordId			Bigint

SET @RecordId = (SELECT RecordId FROM OOS_EmailLog WHERE Company = @Company AND VendorId = @VendorId AND WeekendingDate = @WeekendingDate)

IF @RecordId IS Null
BEGIN
	INSERT INTO OOS_EmailLog
			(Company,
			VendorId,
			WeekendingDate,
			EmailSent,
			[Message])
	VALUES
			(@Company,
			@VendorId,
			@WeekendingDate,
			@EmailSent,
			@Message)
END
ELSE
BEGIN
	UPDATE	OOS_EmailLog
	SET		EmailSent	= @EmailSent,
			[Message]	= @Message
	WHERE	RecordId	= @RecordId
END