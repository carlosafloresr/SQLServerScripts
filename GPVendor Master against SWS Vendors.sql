USE GPCustom
GO

DECLARE @Query	Varchar(MAX),
		@Update	Bit = 0

DECLARE @tblSWSVendors Table (CompanNum Int, VendorId Varchar(15), VndStatus Char(1))

SET @Query = N'SELECT cmpy_no, code, status FROM TRK.Vendor'

INSERT INTO @tblSWSVendors
EXECUTE USP_QuerySWS_ReportData @Query

SELECT	*
FROM	(
		SELECT	CPY.CompanyAlias,
				SWS.CompanNum,
				SWS.VendorId,
				IIF(SWS.VndStatus = 'I', 'Inactive', 'Active') AS VndStatus,
				IIF(VND.SWSVendor = 1, 'YES', 'NO') AS SWSVendor,
				VND.VendName,
				VND.ChangedOn,
				ISNULL(VND.UserId,'') AS UserId,
				IIF(VND.Status = 'I', 'Inactive', 'Active') AS GPStatus,
				IIF(ISNULL(VND.SWSInactive,0) = 0, 'Inactive', 'Active') AS SWSInactive
		FROM	@tblSWSVendors SWS
				INNER JOIN View_CompaniesAndAgents CPY ON SWS.CompanNum = CPY.CompanyNumber AND CPY.CompanyId NOT IN ('ATEST','NDS','PTS','IMCMR','IMCCS','IMCC','IILS')
				INNER JOIN GPVendorMaster VND ON CPY.CompanyId = VND.Company AND SWS.VendorId = ISNULL(VND.SWSVendorId,VND.VendorId)
		WHERE	(SWS.VndStatus = 'A' AND (VND.Status = 'I' OR VND.SWSInactive = 1))
				OR (SWS.VndStatus = 'I' AND (VND.Status = 'A' OR VND.SWSInactive = 0))
				OR VND.SWSVendor = 0
		) DATA
WHERE	VndStatus <> SWSInactive
		OR SWSVendor = 'NO'
ORDER BY CompanyAlias, VendorId