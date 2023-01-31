DECLARE	@CompanyId		Varchar(5) = 'OIS',
		@CompanyNum		Varchar(2),
		@Query			Varchar(300)

SET @CompanyNum = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId)
SET @Query = 'SELECT * FROM trk.vendor WHERE cmpy_no = ' + @CompanyNum

EXECUTE USP_QuerySWS_ReportData @Query, '##tmpdata'

UPDATE	GPVendorMaster
SET		SWSVendor = 1
FROM	(
SELECT	VendorId --, VendName, SWSVendor, SWSVendorId
FROM	GPVendorMaster 
WHERE	Company = @CompanyId
		AND ISNULL(SWSVendorId,vendorid) IN (SELECT Code FROM ##tmpdata)
		AND SWSVendor = 0
		) DATA
WHERE	GPVendorMaster.VendorId = DATA.VendorId
		AND GPVendorMaster.Company = @CompanyId

--SELECT	*
--FROM	##tmpdata
--WHERE	Code  in (SELECT isnull(SWSVendorId,vendorid) FROM GPVendorMaster WHERE Company = 'AIS')
--ORDER BY 2

DROP TABLE ##tmpdata