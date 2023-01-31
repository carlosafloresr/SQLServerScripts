USE [GPCustom]
GO

ALTER PROCEDURE USP_GP_EFT_Vendors
		@FileId bigint,
		@Company varchar(5),
		@VendorId varchar(12),
		@EFTPrenoteDate date = Null
AS
IF EXISTS(SELECT FileId FROM GP_EFT_Vendors WHERE Company = @Company AND VendorId = @VendorId)
	UPDATE	GP_EFT_Vendors
	SET		EFTPrenoteDate		= @EFTPrenoteDate,
			DataDate			= GETDATE(),
			FileBoundSubmited	= 0
	WHERE	Company = @Company
			AND VendorId = @VendorId
ELSE
	INSERT INTO [dbo].[GP_EFT_Vendors]
			   ([FileId]
			   ,[Company]
			   ,[VendorId]
			   ,[EFTPrenoteDate])
	VALUES
			   (@FileId
			   ,@Company
			   ,@VendorId
			   ,@EFTPrenoteDate)
GO


