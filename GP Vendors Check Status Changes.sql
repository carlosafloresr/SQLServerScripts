DECLARE	@Query		Varchar(MAX),
		@Company	Varchar(5) = 'PDS'

SET @Query = N'	SELECT	''' + @Company + ''' AS Company,
			RTRIM(P2.VendorId) AS VendorId,
			RTRIM(LEFT(VendName, 30)) AS VendName,
			RTRIM(LEFT(P3.Address1, 30)) as Address1,
			RTRIM(LEFT(P3.Address2, 30)) as Address2,
			RTRIM(P3.City) AS City,
			RTRIM(P3.State) AS State,
			RTRIM(P3.ZipCode) AS ZipCode,
			CASE WHEN VendStts <> 1 OR Hold = 1 THEN ''I'' ELSE ''A'' END AS Status,
			CASE WHEN P3.PHNUMBR1 IS Null THEN ''''
					WHEN P3.PHNUMBR1 = '''' THEN ''''
					WHEN LEFT(P3.PHNUMBR1, 6) = ''000000'' THEN ''''
					ELSE SUBSTRING(REPLACE(REPLACE(REPLACE(P3.PHNUMBR1, ''-'', ''''), '')'', ''''), ''('', ''''), 1, 3) + ''-'' + SUBSTRING(REPLACE(REPLACE(REPLACE(P3.PHNUMBR1, ''-'', ''''), '')'', ''''), ''('', ''''), 4, 3) + ''-'' + SUBSTRING(REPLACE(REPLACE(REPLACE(P3.PHNUMBR1, ''-'', ''''), '')'', ''''), ''('', ''''), 7, 4)
			END AS Phone,
			RTRIM(LEFT(P3.POEmailRecipient, 40)) AS Email,
			RTRIM(P2.VNDCLSID) AS VendClass
	INTO	##tmpGPVndData
	FROM	' + @Company + '.dbo.PM00200 P2
			LEFT JOIN ' + @Company + '.dbo.PM00300 P3 ON P2.VendorId = P3.VendorId AND P3.AdrsCode = ''MAIN'''

PRINT @Query
EXECUTE(@Query)

SELECT	TMP.*,
		ISNULL(VMA.[Status], TMP.Status) AS GP_Status,
		VMA.[Status] AS STSTUS2
FROM	##tmpGPVndData TMP
		LEFT JOIN GPVendorMaster VMA ON TMP.VendorId = VMA.VendorId AND TMP.Company = VMA.Company --AND VMA.SWSVendor = 1
--WHERE	TMP.[Status] <> ISNULL(VMA.[Status], TMP.Status)
--		OR TMP.vendorid = '50032W'
WHERE	VMA.SWSVendor = 1
order by tmp.vendorid

UPDATE	GPVendorMaster
SET		GPVendorMaster.[Status] = DATA.GP_Status,
		GPVendorMaster.Changed = 1
FROM	(
		SELECT	TMP.*,
				ISNULL(VMA.[Status], TMP.Status) AS GP_Status
		FROM	##tmpGPVndData TMP
				LEFT JOIN GPVendorMaster VMA ON TMP.VendorId = VMA.VendorId AND TMP.Company = VMA.Company
		--WHERE	VMA.SWSVendor = 1
		) DATA
WHERE	GPVendorMaster.Company = DATA.Company
		AND GPVendorMaster.VendorId = DATA.VendorId

DROP TABLE ##tmpGPVndData