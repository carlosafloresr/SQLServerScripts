SELECT	OTR_Number
		,TicketStatus
		,Eqipment_Location
		,Repair_Source
		,ProNumber
		,Container
		,Chassis
		,EquipmentStatus
		,Company
		,DomicileDiv AS Division
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
		,ISNULL(CAST(IdVendor AS Varchar), '') AS VendorId
		,ISNULL(VendorId, '') AS GPVendorId
		,ISNULL(Vendor, '') AS VendorName
		,ISNULL(CityState, '') AS VendorCityState
		,PaymentType
		,ISNULL(EFSAmount, '') AS EFSAmount
		,EFSTransaction
		,InvoiceNumber
		,InvoiceTotal
		,CompanyOwned
		,ISNULL(IEPApprovedVendor, '') AS IEPApprovedVendor
		,ServiceUser
		,CASE WHEN TireRack = 1 THEN 'YES' ELSE 'NO' END AS SpareTire
		,ISNULL(TireDOTNumber, '') AS TireDOTNumber
FROM	View_RSA_Tickets
WHERE	Creation >= GETDATE() - 180
ORDER BY Creation