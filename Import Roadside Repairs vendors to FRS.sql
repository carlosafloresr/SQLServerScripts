INSERT INTO Vendors
	 ([Name]
      ,[Address]
      ,[City]
      ,[State]
      ,[Zip]
      ,[TaxClass]
      ,[FederalID]
      ,[Phone]
      ,[Email]
      ,[Contact]
      ,[PaymentType]
      ,[Status]
      ,[EffectiveDate]
      ,[Notes]
      ,[Longitude]
      ,[Latitude]
      ,[Hours]
      ,[Mobile]
      ,[Type])

SELECT	LEFT(Vendor, 50),
		LEFT(Address, 65),
		City,
		State,
		Zip,
		1,
		TaxId,
		Phone,
		Null,
		Null,
		CASE WHEN Payment = 2 THEN 1 ELSE 2 END,
		Active,
		Creation,
		Null,
		Latitude,
		Longitude,
		Hours,
		ISNULL(Mobile, 0),
		CASE WHEN VendorType = 1 THEN 2 ELSE 1 END
--SELECT	*
FROM	ILSGP01.GPCustom.dbo.RSA_VendorsNetwork
WHERE	Active = 1