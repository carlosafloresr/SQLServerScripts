DECLARE	@APInvoiceNo			varchar(20)='CHS9160771474P',
		@APVendorNo				varchar(50)=NULL,
		@InvoiceDateFrom		datetime=NULL,
		@InvoiceDateTo			datetime=NULL,
		@Company				nvarchar(10)='OIS',
		@RoleID					int=NULL,
		@APInvoices				varchar(MAX)=NULL,
		@LineItemNo				int=1,
		@RequestDate			datetime=NULL

	DECLARE	@Query					varchar(8000),
			@Conditions				Varchar(MAX) = ''

	SELECT DISTINCT InvoiceModId,
			BillToCustomer,
			CASE WHEN Changed_By NOT IN ('dscott','mswain','kstephens','kdetroit') THEN Exception ELSE Null END AS Exception,
			CASE WHEN Changed_By NOT IN ('dscott','mswain','kstephens','kdetroit') THEN Changed_By ELSE Null END AS Changed_By_User,
			Changed_By,
			CustInvNum,
			ProNum,
			DivChargeAmt,
			EquipmentID,
			LineItemNo,
			InvoiceNum
	INTO	##tmpInvoiceMod
	FROM	dbo.InvoiceMod
	WHERE	(@APInvoiceNo IS NULL OR (@APInvoiceNo IS NOT NULL AND InvoiceNum=@APInvoiceNo))
			AND (@LineItemNo IS NULL OR (@LineItemNo IS NOT NULL AND ISNULL(LineItemNo, 0)=@LineItemNo))


SET @Query=N'SELECT ''' + RTRIM(@Company) + ''' Company,
Z.VENDORID VendorId,
RTRIM(Z.VENDNAME) + '' ('' + RTRIM(Z.VENDORID) + '')'' VendorName,
Z.VNDCHKNM CheckName,
Z.DOCNUMBR InvoiceNum,
ISNULL(Z.LineItemNo, 0) LineItemNo,
Z.InvoiceDate,
Z.EquipmentID,
CASE Z.DOCTYPE WHEN 5 THEN -Z.DOCAMNT ELSE Z.DOCAMNT END APAmount,
CASE Z.DOCTYPE WHEN 5 THEN -Z.DOCAMNT ELSE Z.DOCAMNT END RequestAmount,
CASE WHEN ARDIS.APFRDCNM IS NOT NULL AND ARDIS.APFRDCTY=9 THEN ''PAID'' 
WHEN ARHIS.APFRDCNM IS NOT NULL AND ARHIS.APFRDCTY=9 THEN ''PAID''
WHEN ISNULL(Z.DivChargeAmt1, Z.DivChargeAmt2) > 0 THEN ''DIVC'' 
ELSE ''OPEN'' END ARStatus,
AROP.ORTRXAMT,
AROP.CURTRXAM ARAmount,
Z.BillToCustomer,
CASE WHEN ISNULL(Z.DivChargeAmt1, Z.DivChargeAmt2) > 0 THEN '''' ELSE ISNULL(Z.CustInvNum1,Z.CustInvNum2) END CustInvNum,
RTRIM(USR.First_Name) + '' '' + RTRIM(USR.Last_Name) Name,
Z.TRXDSCRN GLDescription ,
ISNULL(ARDIS.APFRDCNM, ARHIS.APFRDCNM) ReceiptNo,
Z.Exception,
Z.TTLPYMTS,
ISNULL(Z.ProNum1, Z.ProNum2) ProNum,
ISNULL(Z.DivChargeAmt1, Z.DivChargeAmt2) DivChargeAmt,
SUBSTRING(Z.DOCNUMBR, 1, CASE WHEN CHARINDEX(''_'', Z.DOCNUMBR)=0 THEN 0 ELSE CHARINDEX(''_'', Z.DOCNUMBR)-1 END) SortKey,
Z.RequestDate, Z.PrincipalID, 0 CheckMasterID, 0 CheckDetail_ID, NULL OpsName '
SET @Query=@Query + 'FROM (SELECT INV.CompanyID
,APOP.VENDORID
,ISNULL(IMOD1.BillToCustomer, IMOD2.BillToCustomer) [BillToCustomer]
,VND.VENDNAME
,VND.VNDCHKNM
,APOP.DOCNUMBR
,CONVERT(Varchar(12), INV.InvoiceDate, 101) [InvoiceDate]
,INV.InvoiceNum
,ISNULL(INVD.EquipmentID, INVD2.EquipmentID) EquipmentID
,ISNULL(INVD.LineItemNo, INVD2.LineItemNo) LineItemNo
,APOP.DOCAMNT
,APOP.CURTRXAM
,APOP.PRCHAMNT
,APOP.TTLPYMTS
,APOP.TRXDSCRN
,ISNULL(INVD.Notes,INVD2.Notes) Notes
,ISNULL(IMOD1.Exception,IMOD2.Exception) [Exception]
,ISNULL(IMOD1.Changed_By_User,IMOD2.Changed_By_User) [Changed_By]
,IMOD1.CustInvNum [CustInvNum1]
,IMOD2.CustInvNum [CustInvNum2]
,IMOD1.ProNum [ProNum1]
,IMOD2.ProNum [ProNum2]
,IMOD1.DivChargeAmt [DivChargeAmt1]
,IMOD2.DivChargeAmt [DivChargeAmt2]
,APOP.VOIDED
,APOP.HOLD
,APOP.DOCTYPE
,ISNULL(INVD.RequestDate, INVD2.RequestDate) AS RequestDate,
INV.PrincipalID '
SET @Query=@Query + 'FROM ILSGP01.' + RTRIM(@Company) + '.dbo.PM20000 APOP 
INNER JOIN ILSGP01.' + RTRIM(@Company) + '.dbo.PM00200 VND ON APOP.VENDORID=VND.VENDORID AND VND.VNDCLSID=''MSCPD''
LEFT OUTER JOIN dbo.InvoiceMaster INV ON APOP.DOCNUMBR LIKE LEFT(INV.InvoiceNum,12) + ''%''
LEFT OUTER JOIN dbo.InvoiceDetail INVD ON APOP.DOCNUMBR=INVD.InvoiceNum + ''_'' + CAST(INVD.LineItemNo AS varchar(3))
LEFT OUTER JOIN dbo.InvoiceDetail INVD2 ON APOP.DOCNUMBR=LEFT(INVD2.InvoiceNum, 12) + ''_'' + CAST(INVD2.LineItemNo AS varchar(3))
LEFT JOIN ##tmpInvoiceMod IMOD1 ON INVD.InvoiceNum=IMOD1.InvoiceNum AND INVD.EquipmentID=IMOD1.EquipmentID AND INVD.LineItemNo=IMOD1.LineItemNo
LEFT JOIN ##tmpInvoiceMod IMOD2 ON INVD2.InvoiceNum=IMOD2.InvoiceNum AND INVD2.EquipmentID=IMOD2.EquipmentID AND INVD2.LineItemNo=IMOD2.LineItemNo) Z
LEFT OUTER JOIN ILSGP01.' + RTRIM(@Company) + '.dbo.RM20101 AROP ON Z.BillToCustomer=AROP.CUSTNMBR AND (Z.CustInvNum1=AROP.DOCNUMBR OR Z.CustInvNum2=AROP.DOCNUMBR)
LEFT OUTER JOIN ILSGP01.' + RTRIM(@Company) + '.dbo.RM30201 ARDIS ON Z.BillToCustomer=ARDIS.CUSTNMBR AND (Z.CustInvNum1=ARDIS.APTODCNM OR Z.CustInvNum2=ARDIS.APTODCNM)
LEFT OUTER JOIN ILSGP01.' + RTRIM(@Company) + '.dbo.RM20201 ARHIS ON Z.BillToCustomer=ARHIS.CUSTNMBR AND (Z.CustInvNum1=ARHIS.APTODCNM OR Z.CustInvNum2=ARHIS.APTODCNM)  
LEFT OUTER JOIN ILSSQL01.Drivers.dbo.Users USR ON Z.Changed_By=USR.UserID 
WHERE '

IF @APInvoiceNo IS NOT Null
	SET @Conditions=@Conditions + CASE WHEN @Conditions='' THEN '' ELSE ' AND ' END + 'Z.InvoiceNum=''' + RTRIM(@APInvoiceNo) + ''''

IF @APVendorNo IS NOT Null
	SET @Conditions=@Conditions + CASE WHEN @Conditions='' THEN '' ELSE ' AND ' END + 'Z.VENDORID=''' + RTRIM(@APVendorNo) + ''''

IF @LineItemNo IS NOT Null
	SET @Conditions=@Conditions + CASE WHEN @Conditions='' THEN '' ELSE ' AND ' END + 'ISNULL(Z.LineItemNo,0)=' + CAST(@LineItemNo AS Varchar)

IF @InvoiceDateFrom IS NOT Null
	SET @Conditions=@Conditions + CASE WHEN @Conditions='' THEN '' ELSE ' AND ' END + 'Z.InvoiceDate>=''' + CONVERT(Char(10), @InvoiceDateFrom, 101) + ''''

IF @InvoiceDateTo IS NOT Null
	SET @Conditions=@Conditions + CASE WHEN @Conditions='' THEN '' ELSE ' AND ' END + 'Z.InvoiceDate<=''' + CONVERT(Char(10), @InvoiceDateTo, 101) + ''''

IF @RequestDate IS NOT Null
	SET @Conditions=@Conditions + CASE WHEN @Conditions='' THEN '' ELSE ' AND ' END + 'Z.InvoiceDate=''' + CONVERT(Char(10), @RequestDate, 101) + ''''

SET @Query=@Query + @Conditions + ' 
ORDER BY Z.VENDORID, SUBSTRING(Z.DOCNUMBR, 1, CASE WHEN CHARINDEX(''_'', Z.DOCNUMBR)=0 THEN 0 ELSE CHARINDEX(''_'', Z.DOCNUMBR) - 1 END), Z.LineItemNo'

PRINT @Query
EXECUTE(@Query)

DROP TABLE ##tmpInvoiceMod

