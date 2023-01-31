USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[sp_Companies_GetVendorsGP]    Script Date: 7/21/2022 9:32:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE sp_Companies_GetVendorsGP 'GLSO'
*/
ALTER PROCEDURE [dbo].[sp_Companies_GetVendorsGP]
	@Company Varchar(5)
AS
BEGIN
	DECLARE @Query		Varchar(2000),
			@VndClass	Varchar(10)

	SET @VndClass = ISNULL((SELECT ParString FROM Companies_Parameters WHERE ParameterCode = 'RSR_VNDCLASS' AND CompanyId = @Company),'MSCO')

	SET @Query = '	SELECT	LTRIM(RTRIM(VendorId)) AS VendorId, LTRIM(RTRIM(VendName)) AS VendorName
					FROM	' + @Company + '.dbo.PM00200 
					WHERE	VNDCLSID = ''' + @VndClass + ''' AND VENDSTTS = 1
					ORDER BY VendName'

	EXECUTE(@Query)
END