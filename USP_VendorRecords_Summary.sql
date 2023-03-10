/*
EXECUTE USP_VendorRecords_Summary 'GIS',4,'1/1/2009', '1/31/2009', 'G6732', 'G6732'
EXECUTE USP_VendorRecords 'GIS',0,'1/1/2009', '1/31/2009', 'G6732', 'G6732'
*/
ALTER PROCEDURE [dbo].[USP_VendorRecords_Summary]
	@Company	Varchar(5),
	@1099		SmallInt,
	@StartDate	SmallDateTime = Null,
	@EndDate	SmallDateTime = Null,
	@VendorId	Varchar(25) = Null,
	@VendorId2	Varchar(25) = Null,
	@VendType	Varchar(5) = Null,
	@Footer		Varchar(70) = Null,
	@Division1	Char(3) = Null,
	@Division2	Char(3) = Null,
	@DrvStatus	Int = Null
AS
DECLARE	@Query	Varchar(Max)

DELETE GPCUSTOM.DBO.Vendor1099 WHERE Company = @Company AND Year1 = YEAR(@StartDate + 15)

SET	@Query = 'SELECT VendorId
      ,CASE WHEN VendorType = ''DRV'' AND dbo.AT(''#'', VendName, 1) > 0 THEN LEFT(VendName, dbo.AT(''#'', VendName, 1) - 1) ELSE VendName END AS VendName
      ,Ten99Type
      ,Is1099
      ,VendorType
      ,VchrNmbr
      ,DocTyNam
      ,DocDate
      ,DocNumbr
      ,DocAmnt
      ,CurTrxAm
      ,Un1099AM
      ,TrxDscrn
      ,CheckDate
      ,PayWithDocument
      ,CheckAmount
      ,CompanyName
      ,CompanyId
      ,Address
      ,Source
      ,DistType
      ,DetailAmount
      ,DistRef
      ,SortDate
      ,HireDate
      ,TerminationDate
      ,DocType
      ,LastPayDate
      ,Dex_Row_id
      ,PostEdDt
	  ,PayType
	  ,Division
	  ,DivisionName
	  ,ROW_NUMBER() OVER (PARTITION BY VchrNmbr ORDER BY VendorId, VchrNmbr, PayType DESC) AS Row FROM ' + @Company + '.dbo.View_VendorRecords WHERE DocAmnt <> 0'

IF @1099 > 0
BEGIN
	SET	@Query = @Query + CASE WHEN @1099 = 1 THEN ' AND Ten99Type = 1' ELSE 'AND Ten99Type > 1' END
END

IF @VendType IS NOT Null
BEGIN
	SET	@Query = @Query + ' AND VendorType = ''' + RTRIM(@VendType) + ''''
END

IF @StartDate IS NOT Null AND @EndDate IS NOT Null
BEGIN
	SET	@Query = @Query + ' AND CheckDate BETWEEN ''' + CONVERT(Char(10), @StartDate, 101) + ''' AND ''' + CONVERT(Char(10), @EndDate, 101) + ''''
	SET	@Query = @Query + ' AND (LastPayDate <= ''' +  CONVERT(Char(10), @EndDate, 101) + ''' OR LastPayDate IS NULL)'
END
ELSE
BEGIN
	IF @StartDate IS NOT Null
	BEGIN
		SET	@Query = @Query + ' AND CheckDate = ''' + CONVERT(Char(10), @StartDate, 101) + ''''
		SET	@Query = @Query + ' AND (LastPayDate <= ''' +  CONVERT(Char(10), @StartDate, 101) + ''' OR LastPayDate IS NULL)'
	END

	IF @EndDate IS NOT Null
	BEGIN
		SET	@Query = @Query + ' AND CheckDate = ''' + CONVERT(Char(10), @EndDate, 101) + ''''
		SET	@Query = @Query + ' AND (LastPayDate <= ''' +  CONVERT(Char(10), @EndDate, 101) + ''' OR LastPayDate IS NULL)'
	END
END

IF @VendorId IS NOT Null AND @VendorId2 IS NOT Null
BEGIN
	SET	@Query = @Query + ' AND VendorId BETWEEN ''' + @VendorId + ''' AND ''' + @VendorId2 + ''''
END
ELSE
BEGIN
	IF @VendorId IS NOT Null
	BEGIN
		SET	@Query = @Query + ' AND VendorId = ''' + @VendorId + ''''
	END
	ELSE
	BEGIN
		IF @VendorId2 IS NOT Null
		BEGIN
			SET	@Query = @Query + ' AND VendorId = ''' + @VendorId2 + ''''
		END
	END
END

IF @Division1 IS NOT Null AND @Division2 IS NOT Null
BEGIN
	SET	@Query = @Query + ' AND Division BETWEEN ''' + RTRIM(@Division1) + ''' AND ''' + RTRIM(@Division2) + ''''
END
ELSE
BEGIN
	IF @Division1 IS NOT Null
	BEGIN
		SET	@Query = @Query + ' AND Division = ''' + RTRIM(@Division1) + ''''
	END
	
	IF @Division2 IS NOT Null
	BEGIN
		SET	@Query = @Query + ' AND Division = ''' + RTRIM(@Division2) + ''''
	END
END

IF @DrvStatus IS NOT Null
BEGIN
	SET	@Query = @Query + ' AND TerminationDate IS ' + CASE WHEN @DrvStatus = 1 THEN '' ELSE 'NOT' END + ' Null'
END

SET	@Query = 'INSERT INTO GPCUSTOM.DBO.Vendor1099 SELECT ''' + RTRIM(@Company) + ''' AS Company, VendorId, YEAR(CheckDate) AS Year1, MONTH(CheckDate) AS PeriodId, SUM(Un1099AM) AS Ten99Sum FROM (' + @Query + ') RECS WHERE Row = 1 GROUP BY VendorId, YEAR(CheckDate), MONTH(CheckDate) ORDER BY 1, 2, 3'

--PRINT @Query
EXECUTE(@Query)

/*
USP_VendorRecords 'IMC', 0, '1/1/2008', '1/31/2008', Null, Null, 'DRV'
USP_VendorRecords 'IMC', 0, '1/1/2008', '12/31/2008', '8972', '8972', Null
USP_VendorRecords 'IMC', 0, {ts '2008-01-01 16:42:43'}, {ts '2008-12-31 16:42:43'}
*/