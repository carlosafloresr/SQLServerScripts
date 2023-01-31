/*
EXECUTE USP_FIData_Inquirer @RecordId = 833140
EXECUTE USP_FIData_Inquirer @DateIni = '06/01/2012', @DateEnd = '06/22/2012', @DateType ='E', @Bids = 'Y', @Depot = 'MEMPHIS', @Remarks = 1
EXECUTE USP_FIData_Inquirer @DateIni = '05/01/2012', @DateEnd = '05/02/2012', @DateType ='E', @Depot = 'MEMPHIS', @EmptyRD = 1
EXECUTE USP_FIData_Inquirer @DateIni = '05/01/2012', @DateEnd = '05/02/2012', @DateType ='E', @Depot = 'MEMPHIS', @RecType = 'E'
EXECUTE USP_FIData_Inquirer @DateIni = '05/01/2012', @DateEnd = '06/02/2012', @DateType ='E', @Depot = 'MEMPHIS', @RecType = 'E', @JobCode = 'MLAF2R'
*/
ALTER PROCEDURE USP_FIData_Inquirer
		@DateIni	Datetime = Null,
		@DateEnd	Datetime = Null,
		@DateType	Char(1) = 'R',
		@RecordId	Int = Null,
		@RecType	Char(1) = 'A',
		@Bids		Char(1) = 'A',
		@Depot		Varchar(20) = Null,
		@EmptyRD	Bit = 0,
		@JobCode	Varchar(15) = Null,
		@Bin		Varchar(20) = Null,
		@Remarks	Bit = 0
AS
DECLARE @Query		Varchar(MAX),
		@Conditions	Varchar(MAX) = '',
		@DateField	Varchar(20)

SET @DateField = CASE @DateType WHEN 'R' THEN 'INV.Rep_Date' WHEN 'E' THEN 'INV.Est_Date' ELSE 'INV.Inv_Date' END

IF @DateIni IS NOT Null AND @DateEnd IS NOT Null
	SET @Conditions = @DateField + ' BETWEEN {' + CONVERT(Char(10), @DateIni, 101) + '} AND {' + CONVERT(Char(10), @DateEnd, 101) + '} '
ELSE
BEGIN
	IF @DateIni IS NOT Null
		SET @Conditions = @DateField + ' = {' + CONVERT(Char(10), @DateIni, 101) + '}'

	IF @DateEnd IS NOT Null
		SET @Conditions = CASE WHEN @Conditions = '' THEN '' ELSE @Conditions + 'AND ' END + @DateField + ' = {' + CONVERT(Char(10), @DateEnd, 101) + '}'
END

IF @RecordId IS NOT Null
BEGIN
	SET @Conditions = CASE WHEN @Conditions = '' THEN '' ELSE @Conditions + 'AND ' END + 'INV.Inv_No = ' + CAST(@RecordId AS Varchar)
END

IF @Depot IS NOT Null
BEGIN
	SET @Conditions = CASE WHEN @Conditions = '' THEN '' ELSE @Conditions + 'AND ' END + 'INV.Depot_Loc = "' + RTRIM(@Depot) + '"'
END

IF @EmptyRD = 1
BEGIN
	SET @Conditions = CASE WHEN @Conditions = '' THEN '' ELSE @Conditions + 'AND ' END + 'EMPTY(INV.Rep_Date)'
END

IF @Bids <> 'A'
BEGIN
	SET @Conditions = CASE WHEN @Conditions = '' THEN '' ELSE @Conditions + 'AND ' END + CASE WHEN @Bids = 'N' THEN 'NOT ' ELSE '' END + 'INLIST(INV.Inv_Mech, "APP", "BID")'
END

IF @RecType <> 'A'
BEGIN
	SET @Conditions = CASE WHEN @Conditions = '' THEN '' ELSE @Conditions + 'AND ' END + 'INV.Inv_Est = "' + @RecType  + '"'
END

IF @JobCode IS NOT Null
BEGIN
	SET @Conditions = CASE WHEN @Conditions = '' THEN '' ELSE @Conditions + 'AND ' END + 'SAL.Part_No = "' + RTRIM(@JobCode)  + '"'
END

SET @Query = 'SELECT INV.INV_NO, INV.Inv_Batch, INV.INV_DATE, INV.Est_Date, INV.Eq_DateIn
		,IIF(EMPTY(INV.Rep_Date), .NULL., INV.Rep_Date) AS Rep_Date
		,IIF(INV.INV_EST = "I", "Invoice ", "Estimate") AS INV_Est
		,INV.DEPOT_LOC AS DEPOT_LOCATION
		,SAL.PART_NO AS JobCode
		,SAL.DESCRIPT AS Description
		,SAL.CDEX_REPAI
		,QTY_SHIPED AS PartQuantity
		,UNIT_PRICE AS UnitPrice
		,PART_TOTAL AS PartTotal
		,SAL.RLABOR AS LaborTotal
		,SAL.RLABOR_QTY AS LaborQuantity
		,SAL.LAB_PRICE AS LaborPrice
		,ROUND(INV.Consum, 2) AS Consum
		,INV.INV_TOTAL AS InvoiceTotal
		,INV.Sale_Tax AS SaleTax
		,ESTATUS AS Status
		,INV.ACCT_NO AS CustomerNumber
		,INV.CONTAINER
		,INV.CHASSIS
		,INV.GENSET_NO
		,INV.GEN_HOURS
		,IIF(INV.INV_TYPE = "R", "Invoice", "Credit ") AS RecordType
		,INV.WORKORDER
		,SAL.CDEX_DAMAG
		,SAL.CDEX_LOCAT
		,NEWDOTON
		,NEWDOTOFF
		,SAL.Bin
		,SAL.inv_mech AS Mechanic
		,INV.EDI_Sent
		,INV.EDI_Time
		,INV.Approval
		,LEFT(INV.CDEX_Remk, 150) AS RepairRemarks
		,LEFT(INV.Inv_Remk, 150) AS PrivateRemarks
FROM 	Invoices INV
		INNER JOIN Sale SAL ON INV.Inv_No = SAL.Inv_No 
WHERE ' + CASE WHEN @Conditions = '' THEN 'SAL.Inv_No BETWEEN 833140 AND 833160' ELSE @Conditions END + 
' ORDER BY INV.Inv_No'

EXECUTE USP_QueryFIDepot @Query, '##tmpFIData'

IF @Remarks = 0
BEGIN
	SELECT	inv_no
			,[status]
			,Inv_Batch
			,inv_date
			,est_date
			,rep_date
			,inv_est
			,depot_location
			,RTRIM(MAIN.jobcode) AS JobCode
			,MAIN.Description
			,CDEX_Repai
			,partquantity
			,unitprice
			,parttotal
			,labortotal
			,laborquantity
			,laborprice
			,Consum
			,invoicetotal
			,saletax
			,customernumber
			,container
			,chassis
			,genset_no
			,gen_hours
			,RecordType
			,workorder
			,cdex_damag
			,cdex_locat
			,newdoton
			,newdotoff
			,UPPER(ISNULL(SUB.Category, MAIN.Bin)) AS Bin
			,Mechanic
			,CASE WHEN EDI_Sent < '01/01/1980' THEN Null ELSE EDI_Sent END AS EDI_Sent
			,CASE WHEN EDI_Time = '' THEN Null ELSE EDI_Time END AS EDI_Time
			,Approval
	FROM	##tmpFIData MAIN
			LEFT JOIN JobCodes SUB ON MAIN.JobCode = SUB.JobCode
END
ELSE
BEGIN
	SELECT	inv_no
			,[status]
			,Inv_Batch
			,inv_date
			,est_date
			,rep_date
			,Eq_DateIn
			,inv_est
			,depot_location
			,MAIN.jobcode
			,MAIN.description
			,cdex_repai
			,partquantity
			,unitprice
			,parttotal
			,labortotal
			,laborquantity
			,laborprice
			,Consum
			,invoicetotal
			,saletax
			,customernumber
			,container
			,chassis
			,genset_no
			,gen_hours
			,RecordType
			,workorder
			,cdex_damag
			,cdex_locat
			,newdoton
			,newdotoff
			,UPPER(ISNULL(SUB.Category, MAIN.Bin)) AS Bin
			,Mechanic
			,CASE WHEN EDI_Sent < '01/01/1980' THEN Null ELSE EDI_Sent END AS EDI_Sent
			,CASE WHEN EDI_Time = '' THEN Null ELSE EDI_Time END AS EDI_Time
			,Approval
			,RTRIM(RepairRemarks) AS RepairRemarks
			,RTRIM(PrivateRemarks) AS PrivateRemarks
	FROM	##tmpFIData MAIN
			LEFT JOIN JobCodes SUB ON MAIN.JobCode = SUB.JobCode
END
DROP TABLE ##tmpFIData