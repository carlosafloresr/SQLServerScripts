SELECT	VENDORID,
		VENDNAME,
		VNDCLSID,
		ADDRESS1,
		ADDRESS2,
		CITY,
		STATE,
		ZIPCODE,
		'' AS COUNTY,
		GPCustom.dbo.FormatPhoneNumber(PHNUMBR1) AS Phone,
		GPCustom.dbo.FormatPhoneNumber(FAXNUMBR) AS Fax,
		'' AS Email,
		'',
		'USD',
		PYMTRMID
FROM	PM00200

-- SELECT * FROM PM00200