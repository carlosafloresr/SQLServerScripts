/*
EXECUTE ILSSQL01.Intranet.dbo.USP_RCMR_Query 'SELECT * FROM Invoices WHERE Inv_No = 420120'

EXECUTE ILSSQL01.Intranet.dbo.USP_RCMR_Query 'SELECT INV.Inv_No, INV.Acct_No, INV.Inv_Total, INV.Inv_Type, INV.Inv_Est, INV.Container, INV.Chassis, INV.Est_Date, INV.Eq_DateIn, INV.Week_End, INV.Rep_Date FROM Invoices INV WHERE Inv_No = 420120'

EXECUTE ILSSQL01.Intranet.dbo.USP_RCMR_Query 'SELECT SAL.Inv_No, SAL.Part_No, SAL.Descript, SAL.Unit_Price, SAL.Part_Total, SAL.Taxable, SAL.ItemTot, SAL.Date, SAL.Inv_Est, SAL.CDex_Damag, SAL.RLabor, SAL.RLabor_Qty, SAL.Lab_Price, SAL.TaxLabor, SAL.TLabor, SAL.Inv_Mech, SAL.Depot_Loc, SAL.Bin FROM Sale SAL WHERE SAL.Inv_No = 420120'
*/

--EXECUTE ILSSQL01.Intranet.dbo.USP_RCMR_Query 'SELECT INV.Inv_No, INV.Acct_No, INV.Labor, INV.Parts, INV.Sale_Tax AS Tax, INV.Inv_Total, INV.Inv_Type, INV.Inv_Est, INV.Container, INV.Chassis, INV.Size, INV.Inv_Batch, INV.Est_Date, INV.Eq_DateIn, INV.Week_End, INV.Rep_Date, SAL.Part_No, SAL.Descript, SAL.Unit_Price, SAL.Part_Total, SAL.Taxable, SAL.ItemTot, SAL.Date, SAL.CDex_Damag, SAL.RLabor, SAL.RLabor_Qty, SAL.Lab_Price, SAL.TaxLabor, SAL.TLabor, SAL.Inv_Mech, SAL.Depot_Loc, SAL.Bin FROM Invoices INV, Sale SAL WHERE INV.Inv_No = SAL.Inv_No AND NOT EMPTY(SAL.CDex_Damag) AND INV.Inv_No = 420120'

SELECT	* 
--INTO	#MyTempTable 
FROM	OPENROWSET('MSDASQL','DRIVER={SQL Server};SERVER=ILSSQL01;UID=GPCUSTOM;PWD=memphis2007','EXECUTE Intranet.dbo.USP_RCMR_Query ''SELECT INV.Inv_No, INV.Acct_No, INV.Labor, INV.Parts, INV.Sale_Tax AS Tax, INV.Inv_Total, INV.Inv_Type, INV.Inv_Est, INV.Container, INV.Chassis, INV.Size, INV.Inv_Batch, INV.Est_Date, INV.Eq_DateIn, INV.Week_End, INV.Rep_Date, SAL.Part_No, SAL.Descript, SAL.Unit_Price, SAL.Part_Total, SAL.Taxable, SAL.ItemTot, SAL.Date, SAL.CDex_Damag, SAL.RLabor, SAL.RLabor_Qty, SAL.Lab_Price, SAL.TaxLabor, SAL.TLabor, SAL.Inv_Mech, SAL.Depot_Loc, SAL.Bin FROM Invoices INV, Sale SAL WHERE INV.Inv_No = SAL.Inv_No AND NOT EMPTY(SAL.CDex_Damag) AND INV.Inv_No = 420120''')

SELECT	* 
FROM	#MyTempTable

DROP TABLE #MyTempTable
/*
sp_configure 'Show Advanced Options', 1
go
RECONFIGURE
sp_configure 'Ad Hoc Distributed Queries', 1
GO
RECONFIGURE

*/