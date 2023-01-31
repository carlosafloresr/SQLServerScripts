-- FIXED ON 05/03/2021 AT 11:44 AM
SELECT	SUP.SupplierID
		,'Y' AS PrimSup
		,PDE.Cost
		,'US$' AS UnitOfMeasure --PIN.UnitOfMeasure
		,PDE.MinLevel
		,PIN.UnitOfMeasure
		,'' AS ModifyBy
		,PDE.Cost
		,ISNULL(CONVERT(Char(10), PDE.LastIssueDate, 101),'')
		,''
		,PIN.SupplierPartNumber
		,''
		,''
		,''
		,PIN.PartNumber
		,'001' AS SHOPID --PIN.PartNumber
FROM	[DirectorSeries].[dbo].[PartsInventory] PIN
		INNER JOIN [DirectorSeries].[dbo].[PartsInventoryDetail] PDE ON PIN.PartsInventoryID = PDE.PartsInventoryID
		LEFT JOIN [DirectorSeries].[dbo].[Supplier] SUP ON PIN.SupplierID = SUP.SupplierID

		--SELECT * FROM [PartsInventory]