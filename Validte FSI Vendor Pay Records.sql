DECLARE	@Company		Varchar(5) = DB_NAME(),
		@WeekEndDate	Date = '07/28/2018'

SELECT	Company,
		BatchId,
		CAST(WeekEndDate AS Date) AS WeekEndDate,
		InvoiceNumber,
		RecordCode AS VendorId,
		ChargeAmount1 AS Amount,
		VendorDocument,
		TrxDscrn,
		Division,
		FSI_ReceivedSubDetailId,
		CAST(FSI_ReceivedSubDetailId AS Varchar) + ',' AS QueryId,
		VNDIntercompany
INTO	##tmpFSI
FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI_Vendors
WHERE	WeekEndDate = @WeekEndDate
		AND Company = @Company
		AND VndIntercompany = 0

SELECT	*
FROM	(
		SELECT	DISTINCT FSI.*,
				CAST(ISNULL(APO.DOCAMNT,APH.DOCAMNT) AS Numeric(10,2)) AS GP_Amount,
				CAST(ISNULL(APO.DOCDATE,APH.DOCDATE) AS Date) AS GP_Date
		FROM	##tmpFSI FSI
				LEFT JOIN PM20000 APO ON FSI.VendorId = APO.VendorId AND FSI.VendorDocument = APO.DocNumbr
				LEFT JOIN PM30200 APH ON FSI.VendorId = APH.VendorId AND FSI.VendorDocument = APH.DocNumbr
		) DATA
WHERE	GP_Amount IS Null

DROP TABLE ##tmpFSI