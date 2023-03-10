USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_NonInvoicedPayouts]    Script Date: 1/25/2023 8:49:36 AM ******/
SET ANSI_NULLS ON
GO 
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_NonInvoicedPayouts 'AIS', '01/25/2021', '50019A,10202,532,', 'DEM,'
EXECUTE USP_SWS_NonInvoicedPayouts 'GLSO','01/25/2023',Null,'DEM'
*/
ALTER PROCEDURE [dbo].[USP_SWS_NonInvoicedPayouts]
		@CompanyId	Varchar(5),
		@RunDate	Date,
		@Vendors	Varchar(500) = Null,
		@AccCodes	Varchar(25) = Null
AS
SET NOCOUNT ON

DECLARE	@Counter	Int,
		@ItemNum	Int = 0,
		@tmpItem	Varchar(800) = ''

DECLARE @CmpyNumb	Varchar(3) = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId),
		@Query		Varchar(Max)

IF @Vendors = ','
	SET @Vendors = Null

SET @Query = N'SELECT a.cmpy_no, a.div_code, 
a.pro,
a.billtl_code,
a.billtl_chkdig,
a.bt_code,
a.altbt_code,
a.billtl_eqocode,
a.status,
a.donedt,
b.vn_code as "Vendor Id", c.name as "Vendor Name", d.total as "Cost", d.prepay as "Payment Type", d.t300_code as "Accessorial Code", a.pudt as "Pickup Date", a.deldt as "Delivery Date"
FROM trk.order a, 
	trk.orvnpay b, 
    trk.vendor c,
    trk.orvnpayt300 d
WHERE a.cmpy_no = ' + @CmpyNumb + '
AND a.invdt is null
AND d.invdate is null
AND b.or_no = a.no 
AND d.or_no = a.no
AND d.orvnpay_rid = b.rid
AND c.cmpy_no = a.cmpy_no
AND c.code = b.vn_code '

--SET @Query = N'SELECT a.cmpy_no, a.div_code, 
--a.pro,
--a.billtl_code,
--a.billtl_chkdig,
--a.bt_code,
--a.altbt_code,
--a.billtl_eqocode,
--a.status,
--a.donedt,
--b.vn_code as "Vendor Id", c.name as "Vendor Name", b.amount as "Cost", b.prepay as "Payment Type", b.t300_code as "Accessorial Code", a.pudt as "Pickup Date", a.deldt as "Delivery Date"
--FROM trk.order a, trk.orvnpay b, trk.vendor c
--WHERE a.cmpy_no = ' + @CmpyNumb + '
--AND a.invdt is null
--AND b.invdate is null
--AND b.or_no = a.no                             
--AND c.cmpy_no = a.cmpy_no
--AND c.code = b.vn_code '

/*
AND a.status != ''V''
AND (a.pudt <= ''' + CAST(@RunDate AS Varchar) + ''' OR a.status = ''A'')
*/

IF @Vendors IS NOT Null
BEGIN
	SET @Counter = dbo.OCCURS(',', @Vendors)
	
	IF @Counter = 1
		SET @Query = @Query + 'AND b.vn_code = ''' + REPLACE(@Vendors, ',', '') + ''' '
	ELSE
	BEGIN
		SET @Vendors = LEFT(@Vendors, LEN(@Vendors) - 1)
		SET @tmpItem = '' + REPLACE(REPLACE(@Vendors, ',', ''','''), ' ', '')
		SET @Query = @Query + 'AND b.vn_code IN (''' + @tmpItem + ''') '
	END
END

IF @AccCodes IS NOT Null
BEGIN
	SET @Counter = dbo.OCCURS(',', @AccCodes)
	
	IF @Counter < 2
		SET @Query = @Query + 'AND b.t300_code = ''' + REPLACE(@AccCodes, ',', '') + ''' '
	ELSE
	BEGIN
		SET @tmpItem = '' + REPLACE(@AccCodes, ',', ''',''')
		SET @Query = @Query + 'AND b.t300_code IN (''' + @tmpItem + ''') '
	END
END

SET @Query = @Query + 'ORDER BY 1,2'
PRINT @Query

EXECUTE USP_QuerySWS_ReportData @Query, '##tmpSWS_Data'

SELECT	cmpy_no,
		div_code + '-' + pro AS DivPro,
		billtl_code + billtl_chkdig AS Container,
		bt_code AS [Bill To],
		altbt_code AS [Alt Ship],
		billtl_eqocode AS [Container Owner],
		status AS [Order Status],
		donedt AS "Order Complete Date",
		[Vendor Id],
		[Vendor Name],
		Cost,
		[Payment Type],
		[Accessorial Code],
		CAST([Pickup Date] AS Date) AS [Pickup Date],
		CAST([Delivery Date] AS Date) AS [Delivery Date]
FROM	##tmpSWS_Data

DROP TABLE ##tmpSWS_Data