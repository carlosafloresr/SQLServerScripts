UPDATE	PM30200 
SET		Ten99Amnt = REC.DocAmnt
FROM	(
		SELECT	PMH.Dex_Row_Id
				,PMH.DocAmnt
				,VND.Ten99Type
		FROM	PM30200 PMH
				INNER JOIN PM00200 VND ON PMH.VendorId = VND.VendorId AND VND.Ten99Type > 1
		WHERE	LEFT(PMH.DocNumbr, 3) IN ('DPY','EIN')
				AND PMH.DocAmnt > 0
		) REC
WHERE	PM30200.Dex_Row_Id = REC.Dex_Row_Id