/*
TRUNCATE TABLE ReceivedSales
*/
UPDATE	ReceivedSales
SET		inv_no = REPLACE(inv_no, 'I', ''), 
		inv_batch = REPLACE(inv_batch, 'B', '')

DROP TABLE Results 

SELECT 	INV.INV_NO
		,INV.INV_TOTAL
		,INV.Sale_Tax
		,PartsLaborSum = (SELECT SUM(S1.part_total + S1.rlabor) FROM Sale S1 WHERE S1.inv_no = INV.INV_no)
		,INV.INV_EST
		,INV.DEPOT_LOC AS DEPOT_LOCATION
		,SAL.PART_NO
		,SAL.DESCRIPT
		,QTY_SHIPED
		,UNIT_PRICE
		,PART_TOTAL
		,DAT.Consum
		,SAL.DATE
		,SAL.CDEX_REPAI
		,SAL.RLABOR
		,SAL.RLABOR_QTY
		,SAL.LAB_PRICE
		,ESTATUS
		,INV.ACCT_NO
		,SAL.DEPOT_LOC AS DEPOT_LOC2
		,INV.CONTAINER
		,INV.CHASSIS
		,INV.GENSET_NO
		,INV.GEN_HOURS
		,INV.INV_TYPE
		,CASE WHEN INV.WORKORDER = '' THEN '' ELSE 'WO: ' + INV.WORKORDER END AS Workorder
		,SAL.CDEX_DAMAG
		,SAL.CDEX_LOCAT
		,NEWDOTON
		,NEWDOTOFF
		,INV.INV_DATE
		,ISNULL(EST.Est_Date, INV.Est_Date) AS Est_Date
		,ISNULL(EST.Rep_Date, INV.Rep_Date) AS Rep_Date
		,SAL.Bin
		,SAL.inv_mech AS Mechanic
		,CAST(Null AS Numeric(12,2)) AS SWS_Hours
		,CAST(Null AS Numeric(12,2)) AS SWS_Labor
		,CAST(Null AS Numeric(12,2)) AS SWS_Parts
		,CAST(Null AS Numeric(12,2)) AS SWS_Tax
		,CAST(Null AS Numeric(12,2)) AS SWS_Total
		,CAST(Null AS Date) AS SWSInv_Date
		,CAST(Null AS Date) AS SWSManifets_Date
		,CAST(Null AS Date) AS SWSPosting_Date
		,DAT.WeekNumber
		,DAT.Period
INTO	Results
FROM 	Invoices INV
		INNER JOIN Sale SAL ON INV.Inv_No = SAL.Inv_No
		INNER JOIN ReceivedSales DAT ON INV.Inv_No = DAT.Inv_No
		LEFT JOIN DeaParts PAR ON SAL.PART_NO = PAR.PART_NO
		LEFT JOIN Estimates EST ON INV.Inv_No = EST.Inv_No
ORDER BY INV.Inv_No
GO

EXECUTE USP_Update_FIResults
GO

INSERT INTO FISales
SELECT	Period,
		WeekNumber,
		INV_NO
		,ROW_NUMBER() OVER(PARTITION BY INV_NO ORDER BY INV_NO DESC) AS ItemNumber
		,Inv_Total
		,PartsLaborSum
		,INV_TOTAL - PartsLaborSum AS Difference
		,Sale_Tax
		,INV_EST
		,DEPOT_LOCATION
		,PART_NO
		,DESCRIPT
		,QTY_SHIPED
		,UNIT_PRICE
		,PART_TOTAL
		,CONSUM
		,DATE
		,CDEX_REPAI
		,RLABOR
		,RLABOR_QTY
		,LAB_PRICE
		,ESTATUS
		,ACCT_NO
		,DEPOT_LOC2
		,RES.CONTAINER
		,RES.CHASSIS
		,GENSET_NO
		,GEN_HOURS
		,INV_TYPE
		,Workorder
		,CDEX_DAMAG
		,CDEX_LOCAT
		,NEWDOTON
		,NEWDOTOFF
		,INV_DATE
		,Est_Date
		,Rep_Date
		,Bin
		,Mechanic
		,SWS_Hours
		,SWS_Labor
		,SWS_Parts
		,SWS_Tax
		,SWS_Total
		,SWSInv_Date
		,SWSManifets_Date
		,SWSPosting_Date
		,Inv_Total - ISNULL(SWS_Total, 0) AS Invoice_Difference
FROM	Results RES
ORDER BY 1, 2, 3

SELECT	FI.*,
		IV.Estatus
FROM	FISales FI
		INNER JOIN Invoices IV ON FI.INV_NO = IV.inv_no
WHERE	WeekNumber = 4
		AND Period = '2012-06'
ORDER BY 1, 2, 3, 4

/*
DELETE	FISales
WHERE	WeekNumber = 4
		AND Period = '2012-06'
*/