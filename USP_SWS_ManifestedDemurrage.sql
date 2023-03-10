USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_InvoicedPayoutsByDate]    Script Date: 1/11/2022 2:16:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_ManifestedDemurrage 'AIS', '12/01/2021', '01/25/2022'
EXECUTE USP_SWS_ManifestedDemurrage 'GLSO', '12/28/2021', '01/20/2022'
EXECUTE USP_SWS_ManifestedDemurrage 'GLSO','10/01/2021','10/26/2021'
*/
ALTER PROCEDURE [dbo].[USP_SWS_ManifestedDemurrage]
		@CompanyId	Varchar(5),
		@DateIni	Date,
		@DateEnd	Date
AS
SET NOCOUNT ON

DECLARE	@Counter	Int,
		@ItemNum	Int = 0,
		@tmpItem	Varchar(800) = '',
		@Company	Varchar(10) = (SELECT CompanyAlias FROM View_CompaniesAndAgents WHERE CompanyId = @CompanyId)

DECLARE @CmpyNumb	Varchar(3) = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId),
		@Query		Varchar(MAX)

SET @Query = N'SELECT distinct inv.code as "DivPro", inv.eq_code as container, inv.bt_code as "Bill-To",
invchrg.t300_code as accessorial_code, inv.invdate as "Invoiced Date",
(SELECT CAST(SUM(c.total - c.admin_fee) AS DOUBLE PRECISION) FROM trk.invchrg c WHERE c.cmpy_no = inv.cmpy_no AND c.inv_code = inv.code AND c.t300_code = ''DEM'') AS "Net Sales",
(SELECT CAST(SUM(c.admin_fee) AS DOUBLE PRECISION) FROM trk.invchrg c WHERE c.cmpy_no = inv.cmpy_no AND c.inv_code = inv.code AND c.t300_code = ''DEM'') AS "Admin Fee",
(SELECT CAST(SUM(c.total) AS DOUBLE PRECISION) FROM trk.invchrg c WHERE c.cmpy_no = inv.cmpy_no AND c.inv_code = inv.code AND c.t300_code = ''DEM'') AS "Gross Sales"
FROM trk.invoice inv
	INNER JOIN trk.invchrg invchrg ON inv.code = invchrg.inv_code AND inv.cmpy_no = invchrg.cmpy_no AND invchrg.t300_code = ''DEM''
WHERE inv.cmpy_no = ' + @CmpyNumb + '
AND inv.invdate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' 
order by "Invoiced Date","DivPro"'

set @query = N'SELECT DISTINCT inv.code AS "DivPro", ord.div_code, ord.pro, inv.eq_code AS container, inv.bt_code AS "Bill_To",  
  (SELECT CAST(COALESCE(SUM(c.total - c.admin_fee), 0) AS DOUBLE PRECISION)
    FROM trk.invchrg c
    WHERE c.cmpy_no = inv.cmpy_no
    AND c.inv_code = inv.code
    AND c.t300_code = ''DEM'') AS "Net Sales",
(SELECT	CAST(COALESCE(SUM(c.admin_fee), 0) AS DOUBLE PRECISION)
    FROM trk.invchrg c
    WHERE c.cmpy_no = inv.cmpy_no
    AND c.inv_code = inv.code
    AND c.t300_code = ''DEM'') AS "Admin Fee",
  (SELECT CAST(COALESCE(SUM(c.total), 0) AS DOUBLE PRECISION)
    FROM trk.invchrg c
    WHERE c.cmpy_no = inv.cmpy_no
    AND c.inv_code = inv.code
    AND c.t300_code = ''DEM'') AS "Gross Sales",
  (SELECT CAST(COALESCE(SUM(d.amount), 0) AS DOUBLE PRECISION)
    FROM trk.invvnpay d
    WHERE d.cmpy_no = inv.cmpy_no
    AND d.inv_code = inv.code
    AND d.t300_code = ''DEM'') AS "Cost",
  inv.invdate AS "Invoiced Date"
FROM trk.invoice inv
LEFT JOIN trk.order ord ON inv.or_no = ord.no AND inv.cmpy_no = ord.cmpy_no
WHERE inv.cmpy_no = ' + @CmpyNumb + '
AND inv.invdate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''''

print @Query

EXECUTE USP_QuerySWS_ReportData @Query, '##tmpSWS_ManifestingData'

SELECT	DISTINCT @Company AS Company, 
		@CmpyNumb AS Cmpy_No,
		DivPro AS Invoice,
		IIF(div_code IS Null, '', div_code + '-' + pro) AS ProNumber,
		Container,
		Bill_To,
		'DEM' AS [Assessorial Code],
		'Demurrage Charges' AS [Accessorial Description],
		[Net Sales],
		[Admin Fee],
		[Gross Sales],
		[Cost],
		[Invoiced Date]
FROM	##tmpSWS_ManifestingData
WHERE	[Net Sales] + [Admin Fee] + [Gross Sales] + [Cost] <> 0
ORDER BY [Invoiced Date], 2

DROP TABLE ##tmpSWS_ManifestingData