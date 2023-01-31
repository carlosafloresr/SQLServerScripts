/*
EXECUTE USP_Depot_DataInquiry @DateIni = '05/20/2019', @DateEnd = '05/25/2019', @DateType = 'I'
EXECUTE USP_Depot_DataInquiry @DateIni = '05/20/2019', @DateEnd = '05/25/2019', @DateType = 'I', @Summary = 1
*/
ALTER PROCEDURE USP_Depot_DataInquiry
		@DateIni			Date,
		@DateEnd			Date,
		@DateType			Char(1),
		@Remarks			Bit = 0,
		@RecordType			Char(1) = Null,
		@Bids				Char(1) = Null,
		@Bins				Varchar(15) = Null,
		@Depot				Varchar(15) = Null,
		@EmptyRepairDate	Bit = Null,
		@EstInvNumber		Varchar(20) = Null,
		@PartNumber			Varchar(20) = Null,
		@Summary			Bit = 0
AS
DECLARE	@Query		Varchar(MAX),
		@DTTypeSel	Varchar(30)

SET @DTTypeSel = CASE @DateType 
					WHEN 'R' THEN 'INV.Repair_Date'
					WHEN 'E' THEN 'INV.Estimate_Date'
					WHEN 'C' THEN 'INV.Entry_Date'
				 ELSE 'CAST(INV.Invoice_Date AS Date)' END
IF @Summary = 1
	SET @Query = N'SELECT	IIF(INV.INV_EST = ''I'', INV.Invoice_No, INV.Estimate_No) AS Inv_No, 
		INV.Inv_Batch, 
		CAST(INV.Invoice_Date AS Date) AS Inv_Date, 
		INV.Est_Date, 
		INV.Eq_DateIn, 
		INV.Entry_Date, 
		CASE WHEN INV.Rep_Date IS NULL OR INV.Rep_Date < ''01/01/1980'' THEN NULL ELSE INV.Rep_Date END AS Rep_Date,
		CASE WHEN INV.INV_EST = ''I'' THEN ''Invoice'' ELSE ''Estimate'' END AS Inv_Est, 
		INV.DEPOT_LOC AS Depot_Location, 
		SPACE(1) AS JobCode, 
		SPACE(1) AS Description, 
		'''' AS CDex_Repai, 
		SUM(QTY_SHIPED) AS PartQuantity,
		SUM(UNIT_PRICE) AS UnitPrice, 
		SUM(PART_TOTAL) AS PartTotal, 
		SUM(SAL.RLABOR) AS LaborTotal, 
		SUM(SAL.RLABOR_QTY) AS LaborQuantity, 
		SUM(SAL.LAB_PRICE) AS LaborPrice, 
		INV.INV_TOTAL AS InvoiceTotal, 
		INV.Sale_Tax AS SaleTax, 
		INV.ESTATUS AS Status, 
		INV.ACCT_NO AS CustomerNumber, 
		INV.CONTAINER, 
		INV.CHASSIS, 
		INV.GENSET_NO, 
		INV.GEN_HOURS, 
		CASE WHEN INV.INV_TYPE = ''R'' THEN ''Invoice'' ELSE ''Credit'' END AS RecordType, 
		INV.WORKORDER, 
		SPACE(1) AS CDEX_DAMAG, 
		SPACE(1) AS CDEX_LOCAT, 
		SPACE(1) AS NEWDOTON, 
		SPACE(1) AS NEWDOTOFF, 
		SPACE(1) AS Bin, 
		INV.Inv_Mech AS Mechanic, 
		INV.EDI_Sent, 
		INV.EDI_Time, 
		INV.Approval, 
		INV.MRSK_Cause '
ELSE
	SET @Query = N'SELECT	IIF(INV.INV_EST = ''I'', INV.Invoice_No, INV.Estimate_No) AS Inv_No, 
		INV.Inv_Batch, 
		INV.Inv_Date, 
		INV.Est_Date, 
		INV.Eq_DateIn, 
		INV.Entry_Date, 
		CASE WHEN INV.Rep_Date IS NULL OR INV.Rep_Date < ''01/01/1980'' THEN NULL ELSE INV.Rep_Date END AS Rep_Date,
		CASE WHEN INV.INV_EST = ''I'' THEN ''Invoice'' ELSE ''Estimate'' END AS Inv_Est, 
		INV.DEPOT_LOC AS Depot_Location, 
		SAL.PART_NO AS JobCode, 
		SAL.DESCRIPT AS Description,
		SAL.CDEX_REPAI, 
		QTY_SHIPED AS PartQuantity, 
		UNIT_PRICE AS UnitPrice, 
		PART_TOTAL AS PartTotal, 
		SAL.RLABOR AS LaborTotal, 
		SAL.RLABOR_QTY AS LaborQuantity, 
		SAL.LAB_PRICE AS LaborPrice,
		INV.INV_TOTAL AS InvoiceTotal, 
		INV.Sale_Tax AS SaleTax, 
		ESTATUS AS Status, 
		INV.ACCT_NO AS CustomerNumber, 
		INV.Container, 
		INV.Chassis, 
		INV.Genset_No,
		INV.Gen_Hours, 
		CASE WHEN INV.INV_TYPE = ''R'' THEN ''Invoice'' ELSE ''Credit'' END AS RecordType, 
		INV.Workorder, 
		SAL.CDEX_DAMAG, 
		SAL.CDEX_LOCAT, 
		NEWDOTON,
		NEWDOTOFF, 
		SAL.Bin, 
		SAL.inv_mech AS Mechanic, 
		INV.EDI_Sent, 
		INV.EDI_Time, 
		INV.Approval, 
		INV.MRSK_Cause '

IF @Remarks = 1
	SET @Query = @Query + ',RTRIM(RepairRemarks) AS RepairRemarks, RTRIM(PrivateRemarks) AS PrivateRemarks '

SET @Query = @Query + 'FROM	Invoices INV
		LEFT JOIN Sale SAL ON INV.Inv_No = SAL.Inv_No 
WHERE	INV.EStatus <> ''CANC''
		AND INV.INV_EST IN (''C'',''E'',''I'')
		AND INV.INV_TYPE NOT IN (''Z'',''G'')
		AND INV.Row_Status <> ''D'' 
		AND ' + @DTTypeSel + ' BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''''

IF @RecordType IS NOT Null
	SET @Query = @Query + ' AND INV.Inv_Est = ''' + @RecordType + ''' '

IF @Bids IS NOT Null
	SET @Query = @Query + ' AND INV.Inv_Mech ' + IIF(@Bids = 'N', 'NOT', '') + ' IN (''APP'',''BID'') '
ELSE
	SET @Query = @Query + ' AND INV.Inv_Mech NOT IN (''APP'',''BID'') '

IF @Bins IS NOT Null
	SET @Query = @Query + ' AND INV.Bin = ''' + @Bins + ''''

IF @Depot IS NOT Null
	SET @Query = @Query + ' AND INV.Depot_Loc = ''' + @Depot + ''' '

IF @EmptyRepairDate IS NOT Null
	SET @Query = @Query + ' AND INV.Rep_Date IS NULL OR INV.Rep_Date = ''01/01/1900'') '

IF @EstInvNumber IS NOT Null
	SET @Query = @Query + ' AND (INV.Invoice_No = ''' + @EstInvNumber + ''' OR INV.Estimate_No = ''' + @EstInvNumber + ''') '

IF @PartNumber IS NOT Null
	SET @Query = @Query + ' AND SAL.PART_NO = ''' + @PartNumber + ''' '
		
IF @Summary = 1
	SET @Query = @Query + ' GROUP BY IIF(INV.INV_EST = ''I'', INV.Invoice_No, INV.Estimate_No), INV.Inv_Batch, CAST(INV.Invoice_Date AS Date), INV.Est_Date, INV.Eq_DateIn, INV.Entry_Date, INV.Rep_Date, INV.INV_EST, INV.DEPOT_LOC, INV.INV_TOTAL, INV.Sale_Tax, INV.ESTATUS, INV.ACCT_NO, INV.CONTAINER, INV.CHASSIS, INV.GENSET_NO, INV.GEN_HOURS, INV.INV_TYPE, INV.WORKORDER, INV.Inv_Mech, INV.EDI_Sent, INV.EDI_Time, INV.Approval, INV.MRSK_Cause '

SET @Query = @Query + ' ORDER BY 1'
print @Query
EXECUTE(@Query)