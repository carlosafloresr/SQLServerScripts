/*
EXECUTE USP_Depot_DataInquiry @DateIni = '05/26/2019', @DateEnd = '06/01/2019', @DateType = 'I'
EXECUTE USP_Depot_DataInquiry @DateIni = '05/26/2019', @DateEnd = '06/01/2019', @DateType = 'I', @Summary = 1
*/
ALTER PROCEDURE [dbo].[USP_Depot_DataInquiry]
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

IF EXISTS(SELECT Name FROM tempdb.sys.objects WHERE Name LIKE '%##tmpData%')
	DROP TABLE ##tmpData

SET @DTTypeSel = CASE @DateType 
					WHEN 'R' THEN 'INV.Repair_Date'
					WHEN 'E' THEN 'INV.Estimate_Date'
					WHEN 'C' THEN 'INV.Entry_Date'
				 ELSE 'CAST(INV.Invoice_Date AS Date)' END
IF @Summary = 1
	SET @Query = N'SELECT DISTINCT INV.Invoice_No AS Inv_No, 
		MAX(INV.Inv_Batch) AS Inv_Batch, 
		CAST(INV.Invoice_Date AS Date) AS Inv_Date, 
		CASE WHEN INV.INV_EST = ''I'' THEN ''Invoice'' ELSE ''Estimate'' END AS Inv_Est, 
		RTRIM(INV.DEPOT_LOC) AS Depot_Location, 
		SUM(QTY_SHIPED) AS PartQuantity,
		SUM(UNIT_PRICE) AS UnitPrice, 
		SUM(PART_TOTAL) AS PartTotal, 
		SUM(SAL.RLABOR) AS LaborTotal, 
		SUM(SAL.RLABOR_QTY) AS LaborQuantity, 
		SUM(SAL.LAB_PRICE) AS LaborPrice, 
		InvoiceTotal = (SELECT SUM(INV2.INV_TOTAL) FROM Invoices INV2 WHERE INV2.Invoice_No = INV.Invoice_No AND INV2.Row_Status <> ''D''),
		SaleTax = (SELECT SUM(INV2.Sale_Tax) FROM Invoices INV2 WHERE INV2.Invoice_No = INV.Invoice_No AND INV2.Row_Status <> ''D''), 
		RTRIM(INV.ACCT_NO) AS CustomerNumber, 
		CASE WHEN INV.INV_TYPE = ''R'' THEN ''Invoice'' ELSE ''Credit'' END AS RecordType, 
		0 AS RowNumber '		
ELSE
	SET @Query = N'SELECT INV.Invoice_No AS Inv_No,  
		INV.Inv_Batch, 
		INV.Invoice_Date AS Inv_Date, 
		INV.Estimate_Date AS Est_Date, 
		INV.Eq_DateIn, 
		INV.Entry_Date, 
		CASE WHEN INV.Repair_Date IS NULL OR INV.Repair_Date < ''01/01/1980'' THEN NULL ELSE INV.Repair_Date END AS Rep_Date,
		CASE WHEN INV.INV_EST = ''I'' THEN ''Invoice'' ELSE ''Estimate'' END AS Inv_Est, 
		INV.DEPOT_LOC AS Depot_Location, 
		ISNULL(SAL.PART_NO, '''') AS JobCode, 
		ISNULL(SAL.DESCRIPT, '''') AS Description,
		ISNULL(SAL.CDEX_REPAI, '''') AS CDEX_REPAI, 
		ISNULL(QTY_SHIPED, 0) AS PartQuantity, 
		ISNULL(UNIT_PRICE, 0) AS UnitPrice, 
		ISNULL(PART_TOTAL, 0) AS PartTotal, 
		ISNULL(SAL.RLABOR, 0) AS LaborTotal, 
		ISNULL(SAL.RLABOR_QTY, 0) AS LaborQuantity, 
		ISNULL(SAL.LAB_PRICE, 0) AS LaborPrice,
		InvoiceTotal = (SELECT SUM(INV2.INV_TOTAL) FROM Invoices INV2 WHERE INV2.Invoice_No = INV.Invoice_No AND INV2.Row_Status <> ''D''),
		SaleTax = (SELECT SUM(INV2.Sale_Tax) FROM Invoices INV2 WHERE INV2.Invoice_No = INV.Invoice_No AND INV2.Row_Status <> ''D''), 
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
		INV.MRSK_Cause,
		ROW_NUMBER() OVER(PARTITION BY IIF(INV.INV_EST = ''I'', INV.Invoice_No, INV.Estimate_No) ORDER BY IIF(INV.INV_EST = ''I'', INV.Invoice_No, INV.Estimate_No) ASC) AS RowNumber '

IF @Remarks = 1
	SET @Query = @Query + ',RTRIM(RepairRemarks) AS RepairRemarks, RTRIM(PrivateRemarks) AS PrivateRemarks '

SET @Query = @Query + 'INTO ##tmpData
FROM	Invoices INV
		LEFT JOIN Sale SAL ON INV.unique_key = SAL.invoices_key AND SAL.Row_Status <> ''D'' 
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
	SET @Query = @Query + ' GROUP BY INV.Invoice_No, CAST(INV.Invoice_Date AS Date), INV.INV_EST, INV.DEPOT_LOC, INV.ACCT_NO, INV.INV_TYPE'

--print @Query
EXECUTE(@Query)

IF @Summary = 0
	UPDATE ##tmpData SET InvoiceTotal = 0, SaleTax = 0 WHERE RowNumber > 1

SELECT	*
FROM	##tmpData
ORDER BY Inv_No, RowNumber

DROP TABLE ##tmpData