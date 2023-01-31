/*
SELECT	* 
FROM	DriverDocuments 
WHERE	BatchId = ''
*/
CREATE PROCEDURE USP_FixFuelDocumentRecords
		@Company	Varchar(5),
		@WeekEnd	Datetime
AS
UPDATE	DriverDocuments
SET		DriverDocuments.BatchId = REC.BatchId
FROM	(
		SELECT	DD.Company
				,DD.VendorId
				,DD.WeekEndingDate
				,DD.Fk_DocumentTypeId
				,DD.FileName
				,DW.BatchId 
		FROM	DriverDocuments DD
				INNER JOIN 
				(SELECT	DISTINCT CompanyId
						,VendorId 
						,WeekEndDate
						,BatchId
				FROM	ILS_Datawarehouse.dbo.DrvReps_RemittanceAdvise
				WHERE	CompanyId = @Company
						AND WeekEndDate = @WeekEnd
						AND BatchId <> '') DW ON DD.Company = DW.CompanyID AND DD.VendorId = DW.VendorId AND DD.WeekEndingDate = DW.WeekEndDate
		WHERE	DD.BatchId = '') REC
WHERE	DriverDocuments.Company = REC.Company 
		AND DriverDocuments.VendorId = REC.VendorId 
		AND DriverDocuments.WeekEndingDate = REC.WeekEndingDate
