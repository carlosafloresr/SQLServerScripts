/*
SELECT	APT.VendorId
		,VND.VendName
		,VND.Ten99Type
		,CASE	WHEN VND.Ten99Type = 1 THEN 'No 1099'
				WHEN VND.Ten99Type = 2 THEN '1099 Dividend'
				WHEN VND.Ten99Type = 3 THEN '1099 Interest'
		 ELSE '1099 Miscellaneous' END AS Is1099
		,APT.VchrNmbr
		,TYP.DocTyNam
		,APT.DocDate
		,APT.DocNumbr
		,APT.DocAmnt
		,APT.CurTrxAm
		,APT.Un1099AM
		,PAY.DocDate
		,PAY.ApFrDcnm
		,APT.TrxDscrn
		,COM.Name AS CompanyName
		,COM.CompanyId
		,'History'
FROM	PM30200 APT
		INNER JOIN PM00200 VND ON APT.VendorId = VND.VendorId
		INNER JOIN PM40102 TYP ON APT.DocType = TYP.DocType
		INNER JOIN Dynamics.dbo.View_Companies COM ON COM.CompanyId = DB_NAME()
		LEFT JOIN PM30300 PAY ON APT.VendorId = PAY.VendorId AND APT.DocNumbr = PAY.ApToDcnm -- AND LEFT(PAY.TrxSorce,5) IN ('PMPAY','PMCHK')
WHERE	LEFT(APT.TrxSorce,5) = 'PMTRX'
		AND PAY.DocDate BETWEEN '12/01/2008' AND '12/31/2008'
		AND APT.VendorId = '9731'
		AND APT.DocNumbr = 'DPY9731080927_033'
ORDER BY PAY.DocDate

select * from PM40102
SELECT * FROM pm00200
select * from PM30200 WHERE DocNumbr = 'std 09/05/' ORDER BY VchrNmbr
SELECT * FROM PM30200 WHERE Ten99Amnt > 0 --DocNumbr IN ('139058','DPY9731080927_033') --VendorId = '9731' AND DocDate BETWEEN '12/01/2008' AND '12/31/2008'
SELECT * FROM PM30600 
SELECT * FROM PM30300 WHERE VendorId = '9731'  AND ApToDcnm = 'DPY9731080927_033'

SELECT	PMD.VendorId
		,VND.VendName
		,VND.Ten99Type
		,CASE	WHEN VND.Ten99Type = 1 THEN 'No 1099'
				WHEN VND.Ten99Type = 2 THEN '1099 Dividend'
				WHEN VND.Ten99Type = 3 THEN '1099 Interest'
		 ELSE '1099 Miscellaneous' END AS Type1099
		,VND.VndClsId AS VendorType
		,PMD.VchrNmbr AS VoucherNumber
		,PMI.DocAmnt AS DocumentAmount
		,(PMD.CrdtAmnt + PMD.DebitAmt) * CASE WHEN PMD.CrdtAmnt > 0 THEN -1 ELSE 1 END AS CheckAmount
		,PMH.DocNumbr AS CheckNumber
		,PMH.DocDate
		,PMD.DocType
		,TYP.DocTyNam
		,PMH.DocAmnt AS CheckAmount
		,PMI.DocNumbr AS DocumentNumber
		,PMI.Un1099AM
		,PMH.TrxDscrn
		,COM.Name AS CompanyName
		,COM.CompanyId
		,PMD.DistType
FROM	PM30600 PMD
		INNER JOIN PM30200 PMH ON PMD.VchrNmbr = PMH.VchrNmbr AND PMD.TrxSorce = PMH.TrxSorce AND PMD.VendorId = PMH.VendorId
		LEFT JOIN PM30200 PMI ON PMH.VchrNmbr = PMI.VchrNmbr AND PMH.VendorId = PMI.VendorId AND LEFT(PMI.TrxSorce, 5) = 'PMTRX'
		INNER JOIN PM00200 VND ON PMH.VendorId = VND.VendorId
		INNER JOIN PM40102 TYP ON PMH.DocType = TYP.DocType
		INNER JOIN Dynamics.dbo.View_Companies COM ON COM.CompanyId = DB_NAME()
WHERE	LEFT(PMD.TrxSorce, 5) IN ('PMPAY','PMCHK')
		AND PMD.DistType > 1
		AND PMD.VendorId = '9731'
*/

SELECT	PMH.VendorId
		,VND.VendName
		,VND.Ten99Type
		,CASE	WHEN VND.Ten99Type IN (0,1) THEN 'No 1099'
				WHEN VND.Ten99Type = 2 THEN '1099 Dividend'
				WHEN VND.Ten99Type = 3 THEN '1099 Interest'
		 ELSE '1099 Miscellaneous' END AS Is1099
		,VND.VndClsId AS VendorType
		,PMH.VchrNmbr
		,TYP.DocTyNam
		,PMH.DocDate
		,PMH.DocNumbr
		,PMH.DocAmnt
		,PMH.CurTrxAm
		,PMH.Ten99Amnt AS Un1099AM9731
		,PMH.TrxDscrn
		,PAY.DocDate AS CheckDate
		,PAY.ApFrDcnm AS PayWithDocument
		,PAY.ApFrmAplyAmt AS CheckAmount
		,COM.Name AS CompanyName
		,COM.CompanyId
		,'HISTORIC' AS Source
		,PMD.DistType
		,(PMD.CrdtAmnt + PMD.DebitAmt) * CASE WHEN PMD.CrdtAmnt > 0 THEN -1 ELSE 1 END AS DetailAmount
		,PMD.DistRef
FROM	PM30200 PMH
		INNER JOIN PM30600 PMD ON PMH.VchrNmbr = PMD.VchrNmbr AND PMH.TrxSorce = PMD.TrxSorce AND PMH.VendorId = PMD.VendorId
		INNER JOIN PM30300 PAY ON PMH.VendorId = PAY.VendorId AND PMH.DocNumbr = PAY.ApToDcnm AND PAY.DocType = 6
		INNER JOIN PM00200 VND ON PMH.VendorId = VND.VendorId
		INNER JOIN PM40102 TYP ON PMH.DocType = TYP.DocType
		INNER JOIN Dynamics.dbo.View_Companies COM ON COM.CompanyId = DB_NAME()
WHERE	LEFT(PMH.TrxSorce, 5) = 'PMTRX'
		AND PAY.DocDate BETWEEN '01/01/2008' AND '12/31/2008'
		AND PMD.DistType = 6
		--AND PMH.VendorId = '9731'
ORDER BY PMH.VendorId, PAY.DocDate, PMH.DocNumbr