USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_NonInvoicedPayouts]    Script Date: 5/23/2022 12:19:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_VendorManifestDetail 'AIS', 'CFLORES'
EXECUTE USP_SWS_VendorManifestDetail 'GLSO','CFLORES'
*/
ALTER PROCEDURE [dbo].[USP_SWS_VendorManifestDetail]
		@CompanyId	Varchar(5),
		@UserId		Varchar(30)
AS
SET NOCOUNT ON

DECLARE @CmpyNumb	Varchar(3) = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId),
		@Company	Varchar(5) = (SELECT CompanyAlias FROM View_CompanyAgents WHERE  CompanyId = @CompanyId),
		@Query		Varchar(8000),
		@Pros		Varchar(Max) = '',
		@ProNumber	Varchar(15) = ''

DECLARE curProNumbers CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	TOP 600 ProNumber
FROM	SWS_Reports_ProNumbers
WHERE	UserId = @UserId

OPEN curProNumbers 
FETCH FROM curProNumbers INTO @ProNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Pros = @Pros + IIF(@Pros = '', '''', ',''') + @ProNumber + ''''

	FETCH FROM curProNumbers INTO @ProNumber
END

CLOSE curProNumbers
DEALLOCATE curProNumbers

SET @Query = 'SELECT CAST(a.div_code||''-''||a.pro AS STRING) as "DivPro", CAST(a.billtl_code||a.billtl_chkdig AS STRING) as Container, a.status as "Order Status",
b.vn_code as vendor_code, c.name as vendor_name, b.amount as "Cost", b.vnref as "Vendor Invoice", b.prepay as "Payment Type", invdt as "Invoiced Date" 
FROM trk.order a, trk.orvnpay b, trk.vendor c
WHERE a.cmpy_no = ' + @CmpyNumb + ' 
AND b.or_no = a.no 
AND c.cmpy_no = a.cmpy_no 
AND b.cmpy_no = a.cmpy_no 
AND c.code = b.vn_code 
AND CAST(a.div_code||''-''||a.pro AS STRING) IN (' + @Pros + ')
ORDER BY 1'

PRINT @Query

EXECUTE USP_QuerySWS_ReportData @Query, '##tmpSWS_VendorManifestDetailData'

SELECT	@Company AS Company,
		*
FROM	##tmpSWS_VendorManifestDetailData

DROP TABLE ##tmpSWS_VendorManifestDetailData