USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_ManifestedDemurrage_Cost]    Script Date: 5/5/2022 10:35:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_ManifestedDemurrage_Cost 'AIS', '12/01/2021', '01/25/2022' 
EXECUTE USP_SWS_ManifestedDemurrage_Cost 'GLSO', '12/28/2021', '01/20/2022'
EXECUTE USP_SWS_ManifestedDemurrage_Cost 'GLSO','03/01/2022','05/01/2022'
*/
ALTER  PROCEDURE [dbo].[USP_SWS_ManifestedDemurrage_Cost]
		@CompanyId	Varchar(5),
		@DateIni	Date,
		@DateEnd	Date
AS
SET NOCOUNT ON

DECLARE	@Counter	Int,
		@ItemNum	Int = 0,
		@tmpItem	Varchar(800) = ''

DECLARE @CmpyNumb	Varchar(3) = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId),
		@Query		Varchar(8000)

SET @Query = N'select distinct inv.code as "DivPro",
inv.eq_code as container, invpay.vn_code as "Vendor Code",
invpay.t300_code as "accessorial code",
(SELECT CAST(SUM(c.amount) AS DOUBLE PRECISION) FROM trk.invvnpay c where c.cmpy_no = inv.cmpy_no and c.inv_code = inv.code and c.t300_code = ''DEM'' and c.vn_code = invpay.vn_code) as "Demurrage Cost",
(SELECT CAST(SUM(c.amount) AS DOUBLE PRECISION) FROM trk.invvnpay c WHERE c.cmpy_no = inv.cmpy_no AND c.inv_code = inv.code AND c.t300_code = ''DEM''),
inv.invdate as "Invoiced Date" 
FROM trk.invoice inv
	INNER JOIN trk.invvnpay invpay ON inv.code = invpay.inv_code AND inv.cmpy_no = invpay.cmpy_no AND invpay.t300_code = ''DEM''
WHERE inv.cmpy_no = ' + @CmpyNumb + '
AND inv.invdate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' 
ORDER BY "Invoiced Date","DivPro"'

print @Query

EXECUTE USP_QuerySWS_ReportData @Query, '##tmpSWS_ManifestingDataCost'

SELECT	DISTINCT DivPro,
		Container,
		[Vendor Code],
		[Accessorial Code],
		'Demurrage' AS [Accessorial Description],
		[Demurrage Cost],
		[Sum],
		[Invoiced Date]
FROM	##tmpSWS_ManifestingDataCost
ORDER BY [Invoiced Date],[DivPro]

DROP TABLE ##tmpSWS_ManifestingDataCost