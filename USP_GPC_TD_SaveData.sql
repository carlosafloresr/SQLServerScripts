CREATE PROCEDURE USP_GPC_TD_SaveData
	@TDExtendedInfoId	Int,
	@Company		Char(5),
	@VoucherNo		Varchar(25), 
	@AccountNumber		Varchar(10), 
	@AccountType		Int,
	@ReferenceId		Varchar(25),  
	@ProNumber		Varchar(12), 
	@DriverId		Int,
	@Description		Varchar(50)
AS
DECLARE	@RecordId		Int

BEGIN TRANSACTION
IF EXISTS (SELECT TDExtendedInfoId FROM TDExtendedInfo WHERE TDExtendedInfoId = @TDExtendedInfoId)
BEGIN
	UPDATE	TDExtendedInfo
	SET	ReferenceId		= @ReferenceId,
		ProNumber		= @ProNumber,
		DriverId		= @DriverId,
		Description		= @Description
	WHERE	TDExtendedInfoId	= @TDExtendedInfoId

	SET	@RecordId 		= @TDExtendedInfoId
END
ELSE
BEGIN
	INSERT INTO TDExtendedInfo (
		Company,
		VoucherNo,
		AccountNumber,
		AccountType,
		ReferenceId,
		ProNumber,
		DriverId,
		Description)
	VALUES (@Company,
		@VoucherNo,
		@AccountNumber,
		@AccountType,
		@ReferenceId,
		@ProNumber,
		@DriverId,
		@Description)

	SET	@RecordId = @@IDENTITY
END

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	RETURN @RecordId
END
ELSE
BEGIN
	ROLLBACK
	RETURN @@ERROR * -1
END

GO
