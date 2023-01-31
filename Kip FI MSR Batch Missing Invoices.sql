DECLARE	@Inv_No		Varchar(20),
		@Query		Varchar(MAX)
		
	SET @Query = 'SELECT * FROM public.mrinv WHERE mrcompany_code = ''55'' AND InvNo = ''I763595'''
	SET @Query = 'SELECT * FROM public.mrinv WHERE mrcompany_code = ''55'' AND MRBILLTO_CODE = ''NASMAE'' AND INVDATE = ''01/14/2012'' AND INVBATCH = ''B0'''
	
	EXECUTE Integrations.dbo.USP_QuerySWS @Query