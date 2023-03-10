USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_Purchasing_Vouchers]    Script Date: 5/18/2022 8:34:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_Purchasing_Vouchers]
	@VoucherNumber	Varchar(25),
	@CompanyId		Varchar(6),
	@ProNumber		Varchar(20) = Null,
	@TrailerNumber	Varchar(15) = Null,
	@ChassisNumber	Varchar(15) = Null,
	@UserId			Varchar(25),
	@DriverId		Varchar(12) = Null,
	@Source			Char(2) = Null,
	@BatchId		Varchar(25) = Null,
	@SWSId			Varchar(30) = Null
AS

IF @Source IS Null
BEGIN
	IF LEN(@VoucherNumber) < 8
		SET @Source = 'GL'
	ELSE
		SET @Source = 'AP'
END

DECLARE @RecordId	Int
SET	@RecordId	= (SELECT VoucherLineId FROM Purchasing_Vouchers WHERE VoucherNumber = RTRIM(@VoucherNumber) AND CompanyId = RTRIM(@CompanyId) AND [Source] = @Source)

IF @RecordId IS Null
BEGIN
	BEGIN TRANSACTION

	INSERT INTO Purchasing_Vouchers
	       ([Source],
			VoucherNumber,
			CompanyId,
			ProNumber,
			TrailerNumber,
			ChassisNumber,
			DriverId,
			BatchId,
			SWSId,
			EnteredBy,
			ChangedBy)
		VALUES (@Source,
			@VoucherNumber,
			@CompanyId,
			@ProNumber,
			@TrailerNumber,
			@ChassisNumber,
			@DriverId,
			@BatchId,
			@SWSId,
			@UserId,
			@UserId)

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @@IDENTITY
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END
ELSE
BEGIN
	BEGIN TRANSACTION

	UPDATE	Purchasing_Vouchers
	SET		ProNumber		= @ProNumber,
			TrailerNumber	= @TrailerNumber,
			ChassisNumber	= @ChassisNumber,
			DriverId		= @DriverId,
			ChangedBy		= @UserId,
			ChangedOn		= GETDATE()
	WHERE	VoucherLineId 	= @RecordId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @RecordId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END