DECLARE	@Company	Varchar(5) = 'GSA',
		@StartDate	Date = '6/24/2017',
		@AccountIni	Char(4) = '4010',
		@AccountEnd	Char(4) = '4033'

DECLARE	@Query		Varchar(MAX),
		@CompanyNo	Int

SET @CompanyNo = ISNULL((SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company), 0)
SET @Query = N'SELECT CUSTNMBR,
       Invoice,
       CAST(invoice_date AS Date) AS invoice_date,
       CAST(SUM(ORTRXAMT) AS Numeric(10,2)) AS ORTRXAMT,
       Description,
       0.00 AS Cost,
       last_modified_by,
       enterprise_customer_id,
       customer_group_id,
       BACHNUMB,
       ' + CAST(@CompanyNo AS Varchar) + ' AS company_no
 FROM (
		SELECT HDR.CUSTNMBR,
			   HDR.DOCNUMBR AS Invoice,
			   HDR.DOCDATE  AS invoice_date,
			   DET.CRDTAMNT + (DET.DEBITAMT*-1) AS ORTRXAMT,
			   HDR.TRXDSCRN AS Description,
			  ''GP'' AS last_modified_by,
			  ''TBD'' AS enterprise_customer_id,
			  ''TBD'' AS customer_group_id,
			   HDR.BACHNUMB
		FROM   ' + RTRIM(@Company) + '.dbo.RM20101 HDR
				INNER JOIN ' + RTRIM(@Company) + '.dbo.RM10101 DET ON HDR.DOCNUMBR = DET.DOCNUMBR
				INNER JOIN ' + RTRIM(@Company) + '.dbo.GL00105 ACT ON DET.DSTINDX  = ACT.ACTINDX
		WHERE  ACT.ACTNUMBR_3 BETWEEN ''' + @AccountIni + ''' AND ''' + @AccountEnd + ''' AND 
			   HDR.DOCDATE BETWEEN ''' + CAST(@StartDate AS Varchar) + '''  AND CONVERT(date, GETDATE()) AND 
			   HDR.VOIDSTTS = 0 AND 
			   LEFT(HDR.BACHNUMB,2) = ''IA''   
		UNION ALL
		SELECT HDR.CUSTNMBR,
			   HDR.DOCNUMBR AS Invoice,
			   HDR.DOCDATE  AS invoice_date,
			   DET.CRDTAMNT + (DET.DEBITAMT*-1) AS ORTRXAMT,
			   HDR.TRXDSCRN AS Description,
			  ''GP''          AS last_modified_by,
			  ''TBD''         AS enterprise_customer_id,
			  ''TBD''         AS customer_group_id,
			   HDR.BACHNUMB
		FROM   ' + RTRIM(@Company) + '.dbo.RM30101 HDR
					  INNER JOIN ' + RTRIM(@Company) + '.dbo.RM30301 DET ON HDR.DOCNUMBR = DET.DOCNUMBR
					  INNER JOIN ' + RTRIM(@Company) + '.dbo.GL00105 ACT ON DET.DSTINDX  = ACT.ACTINDX
		WHERE  ACT.ACTNUMBR_3 BETWEEN ''' + @AccountIni + ''' AND ''' + @AccountEnd + ''' AND 
			   HDR.DOCDATE BETWEEN ''' + CAST(@StartDate AS Varchar) + '''  AND CONVERT(date, GETDATE()) AND 
			   HDR.VOIDSTTS = 0 AND 
			   LEFT(HDR.BACHNUMB,2) = ''IA''  
	) AS Data
GROUP BY 
CUSTNMBR,Invoice,invoice_date, Description, last_modified_by,enterprise_customer_id, customer_group_id,  BACHNUMB'

EXECUTE(@Query)