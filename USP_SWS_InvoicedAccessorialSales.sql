USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_InvoicedAccessorialSales]    Script Date: 8/31/2022 10:44:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_InvoicedAccessorialSales 'AIS', '05/11/2022', '05/26/2022','DEM,'
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
CAST(a.eq_code || a.eqchkdig AS STRING) as container, a.bt_code as bill_to, a.altbt_code as alt_bill_to,
b.t300_code as accessorial_code, b.description as accessorial_name, 
b.total as sales, 
(SELECT pudt FROM trk.order WHERE no = a.or_no AND cmpy_no = a.cmpy_no) as pickup_date,
(SELECT deldt FROM trk.order WHERE no = a.or_no AND cmpy_no = a.cmpy_no) as delivery_date, 
a.invdate
FROM trk.invoice a, trk.invchrg b
WHERE a.code = b.inv_code
AND a.cmpy_no = b.cmpy_no
AND a.cmpy_no = ' + @CmpyNumb + '
AND a.invdate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' 
AND b.total <> 0 '

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
--SET @Query = @Query + 'ORDER BY a.cmpy_no, a.invdate, a.code'
PRINT @Query

EXECUTE USP_QuerySWS_ReportData @Query, '##tmpInvoicedAccessorialSales'

SELECT	cmpy_no AS Company,
		divpro AS ProNumber,
		Container,
		Bill_To,
		Alt_Bill_To,
		Accessorial_Code,
		Accessorial_Name,
		Sales,
		CONVERT(Char(10), pickup_date, 101) AS Pickup_Date,
		CONVERT(Char(10), Delivery_Date, 101) AS Delivery_Date,
		CONVERT(Char(10), InvDate, 101) AS Invoice_Date
FROM	##tmpInvoicedAccessorialSales
ORDER BY cmpy_no, InvDate, divpro

DROP TABLE ##tmpInvoicedAccessorialSales


/*
SET	@Query = N'SELECT a.cmpy_no, a.code as divpro,
CAST(a.eq_code || a.eqchkdig AS STRING) as container, a.bt_code as bill_to,
b.t300_code as accessorial_code, b.description as accessorial_name, 
b.total as sales, 
(SELECT pudt FROM trk.order WHERE no = a.or_no AND cmpy_no = a.cmpy_no) as pickup_date, 
d.deldt as delivery_date, a.invdate
FROM trk.invoice a, trk.invchrg b, trk.order d
WHERE a.code = b.inv_code
AND a.cmpy_no = b.cmpy_no
AND a.or_no = d.no 
AND a.cmpy_no = d.cmpy_no 
AND a.cmpy_no = ' + @CmpyNumb + '
AND a.invdate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' 
AND b.total > 0 '
*/