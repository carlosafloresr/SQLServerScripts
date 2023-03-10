-- EXECUTE USP_NRD_CreaBatch NULL, 'IMC', 'NRD_080516_1353', 'NDR Testing', '05/16/2008', '0-00-1102', '0-00-1103'

ALTER PROCEDURE USP_NRD_CreaBatch
		@NRD_HeaderId	Int,
		@Company		Char(6),
		@BatchId		Char(15),
		@Description	Varchar(30),
		@BatchDate		Datetime,
		@DebitAccount	Char(10),
		@CreditAccount	Char(10)
AS
BEGIN TRANSACTION

IF @NRD_HeaderId IS Null OR @NRD_HeaderId = 0
BEGIN
	INSERT INTO NRD_Header (
			Company,
			BatchId,
			Description,
			BatchDate,
			DebitAccount,
			CreditAccount)
	VALUES (@Company,
			@BatchId,
			@Description,
			@BatchDate,
			@DebitAccount,
			@CreditAccount)

	IF @@ERROR = 0
		SET @NRD_HeaderId = @@IDENTITY
	ELSE
		SET @NRD_HeaderId = -1
END
ELSE
BEGIN
	BEGIN TRANSACTION

	UPDATE	NRD_Header
	SET		Company			= @Company,
			BatchId			= @BatchId,
			Description		= @Description,
			BatchDate		= @BatchDate,
			DebitAccount	= @DebitAccount,
			CreditAccount	= @CreditAccount
	WHERE	NRD_HeaderId = @NRD_HeaderId

	IF @@ERROR <> 0
		SET @NRD_HeaderId = -1
END

IF @@ERROR = 0
BEGIN
	DECLARE	@Query	Varchar(5000)
	SET		@Query = 'INSERT INTO NRD_Details (BatchId, VendorId, VendName) SELECT ''' + @BatchId + ''', VendorId, VendName '
	SET		@Query = @Query + 'FROM ' + RTRIM(@Company) + '.dbo.PM00200 WHERE VndClsId = ''DRV'' AND VendStts = 1'
	
EXECUTE(@Query)

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		SELECT * FROM NRD_Details WHERE BatchId = @BatchId ORDER BY VendName
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
END

RETURN @NRD_HeaderId