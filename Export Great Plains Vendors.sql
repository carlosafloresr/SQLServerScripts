SELECT	DB_NAME() AS CompanyId,
		VendorId,
		VendName,
		Address1,
		Address2,
		Address3,
		City,
		State,
		ZipCode, 
		Country,
		CASE WHEN LEFT(Phnumbr1, 6) = '000000' THEN '' ELSE GPCustom.dbo.FormatPhoneNumber(Phnumbr1) END AS Phone1,
		CASE WHEN LEFT(Phnumbr2, 6) = '000000' THEN '' ELSE GPCustom.dbo.FormatPhoneNumber(Phnumbr2) END AS Phone2,
		CASE WHEN LEFT(Phone3, 6) = '000000' THEN '' ELSE GPCustom.dbo.FormatPhoneNumber(Phone3) END AS Phone3,
		CASE WHEN LEFT(FaxNumbr, 6) = '000000' THEN '' ELSE GPCustom.dbo.FormatPhoneNumber(FaxNumbr) END AS Fax,
		Comment1,
		Comment2,
		CASE WHEN VENDSTTS = 1 THEN 'NO' ELSE 'YES' END AS Inactive
FROM	PM00200
ORDER BY VENDNAME
