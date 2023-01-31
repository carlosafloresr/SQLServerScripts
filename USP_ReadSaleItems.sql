CREATE PROCEDURE USP_ReadSaleItems (@UserId Varchar(25))
AS
SELECT	SAL.InvoiceNumber
		,SAL.RecordType
		,SAL.DepotLocation
		,SAL.Bin
		,SAL.PartNumber
		,SAL.Description
		,SAL.QuantityShipped
		,SAL.UnitPrice
		,SAL.PartsTotal
		,SAL.Date
		,SAL.RepairCode
		,SAL.Labor
		,SAL.LaborQuantity
		,SAL.LabPrice
		,SAL.Estatus
		,SAL.CustomerNumber
		,SAL.Container
		,SAL.Chassis
		,SAL.GenSetNumber
		,SAL.GenHours
		,SAL.InventoryType
		,SAL.WorkOrder
		,SAL.DamageCode
		,SAL.CodeLocation
		,SAL.NewDotOn
		,SAL.NewDotOff
		,SAL.InvoiceDate
		,ISNULL(EST.Est_Date, SAL.EstimateDate) AS EstimateDate
		,ISNULL(EST.Rep_Date, SAL.RepairDate) AS RepairDate
FROM	View_SaleItems SAL
		LEFT JOIN Estimates EST ON SAL.InvoiceNumber = EST.Inv_No
WHERE	UserId = @UserId
ORDER BY 
		SAL.DepotLocation
		,SAL.Date
		,SAL.PartNumber