ALTER PROCEDURE USP_RunBatch
		@Integration	Varchar(6),
		@Company		Varchar(6),
		@BatchId		Varchar(30)
AS
DECLARE	@err			Int,
		@sh				Int,
		@ret			Varchar(Max),
		@msg			Varchar(32),
		@src			Varchar(8000),
		@desc			Varchar(8000)

SELECT	@msg = 'SP_OACreate'
EXECUTE	@err = SP_OACreate 'MSSOAP.SoapClient30', @sh OUT

IF @err = 0
BEGIN
	SELECT	@msg = 'MSSoapInit'
	EXECUTE	@err = SP_OAMethod @sh, 'MSSoapInit', NULL, 'http://ILSINT01/ILSIntegrations.asmx?WSDL'
END

IF @err = 0
BEGIN
	SELECT	@msg = 'Call Web Service'
	EXECUTE	@err = SP_OAMethod @sh, 'ProcessBatch', @ret OUT, @Integration, @Company, @BatchId
END

IF @err = 0
BEGIN
	SELECT	@msg = 'SP_OADestroy'
	EXECUTE SP_OADestroy @sh
END

IF @err = 0
	SELECT [ret] = @ret
ELSE
BEGIN
	EXECUTE SP_OAGetErrorInfo @sh, @src OUT, @desc OUT

	PRINT @msg
	PRINT @src
	PRINT @desc
	PRINT CONVERT(Varbinary(4), @err)
END
