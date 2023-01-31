DROP TABLE FI_Results

SELECT	*
INTO	FI_Results
FROM	(
		SELECT	REC.*
				,UPPER(KIP.Location) AS KIP_Location
				,KIP.DATE AS KIP_Date
				,KIP.Customer AS KIP_Customer
				,KIP.Equipment AS KIP_Equipment
				,KIP.Status AS KIP_Status
				,KIP.Parts AS KIP_Parts_Total
				,KIP.Labor AS KIP_Labor_Total
				,KIP.Inv_Tax AS KIP_Tax
				,KIP.Inv_Total AS KIP_Inv_Total
				,CAST(NUll AS Bit) AS InSWS
				,INV.inv_mech AS Mechanic
				,INV.rep_date AS RepairDate
		FROM	(
				SELECT	FID.Inv_No
						,FID.Depot_Loc AS TIM_Location
						,FID.Customer AS TIM_Customer
						,FID.UnitNo AS Tim_UnitNo
						,SUM(FID.Parts_Total) AS TIM_Parts_Total
						,SUM(FID.Labor_Totale) AS TIM_Labor_Total
						,SUM(FID.Line_Total) AS TIM_Line_Total
				FROM	FI_Dec_Sales FID
						LEFT JOIN Invoices INV ON FID.INV_NO = INV.INV_NO
						LEFT JOIN Integrations.dbo.MSR_ReceviedTransactions MSR ON 'I' + CAST(FID.Inv_No AS Varchar(10)) = MSR.DocNumber AND MSR.Company = 'FI'
						LEFT JOIN FI_Kip_Estimates KIP ON FID.INV_NO = KIP.INV_NO
				WHERE	FID.I_E = 'E'
				GROUP BY FID.Inv_No
						,FID.Depot_Loc
						,FID.Customer
						,FID.UnitNo
				) REC
				LEFT JOIN FI_Kip_Estimates KIP ON REC.INV_NO = KIP.INV_NO
				LEFT JOIN Invoices INV ON CAST(REC.Inv_No AS Int) = INV.Inv_No
		UNION
		SELECT	KIP.INV_NO
				,NULL AS TIM_Location
				,NULL AS TIM_Customer
				,NULL AS Tim_UnitNo
				,NULL AS TIM_Parts_Total
				,NULL AS TIM_Labor_Total
				,NULL AS TIM_Line_Total
				,UPPER(KIP.Location) AS KIP_Location
				,KIP.DATE AS KIP_Date
				,KIP.Customer AS KIP_Customer
				,KIP.Equipment AS KIP_Equipment
				,KIP.Status AS KIP_Status
				,KIP.Parts AS KIP_Parts_Total
				,KIP.Labor AS KIP_Labor_Total
				,KIP.Inv_Tax AS KIP_Tax
				,KIP.Inv_Total AS KIP_Inv_Total
				,CAST(NUll AS Bit) AS InSWS
				,INV.inv_mech AS Mechanic
				,INV.rep_date AS RepairDate
		FROM	FI_Kip_Estimates KIP
				LEFT JOIN Invoices INV ON CAST(KIP.Inv_No AS Int) = INV.Inv_No
		WHERE	KIP.INV_NO NOT IN (SELECT INV_NO FROM FI_Dec_Sales)
		) INV


DECLARE	@Inv_No		Varchar(20),
		@Query		Varchar(MAX),
		@InSWS		Bit
		
DECLARE curInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(Inv_No) AS InvoiceNumber
FROM	FI_Results

OPEN curInvoices 
FETCH FROM curInvoices INTO @Inv_No

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT PostDate FROM public.mrinv WHERE mrcompany_code = ''55'' AND InvNo = ''I' + @Inv_No + ''''
	
	EXECUTE Integrations.dbo.USP_QuerySWS @Query, '##tmpInvoice'
	
	SELECT	@InSWS = CASE WHEN PostDate IS NULL THEN 0 ELSE 1 END
	FROM	##tmpInvoice
	
	IF @@ROWCOUNT > 0
	BEGIN
		UPDATE FI_Results SET InSWS = @InSWS WHERE Inv_No = @Inv_No
	END
	
	DROP TABLE ##tmpInvoice
	
	FETCH FROM curInvoices INTO @Inv_No
END

CLOSE curInvoices
DEALLOCATE curInvoices

SELECT * FROM FI_Results ORDER BY Inv_No
		
-- select * from Invoices where inv_no = 753207