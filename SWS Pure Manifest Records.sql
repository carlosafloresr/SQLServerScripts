DECLARE	@Inv_No		Varchar(20),
		@Query		Varchar(MAX),
		@InvDate	Date,
		@ManDate	Date,
		@PosDate	Date

DROP TABLE SWS_Manifest
		
SET @Query = 'SELECT * FROM public.mrinv WHERE mrcompany_code = ''55'' AND weekending BETWEEN ''12/04/2011'' AND ''12/31/2011'''
	
EXECUTE Integrations.dbo.USP_QuerySWS @Query, '##tmpInvoice'

UPDATE	##tmpInvoice
SET		Invno = RTRIM(REPLACE(Invno, 'I', Invno))

SELECT	*
INTO	SWS_Manifest
FROM	##tmpInvoice

DROP TABLE ##tmpInvoice

SELECT	SWS.invno
		,SWS.invbatch
		,SWS.invdate
		,SWS.mrbillto_code
		,SWS.invtotal AS SWS_InvTotal
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
