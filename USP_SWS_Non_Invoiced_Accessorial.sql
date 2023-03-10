USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_Non_Invoiced_Accessorial]    Script Date: 8/26/2022 1:21:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_Non_Invoiced_Accessorial 'GIS', Null, '395,'
EXECUTE USP_SWS_Non_Invoiced_Accessorial 'GLSO','11/20/2021',',',Null
*/
ALTER PROCEDURE [dbo].[USP_SWS_Non_Invoiced_Accessorial]
		@CompanyId	Varchar(5),
		@Customer	Varchar(12) = Null,
		@AccCodes	Varchar(25) = Null
AS
SET NOCOUNT ON

DECLARE	@Counter	Int,
		@ItemNum	Int = 0,
		@tmpItem	Varchar(800) = ''

DECLARE @CmpyNumb	Varchar(3) = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId),
		@Query		Varchar(Max)

IF @Customer = ','
	SET @Customer = Null

SET @Query = N'select a.cmpy_no, a.div_code, a.pro,
a.billtl_code,
a.billtl_chkdig,
a.bt_code,
a.altbt_code,
a.billtl_eqocode, 
a.status,
a.donedt, 
b.t300_code, 
b.description, 
b.total,
a.pudt, 
a.deldt
FROM trk.order a, trk.orchrg b
WHERE a.cmpy_no = ' + @CmpyNumb + '
AND a.invdt is null
and b.invdate is null
AND b.or_no = a.no                             
AND b.cmpy_no = a.cmpy_no '

IF @Customer IS NOT Null
BEGIN
	SET @Query = @Query + ' AND a.bt_code = ''' + REPLACE(@Customer, ',', '') + ''' '
END

IF @AccCodes IS NOT Null
BEGIN
	SET @Counter = dbo.OCCURS(',', @AccCodes)
	
	IF @Counter = 1
		SET @Query = @Query + 'AND b.t300_code = ''' + REPLACE(@AccCodes, ',', '') + ''' '
	ELSE
	BEGIN
		SET @Customer = LEFT(@AccCodes, LEN(@AccCodes) - 1)
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
		t300_code AS "Accessorial Code",
		description as "Accessorial Desc",
		TOTAL as "Sales",
		pudt as pickup_date,
		deldt as delivery_date
FROM	##tmpSWS_Data

DROP TABLE ##tmpSWS_Data