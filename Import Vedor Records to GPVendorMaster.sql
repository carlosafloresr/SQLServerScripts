USE GLSO
GO

INSERT INTO [GPCustom].[dbo].[GPVendorMaster]
        ([Company]
        ,[VendorId]
        ,[VendName]
        ,[Address1]
        ,[Address2]
        ,[City]
        ,[State]
        ,[ZipCode]
        ,[Status]
        ,[Phone]
        ,[Email]
        ,[VendClass]
        ,[SWSVendor]
        ,[Changed]
        ,[ChangedOn])
SELECT	DB_NAME() AS Company,
		RTRIM(P2.VendorId) AS VendorId,
		RTRIM(LEFT(VendName, 30)) AS VendName,
		RTRIM(LEFT(P3.Address1, 30)) as Address1,
		RTRIM(LEFT(P3.Address2, 30)) as Address2,
		RTRIM(P3.City) AS City,
		RTRIM(P3.State) AS State,
		RTRIM(P3.ZipCode) AS ZipCode,
		CASE WHEN VendStts = 1 THEN 'A' ELSE 'I' END AS Status,
		CASE WHEN P3.PHNUMBR1 IS Null THEN ''
				WHEN P3.PHNUMBR1 = '' THEN ''
				WHEN LEFT(P3.PHNUMBR1, 6) = '000000' THEN ''
				ELSE SUBSTRING(REPLACE(REPLACE(REPLACE(P3.PHNUMBR1, '-', ''), ')', ''), '(', ''), 1, 3) + '-' + SUBSTRING(REPLACE(REPLACE(REPLACE(P3.PHNUMBR1, '-', ''), ')', ''), '(', ''), 4, 3) + '-' + SUBSTRING(REPLACE(REPLACE(REPLACE(P3.PHNUMBR1, '-', ''), ')', ''), '(', ''), 7, 4)
		END AS Phone,
		ISNULL(RTRIM(LEFT(SY.EmailCardAddress, 40)), '') AS Email,
		RTRIM(P2.VNDCLSID) AS VendClass,
		1 AS SWSVendor,
		1 AS Changed,
		GETDATE() AS ChangedOn
FROM	PM00200 P2
		LEFT JOIN PM00300 P3 ON P2.VendorId = P3.VendorId AND P3.AdrsCode = 'MAIN'
		LEFT JOIN SY04906 SY ON SY.EmailRecipientTypeTo = 1 AND P2.VendorId = SY.EmailCardid 
WHERE	--P2.VendorId NOT IN (SELECT VendorId FROM GPCustom.dbo.GPVendorMaster WHERE Company = DB_NAME())
		p2.vendorid = '8066'

		--update GPCustom.dbo.GPVendorMaster set changed = 1 where vendorid = '1073' and Company = 'ais'

--select * from GPCustom.dbo.GPVendorMaster where vendorid = '50077A' and Company = 'ais'