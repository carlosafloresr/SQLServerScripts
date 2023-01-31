SELECT DISTINCT MAX([ImportVendorFile].[ProductID]) AS ProductID,
      [ImportVendorFile].[VendorID] AS ImportVendorID,
      [ImportVendorFile].[VendorName] AS ImportVendorName,
      [Vendors].[CCI VENDOR CODE],
      [Vendors].[TP VENDOR CODE]
FROM [dbo].[datafiles_VendorMaster] AS ImportVendorFile
      LEFT OUTER JOIN [dbo].[OSP_map_ApprovedVendors] AS Vendors ON [ImportVendorFile].[VendorID] >= [Vendors].[CCI VENDOR CODE] + '' AND [ImportVendorFile].[VendorID] <= [Vendors].[CCI VENDOR CODE]
WHERE [ImportVendorFile].[VendorID] IS NOT NULL
GROUP BY [ImportVendorFile].[VendorID], [ImportVendorFile].[VendorName], [Vendors].[CCI VENDOR CODE], [Vendors].[TP VENDOR CODE]

SELECT DISTINCT [ImportVendorFile].[VendorID] AS ImportVendorID
		, [ImportVendorFile].[VendorName] AS ImportVendorName
		, [Vendors].[CCI VENDOR CODE]
		, [Vendors].[TP VENDOR CODE]
		, CASE WHEN [Vendors].[CCI VENDOR CODE] IS Null THEN 'Without Approved Vendors' ELSE 'With Approved Vendors' END AS [Status]
FROM	[dbo].[datafiles_VendorMaster] ImportVendorFile
		LEFT JOIN [dbo].[OSP_map_ApprovedVendors] Vendors ON [ImportVendorFile].[VendorID] = [Vendors].[CCI VENDOR CODE]
ORDER BY
		[ImportVendorFile].[VendorID]
		, [ImportVendorFile].[VendorName]
		, [Vendors].[CCI VENDOR CODE]
		, [Vendors].[TP VENDOR CODE]


CREATE INDEX IX_datafiles_VendorMaster_ProductID ON [datafiles_VendorMaster] (ProductID);

CREATE INDEX IX_datafiles_VendorMaster_VendorID ON [datafiles_VendorMaster] (VendorID);

CREATE INDEX IX_Vendors_TPVendorCode ON [Vendors] ([TP VENDOR CODE]);
