DECLARE	@BatchId	Varchar(25),
		@Counter	Int

SET		@BatchId	=  'AR_FI_110131'
--SELECT DISTINCT Inv_No FROM Invoices WHERE BatchId = 'AR_FI_110131' AND Inv_No NOT IN (SELECT Inv_No FROM ILSINT01.FI_Data.dbo.Invoices WHERE BatchId = 'AR_FI_110131')
SELECT	inv_no, 
		sbt_no, 
		acct_no, 
		inv_date, 
		inv_total, 
		inv_type, 
		inv_mech, 
		container, 
		chassis, 
		genset_no, 
		labor_hour, 
		labor, 
		parts, 
		tirerpl, 
		tirerpr, 
		size, 
		sale_tax1, 
		sale_tax2, 
		unit_f, 
		tir_no, 
		gen_ser, 
		gen_mod, 
		gen_hours, 
		driver, 
		inv_batch, 
		fhwa, 
		inv_format, 
		approval, 
		cdex_lesee, 
		cdex_dpp, 
		cedxonhir, 
		fhwaappv, 
		eq_datein, 
		mfg_date, 
		rep_date, 
		workorder, 
		inv_remk,
		@BatchId AS BatchId
INTO	#tmpInvoice
FROM	FI_Data.dbo.Invoices 
WHERE	BatchId = @BatchId

SELECT	TMP.Inv_No, 
		TMP.Inv_Total,
		TMP.Acct_No
INTO	#tmpInvValid
FROM	#tmpInvoice TMP, ILSINT01.FI_Data.dbo.Invoices INV 
WHERE	TMP.Inv_No = INV.Inv_No
		AND (INV.Inv_No IS NULL
		OR TMP.Inv_Total <> INV.Inv_Total)

SET		@Counter = (SELECT COUNT(Inv_No) FROM #tmpInvValid)

IF @Counter > 0
BEGIN
	--DELETE	ILSINT01.FI_Data.dbo.Invoices
	--WHERE	BatchId = @BatchId
	--		AND Inv_No IN (SELECT Inv_No FROM #tmpInvValid)
	

	--EXECUTE ILSINT01.FI_Data.dbo.USP_DeleteInvalidSaleRecords @BatchId
	
	--INSERT INTO ILSINT01.FI_Data.dbo.Invoices
	--		(inv_no, 
	--		sbt_no, 
	--		acct_no, 
	--		inv_date, 
	--		inv_total, 
	--		inv_type, 
	--		inv_mech, 
	--		container, 
	--		chassis, 
	--		genset_no, 
	--		labor_hour, 
	--		labor, 
	--		parts, 
	--		tirerpl, 
	--		tirerpr, 
	--		size, 
	--		sale_tax1, 
	--		sale_tax2, 
	--		unit_f, 
	--		tir_no, 
	--		gen_ser, 
	--		gen_mod, 
	--		gen_hours, 
	--		driver, 
	--		inv_batch, 
	--		fhwa, 
	--		inv_format, 
	--		approval, 
	--		cdex_lesee, 
	--		cdex_dpp, 
	--		cedxonhir, 
	--		fhwaappv, 
	--		eq_datein, 
	--		mfg_date, 
	--		rep_date, 
	--		workorder, 
	--		inv_remk,
	--		BatchId)
	SELECT	*
	FROM	#tmpInvoice
	WHERE	Inv_No IN (SELECT Inv_No FROM #tmpInvValid)
	
	SELECT	inv_no, 
			part_no, 
			descript, 
			qty_shiped,
			unit_price, 
			part_total, 
			itemtot, 
			repaircd,
			damagecd, 
			partscd, 
			cdex_party, 
			cdex_damag,
			cdex_repai, 
			cdex_compo, 
			cdex_locat, 
			cdex_lengt,
			cdex_width, 
			dpart_no, 
			rlabor, 
			rlabor_qty,
			newdoton, 
			newdotoff, 
			lpart_no, 
			idcs_ym, 
			idcs_loc,
			idcs_cond
	--INTO	#tmpSale
	FROM	FI_Data.dbo.Sale
	WHERE	Inv_No IN (SELECT Inv_No FROM #tmpInvValid)

	--INSERT INTO ILSINT01.FI_Data.dbo.Sale
	--		(inv_no, 
	--		part_no, 
	--		descript, 
	--		qty_shiped,
	--		unit_price, 
	--		part_total, 
	--		itemtot, 
	--		repaircd,
	--		damagecd, 
	--		partscd, 
	--		cdex_party, 
	--		cdex_damag,
	--		cdex_repai, 
	--		cdex_compo, 
	--		cdex_locat, 
	--		cdex_lengt,
	--		cdex_width, 
	--		dpart_no, 
	--		rlabor, 
	--		rlabor_qty,
	--		newdoton, 
	--		newdotoff, 
	--		lpart_no, 
	--		idcs_ym, 
	--		idcs_loc,
	--		idcs_cond)
	--SELECT	*
	--FROM	#tmpSale

	--SELECT	Acct_No, 
	--		Acct_Name, 
	--		BAddress, 
	--		BAddress1, 
	--		BCity, 
	--		BState, 
	--		BZip, 
	--		BContact, 
	--		Vencode, 
	--		ECurrency
	--INTO	#tmpAccounts
	--FROM	FI_Data.dbo.Accounts
	--WHERE	Acct_No IN (SELECT DISTINCT Acct_No FROM #tmpInvValid)

	--INSERT INTO ILSINT01.FI_Data.dbo.Accounts
	--		(Acct_No, 
	--		Acct_Name, 
	--		BAddress, 
	--		BAddress1, 
	--		BCity, 
	--		BState, 
	--		BZip, 
	--		BContact, 
	--		Vencode, 
	--		ECurrency)
	--SELECT	*
	--FROM	#tmpAccounts
	--WHERE	Acct_No NOT IN (SELECT Acct_No FROM ILSINT01.FI_Data.dbo.Accounts)

	--DROP TABLE #tmpSale
	--DROP TABLE #tmpAccounts
END

DROP TABLE #tmpInvValid
DROP TABLE #tmpInvoice