--SELECT	[Vendor ID], 
--		[Document Date] AS [Check Date], 
--		[Document Number] AS [Check Number], 
--		[Document Type], 
--		[Document Amount], 
--		[Vendor Check Name],
--		[Vendor Check Name from Vendor Master]
--FROM    PayablesTransactions
--WHERE   [Document Type] = 'Payment'

SELECT	M1.*,
		C1.*
FROM	ME123504 M1
		LEFT JOIN CM20200 C1 ON M1.CHEKBKID = C1.CHEKBKID AND M1.CMTrxNum = C1.CMTrxNum
WHERE	M1.MEUPLDID = '10/24/2019-4:03:10 P'
		AND C1.SOURCDOC = 'PMCHK      '

--SELECT	*
--FROM	ME123506

SELECT	*
FROM	CM20200