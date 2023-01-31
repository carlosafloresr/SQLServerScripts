DECLARE	@DateIni	Date = '02/09/2014',
		@DateEnd	Date = '02/15/2014',
		@Query		Varchar(MAX)

SET @Query = N'SELECT TRIM(INV.Depot_Loc) AS Depot, 
		TRIM(SAL.Inv_Mech) AS Mechanic, 
		SAL.date + 1 AS Inv_Date, 
		TRIM(INV.acct_no) AS CustNo, 
		TRIM(INV.container) AS Container, 
		TRIM(INV.chassis) AS Chassis, 
		TRIM(INV.genset_no) AS Genset_No, 
		TRIM(SAL.inv_est) AS Inv_Est, 
		SAL.qty_shiped * 1 AS Qty, 
		INV.tirerpl * 1 AS TireRpl, 
		INV.tirerpr * 1 AS TireRpr, 
		SAL.inv_no * 1 AS Inv_No, 
		INV.mech_hours * 1 AS Mech_Hours, 
		TRIM(INV.inv_type) AS Inv_Type, 
		INV.rep_date + 1 AS Rep_Date, 
		INV.est_date + 1 AS Est_Date, 
		TRIM(SAL.part_no) AS Part_No, 
		TRIM(SAL.descript) AS Descript, 
		SAL.part_total * 1 AS Parts, 
		SAL.rlabor_qty * 1 AS Labor_Hours,  
		SAL.rlabor * 1 AS Labor, 
		INV.sale_tax * 1 AS Sale_Tax, 
		SAL.itemtot * 1 AS Inv_Total, 
		SAL.mechlabtm * 1 AS MechLab
FROM	Invoices INV 
		INNER JOIN Sale SAL ON INV.Inv_No = SAL.Inv_No 
WHERE	INV.Rep_Date BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
		AND INV.Estatus <> ''CANC'' 
		AND INV.Depot_Loc = ''ALLIANCE'' 
        AND INV.INV_TYPE NOT IN (''G'',''I'',''L'',''N'',''S'',''T'',''Z'')
		AND SAL.Inv_Mech BETWEEN ''1'' AND ''999'' 
ORDER BY INV.Depot_Loc, SAL.Inv_Mech, INV.acct_no'

-- AND SAL.Inv_Mech = ''125''

EXECUTE USP_QueryFIDepot @Query, '##tmpPayrollData'

SELECT	Depot,
		Mechanic,
		SUM(Qty) AS Quantiry, 
		SUM(ROUND(MechLab, 2)) AS Hours
FROM	##tmpPayrollData
GROUP BY Depot, Mechanic
ORDER BY Depot, Mechanic

DROP TABLE ##tmpPayrollData