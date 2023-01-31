SELECT	PMV.VendorId,
		PMV.VendName,
		PMV.VndClsId,
		CASE WHEN VCD.CheckDocOption IS Null OR VCD.CheckDocOption = 1 THEN 'No Documentation'
			 WHEN VCD.CheckDocOption = 2 THEN 'Always Attach Documents'
			 ELSE 'Attach Documents if Amount > ' + CAST(VCD.InvoiceAmount AS Varchar) END AS 'Rule'
FROM	PM00200 PMV
		LEFT JOIN GPCustom.dbo.VendorCheckDocument VCD ON PMV.VendorId = VCD.VendorId AND VCD.Company = DB_NAME()
WHERE	PMV.VNDCLSID <> 'DRV'
ORDER BY 2, 1