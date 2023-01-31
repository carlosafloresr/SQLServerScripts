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
		inv_remk 
INTO	#tmpInvoice
FROM	FI.FI_Data.dbo.Invoices 
WHERE	Inv_No IN (	SELECT	REPLACE(DocNumber, 'I', '') AS Inv_No
					FROM	Integrations.dbo.MSR_ReceviedTransactions
					WHERE	Company = 'FI'
							AND BatchId = 'AR_FI_110131'
							AND LEFT(DocNumber, 1) = 'I')
							

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
INTO	#tmpSale
FROM	FI.FI_Data.dbo.Sale
WHERE	Inv_No IN (SELECT Inv_No FROM #tmpInvoice)

SELECT	Acct_No, 
		Acct_Name, 
		BAddress, 
		BAddress1, 
		BCity, 
		BState, 
		BZip, 
		BContact, 
		Vencode, 
		ECurrency
INTO	#tmpAccounts
FROM	FI.FI_Data.dbo.Accounts
WHERE	Acct_No IN (SELECT DISTINCT Acct_No FROM #tmpInvoice)

DROP TABLE #tmpInvoice
DROP TABLE #tmpSale
DROP TABLE #tmpAccounts