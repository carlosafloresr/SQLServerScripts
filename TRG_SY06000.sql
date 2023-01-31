USE GLSO
GO

SET ANSI_NULLS ON
GO 
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER dbo.TRG_SY06000 ON dbo.SY06000
   FOR INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @VendorId	Varchar(12),
			@Company	Varchar(5) = DB_NAME(),
			@DataDate	Date,
			@RecordId	Int

	SELECT	@VendorId = RTRIM(VendorId),
			@DataDate = EFTPrenoteDate
	FROM	Inserted

	IF EXISTS(SELECT TOP 1 GP_EFT_VendorId FROM GPCustom.dbo.GP_EFT_Vendors WHERE Company = @Company AND VendorId = @VendorId)
    BEGIN
		IF @DataDate > '01/01/1980'
			UPDATE	GPCustom.dbo.GP_EFT_Vendors
			SET		EFTPrenoteDate = @DataDate,
					Changed	 = 1
			FROM	(
					SELECT	TOP 1 *
					FROM	GPCustom.dbo.GP_EFT_Vendors
					WHERE	Company = @Company
							AND VendorId = @VendorId
					ORDER BY DataDate DESC
					) DATA
			WHERE	GP_EFT_Vendors.GP_EFT_VendorId = DATA.GP_EFT_VendorId
	END
END
GO
