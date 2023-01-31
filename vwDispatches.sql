/*
SELECT * FROM vwDispatches
*/
ALTER VIEW [dbo].[vwDispatches]
AS
SELECT	Dispatches.ID, 
		Dispatches.RepairID, 
		Tickets.RepairID AS FRSTicket, 
		Dispatches.VendorID, 
		Dispatches.StartTime, 
		Dispatches.ETA, 
		Dispatches.CompleteTime,
		Dispatches.Tech, 
		Dispatches.TechPhone, 
		Dispatches.Estimate, 
		Dispatches.Rating, 
		Dispatches.VendorInvoice, 
		Vendors.Name, 
		Vendors.Address, 
        Vendors.City, 
		Vendors.State, 
		Vendors.Zip, 
		Vendors.TaxClass, 
		TaxClasses.Classification, 
		Vendors.FederalID, 
		Vendors.Phone, 
		Vendors.Email, 
		Vendors.Contact,
        Vendors.PaymentType, 
		PayTypes.PaymentType AS PaymentName, 
		Vendors.Status, 
		Vendors.EffectiveDate, 
		Vendors.Notes, 
		Vendors.Longitude, 
        Vendors.Latitude, 
		Vendors.Hours, 
		Vendors.Mobile, 
        CASE WHEN [Vendors].[Mobile] = 0 THEN 'Mobile Service Not Available' ELSE 'Mobile Service Available' END AS MobileSrv, 
		Vendors.Type, 
        VendorTypes.VendorType, 
		Repairs.Position, 
		RepairPositions.Description AS PositionName, 
		Repairs.TireSize, 
		TireSizes.Description AS TireSizeName, 
        Repairs.Cause, 
		Causes.Description AS CauseName, 
		Bound.DamageType AS BoundToName, 
		Repairs.CreatedBy, 
        Repairs.CreatedTime, 
		Repairs.UpdateBy, 
		Repairs.UpdateTime, 
		Repairs.RepairType, 
		RepairType.Types AS RepairTypeName
FROM	dbo.Dispatches AS Dispatches 
		INNER JOIN dbo.Tickets AS Tickets ON Dispatches.RepairID = Tickets.ID 
		LEFT OUTER JOIN dbo.Vendors AS Vendors ON Dispatches.VendorID = Vendors.ID 
		INNER JOIN lookup.VendorTaxClasses AS TaxClasses ON Vendors.TaxClass = TaxClasses.ID 
		INNER JOIN lookup.VendorTypes AS VendorTypes ON Vendors.Type = VendorTypes.ID 
		INNER JOIN lookup.PayTypes AS PayTypes ON Vendors.PaymentType = PayTypes.ID 
		--LEFT OUTER JOIN dbo.Repairs AS Repairs ON Repairs.AssignTo = Dispatches.ID 
		INNER JOIN lookup.Positions AS RepairPositions ON Repairs.Position = RepairPositions.ID 
		INNER JOIN lookup.TireSizes AS TireSizes ON Repairs.TireSize = TireSizes.ID 
		INNER JOIN lookup.Causes AS Causes ON Repairs.Cause = Causes.ID 
		--INNER JOIN lookup.DamageTypes AS Bound ON Repairs.BoundTo = Bound.ID 
		INNER JOIN lookup.RepairTypes AS RepairType ON Repairs.RepairType = RepairType.ID

GO