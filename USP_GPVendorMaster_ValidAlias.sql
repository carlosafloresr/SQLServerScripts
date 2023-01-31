USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CustomerMaster_ValidAlias]    Script Date: 9/20/2017 4:25:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GPVendorMaster_ValidAlias 'PTS','HAPAGHOU','AACA'
*/
CREATE PROCEDURE [dbo].[USP_GPVendorMaster_ValidAlias]
		@Company	Varchar(5),
		@VendorId	Varchar(20),
		@VendAlias	Varchar(6)
AS
DECLARE @ValidAlias	Bit = 1

IF EXISTS(SELECT SWSVendorId 
		FROM	GPVendorMaster 
		WHERE	Company = @Company
				AND ((VendorId <> @VendorId
				AND SWSVendorId = @VendAlias)
				OR VendorId = @VendAlias))
BEGIN
	SET @ValidAlias = 0
END

SELECT	@ValidAlias AS ValidAlias

-- SELECT * FROM CustomerMaster WHERE CompanyId = 'PTS'