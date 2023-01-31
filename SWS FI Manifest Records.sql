DECLARE	@Inv_No		Varchar(20),
		@Query		Varchar(MAX),
		@InvDate	Date,
		@ManDate	Date,
		@PosDate	Date

DROP TABLE SWS_Manifest
		
SET @Query = 'SELECT * FROM public.mrinv WHERE mrcompany_code = ''55'' AND weekending BETWEEN ''12/04/2011'' AND ''12/31/2011'''
	
EXECUTE Integrations.dbo.USP_QuerySWS @Query, '##tmpInvoice'

SELECT	*
INTO	SWS_Manifest
FROM	##tmpInvoice

DROP TABLE ##tmpInvoice