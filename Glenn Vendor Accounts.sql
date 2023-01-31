UPDATE	Records3
SET		Records3.[Purchases Account Number] = REC.ActNumSt
FROM	(
SELECT	P1.VchrNmbr,
		GL.ActNumSt
FROM	Records3 REC
		LEFT JOIN ILSGP01.RCMR.dbo.PM30200 P1 ON REC.[Vendor Id] = P1.VendorId AND REC.[Trans Number] = P1.VchrNmbr AND LEFT(P1.TrxSorce, 5) = 'PMTRX'
		LEFT JOIN ILSGP01.RCMR.dbo.PM30600 P2 ON P1.VendorId = P2.VendorId AND P1.VchrNmbr = P2.VchrNmbr AND P1.TrxSorce = P2.TrxSorce AND P2.DstSqNum = 16384
		LEFT JOIN ILSGP01.RCMR.dbo.GL00105 GL ON P2.DstIndx = GL.ActIndx) REC
WHERE	Records3.[Trans Number] = REC.VchrNmbr
		AND RTRIM(Records3.[Purchases Account Number]) = ''
/*
SELECT * FROM Records1
SELECT * FROM ILSGP01.RCMR.dbo.PM30200
SELECT * FROM ILSGP01.RCMR.dbo.PM30600
SELECT * FROM ILSGP01.RCMR.dbo.GL00105
*/