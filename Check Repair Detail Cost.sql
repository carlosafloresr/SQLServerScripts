DECLARE	@InvoiceNumber Int = 1408433 

SELECT	WorkOrder,
		Equipment,
		CustomerNumber,
		EquipmentLocation,
		SubLocation,
		EstimateDate,
		Mechanic,
		MechanicName,
		CASE WHEN LineItem < 0 THEN 0 ELSE LineItem END AS LineItem,
		RepairedComponent AS Category,
		SubCategory,
		PartNumber,
		PartDescription,
		DamageCode,
		RepairCode,
		Quantity,
		Cost,
		Cost * Quantity AS Total
FROM	View_RepairsDetails
WHERE	InvoiceNumber = @InvoiceNumber
ORDER BY LineItem