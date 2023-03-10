USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AP_VelidEFT]    Script Date: 11/15/2022 2:46:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AP_VelidEFT 'DNJ', 'D50121'
*/
ALTER PROCEDURE [dbo].[USP_AP_VelidEFT]
		@Company		Varchar(5),
		@VendorId		Varchar(15)
AS
SET NOCOUNT ON

DECLARE	@tblEFT			Table (PrenoteDate Date, GraceDays Int)

DECLARE @PrenoteDate	Date,
		@GraceDays		Int,
		@ValidEFT		Bit = 0,
		@Query			varchar(MAX)

SET @Query = N'SELECT SY06.EFTPrenoteDate, ISNULL(CH.EFTPMPrenoteGracePeriod, 1) 
FROM ' + @Company + '.dbo.SY06000 SY06
		INNER JOIN ' + @Company + '.dbo.PM00200 AP ON SY06.VENDORID = AP.VENDORID
		INNER JOIN ' + @Company + '.dbo.CM00101 CH ON AP.CHEKBKID = CH.CHEKBKID
WHERE	SY06.EFTTransitRoutingNo <> ''''
		AND SY06.EFTBankAcct <> ''''
		AND SY06.INACTIVE = 0
		AND SY06.EFTPrenoteDate > ''01/01/1980''
		AND SY06.ADRSCODE = (SELECT VADCDTRO FROM ' + @Company + '.dbo.PM00200 PM02 WHERE PM02.VENDORID = SY06.VENDORID) 
		AND SY06.VENDORID = ''' + @VendorId + ''''

INSERT INTO @tblEFT
EXECUTE(@Query)

PRINT @Query

IF (SELECT COUNT(*) FROM @tblEFT) <> 0
BEGIN
	SET @PrenoteDate	= ISNULL((SELECT PrenoteDate FROM @tblEFT), GETDATE())
	SET @GraceDays		= (SELECT GraceDays FROM @tblEFT)
	SET @ValidEFT		= IIF(GETDATE() > DATEADD(dd, @GraceDays, @PrenoteDate), 1, 0)
END

SELECT @ValidEFT AS ValidEFT