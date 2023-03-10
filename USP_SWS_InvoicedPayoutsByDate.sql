USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_InvoicedPayoutsByDate]    Script Date: 2/3/2021 11:20:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_InvoicedPayoutsByDate 'AIS', '01/01/2020', '01/25/2021','50019A,10202,532,'
EXECUTE USP_SWS_InvoicedPayoutsByDate 'GLSO', '01/01/2020', '02/02/2021',Null,'300,'
EXECUTE USP_SWS_InvoicedPayoutsByDate 'GLSO','01/19/2021','02/03/2021',',','300,'
*/
ALTER PROCEDURE [dbo].[USP_SWS_InvoicedPayoutsByDate]
		@CompanyId	Varchar(5),
		@DateIni	Date,
		@DateEnd	Date,
		@Vendors	Varchar(500) = Null,
		@AccCodes	Varchar(50) = Null
AS
SET NOCOUNT ON

IF @Vendors = ''
	SET @Vendors = Null

IF @AccCodes = ''
	SET @AccCodes = Null

DECLARE	@Counter	Int,
		@ItemNum	Int = 0,
		@tmpItem	Varchar(800) = ''

DECLARE @CmpyNumb	Varchar(3) = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId),
		@Query		Varchar(Max)

SET @Query = N'select a.code AS pro, eq_code, eqchkdig, b.vn_code AS vendor_code, 
c.name AS vendor_name, b.amount AS "Cost", b.prepay AS "Payment Type", b.t300_code as "Accessorial Code", d.pudt AS pickup_date, 
d.deldt AS delivery_date, a.invdate
FROM trk.invoice a, trk.invvnpay b, trk.vendor c, trk.order d
WHERE a.cmpy_no = ' + @CmpyNumb + '
AND a.invdate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' 
AND b.inv_code = a.code 
AND b.cmpy_no = a.cmpy_no
AND d.no = a.or_no
AND c.cmpy_no = a.cmpy_no
AND c.code = b.vn_code '

IF @Vendors IS NOT Null
BEGIN
	SET @Counter = dbo.OCCURS(',', @Vendors)
	
	IF @Counter = 1
		SET @Query = @Query + 'AND b.vn_code = ''' + REPLACE(@Vendors, ',', '') + ''' '
	ELSE
	BEGIN
		SET @Vendors = LEFT(@Vendors, LEN(@Vendors) - 1)
		SET @tmpItem = '' + REPLACE(@Vendors, ',', ''',''')
		SET @Query = @Query + 'AND b.vn_code IN (''' + @tmpItem + ''') '
	END
END

IF @AccCodes IS NOT Null
BEGIN
	SET @Counter = dbo.OCCURS(',', @AccCodes)
	
	IF @Counter = 1
		SET @Query = @Query + 'AND b.t300_code = ''' + REPLACE(@AccCodes, ',', '') + ''' '
	ELSE
	BEGIN
		SET @Vendors = LEFT(@AccCodes, LEN(@AccCodes) - 1)
		SET @tmpItem = '' + REPLACE(@AccCodes, ',', ''',''')
		SET @Query = @Query + 'AND b.t300_code IN (''' + @tmpItem + ''') '
	END
END

SET @Query = @Query + 'ORDER BY a.code'
PRINT @Query

EXECUTE USP_QuerySWS_ReportData @Query, '##tmpSWS_InvoiceData'

SELECT	Pro,
		eq_code + '-' + eqchkdig AS [Container Nbr],
		vendor_code,
		vendor_name,
		Cost,
		[Payment Type],
		[Accessorial Code],
		pickup_date,
		delivery_date,
		invdate AS invoice_date
FROM	##tmpSWS_InvoiceData

DROP TABLE ##tmpSWS_InvoiceData