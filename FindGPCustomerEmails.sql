CREATE FUNCTION FindGPCustomerEmails (@Customer Varchar(15))
RETURNS Varchar(MAX)
AS
BEGIN
	DECLARE	@ReturnValue Varchar(MAX)
	
	SELECT @ReturnValue = COALESCE(@ReturnValue + ';', '') + RTRIM(Email_Recipient) FROM RM00106 WHERE CUSTNMBR = @Customer AND Email_Type = 1
	
	RETURN ISNULL(@ReturnValue,'')
END