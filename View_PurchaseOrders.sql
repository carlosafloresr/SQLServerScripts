ALTER VIEW View_PurchaseOrders
AS
SELECT	PurchaseOrderId
		,PO_Type
		,CASE WHEN PO_Type = 1 THEN 'Regular' ELSE 'Intercompany' END AS PO_TypeText
		,Company
		,Division
		,PO_Number
		,CAST(PO_Number AS Varchar(10)) + '-' + Division AS PO_NumberText
		,PO_Date
		,VendorId
		,DepotFacility
		,PO_Description
		,EquipmentId
		,ProNumber
		,Companion
		,Recoverable
		,EstimateId
		,EstimateAmount
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn
		,Status
		,CASE WHEN [Status] = 2 THEN 'Closed' WHEN [Status] = 1 AND SentTo IS Null THEN 'Requisition' ELSE 'Open' END AS TextStatus
		,SentTo
		,SentDate
FROM	dbo.PurchaseOrders