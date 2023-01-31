SELECT	VENDORID
INTO	#tmpVendors
FROM	(
		SELECT	VendorId
				,SUM(CRDTAMNT) AS CRDTAMNT
				,SUM(DEBITAMT) AS DEBITAMT
				,Escrow = (SELECT SUM(ESC.Amount) FROM EscrowTransactions ESC WHERE ESC.CompanyId = 'GIS' AND ESC.AccountNumber = '0-00-2784' AND ESC.EnteredOn BETWEEN '01/01/2012' AND '05/29/2012' AND ESC.VendorId = REC.VendorId AND ESC.Source = 'AP')
		FROM	(
				SELECT	PMH.VCHRNMBR
						,PMD.VENDORID
						,PMH.DOCDATE
						,PMH.BACHNUMB
						,PMD.CRDTAMNT
						,PMD.DEBITAMT
						,PMD.DSTSQNUM
						,PMD.DistRef
				FROM	GIS.dbo.PM20000 PMH
						INNER JOIN GIS.dbo.PM10100 PMD ON PMH.TRXSORCE = PMD.TRXSORCE AND PMH.VENDORID = PMD.VENDORID AND PMH.VCHRNMBR = PMD.VCHRNMBR
				WHERE	PMD.DSTINDX IN (SELECT ActIndx FROM GIS.dbo.GL00105 WHERE ACTNUMST = '0-00-2784')
						AND PMH.DOCDATE BETWEEN '01/01/2012' AND '05/29/2012'
						--AND PMD.VENDORID = 'G0118'
				UNION
				SELECT	PMH.VCHRNMBR
						,PMD.VENDORID
						,PMH.DOCDATE
						,PMH.BACHNUMB
						,PMD.CRDTAMNT
						,PMD.DEBITAMT
						,PMD.DSTSQNUM
						,PMD.DistRef
				FROM	GIS.dbo.PM30200 PMH
						INNER JOIN GIS.dbo.PM30600 PMD ON PMH.TRXSORCE = PMD.TRXSORCE AND PMH.VENDORID = PMD.VENDORID AND PMH.VCHRNMBR = PMD.VCHRNMBR
				WHERE	PMD.DSTINDX IN (SELECT ActIndx FROM GIS.dbo.GL00105 WHERE ACTNUMST = '0-00-2784')
						AND PMH.DOCDATE BETWEEN '01/01/2012' AND '05/29/2012'
						--AND PMD.VENDORID = 'G0118'
				) REC
		GROUP BY VendorId
		) DAT
WHERE	CRDTAMNT <> escrow

DELETE	EscrowTransactions 
WHERE	CompanyId = 'GIS' AND Source = 'AP' AND AccountNumber = '0-00-2784' AND EnteredOn BETWEEN '01/01/2012' AND '05/29/2012' AND Fk_EscrowModuleId = 11
		AND VendorId IN (SELECT VendorId FROM #tmpVendors)

INSERT INTO EscrowTransactions (
		Source,
		VoucherNumber,
		ItemNumber,
		CompanyId,
		Fk_EscrowModuleId,
		AccountNumber,
		AccountType,
		VendorId,
		Amount,
		TransactionDate,
		PostingDate,
		EnteredBy,
		EnteredOn,
		ChangedBy,
		ChangedOn,
		BatchId)

SELECT	'AP' AS Source
		,VCHRNMBR
		,DSTSQNUM
		,'GIS'
		,11
		,'0-00-2784'
		,DistType
		,VendorId
		,CRDTAMNT
		,DOCDATE
		,PstgDate
		,PTDUsrId
		,ModifDt
		,PTDUsrId
		,ModifDt
		,BACHNUMB
FROM	(
		SELECT	PMH.VCHRNMBR
				,PMD.VENDORID
				,PMH.DOCDATE
				,PMH.BACHNUMB
				,PMD.CRDTAMNT
				,PMD.DEBITAMT
				,PMD.DSTSQNUM
				,PMD.DistRef
				,PMD.DistType
				,PMD.PstgDate
				,PMH.ModifDt
				,PMH.PTDUsrId
		FROM	GIS.dbo.PM20000 PMH
				INNER JOIN GIS.dbo.PM10100 PMD ON PMH.TRXSORCE = PMD.TRXSORCE AND PMH.VENDORID = PMD.VENDORID AND PMH.VCHRNMBR = PMD.VCHRNMBR
		WHERE	PMD.DSTINDX IN (SELECT ActIndx FROM GIS.dbo.GL00105 WHERE ACTNUMST = '0-00-2784')
				AND PMH.DOCDATE BETWEEN '01/01/2012' AND '05/29/2012'
		UNION
		SELECT	PMH.VCHRNMBR
				,PMD.VENDORID
				,PMH.DOCDATE
				,PMH.BACHNUMB
				,PMD.CRDTAMNT
				,PMD.DEBITAMT
				,PMD.DSTSQNUM
				,PMD.DistRef
				,PMD.DistType
				,PMD.PstgDate
				,PMH.ModifDt
				,PMH.PTDUsrId
		FROM	GIS.dbo.PM30200 PMH
				INNER JOIN GIS.dbo.PM30600 PMD ON PMH.TRXSORCE = PMD.TRXSORCE AND PMH.VENDORID = PMD.VENDORID AND PMH.VCHRNMBR = PMD.VCHRNMBR
		WHERE	PMD.DSTINDX IN (SELECT ActIndx FROM GIS.dbo.GL00105 WHERE ACTNUMST = '0-00-2784')
				AND PMH.DOCDATE BETWEEN '01/01/2012' AND '05/29/2012'
		) REC
WHERE	VendorId IN (SELECT VendorId FROM #tmpVendors)

DROP TABLE #tmpVendors