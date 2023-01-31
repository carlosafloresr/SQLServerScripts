DECLARE	@Company	Varchar(5) = 'GIS',
		@Query		Varchar(MAX)

SET @Query = N'SELECT * FROM (
        SELECT	R1.CUSTNMBR, 
				R1.DOCNUMBR AS [Pro], 
				R1.DOCDATE, 
				R1.ORTRXAMT, 
				R1.CURTRXAM, 
				R1.RMDTYPAL, 
				R1.VOIDSTTS,
				ApplyDate = (SELECT MAX(GLPOSTDT) FROM ' + @Company + '.dbo.RM20201 R2 WHERE R1.CUSTNMBR = R2.CUSTNMBR AND R1.DOCNUMBR = R2.APTODCNM AND R2.APFRDCTY <> 7) 
        FROM	' + @Company + '.dbo.RM20101 R1 
				INNER JOIN GPCustom.dbo.CustomerMaster CM ON R1.CUSTNMBR = CM.CUSTNMBR and CM.CompanyId = ''' + @Company + ''' 
        WHERE	VOIDSTTS = 0 
				AND RMDTYPAL < 7 
				AND CM.ExcludeFromShortPay = 0 
				AND R1.CURTRXAM > 0
				AND DOCNUMBR NOT IN (SELECT ProNumber FROM LENSASQL002.Tributary.dbo.lu_ActiveShortPay WHERE Company = ''' + @Company + ''') 
        ) DATA  
WHERE	ApplyDate >= (SELECT VarD FROM GPCustom.dbo.Parameters WHERE ParameterCode = ''EBE_SHORTPAY_STARTDATE'' AND Company = ''' + @Company + ''') 
ORDER BY PRO'

EXECUTE(@Query)