SELECT	SWS.invno
		,SWS.invbatch
		,SWS.invdate
		,SWS.mrbillto_code
		,SWS.invtotal AS SWS_InvTotal
		,INV.inv_total AS ILS_InvTotal
		,INV.inv_total - SWS.invtotal AS DIF_InvTotal
		,SWS.invtype
		,SWS.mrmechanic_code
		,SWS.container
		,SWS.chassis
		,SWS.genset
		,SWS.eir_code
		,SWS.laborhours
		,SWS.parts
		,SWS.labor
		,SWS.salestax
		,SWS.purchaseprice
		,SWS.glarec
		,SWS.storage
		,SWS.inspec
		,SWS.lifts
		,SWS.mrlocation_code
		,SWS.alogin
		,SWS.adate
		,SWS.atime
		,SWS.ulogin
		,SWS.udate
		,SWS.utime
		,SWS.mrcompany_code
		,SWS.postdate
		,SWS.posttime
		,SWS.plogin
		,SWS.dsinvtype
		,SWS.partscost
		,SWS.laborcost
		,SWS.manifestdate
		,SWS.manifesttime
		,SWS.manifestlogin
		,SWS.month
		,SWS.year
		,SWS.weekending
		,SWS.wo
		,SWS.jo
		--,MSR.BatchId
FROM	SWS_Manifest SWS
		--LEFT JOIN Invoices INV ON SWS.InvNo = INV.inv_no
		--LEFT JOIN Integrations.dbo.MSR_ReceviedTransactions MSR ON 'I' + CAST(SWS.InvNo AS Varchar(10)) = MSR.DocNumber AND MSR.Company = 'FI'
