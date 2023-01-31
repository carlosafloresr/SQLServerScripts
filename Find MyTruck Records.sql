/*
EXECUTE USP_MyTruck_Report 'IMC', 
M&R_Escrow > AR_Balance
*/
ALTER PROCEDURE USP_MyTruck_Report
		@Company	Varchar(5) = Null,
		@Filters	Varchar(5000) = Null
AS
DECLARE	@LastPay	DateTime,
		@Query		Varchar(Max)

SELECT	@LastPay = MAX(PayDate)
FROM	ILS_Datawarehouse.dbo.MyTruck

SELECT	Company
		,UnitId AS Unit_No
		,VendorId AS Driver
		,Division
		,VendorName AS Vendor_Name
		,[A/R Balance] AS AR_Balance
		,Payment
		,CAST(ISNULL(CASE WHEN [A/R Balance] <> 0 AND Payment <> 0 THEN [A/R Balance] / Payment ELSE Null END, 0) AS Int) AS Remain_Payments
		,HireDate AS [Start_Date]
		,@LastPay AS [As_of_Date]
		,@LastPay + (CAST(ISNULL(CASE WHEN [A/R Balance] <> 0 AND Payment <> 0 THEN [A/R Balance] / Payment ELSE Null END, 0) AS Int) * 7) AS [Payoff_Date]
		,CAST(dbo.DriverEscrowBalance(Company, VendorId, @LastPay) AS Int) AS EscrowBalance
		,MR_Escrow
		,Miles + SumMiles AS Miles
		,dbo.DriverPayrollConceptBalance(Company, VendorId, 'Drayage', 26) AS Drayage_26_WksAvg
		,dbo.DriverPayrollConceptBalance(Company, VendorId, 'Drayage', 4) AS Drayage_4_WksAvg
		,dbo.DriverPayrollConceptBalance(Company, VendorId, 'Pay', 26) AS Pay_26_WksAvg
		,dbo.DriverPayrollConceptBalance(Company, VendorId, 'Pay', 4) AS Pay_4_WksAvg
		,Issues
INTO	#tmpMyTruck
FROM	(SELECT	VMA.Company
				,VMA.VendorId
				,VMA.UnitId
				,VMA.Issues
				,VMA.Division
				,dbo.GetVendorName(VMA.Company, VMA.VendorId) AS VendorName
				,ISNULL(MTS.CurTrxAm, 0) AS [A/R Balance]
				,Payment = ISNULL((SELECT TOP 1 Balance FROM ILS_Datawarehouse.dbo.MyTruck MYT WHERE VMA.Company = MYT.CompanyId AND VMA.VendorId = MYT.VendorId AND MYT.Description ='Total Lease Payment' ORDER BY PayDate DESC), 0)
				,VMA.HireDate
				,MR_Escrow = ISNULL((SELECT TOP 1 Balance FROM ILS_Datawarehouse.dbo.MyTruck MYT WHERE VMA.Company = MYT.CompanyId AND VMA.VendorId = MYT.VendorId AND MYT.Description ='M&R Escrow' ORDER BY PayDate DESC), 0)
				,SumMiles = ISNULL((SELECT SUM(Miles) FROM View_Integration_AP DPY WHERE DPY.VendorId = VMA.VendorId AND DPY.WeekEndDate >= @LastPay - 28), 0)
				,ISNULL(VMA.Miles, 0) AS Miles
		FROM	VendorMaster VMA
				LEFT JOIN View_MyTruckRecords_Summary MTS ON VMA.Company = MTS.Company AND VMA.VendorId = MTS.VendorId
		WHERE	VMA.SubType = 2
				AND (@Company IS Null OR (@Company IS NOT Null AND VMA.Company = @Company))
				AND VMA.TerminationDate IS Null
				AND ISNULL(MTS.CurTrxAm, 0) <> 0) RECS
ORDER BY 
		Company
		,VendorId
		
SET @Query = 'SELECT * FROM #tmpMyTruck'

IF @Filters IS NOT Null
	SET @Query = @Query + ' WHERE ' + @Filters 

EXECUTE(@Query)

DROP TABLE #tmpMyTruck