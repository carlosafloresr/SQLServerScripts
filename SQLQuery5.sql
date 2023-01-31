SELECT	OOS.Company
		,OOS.WED
		,OOS.Vendorid
		,SUM(CASE WHEN OOS.ColumnType = 'STDESCROW' THEN OOS.DedAmount ELSE 0.00 END) AS StandardEscrow
		,SUM(CASE WHEN OOS.ColumnType = 'OOINSURANCE' THEN OOS.DedAmount ELSE 0.00 END) AS OOInsurance
		,SUM(CASE WHEN OOS.ColumnType = 'PEOPLENET' THEN OOS.DedAmount ELSE 0.00 END) AS PeopleNet
		,SUM(CASE WHEN OOS.ColumnType = 'GARNISHMENTS' THEN OOS.DedAmount ELSE 0.00 END) AS Garnishments
		,SUM(CASE WHEN OOS.ColumnType = 'M&R' THEN OOS.DedAmount ELSE 0.00 END) AS MaintAndRepairs
		,SUM(CASE WHEN OOS.ColumnType = 'LEASEPAYMENT' THEN OOS.DedAmount ELSE 0.00 END) AS LeasePayment
		,SUM(CASE WHEN OOS.ColumnType = 'SAVING' THEN OOS.DedAmount ELSE 0.00 END) AS Savings
		,SUM(CASE WHEN OOS.ColumnType = 'ADVREPAY' THEN OOS.DedAmount ELSE 0.00 END) AS EscrowRepayment
		,SUM(CASE WHEN OOS.ColumnType = 'TAG&TAXES' THEN OOS.DedAmount ELSE 0.00 END) AS TagsandTaxes
		,SUM(CASE WHEN OOS.ColumnType = 'OTHERINS' THEN ISNULL(OOS.DedAmount, 0.00) ELSE 0.00 END) AS OtherInsurance
		,SUM(CASE WHEN OOS.ColumnType = 'OTHER' OR OOS.ColumnType IS Null THEN ISNULL(OOS.DedAmount, 0.00) ELSE 0.00 END) AS OtherDeductions
FROM	GPCustom.dbo.View_OOS_Transactions OOS
WHERE	OOS.Company = 'GIS'
		AND OOS.WED BETWEEN '01/01/2021' AND '02/19/2022'
		AND OOS.Trans_DeletedOn IS Null
		AND OOS.VendorId = 'G50276'
GROUP BY
		OOS.Company
		,OOS.WED
		,OOS.Vendorid