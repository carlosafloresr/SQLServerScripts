/*
EXECUTE sp_RSA_PostingToDEX 5259
*/
ALTER PROCEDURE sp_RSA_PostingToDEX (@vOTRNumber Int)
AS
SELECT	TOP 1 CONVERT(VARCHAR(100), ven.Vendor) AS Field1,
		inv.Creation AS Field2,
		CONVERT(VARCHAR(100), dri.Chassis) AS Field3,
		CONVERT(VARCHAR(40), inv.InvoiceNumber) AS Field4,
		inv.Total AS Field5,
		ISNULL(ApprovedBy, 'RSR_APP') AS Field6,
		'UNKNOWN' AS Field7,
		CONVERT(VARCHAR(50), VGP.VendorId) AS Field8,
		@vOTRNumber AS Field9,
		inv.InvoiceDate AS Field10,
		CONVERT(VARCHAR(50), dri.ProNumber) AS Field11,
		'' AS Field12,
		IDS.GLDescription AS Field13,
		CONVERT(VARCHAR(50), dri.Container) AS Field14,
		'' AS Field15,
		'' AS Field16,
		IDS.GLCode AS Field17,
		IDS.Department AS Field18,
		'' AS Field19,
		'' AS Field20,
		dri.Company,
		dex.ProjectId
FROM	(SELECT	ApprovedBy,
				MAX(Creation) as Creation, 
				MAX(InvoiceNumber) as InvoiceNumber, 
				MAX(Total) as Total, 
				MAX(InvoiceDate) as InvoiceDate, 
				MAX(IdRepairNumber) as IdRepairNumber,
				MAX(CONVERT(int,ISNULL(Active, 0))) AS Active,
				MAX(CONVERT(int,ISNULL(Approved, 0))) AS Approved,
				MAX(CONVERT(int,ISNULL(Posted, 0))) AS Posted
		FROM	dbo.RSA_Invoice
		WHERE	IdRepairNumber IS NOT Null
		GROUP BY IdRepairNumber, ApprovedBy
		) inv 
		INNER JOIN dbo.Tickets as tic ON tic.Id = inv.IdRepairNumber and tic.Active = 1
		INNER JOIN (SELECT	MAX(Chassis) as Chassis,  MAX(IdRepairNumber) as IdRepairNumber, 
							MAX(CONVERT(int,ISNULL(Active, 0))) as Active, 
							MAX(ProNumber) as ProNumber,
							MAX(Container) as Container,
							MAX(Company) as Company
					FROM	dbo.DriverInfo 
					WHERE	IdRepairNumber IS NOT Null
					GROUP BY IdRepairNumber
					) AS dri ON dri.IdRepairNumber = tic.Id and dri.Active = 1
		INNER JOIN  (SELECT MAX(Vendor) as Vendor, MAX(IdVendor) as IdVendor,
							MAX(convert(int,ISNULL(Active, 0))) as Active,
							MAX(IdRepairNumber) as IdRepairNumber
					FROM	dbo.VendorInfo 
					WHERE	IdRepairNumber is not null
					GROUP BY IdRepairNumber
					) ven ON ven.IdRepairNumber = tic.Id AND ven.Active = 1
		INNER JOIN dbo.RepairInfo ri on tic.IdRepairInfo = ri.Id and tic.Id = ri.IdRepairNumber
		LEFT JOIN dbo.DriverInfo DRIN ON tic.id = DRIN.IdRepairNumber
		LEFT JOIN dbo.DexCompanyProjects dex ON DRIN.Company = dex.Company AND dex.ProjectType = 'AP'
		LEFT JOIN dbo.RSA_VendorsNetworkGP VGP on ven.IdVendor = VGP.Fk_RSA_VendorsNetworkId and VGP.Company = DRIN.Company
		LEFT JOIN (SELECT	@vOTRNumber AS IdRepairNumber, 
							RI.Id AS IdInvoice, 
							REPLACE(ISNULL(RID.GLCode, ''), '-', '') AS GLCode, 
							REPLACE(ISNULL(RID.GLCode, ''), '-', '') AS Department,
							RID.GLDescription
					FROM	RSA_Invoice RI
							LEFT JOIN RSA_InvoiceDetail RID ON RI.Id = RID.IdInvoice
					WHERE	RI.IdRepairNumber= @vOTRNumber
							AND	RID.IdLine = 1
					) IDS ON IDS.IdRepairNumber = tic.Id
WHERE	tic.Id = @vOTRNumber