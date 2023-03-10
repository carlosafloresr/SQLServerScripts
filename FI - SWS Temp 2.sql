SELECT	FID.Inv_No
		,FID.I_E
		,FID.Depot_Loc
		,FID.Customer
		,FID.Status
		,FID.UnitNo
		,ROW_NUMBER() OVER(PARTITION BY FID.INV_NO ORDER BY FID.INV_NO DESC) AS ItemNumber
		,FID.Item
		,FID.Description
		,FID.Repair
		,FID.Gen_hrs
		,FID.Qty
		,FID.Price
		,FID.Parts_Total
		,FID.Lab_hrs
		,FID.Rate
		,FID.Labor_Totale AS Labor_Total
		,FID.Line_Total
		,FI_Full_Line_Total = (SELECT SUM(S1.Line_Total * 1.00) FROM FI_Dec_Sales S1 WHERE S1.inv_no = FID.Inv_No)
		,File_Full_Line_Total = (SELECT ISNULL(SUM(S1.itemtot * 1.00), 0) FROM Sale S1 WHERE S1.inv_no = FID.Inv_No)
		,FID.Date
		,CASE WHEN INV.inv_total IS NULL THEN 'YES' ELSE 'NO' END AS TableDeleted
		,CASE WHEN FID.SWSWeekEnding_Date IS NULL THEN 'NO' ELSE 'YES' END AS SWS_Integrated
		,CASE WHEN MSR.DocNumber IS NULL THEN 'NO' ELSE 'YES' END AS GP_Integrated
FROM	FI_Dec_Sales FID
		LEFT JOIN Invoices INV ON FID.INV_NO = INV.INV_NO
		LEFT JOIN Integrations.dbo.MSR_ReceviedTransactions MSR ON 'I' + CAST(FID.Inv_No AS Varchar(10)) = MSR.DocNumber AND MSR.Company = 'FI'
WHERE	FID.I_E = 'E'

/*
DECLARE	@Inv_No		Varchar(20),
		@Query		Varchar(MAX),
		@InvDate	Date,
		@ManDate	Date,
		@PosDate	Date
		
DECLARE curInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT RTRIM(INV_NO) AS InvoiceNumber
FROM	FI_Dec_Sales
WHERE	I_E = 'E'

OPEN curInvoices 
FETCH FROM curInvoices INTO @Inv_No

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT PostDate, WeekEnding FROM public.mrinv WHERE mrcompany_code = ''55'' AND InvNo = ''I' + @Inv_No + ''''
	
	EXECUTE Integrations.dbo.USP_QuerySWS @Query, '##tmpInvoice'
	
	SELECT	@ManDate = WeekEnding,
			@PosDate = PostDate
	FROM	##tmpInvoice
	
	IF @@ROWCOUNT > 0
	BEGIN
		UPDATE	FI_Dec_Sales 
		SET		SWSWeekEnding_Date = @ManDate, 
				SWSPosting_Date = @PosDate 
		WHERE	INV_NO = @Inv_No
	END
	
	DROP TABLE ##tmpInvoice
	
	FETCH FROM curInvoices INTO @Inv_No
END

CLOSE curInvoices
DEALLOCATE curInvoices
*/