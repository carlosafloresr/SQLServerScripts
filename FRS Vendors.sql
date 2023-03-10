/****** Script for SelectTopNRows command from SSMS  ******/
SELECT	VND.[vendor]
		,VND.[address]
		,VND.[city]
		,VND.[state]
		,VND.[zipcode]
		,VND.[typeservic] AS TypeOfService
		,VND.[phone]
		,VND.[cell]
		,VND.[payment] AS PaymentType
		,RSA.TAXDEFINITION AS TaxCompleted
		,RSA.VendorId
		,MAP.NewVendorId AS GP_Vendor
		--,COALESCE((SELECT VendorId FROM RSA_VendorsNetworkGP GPV WHERE GPV.Fk_RSA_VendorsNetworkId = RSA.VendorId AND GPV.Company = 'IMC'),(SELECT VendorId FROM RSA_VendorsNetworkGP GPV WHERE GPV.Fk_RSA_VendorsNetworkId = RSA.VendorId AND GPV.Company = 'DNJ'),(SELECT VendorId FROM RSA_VendorsNetworkGP GPV WHERE GPV.Fk_RSA_VendorsNetworkId = RSA.VendorId AND GPV.Company = 'AIS'))
		--,GP_Company = COALESCE((SELECT 'IMC' FROM RSA_VendorsNetworkGP GPV WHERE GPV.Fk_RSA_VendorsNetworkId = RSA.VendorId AND GPV.Company = 'IMC'),(SELECT 'DNJ' FROM RSA_VendorsNetworkGP GPV WHERE GPV.Fk_RSA_VendorsNetworkId = RSA.VendorId AND GPV.Company = 'DNJ'),(SELECT 'AIS' FROM RSA_VendorsNetworkGP GPV WHERE GPV.Fk_RSA_VendorsNetworkId = RSA.VendorId AND GPV.Company = 'AIS'))
FROM	[GPCustom].[dbo].[FRS_Vendors] VND
		LEFT JOIN View_RSA_VendorNetwork_DataExport RSA ON VND.PHONE = REPLACE(RSA.PHONE, '-', '')
		LEFT JOIN FRS_MappedVendors MAP ON COALESCE((SELECT VendorId FROM RSA_VendorsNetworkGP GPV WHERE GPV.Fk_RSA_VendorsNetworkId = RSA.VendorId AND GPV.Company = 'IMC'),(SELECT VendorId FROM RSA_VendorsNetworkGP GPV WHERE GPV.Fk_RSA_VendorsNetworkId = RSA.VendorId AND GPV.Company = 'DNJ'),(SELECT VendorId FROM RSA_VendorsNetworkGP GPV WHERE GPV.Fk_RSA_VendorsNetworkId = RSA.VendorId AND GPV.Company = 'AIS')) = MAP.VendorId AND VND.Payment = MAP.Payment
WHERE	RSA.VendorId IS NOT Null
		--AND VND.[payment] = 'Charge Account'
ORDER BY 1, 4,3

  /*
  SELECT	*
  FROM		RSA_VendorsNetworkGP
  WHERE		Fk_RSA_VendorsNetworkId = 2227
  */