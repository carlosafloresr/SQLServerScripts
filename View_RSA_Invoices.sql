/*
SELECT * FROM View_RSA_Invoices WHERE RepairNumber = 2686
*/
ALTER VIEW View_RSA_Invoices
AS
SELECT	DRIN.Company
		,DRIN.IdRepairNumber AS RepairNumber
		,DRIN.ProNumber
		,DRIN.Container
		,DRIN.Chassis
		,DRIN.DriverNumber AS DriverId
		,DRIN.DomicileDiv AS Division
		,DRIN.TruckUnit
		,INVH.Id AS RSA_InvoiceId
		,INVH.AfterBusinessHour
		,INVH.Pool
		,INVH.Service
		,INVH.InvoiceDate
		,INVH.EffectiveDate
		,INVH.IdRepairNumber
		,INVH.InvoiceNumber
		,INVH.InvoiceTotal
		,INVH.BaseAmount
		,INVH.ServiceCharges
		,INVH.Mileage
		,INVH.Other
		,INVH.SalesTax
		,INVH.Total
		,INVH.Difference
		,INVH.EFSProcessing
		,INVH.EFSNumber
		,INVH.EFSAmount
		,INVH.EFSDate
		,INVH.Posted
		,INVH.Approved
		,INVH.Comment
		,INVH.Creation
		,INVH.Active
		,INVH.UserName
		,INVH.UserMail
		,'RSA-' + CONVERT(nvarchar, INVH.Creation, 112) + REPLACE(CONVERT(nvarchar, INVH.Creation, 108), ':', '') AS VoucherNumber
		,INVD.Id AS RSA_InvoiceDetailId
		,INVD.IdLine
		,INVD.TypeRepair
		,INVD.Repair
		,INVD.TypeTire
		,INVD.IdRepairType
		,INVD.Position
		,INVD.Failure
		,INVD.GLCode
		,INVD.GLDescription
		,INVD.BaseCost
		,INVD.AllocatedAmount
		,INVD.Total AS LineTotal
		,INVD.ReviewAndApproval
		,INVD.PopUpId
		,VEND.IdVendor
		,VNGP.VendorId
		,VEND.Vendor AS VendorName
		,RTRIM(VNGP.VendorId) + ' - ' + RTRIM(VEND.Vendor) AS Vendor
FROM	dbo.RSA_Invoice INVH
		INNER JOIN dbo.RSA_InvoiceDetail INVD ON INVH.ID = INVD.IdInvoice
		INNER JOIN dbo.DriverInfo DRIN ON INVH.IdRepairNumber = DRIN.IdRepairNumber
		INNER JOIN dbo.VendorInfo VEND ON INVH.IdRepairNumber = VEND.IdRepairNumber
		LEFT JOIN dbo.RSA_VendorsNetworkGP VNGP ON DRIN.Company = VNGP.Company AND VEND.IdVendor = VNGP.Fk_RSA_VendorsNetworkId