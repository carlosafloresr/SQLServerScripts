DECLARE	@Company		Varchar(5) = DB_NAME(),
		@WeekEndDate	Date = '07/29/2017'

SELECT	Company,
		BatchId,
		DetailId,
		CAST(WeekEndDate AS Date) AS WeekEndDate,
		CustomerNumber,
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
FROM	ILSINT02.Integrations.dbo.View_Integration_FSI_Vendors
WHERE	WeekEndDate = @WeekEndDate
		AND Company = @Company
		AND VndIntercompany = 0

SELECT	*
FROM	(
		SELECT	DISTINCT FSI.*,
				CAST(ISNULL(ARO.ORTRXAMT,ARH.ORTRXAMT) AS Numeric(10,2)) AS GP_Amount,
				CAST(ISNULL(ARO.DOCDATE,ARH.DOCDATE) AS Date) AS GP_Date
		FROM	##tmpFSI FSI
				LEFT JOIN RM20101 ARO ON FSI.CustomerNumber = ARO.custnmbr AND FSI.InvoiceNumber = ARO.DocNumbr
				LEFT JOIN RM30101 ARH ON FSI.CustomerNumber = ARH.custnmbr AND FSI.InvoiceNumber = ARH.DocNumbr
		) DATA
WHERE	GP_Amount IS Null

DROP TABLE ##tmpFSI

-- select top 100 * from RM20101