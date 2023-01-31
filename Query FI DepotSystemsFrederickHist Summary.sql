SELECT	INV.Inv_No, 
		INV.Inv_Batch, 
		INV.Inv_Date, 
		INV.Est_Date, 
		INV.Eq_DateIn, 
		INV.Entry_Date, 
		CASE WHEN INV.Rep_Date IS NULL OR INV.Rep_Date < '01/01/1980' THEN NULL ELSE INV.Rep_Date END AS Rep_Date,
		CASE WHEN INV.INV_EST = 'I' THEN 'Invoice ' ELSE 'Estimate' END AS Inv_Est, 
		INV.DEPOT_LOC AS Depot_Location, 
		SUM(QTY_SHIPED) AS PartQuantity,
		SUM(UNIT_PRICE) AS UnitPrice, 
		SUM(PART_TOTAL) AS PartTotal, 
		SUM(SAL.RLABOR) AS LaborTotal, 
		SUM(SAL.RLABOR_QTY) AS LaborQuantity, 
		SUM(SAL.LAB_PRICE) AS LaborPrice, 
		INV.INV_TOTAL AS InvoiceTotal, 
		INV.Sale_Tax AS SaleTax, 
		INV.ESTATUS AS Status, 
		INV.ACCT_NO AS CustomerNumber, 
		INV.CONTAINER, 
		INV.CHASSIS, 
		INV.GENSET_NO, 
		INV.GEN_HOURS, 
		CASE WHEN INV.INV_TYPE = 'R' THEN 'Invoice' ELSE 'Credit ' END AS RecordType, 
		INV.WORKORDER, 
		INV.Inv_Mech AS Mechanic, 
		INV.EDI_Sent, 
		INV.EDI_Time, 
		INV.Approval, 
		INV.MRSK_Cause 
FROM	HisInvFull INV 
		INNER JOIN HisSaleFull SAL ON INV.Inv_No = SAL.Inv_No 
WHERE	INV.EStatus <> 'CANC' 
		--AND INV.Inv_Date BETWEEN '1/1/2015' AND '3/31/2015' 
		--AND INV.Inv_Date BETWEEN '4/1/2015' AND '6/30/2015' 
		--AND INV.Inv_Date BETWEEN '7/1/2015' AND '9/30/2015' 
		AND INV.Inv_Date BETWEEN '10/1/2015' AND '12/31/2015' 
		AND INV.Inv_Date <> '01/01/1900' 
		AND INV.Inv_Est = 'I' 
		AND INV.Inv_Mech NOT IN ('APP','BID') 
GROUP BY 
		INV.Inv_No, 
		INV.Inv_Batch, 
		INV.Inv_Date, 
		INV.Est_Date, 
		INV.Eq_DateIn, 
		INV.Entry_Date, 
		INV.Rep_Date, 
		INV.INV_EST, 
		INV.DEPOT_LOC, 
		INV.INV_TOTAL, 
		INV.Sale_Tax, 
		INV.ESTATUS, 
		INV.ACCT_NO, 
		INV.CONTAINER, 
		INV.CHASSIS, 
		INV.GENSET_NO, 
		INV.GEN_HOURS, 
		INV.INV_TYPE, 
		INV.WORKORDER, 
		INV.Inv_Mech, 
		INV.EDI_Sent, 
		INV.EDI_Time, 
		INV.Approval, 
		INV.MRSK_Cause 
ORDER BY
		INV.Inv_Date, 
		INV.Inv_No