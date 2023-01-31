DECLARE	@CompanyId	Char(6),
	@EscrowType	Int

SET	@CompanyId	= 'AIS'
SET	@EscrowType	= 5
	-- HISTORY
		SELECT	RH.SopType AS DocType,
			RD.SopNumbe AS VchrNmbr,
			RH.DocDate,
			RD.SopNumbe AS DocNumbr,
			SeqNumbr AS DstSqNum,
			CrdtAmnt,
			DebitAmt,
			ActIndx AS DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			RH.CustNmbr AS ClientId,
			CU.CustName AS ClientName,
			DistRef
		FROM	SOP10102 RD
			INNER JOIN SOP30200 RH ON RD.SopNumbe = RH.SopNumbe
			LEFT JOIN RM00101 CU ON RH.CustNmbr = CU.CustNmbr
		WHERE	ActIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			RD.SopNumbe IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType)
		UNION
		-- WORK
		SELECT	RH.SopType AS DocType,
			RD.SopNumbe AS VchrNmbr,
			RH.DocDate,
			RD.SopNumbe AS DocNumbr,
			SeqNumbr AS DstSqNum,
			CrdtAmnt,
			DebitAmt,
			ActIndx AS DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			RH.CustNmbr AS ClientId,
			CU.CustName AS ClientName,
			DistRef
		FROM	SOP10102 RD
			INNER JOIN SOP10100 RH ON RD.SopNumbe = RH.SopNumbe
			LEFT JOIN RM00101 CU ON RH.CustNmbr = CU.CustNmbr
		WHERE	ActIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			RD.SopNumbe IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType)
		ORDER BY
			RH.DocDate,
			RH.DocNumbr

SELECT * FROM SOP10100 ORDER BY SOPNUMBE
SELECT * FROM RM20101 WHERE DOCNUMBR IN ('DM-A1214', 'DM-A1215', 'DM-A1216', 'DM-A1217') ORDER BY DOCNUMBR
SELECT * FROM RM10101 WHERE DOCNUMBR IN ('DM-A1214', 'DM-A1215', 'DM-A1216', 'DM-A1217') ORDER BY DOCNUMBR
SELECT * FROM SOP30200 ORDER BY SOPNUMBE