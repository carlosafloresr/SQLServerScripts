/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * FROM [GPCustom].[dbo].[RapidPay_VendorAddress]
SELECT * FROM [RapidPay_VendorAch]
SELECT * FROM GPVendorMaster WHERE RapidPay = 1

DECLARE	@Company		Varchar(5) = 'GLSO',
		@VendorId		Varchar(15) = '1038'

SELECT * FROM PM00200 WHERE VENDORID = @VendorId
SELECT * FROM PM00300 WHERE VENDORID = @VendorId
SELECT * FROM SY06000 WHERE VENDORID = @VendorId

/*
DELETE PM00300 WHERE ADRSCODE = 'REMIT' AND VENDORID = '1038'
DELETE SY06000 WHERE ADRSCODE = 'REMIT' AND VENDORID = '1038'
*/

/*
EXECUTE USP_RapidPay_VendorAch 'GIS', '1070'
EXECUTE USP_RapidPay_VendorAch 'GIS', '1089'
EXECUTE USP_RapidPay_VendorAch 'GIS', '1094'

TRUNCATE TABLE RapidPay_VendorAch
TRUNCATE TABLE RapidPay_VendorAddress
*/

/*
UPDATE GPVendorMaster SET RapidPay = 1, RP_EffectiveDate = '01/25/2022', RP_Active = 1 WHERE Company = 'glso' AND VendorId IN ('1038')
*/