/*
EXECUTE USP_FSIBatch_FindInvoices '1FSI20130319_1006'
*/
ALTER PROCEDURE USP_FSIBatch_FindInvoices (@BatchId Varchar(25))
AS
DECLARE	@Query		Varchar(MAX),
		@SWSDate	Varchar(10),
		@SWSTime	Varchar(10)

SELECT	@SWSDate = REPLACE(CONVERT(Varchar(10), ReceivedOn, 102), '.', '-'),
		@SWSTime = SUBSTRING(CONVERT(Varchar(20), ReceivedOn, 120), 12, 5)
FROM	FSI_ReceivedHeader 
WHERE	BatchId = @BatchId

SET @Query = 'SELECT INV.cmpy_no AS CompanyID, INV.div_code AS Division, INV.Pro, INV.btname AS BillTo, INV.btaddr1 AS BillTo_Addr1, INV.btaddr2 AS BillTo_Addr2, 
                         INV.btcity || '', '' || INV.btst_code || '' '' || INV.btzip AS BillTo_Addr3, INV.btcity AS BillTo_City, ORD.no AS OrderID, ORD.shzip AS Shipper_Zip, 
                         INV.btst_code AS BillTo_State, INV.btzip AS BillTo_Zip, ORD.cnzip AS Consignee_Zip, ORD.tl_code || ORD.tlchkdig AS TrailerNo, BLL.doccodes, BLL.prtinv AS _PrintInvoice
						 FROM trk.invoice INV INNER JOIN trk.order ORD ON INV.or_no = ORD.no
							  INNER JOIN com.billto BLL ON INV.bt_code = BLL.code AND INV.cmpy_no = BLL.cmpy_no '
SET @Query = @Query + 'WHERE INV.pdate = ''' + @SWSDate + ''' AND INV.ptime = ''' + @SWSTime + ''''

EXECUTE USP_QuerySWS @Query, '##TEST'

SELECT * FROM ##TEST

DROP TABLE ##TEST
