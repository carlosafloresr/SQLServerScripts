USE GPCustom
GO

DECLARE @Query	Varchar(MAX),
		@Update	Bit = 0

--SELECT	*
--FROM	GPVendorMaster
--WHERE	VENDORID = '513'

DECLARE @tblSWSVendors Table (CompanNum Int, VendorId Varchar(15), VndStatus Char(1))

SET @Query = N'SELECT cmpy_no, code, status FROM TRK.Vendor'

INSERT INTO @tblSWSVendors
EXECUTE USP_QuerySWS_ReportData @Query

SELECT	CPY.CompanyId,
		SWS.CompanNum,
		SWS.VendorId,
		IIF(SWS.VndStatus = 'I', 'Inactive', 'Active') AS VndStatus,
		VND.SWSVendor,
		VND.VendName,
		VND.ChangedOn,
		VND.UserId,
		IIF(VND.Status = 'I', 'Inactive', 'Active') AS GPStatus,
		ISNULL(VND.SWSInactive,0) AS SWSInactive
FROM	@tblSWSVendors SWS
		INNER JOIN Companies CPY ON SWS.CompanNum = CPY.CompanyNumber AND CPY.CompanyId NOT IN ('ATEST','NDS','PTS','IMCMR','IMCCS','IMCC','IILS')
		INNER JOIN GPVendorMaster VND ON CPY.CompanyId = VND.Company AND SWS.VendorId = ISNULL(VND.SWSVendorId,VND.VendorId)
WHERE	(SWS.VndStatus = 'A' AND (VND.Status = 'I' OR VND.SWSInactive = 1))
		OR (SWS.VndStatus = 'I' AND VND.Status = 'A' AND VND.SWSInactive = 0)
		OR VND.SWSVendor = 0
		--OR SWS.VendorId = '50688G'
ORDER BY CPY.CompanyId, SWS.VendorId

IF @Update = 1
BEGIN
	UPDATE	GPVendorMaster
	SET		GPVendorMaster.Changed = 1,
			GPVendorMaster.SWSVendor = 1
	FROM	(
			SELECT	CPY.CompanyId,
					SWS.*,
					VND.SWSVendor,
					VND.Status,
					VND.VendorId AS VndId
			FROM	@tblSWSVendors SWS
					INNER JOIN Companies CPY ON SWS.CompanNum = CPY.CompanyNumber AND CPY.CompanyId NOT IN ('ATEST','NDS','PTS','IMCMR','IMCCS','IMCC')
					INNER JOIN GPVendorMaster VND ON CPY.CompanyId = VND.Company AND SWS.VendorId = ISNULL(VND.SWSVendorId,VND.VendorId)
			WHERE	(SWS.VndStatus = 'A' AND (VND.Status = 'I' OR VND.SWSInactive = 1))
					OR (SWS.VndStatus = 'I' AND (VND.Status = 'A' AND VND.SWSInactive = 0))
					OR VND.SWSVendor = 0
			) TMP
	WHERE	TMP.CompanyId = GPVendorMaster.Company
			AND TMP.VndId = GPVendorMaster.VendorId
END