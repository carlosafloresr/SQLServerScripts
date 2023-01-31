/*
EXECUTE USP_Integrations_SOP_Batch 'PDINV', 'DNJ', 'PD180823114402R'
*/
ALTER PROCEDURE USP_Integrations_SOP_Batch
		@Integration	Varchar(6),
		@Company		Varchar(5),
		@BatchId		Varchar(20)
AS
SET NOCOUNT ON

DECLARE	@Account		Varchar(30),
		@AcctError		Varchar(200) = '',
		@Query			Varchar(Max) = ''

DECLARE	@tblAccount		Table (AcctActive Bit Null)

DECLARE	@tblData		Table (
		CUSTNMBR		Varchar(20), 
		SOPNUMBE		Varchar(30),
		DOCDATE			Date, 
		DOCAMNT			Numeric(10,2), 
		DistRef			Varchar(30),
		ACTNUMST		Varchar(30))

INSERT INTO @tblData
SELECT DISTINCT CUSTNMBR, SOPNUMBE, DOCDATE, DOCAMNT, DistRef, ACTNUMST FROM Integrations_SOP WHERE Integration = @Integration AND Company = @Company AND BACHNUMB = @BatchId AND Processed = 0

DECLARE curGLAccounts CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT RTRIM(ACTNUMST)
FROM	@tblData

OPEN curGLAccounts 
FETCH FROM curGLAccounts INTO @Account

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblAccount

	SET @Query = N'SELECT ACTIVE FROM LENSASQL001.' + @Company + '.dbo.GL00100 WHERE ACTINDX IN (SELECT ACTINDX FROM LENSASQL001.' + @Company + '.dbo.GL00105 WHERE ACTNUMST = ''' + RTRIM(@Account) + ''')'

	INSERT INTO @tblAccount
	EXECUTE(@Query)

	IF @@ROWCOUNT = 0
		SET @AcctError = @AcctError + IIF(@AcctError <> '', '/', '') + 'Account ' + RTRIM(@Account) + ' does not exists in GP'
	ELSE
	BEGIN
		IF (SELECT * FROM @tblAccount) = 0
			SET @AcctError = @AcctError + IIF(@AcctError <> '', '/', '') + 'Account ' + RTRIM(@Account) + ' is inactive in GP'
	END

	FETCH FROM curGLAccounts INTO @Account
END

CLOSE curGLAccounts
DEALLOCATE curGLAccounts

SELECT	DISTINCT CUSTNMBR, SOPNUMBE, DOCDATE, DOCAMNT, DistRef, @AcctError AS AcctError
FROM	@tblData