USE [DepotSystemsFrederickHist]
GO

DECLARE	@StartDate	Date = '12/01/2015',
		@EndDate	Date = '12/31/2015'

SELECT	INV.Inv_No, 
		INV.Inv_Batch, 
		INV.Inv_Date, 
		INV.Est_Date, 
		INV.Eq_DateIn, 
		INV.Entry_Date, 
		CASE WHEN INV.Rep_Date IS NULL OR INV.Rep_Date < '01/01/1980' THEN NULL ELSE INV.Rep_Date END AS Rep_Date,
		CASE WHEN INV.INV_EST = 'I' THEN 'Invoice ' ELSE 'Estimate' END AS Inv_Est, 
		INV.DEPOT_LOC AS Depot_Location, 
		SAL.PART_NO AS JobCode, 
		SAL.DESCRIPT AS Description,
		SAL.CDEX_REPAI, 
		QTY_SHIPED AS PartQuantity, 
		UNIT_PRICE AS UnitPrice, 
		PART_TOTAL AS PartTotal, 
		SAL.RLABOR AS LaborTotal, 
		SAL.RLABOR_QTY AS LaborQuantity, 
		SAL.LAB_PRICE AS LaborPrice,
		INV.INV_TOTAL AS InvoiceTotal, 
		INV.Sale_Tax AS SaleTax, 
		ESTATUS AS Status, 
		INV.ACCT_NO AS CustomerNumber, 
		INV.Container, 
		INV.Chassis, 
		INV.Genset_No,
		INV.Gen_Hours, 
		CASE WHEN INV.INV_TYPE = 'R' THEN 'Invoice' ELSE 'Credit ' END AS RecordType, 
		INV.Workorder, 
		SAL.CDEX_DAMAG, 
		SAL.CDEX_LOCAT, 
		NEWDOTON,
		NEWDOTOFF, 
		SAL.Bin, 
		SAL.inv_mech AS Mechanic, 
		INV.EDI_Sent, 
		INV.EDI_Time, 
		INV.Approval, 
		INV.MRSK_Cause 
FROM	HisInvFull INV 
		INNER JOIN HisSaleFull SAL ON INV.Inv_No = SAL.Inv_No 
WHERE	INV.EStatus <> 'CANC' 
		AND INV.Inv_Date BETWEEN @StartDate AND @EndDate 
		AND INV.Inv_Date <> '01/01/1900' 
		AND INV.Inv_Est = 'I' 
		AND INV.Inv_Mech NOT IN ('APP','BID') 
ORDER BY INV.Inv_No