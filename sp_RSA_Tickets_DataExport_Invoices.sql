/*
EXECUTE sp_RSA_Tickets_DataExport_Invoices '01/01/2014','08/27/2014','E',1200
*/
CREATE PROCEDURE sp_RSA_Tickets_DataExport_Invoices
		@DateIni	Date,
		@DateEnd	Date,
		@PayType	Char(1) = 'A',
		@Amount		Numeric(10,2) = 0,
		@Company	Varchar(5) = Null,
		@UserId		Varchar(25) = Null,
		@VendorId	Varchar(12) = Null,
		@VendorLike	Varchar(25) = Null
AS
IF @PayType IS Null
	SET @PayType = 'A'

SELECT	OTR_Number
		,TicketStatus
		,ISNULL(CAST(IdVendor AS Varchar), '') AS VendorId
		,ISNULL(VendorId, '') AS GPVendorId
		,ISNULL(Vendor, '') AS VendorName
		,ISNULL(CityState, '') AS VendorCityState
		,PaymentType
		,ISNULL(EFSAmount, '') AS EFSAmount
		,EFSTransaction
		,Company
		,DomicileDiv AS Division
		,REPLACE(REPLACE(InvoiceNumber, '_', ''), ' ', '') AS InvoiceNumber
		,BaseAmount
		,ServiceCharges
		,Mileage
		,Other
		,SalesTax
		,InvoiceTotal
		,Eqipment_Location
		,Repair_Source
		,ProNumber
		,Container
		,Chassis
		,EquipmentStatus
		,DriverNumber
		,dbo.PROPER(DriverName) AS DriverName
		,[Week]
		,[Month]
		,Creation AS CreationTime
		,DispatchDateTime AS DispatchTime
		,ETADateTime AS ETA
		,RepairCompletionDateTime AS CompletionTime
		,ISNULL(StartToCompletionTime, 0) AS StartToCompletionTime
		,ISNULL(ETAToCompletionTime, 0) AS ETAToCompletionTime
		,CallTime
		,CompanyOwned
		,ISNULL(IEPApprovedVendor, '') AS IEPApprovedVendor
		,ServiceUser
		,UserName
		,CASE WHEN TireRack = 1 THEN 'YES' ELSE 'NO' END AS SpareTire
		,ISNULL(TireDOTNumber, '') AS TireDOTNumber
INTO	#tmpAllByVendor
FROM	View_RSA_Tickets
WHERE	TicketStatus IN ('Invoiced','In Great Plains')
		AND (@DateIni IS Null OR (@DateIni IS NOT Null AND Creation BETWEEN @DateIni AND @DateEnd))
		AND (@Company IS Null OR Company = @Company)
		AND (@UserId IS Null OR ServiceUser = @UserId)
		AND (@VendorId IS Null OR IdVendor = @VendorId)
		AND (@VendorLike IS Null OR (@VendorLike IS NOT Null AND Vendor LIKE ('%' + @VendorLike + '%')))
		AND (@PayType = 'A' OR (@PayType = 'E' AND PaymentType = 'EFS') OR (@PayType = 'C' AND PaymentType = 'Charge Account'))
ORDER BY 3, Creation

SELECT	VendorId
		,SUM(InvoiceTotal) AS InvoiceTotal
INTO	#tmpSumByVendor
FROM	#tmpAllByVendor
GROUP BY VendorId

SELECT	*
FROM	#tmpAllByVendor
WHERE	VendorId IN (SELECT VendorId FROM #tmpSumByVendor WHERE InvoiceTotal >= @Amount)

DROP TABLE #tmpAllByVendor
DROP TABLE #tmpSumByVendor