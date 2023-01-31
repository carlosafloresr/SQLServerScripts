--EXECUTE USP_GPEscrowRecords 'SO', 'AIS', 1
CREATE PROCEDURE USP_GPEscrowRecords
	@EntryType	Char(2),
	@CompanyId	Char(6),
	@EscrowType	Int,
	@VendorId	Char(10) = Null,
	@VoucherNumber	Varchar(25) =  Null
AS
IF @EntryType = 'AP'
BEGIN
	IF @VendorId IS Null AND @VoucherNumber IS Null
	BEGIN
		-- HISTORIC AP
		SELECT 	DISTINCT PD.DocType,
			PD.VchrNmbr,
			DocDate,
			DocNumbr,
			DstSqNum,
			CrdtAmnt,
			DebitAmt,
			DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			PD.VendorId AS ClientId,
			VendName AS ClientName,
			DistRef,
			'HISTORIC' AS DataTable
		FROM 	PM30600 PD
			INNER JOIN PM30200 PH ON PD.VchrNmbr = PH.VchrNmbr AND PD.DocType = PH.DocType
			LEFT JOIN PM00200 VE ON PD.VendorId = VE.VendorId
		WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND 
			PD.VchrNmbr NOT IN (SELECT VchrNmbr FROM PM10100)
		UNION
		-- WORK AP
		SELECT 	DISTINCT DocType,
			PD.VchrNmbr,
			DocDate,
			DocNumbr,
			DstSqNum,
			CrdtAmnt,
			DebitAmt,
			DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			PD.VendorId AS ClientId,
			VendName AS ClientName,
			DistRef,
			'WORK' AS DataTable
		FROM 	PM10100 PD
			INNER JOIN PM10000 PH ON PD.VchrNmbr = PH.VchNumWk
			LEFT JOIN PM00200 VE ON PD.VendorId = VE.VendorId
		WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType)
		UNION
		-- OPEN AP
		SELECT 	DISTINCT PD.DocType,
			PD.VchrNmbr,
			DocDate,
			DocNumbr,
			DstSqNum,
			CrdtAmnt,
			DebitAmt,
			DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			PH.VendorId,
			VendName AS ClientName,
			'' AS DistRef,
			'OPEN' AS DataTable
		FROM 	PM20200 PD
			INNER JOIN PM20000 PH ON PD.VchrNmbr = PH.VchrNmbr AND PD.DocType = PH.DocType
			LEFT JOIN PM00200 VE ON PH.VendorId = VE.VendorId
		WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType)
		ORDER BY
			DocDate,
			PD.VchrNmbr
	END
	ELSE
	BEGIN
		IF @VoucherNumber IS Null
		BEGIN
			-- HISTORIC AP
			SELECT 	PD.DocType,
				PD.VchrNmbr,
				DocDate,
				DocNumbr,
				DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				PD.VendorId AS ClientId,
				VendName AS ClientName,
				DistRef
			FROM 	PM30600 PD
				INNER JOIN PM30200 PH ON PD.VchrNmbr = PH.VchrNmbr AND PD.DocType = PH.DocType
				LEFT JOIN PM00200 VE ON PD.VendorId = VE.VendorId
			WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VendorId = @VendorId
			UNION
			-- WORK AP
			SELECT 	DocType,
				PD.VchrNmbr,
				DocDate,
				DocNumbr,
				DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				PD.VendorId AS ClientId,
				VendName AS ClientName,
				DistRef
			FROM 	PM10100 PD
				INNER JOIN PM10000 PH ON PD.VchrNmbr = PH.VchNumWk
				LEFT JOIN PM00200 VE ON PD.VendorId = VE.VendorId
			WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VendorId = @VendorId
			UNION
			-- OPEN AP
			SELECT 	PD.DocType,
				PD.VchrNmbr,
				DocDate,
				DocNumbr,
				DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				PH.VendorId,
				VendName AS ClientName,
				'' AS DistRef
			FROM 	PM20200 PD
				INNER JOIN PM20000 PH ON PD.VchrNmbr = PH.VchrNmbr AND PD.DocType = PH.DocType
				LEFT JOIN PM00200 VE ON PH.VendorId = VE.VendorId
			WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PH.VendorId = @VendorId
			ORDER BY
				DocDate,
				PD.VchrNmbr
		END
		ELSE
		BEGIN
			-- HISTORIC AP
			SELECT 	PD.DocType,
				PD.VchrNmbr,
				DocDate,
				DocNumbr,
				DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				PD.VendorId AS ClientId,
				VendName AS ClientName,
				DistRef
			FROM 	PM30600 PD
				INNER JOIN PM30200 PH ON PD.VchrNmbr = PH.VchrNmbr AND PD.DocType = PH.DocType
				LEFT JOIN PM00200 VE ON PD.VendorId = VE.VendorId
			WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VchrNmbr = @VoucherNumber
			UNION
			-- WORK AP
			SELECT 	DocType,
				PD.VchrNmbr,
				DocDate,
				DocNumbr,
				DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				PD.VendorId AS ClientId,
				VendName AS ClientName,
				DistRef
			FROM 	PM10100 PD
				INNER JOIN PM10000 PH ON PD.VchrNmbr = PH.VchNumWk
				LEFT JOIN PM00200 VE ON PD.VendorId = VE.VendorId
			WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VchrNmbr = @VoucherNumber
			UNION
			-- OPEN AP
			SELECT 	PD.DocType,
				PD.VchrNmbr,
				DocDate,
				DocNumbr,
				DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				PH.VendorId,
				VendName AS ClientName,
				'' AS DistRef
			FROM 	PM20200 PD
				INNER JOIN PM20000 PH ON PD.VchrNmbr = PH.VchrNmbr AND PD.DocType = PH.DocType
				LEFT JOIN PM00200 VE ON PH.VendorId = VE.VendorId
			WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				PH.VchrNmbr = @VoucherNumber
			ORDER BY
				DocDate,
				PD.VchrNmbr
		END
	END
END -- END OF AP

IF @EntryType = 'AR'
BEGIN
	IF @VendorId IS Null AND @VoucherNumber IS Null
	BEGIN
		-- HISTORIC
		SELECT	RH.RmdTypal AS DocType,
			RD.DocNumbr AS VchrNmbr,
			RH.DocDate,
			RD.DocNumbr AS DocNumbr,
			SeqNumbr AS DstSqNum,
			CrdtAmnt,
			DebitAmt,
			DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			RD.CustNmbr AS ClientId,
			CU.CustName AS ClientName,
			DistRef
		FROM	RM30301 RD
			INNER JOIN RM30101 RH ON RD.DOCNUMBR = RH.DOCNUMBR
			LEFT JOIN RM00101 CU ON RD.CustNmbr = CU.CustNmbr
		WHERE	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			RD.DOCNUMBR NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType)
		UNION
		-- WORK
		SELECT	RH.RmdTypal AS DocType,
			RH.DocNumbr AS VchrNmbr,
			RH.DocDate,
			RD.DocNumbr AS DocNumbr,
			SeqNumbr AS DstSqNum,
			CrdtAmnt,
			DebitAmt,
			DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			RD.CustNmbr AS ClientId,
			CU.CustName AS ClientName,
			DistRef
		FROM	RM10101 RD
			INNER JOIN RM10301 RH ON RD.DOCNUMBR = RH.DOCNUMBR
			LEFT JOIN RM00101 CU ON RD.CustNmbr = CU.CustNmbr
		WHERE	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			RD.DOCNUMBR NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType)
		UNION
		-- OPEN
		SELECT	RH.RmdTypal AS DocType,
			RH.DocNumbr AS VchrNmbr,
			RH.DocDate,
			RD.DocNumbr AS DocNumbr,
			SeqNumbr AS DstSqNum,
			CrdtAmnt,
			DebitAmt,
			DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			RD.CustNmbr AS ClientId,
			CU.CustName AS ClientName,
			DistRef
		FROM	RM10101 RD
			INNER JOIN RM20101 RH ON RD.DOCNUMBR = RH.DOCNUMBR
			LEFT JOIN RM00101 CU ON RD.CustNmbr = CU.CustNmbr
		WHERE	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			RD.DOCNUMBR NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType)
		ORDER BY
			RH.DocDate,
			RH.DocNumbr
	END
	ELSE
	BEGIN
		IF @VoucherNumber IS Null
		BEGIN
			-- HISTORIC
			SELECT	RH.RmdTypal AS DocType,
				RD.DocNumbr AS VchrNmbr,
				RH.DocDate,
				RD.DocNumbr AS DocNumbr,
				SeqNumbr AS DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				RD.CustNmbr AS ClientId,
				CU.CustName AS ClientName,
				DistRef
			FROM	RM30301 RD
				INNER JOIN RM30101 RH ON RD.DOCNUMBR = RH.DOCNUMBR
				LEFT JOIN RM00101 CU ON RD.CustNmbr = CU.CustNmbr
			WHERE	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				RD.DOCNUMBR NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RD.CustNmbr = @VendorId
			UNION
			-- WORK
			SELECT	RH.RmdTypal AS DocType,
				RH.DocNumbr AS VchrNmbr,
				RH.DocDate,
				RD.DocNumbr AS DocNumbr,
				SeqNumbr AS DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				RD.CustNmbr AS ClientId,
				CU.CustName AS ClientName,
				DistRef
			FROM	RM10101 RD
				INNER JOIN RM10301 RH ON RD.DOCNUMBR = RH.DOCNUMBR
				LEFT JOIN RM00101 CU ON RD.CustNmbr = CU.CustNmbr
			WHERE	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				RD.DOCNUMBR NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RD.CustNmbr = @VendorId
			UNION
			-- OPEN
			SELECT	RH.RmdTypal AS DocType,
				RH.DocNumbr AS VchrNmbr,
				RH.DocDate,
				RD.DocNumbr AS DocNumbr,
				SeqNumbr AS DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				RD.CustNmbr AS ClientId,
				CU.CustName AS ClientName,
				DistRef
			FROM	RM10101 RD
				INNER JOIN RM20101 RH ON RD.DOCNUMBR = RH.DOCNUMBR
				LEFT JOIN RM00101 CU ON RD.CustNmbr = CU.CustNmbr
			WHERE	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				RD.DOCNUMBR NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RD.CustNmbr = @VendorId
			ORDER BY
				RH.DocDate,
				RH.DocNumbr
		END
		ELSE
		BEGIN
			-- HISTORIC
			SELECT	RH.RmdTypal AS DocType,
				RD.DocNumbr AS VchrNmbr,
				RH.DocDate,
				RD.DocNumbr AS DocNumbr,
				SeqNumbr AS DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				RD.CustNmbr AS ClientId,
				CU.CustName AS ClientName,
				DistRef
			FROM	RM30301 RD
				INNER JOIN RM30101 RH ON RD.DOCNUMBR = RH.DOCNUMBR
				LEFT JOIN RM00101 CU ON RD.CustNmbr = CU.CustNmbr
			WHERE	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				RD.DOCNUMBR NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RH.DocNumbr = @VoucherNumber
			UNION
			-- WORK
			SELECT	RH.RmdTypal AS DocType,
				RH.DocNumbr AS VchrNmbr,
				RH.DocDate,
				RD.DocNumbr AS DocNumbr,
				SeqNumbr AS DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				RD.CustNmbr AS ClientId,
				CU.CustName AS ClientName,
				DistRef
			FROM	RM10101 RD
				INNER JOIN RM10301 RH ON RD.DOCNUMBR = RH.DOCNUMBR
				LEFT JOIN RM00101 CU ON RD.CustNmbr = CU.CustNmbr
			WHERE	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				RD.DOCNUMBR NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RH.DocNumbr = @VoucherNumber
			UNION
			-- OPEN
			SELECT	RH.RmdTypal AS DocType,
				RH.DocNumbr AS VchrNmbr,
				RH.DocDate,
				RD.DocNumbr AS DocNumbr,
				SeqNumbr AS DstSqNum,
				CrdtAmnt,
				DebitAmt,
				DstIndx,
				DistType,
				CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
				(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
				RD.CustNmbr AS ClientId,
				CU.CustName AS ClientName,
				DistRef
			FROM	RM10101 RD
				INNER JOIN RM20101 RH ON RD.DOCNUMBR = RH.DOCNUMBR
				LEFT JOIN RM00101 CU ON RD.CustNmbr = CU.CustNmbr
			WHERE	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
				RD.DOCNUMBR NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RH.DocNumbr = @VoucherNumber
			ORDER BY
				RH.DocDate,
				RH.DocNumbr
		END
	END
END -- END OF AR

IF @EntryType = 'SO'
BEGIN
	IF @VendorId IS Null AND @VoucherNumber IS Null
	BEGIN
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
			RD.SopNumbe NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType)
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
			RD.SopNumbe NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType)
		ORDER BY
			RH.DocDate,
			RH.DocNumbr
	END
	ELSE
	BEGIN
		IF @VoucherNumber IS Null
		BEGIN
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
				RD.SopNumbe NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RH.CustNmbr = @VendorId
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
				RD.SopNumbe NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RH.CustNmbr = @VendorId
			ORDER BY
				RH.DocDate,
				RH.DocNumbr
		END
		ELSE
		BEGIN
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
				RD.SopNumbe NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RH.SopNumbe = @VoucherNumber
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
				RD.SopNumbe NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
				RH.SopNumbe = @VoucherNumber
			ORDER BY
				RH.DocDate,
				RH.DocNumbr
		END
	END
END -- END OF SO

IF @EntryType = 'GL'
BEGIN
	IF @VoucherNumber IS Null
	BEGIN
		-- WORK/HISTORY
		SELECT	99 AS DocType,
			CAST(JrnEntry AS Char(20)) AS VchrNmbr,
			TrxDate AS DocDate,
			CAST(JrnEntry AS Char(20)) AS DocNumbr,
			SeqNumbr AS DstSqNum,
			CrdtAmnt,
			DebitAmt,
			ActIndx AS DstIndx,
			99 AS DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			'' AS ClientId,
			'' AS ClientName,
			ISNULL(Dscriptn,Refrence) AS DistRef
		FROM	GL30000
		WHERE	ActIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			CAST(JrnEntry AS Char(20)) NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType)
	END
	ELSE
	BEGIN
		-- WORK/HISTORY
		SELECT	99 AS DocType,
			CAST(JrnEntry AS Char(20)) AS VchrNmbr,
			TrxDate AS DocDate,
			CAST(JrnEntry AS Char(20)) AS DocNumbr,
			SeqNumbr AS DstSqNum,
			CrdtAmnt,
			DebitAmt,
			ActIndx AS DstIndx,
			99 AS DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			'' AS ClientId,
			'' AS ClientName,
			ISNULL(Dscriptn,Refrence) AS DistRef
		FROM	GL30000
		WHERE	ActIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10 AND Fk_EscrowModuleId = @EscrowType) AND
			CAST(JrnEntry AS Char(20)) NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId = @EscrowType) AND
			RTRIM(CAST(JrnEntry AS Char(20))) = @VoucherNumber
	END
END


GO
