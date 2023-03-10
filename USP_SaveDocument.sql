ALTER PROCEDURE [dbo].[USP_SaveDocument]
	@Document	varchar(40),
	@DocType	varchar(6),
	@DocNumber	varchar(20),
	@Par_Type	varchar(6),
	@Par_Doc	varchar(20)
AS
IF NOT EXISTS(SELECT Document FROM FI_Documents WHERE DocType = @DocType AND DocNumber = @DocNumber AND Par_Doc = @Par_Doc)
BEGIN
	INSERT INTO FI_Documents
			(Document
			,DocType
			,DocNumber
			,Par_Type
			,Par_Doc)
	VALUES
			(@Document
			,@DocType
			,@DocNumber
			,@Par_Type
			,@Par_Doc)
END