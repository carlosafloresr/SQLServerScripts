USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_RapidPay_VendorAddress]    Script Date: 2/3/2022 1:37:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_RapidPay_VendorAddress 'GLSO', '1173' 
*/
ALTER PROCEDURE [dbo].[USP_RapidPay_VendorAddress]
		@Company		Varchar(5),
		@VendorId		Varchar(15)
AS
DECLARE @Query			Varchar(MAX),
		@EffectiveDate	Date = (SELECT RP_EffectiveDate FROM GPVendorMaster WHERE Company = @Company AND VendorId = @VendorId)

SET @Query = N'SELECT ''' + RTRIM(@Company) + ''' AS COMPANY,
		[VENDORID]
		,[ADRSCODE]
		,[VNDCNTCT]
		,[ADDRESS1]
		,[ADDRESS2]
		,[ADDRESS3]
		,[CITY]
		,[STATE]
		,[ZIPCODE]
		,[COUNTRY]
		,[UPSZONE]
		,[PHNUMBR1]
		,[PHNUMBR2]
		,[PHONE3]
		,[FAXNUMBR]
		,[SHIPMTHD]
		,[TAXSCHID]
		,[EmailPOs]
		,[POEmailRecipient]
		,[EmailPOFormat]
		,[FaxPOs]
		,[POFaxNumber]
		,[FaxPOFormat]
		,[CCode]
		,[DECLID]
		,[DEX_ROW_TS]
		,[DEX_ROW_ID]
		,''' + CONVERT(Char(10), @EffectiveDate, 101) + ''' 
FROM	' + RTRIM(@Company) + '.dbo.PM00300
WHERE	VENDORID = ''' + RTRIM(@VendorId) + ''' 
		AND ADRSCODE IN (SELECT VADCDTRO FROM ' + RTRIM(@Company) + '.dbo.PM00200 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''')'

IF NOT EXISTS(SELECT VendorId FROM RapidPay_VendorAddress WHERE Company = @Company AND VendorId = @VendorId AND EffectiveDate = @EffectiveDate)
BEGIN
	INSERT INTO [dbo].[RapidPay_VendorAddress]
			   ([COMPANY]
			   ,[VENDORID]
			   ,[ADRSCODE]
			   ,[VNDCNTCT]
			   ,[ADDRESS1]
			   ,[ADDRESS2]
			   ,[ADDRESS3]
			   ,[CITY]
			   ,[STATE]
			   ,[ZIPCODE]
			   ,[COUNTRY]
			   ,[UPSZONE]
			   ,[PHNUMBR1]
			   ,[PHNUMBR2]
			   ,[PHONE3]
			   ,[FAXNUMBR]
			   ,[SHIPMTHD]
			   ,[TAXSCHID]
			   ,[EmailPOs]
			   ,[POEmailRecipient]
			   ,[EmailPOFormat]
			   ,[FaxPOs]
			   ,[POFaxNumber]
			   ,[FaxPOFormat]
			   ,[CCode]
			   ,[DECLID]
			   ,[DEX_ROW_TS]
			   ,[DEX_ROW_ID]
			   ,[EffectiveDate])
	EXECUTE(@Query)
END