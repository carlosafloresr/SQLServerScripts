CREATE PROCEDURE USP_Fix_SOPEscrowRecords
AS
IF EXISTS(SELECT TOP 1 VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE Source IN ('AR','SO') AND ItemNumber IS Null AND DeletedBy IS Null)
BEGIN
	-- AIS
	IF EXISTS(SELECT TOP 1 VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE Source IN ('AR','SO') AND ItemNumber IS Null AND DeletedBy IS Null AND CompanyId = 'AIS')
	BEGIN
		UPDATE	GPCustom.dbo.EscrowTransactions
		SET		ItemNumber = DAT.SEQNUMBR
		FROM	(
				SELECT	SOP.SOPNUMBE
						,SOP.SEQNUMBR
						,SOP.CRDTAMNT
						,ESC.Amount
						,ESC.AccountNumber
						,ESC.EscrowTransactionId
						,ESC.ItemNumber
				FROM	AIS.dbo.SOP10102 SOP
						INNER JOIN GPCustom.dbo.EscrowTransactions ESC ON SOP.SOPNUMBE = ESC.VoucherNumber
						INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON ESC.Fk_EscrowModuleId = ESA.Fk_EscrowModuleId AND SOP.ACTINDX = ESA.AccountIndex AND ESC.CompanyId = ESC.CompanyId
				WHERE	ESC.Source IN ('AR','SO')
						AND ESC.ItemNumber IS Null
						AND ESC.CompanyId = DB_NAME()
				) DAT
		WHERE	EscrowTransactions.EscrowTransactionId = DAT.EscrowTransactionId

		DELETE	GPCustom.dbo.EscrowTransactions
		WHERE	Source IN ('AR','SO')
				AND ItemNumber IS Null
				AND DeletedBy IS Null
				AND CompanyId = DB_NAME()
				AND VoucherNumber NOT IN (SELECT SOPNUMBE FROM AIS.dbo.SOP10102)
	END

	-- DNJ
	IF EXISTS(SELECT TOP 1 VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE Source IN ('AR','SO') AND ItemNumber IS Null AND DeletedBy IS Null AND CompanyId = 'AIS')
	BEGIN
		UPDATE	GPCustom.dbo.EscrowTransactions
		SET		ItemNumber = DAT.SEQNUMBR
		FROM	(
				SELECT	SOP.SOPNUMBE
						,SOP.SEQNUMBR
						,SOP.CRDTAMNT
						,ESC.Amount
						,ESC.AccountNumber
						,ESC.EscrowTransactionId
						,ESC.ItemNumber
				FROM	DNJ.dbo.SOP10102 SOP
						INNER JOIN GPCustom.dbo.EscrowTransactions ESC ON SOP.SOPNUMBE = ESC.VoucherNumber
						INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON ESC.Fk_EscrowModuleId = ESA.Fk_EscrowModuleId AND SOP.ACTINDX = ESA.AccountIndex AND ESC.CompanyId = ESC.CompanyId
				WHERE	ESC.Source IN ('AR','SO')
						AND ESC.ItemNumber IS Null
						AND ESC.CompanyId = DB_NAME()
				) DAT
		WHERE	EscrowTransactions.EscrowTransactionId = DAT.EscrowTransactionId

		DELETE	GPCustom.dbo.EscrowTransactions
		WHERE	Source IN ('AR','SO')
				AND ItemNumber IS Null
				AND DeletedBy IS Null
				AND CompanyId = DB_NAME()
				AND VoucherNumber NOT IN (SELECT SOPNUMBE FROM DNJ.dbo.SOP10102)
	END

	-- GIS
	IF EXISTS(SELECT TOP 1 VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE Source IN ('AR','SO') AND ItemNumber IS Null AND DeletedBy IS Null AND CompanyId = 'AIS')
	BEGIN
		UPDATE	GPCustom.dbo.EscrowTransactions
		SET		ItemNumber = DAT.SEQNUMBR
		FROM	(
				SELECT	SOP.SOPNUMBE
						,SOP.SEQNUMBR
						,SOP.CRDTAMNT
						,ESC.Amount
						,ESC.AccountNumber
						,ESC.EscrowTransactionId
						,ESC.ItemNumber
				FROM	GIS.dbo.SOP10102 SOP
						INNER JOIN GPCustom.dbo.EscrowTransactions ESC ON SOP.SOPNUMBE = ESC.VoucherNumber
						INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON ESC.Fk_EscrowModuleId = ESA.Fk_EscrowModuleId AND SOP.ACTINDX = ESA.AccountIndex AND ESC.CompanyId = ESC.CompanyId
				WHERE	ESC.Source IN ('AR','SO')
						AND ESC.ItemNumber IS Null
						AND ESC.CompanyId = DB_NAME()
				) DAT
		WHERE	EscrowTransactions.EscrowTransactionId = DAT.EscrowTransactionId

		DELETE	GPCustom.dbo.EscrowTransactions
		WHERE	Source IN ('AR','SO')
				AND ItemNumber IS Null
				AND DeletedBy IS Null
				AND CompanyId = DB_NAME()
				AND VoucherNumber NOT IN (SELECT SOPNUMBE FROM GIS.dbo.SOP10102)
	END

	-- IMC
	IF EXISTS(SELECT TOP 1 VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE Source IN ('AR','SO') AND ItemNumber IS Null AND DeletedBy IS Null AND CompanyId = 'AIS')
	BEGIN
		UPDATE	GPCustom.dbo.EscrowTransactions
		SET		ItemNumber = DAT.SEQNUMBR
		FROM	(
				SELECT	SOP.SOPNUMBE
						,SOP.SEQNUMBR
						,SOP.CRDTAMNT
						,ESC.Amount
						,ESC.AccountNumber
						,ESC.EscrowTransactionId
						,ESC.ItemNumber
				FROM	IMC.dbo.SOP10102 SOP
						INNER JOIN GPCustom.dbo.EscrowTransactions ESC ON SOP.SOPNUMBE = ESC.VoucherNumber
						INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON ESC.Fk_EscrowModuleId = ESA.Fk_EscrowModuleId AND SOP.ACTINDX = ESA.AccountIndex AND ESC.CompanyId = ESC.CompanyId
				WHERE	ESC.Source IN ('AR','SO')
						AND ESC.ItemNumber IS Null
						AND ESC.CompanyId = DB_NAME()
				) DAT
		WHERE	EscrowTransactions.EscrowTransactionId = DAT.EscrowTransactionId

		DELETE	GPCustom.dbo.EscrowTransactions
		WHERE	Source IN ('AR','SO')
				AND ItemNumber IS Null
				AND DeletedBy IS Null
				AND CompanyId = DB_NAME()
				AND VoucherNumber NOT IN (SELECT SOPNUMBE FROM IMC.dbo.SOP10102)
	END

	-- NDS
	IF EXISTS(SELECT TOP 1 VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE Source IN ('AR','SO') AND ItemNumber IS Null AND DeletedBy IS Null AND CompanyId = 'AIS')
	BEGIN
		UPDATE	GPCustom.dbo.EscrowTransactions
		SET		ItemNumber = DAT.SEQNUMBR
		FROM	(
				SELECT	SOP.SOPNUMBE
						,SOP.SEQNUMBR
						,SOP.CRDTAMNT
						,ESC.Amount
						,ESC.AccountNumber
						,ESC.EscrowTransactionId
						,ESC.ItemNumber
				FROM	NDS.dbo.SOP10102 SOP
						INNER JOIN GPCustom.dbo.EscrowTransactions ESC ON SOP.SOPNUMBE = ESC.VoucherNumber
						INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON ESC.Fk_EscrowModuleId = ESA.Fk_EscrowModuleId AND SOP.ACTINDX = ESA.AccountIndex AND ESC.CompanyId = ESC.CompanyId
				WHERE	ESC.Source IN ('AR','SO')
						AND ESC.ItemNumber IS Null
						AND ESC.CompanyId = DB_NAME()
				) DAT
		WHERE	EscrowTransactions.EscrowTransactionId = DAT.EscrowTransactionId

		DELETE	GPCustom.dbo.EscrowTransactions
		WHERE	Source IN ('AR','SO')
				AND ItemNumber IS Null
				AND DeletedBy IS Null
				AND CompanyId = DB_NAME()
				AND VoucherNumber NOT IN (SELECT SOPNUMBE FROM NDS.dbo.SOP10102)
	END
END