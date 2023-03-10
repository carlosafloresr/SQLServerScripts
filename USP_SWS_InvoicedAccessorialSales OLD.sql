USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_InvoicedAccessorialSales]    Script Date: 7/11/2022 1:31:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_InvoicedAccessorialSales 'AIS', '05/11/2021', '05/26/2021','300,'
EXECUTE USP_SWS_InvoicedAccessorialSales 'GLSO', '01/01/2020', '02/02/2021',Null,'300,'
EXECUTE USP_SWS_InvoicedAccessorialSales 'GLSO','03/01/2022','03/26/2022','DEM,'
*/
ALTER PROCEDURE [dbo].[USP_SWS_InvoicedAccessorialSales]
		@CompanyId	Varchar(5),
		@DateIni	Date,
		@DateEnd	Date,
		@AccCodes	Varchar(50) = Null
AS
SET NOCOUNT ON

IF @AccCodes = ''
	SET @AccCodes = Null

DECLARE	@Counter	Int,
		@ItemNum	Int = 0,
		@tmpItem	Varchar(800) = ''

DECLARE @CmpyNumb	Varchar(3) = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId),
		@Query		Varchar(Max)

SET	@Query = N'SELECT a.cmpy_no, a.code as divpro,
CAST(a.eq_code || a.eqchkdig AS STRING) as container, a.bt_code as bill_to,
b.t300_code as accessorial_code, b.description as accessorial_name, b.total as sales, d.pudt as pickup_date, d.deldt as delivery_date, a.invdate
FROM trk.invoice a, trk.invchrg b, trk.order d
WHERE a.code = b.inv_code
AND a.cmpy_no = b.cmpy_no
AND a.or_no = d.no 
AND a.cmpy_no = d.cmpy_no 
AND a.cmpy_no = ' + @CmpyNumb + '
AND a.invdate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' '

IF @AccCodes IS NOT Null
BEGIN
	SET @Counter = dbo.OCCURS(',', @AccCodes)
	
	IF @Counter = 1
		SET @Query = @Query + 'AND b.t300_code = ''' + REPLACE(@AccCodes, ',', '') + ''' '
	ELSE
	BEGIN
		SET @tmpItem = '' + REPLACE(@AccCodes, ',', ''',''')
		SET @Query = @Query + 'AND b.t300_code IN (''' + @tmpItem + ''') '
	END
END

SET	@Query = @Query + N'UNION
SELECT a.cmpy_no, a.code as divpro,
CAST(a.eq_code || a.eqchkdig AS STRING) as container, a.bt_code as bill_to,
b.t300_code as accessorial_code, 
b.description as accessorial_name, 
b.total as sales, 
NULL as pickup_date, 
NULL as delivery_date, 
a.invdate 
FROM trk.invoice a, trk.invchrg b 
WHERE a.code = b.inv_code
AND a.cmpy_no = b.cmpy_no
AND a.type in (''C'',''D'',''T'',''M'')
AND b.t300_code in (''DEM'', ''CHZ'')
AND b.total > 0
AND a.cmpy_no = ' + @CmpyNumb + '
AND a.invdate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' '

--SET @Query = @Query + 'ORDER BY a.cmpy_no, a.invdate, a.code'
PRINT @Query

EXECUTE USP_QuerySWS_ReportData @Query, '##tmpInvoicedAccessorialSales'

SELECT	cmpy_no AS Company,
		divpro AS ProNumber,
		Container,
		Bill_To,
		Accessorial_Code,
		Accessorial_Name,
		Sales,
		CONVERT(Char(10), pickup_date, 101) AS Pickup_Date,
		CONVERT(Char(10), Delivery_Date, 101) AS Delivery_Date,
		CONVERT(Char(10), InvDate, 101) AS Invoice_Date
FROM	##tmpInvoicedAccessorialSales
ORDER BY cmpy_no, InvDate, divpro

DROP TABLE ##tmpInvoicedAccessorialSales