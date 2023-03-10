USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_EBEFindShortPay]    Script Date: 10/26/2022 11:58:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE GPCustom.dbo.USP_EBEFindShortPay 'GLSO'
*/
ALTER PROCEDURE [dbo].[USP_EBEFindShortPay]
		@Company	Varchar(5)
AS
SET NOCOUNT ON

SET	@Company = UPPER(RTRIM(@Company))

DECLARE	@ApplyDate	Date = (SELECT VarD FROM GPCustom.dbo.[Parameters] WHERE ParameterCode = 'EBE_SHORTPAY_STARTDATE' AND Company = @Company),
		@Query		Varchar(Max)


SET		@Query = N'SELECT	* 
FROM	(
        SELECT	R1.CUSTNMBR, 
				R1.DOCNUMBR AS [Pro], 
				CAST(R1.DOCDATE AS Date) AS DOCDATE, 
				R1.ORTRXAMT, 
				R1.CURTRXAM, 
				R1.RMDTYPAL, 
				ApplyDate = CAST((SELECT MAX(R2.GLPOSTDT) FROM ' + @Company + '.dbo.RM20201 R2 WHERE R1.CUSTNMBR = R2.CUSTNMBR AND R1.DOCNUMBR = R2.APTODCNM AND R2.APFRDCTY <> 7) AS Date)
        FROM	' + @Company + '.dbo.RM20101 R1 WITH (NOLOCK)
				INNER JOIN GPCustom.dbo.CustomerMaster CM WITH (NOLOCK) ON CM.CompanyId = ''' + @Company + ''' AND R1.CUSTNMBR = CM.CUSTNMBR AND CM.ExcludeFromShortPay = 0 
        WHERE	R1.VOIDSTTS = 0 
				AND R1.RMDTYPAL < 7 
				AND R1.CURTRXAM > 0.0
				AND R1.CURTRXAM < R1.ORTRXAMT
        ) DATA  
WHERE	ApplyDate >= ''' + CAST(@ApplyDate AS Varchar) + '''
ORDER BY Pro'

EXECUTE(@Query)