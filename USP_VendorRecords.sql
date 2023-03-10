USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_VendorRecords]    Script Date: 1/15/2020 10:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
USP_VendorRecords 'AIS', 0, '12/30/2018', '12/28/2019', Null, Null, 'DRV', 'TEST FOOTER', NULL, NULL, NULL, 0, 600
USP_VendorRecords 'IMC', 0, '1/1/2008', '12/31/2008', '9761', '9761', Null, Null, Null, Null, Null, 0, 600
USP_VendorRecords 'IMC', 0, {ts '2008-01-01 16:42:43'}, {ts '2008-12-31 16:42:43'}
USP_VendorRecords 'GIS', 0, '12/01/2015', '12/31/2016', 'G0720', 'G0720', 'DRV', NULL, NULL, NULL
USP_VendorRecords 'NDS', 0, '01/01/2019', '12/31/2019', 'N10008', NULL, 'DRV', NULL, NULL, NULL
USP_VendorRecords 'HMIS', 0, '01/01/2018', '12/31/2018', '51703', NULL, 'DRV', NULL, NULL, NULL
*/
ALTER PROCEDURE [dbo].[USP_VendorRecords]
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
	@DrvStatus	Int = Null,
	@OnlyBonus	Bit = 0,
	@JustAbove	Numeric(10,2) = Null
AS
SET NOCOUNT ON

DECLARE	@Query	Varchar(Max)

IF @VendorId = ''
	SET @VendorId = Null

IF @VendorId2 = ''
	SET @VendorId2 = Null

IF @VendType = ''
	SET @VendType = Null

IF @Footer = ''
	SET @Footer = Null

IF @Division1 = ''
	SET @Division1 = Null

IF @Division2 = ''
	SET @Division2 = Null

DECLARE	@tbl1099 Table (
	[VendorId]			[varchar](15) NOT NULL,
	[VendName]			[varchar](65) NULL,
	[Ten99Type]			[smallint] NOT NULL,
	[Is1099]			[varchar](18) NOT NULL,
	[VendorType]		[varchar](11) NOT NULL,
	[VchrNmbr]			[varchar](21) NOT NULL,
	[DocTyNam]			[varchar](21) NOT NULL,
	[DocDate]			[datetime] NOT NULL,
	[DocNumbr]			[varchar](21) NOT NULL,
	[DocAmnt]			[numeric](19, 5) NOT NULL,
	[CurTrxAm]			[numeric](19, 5) NOT NULL,
	[Un1099AM]			[numeric](19, 5) NOT NULL,
	[TrxDscrn]			[varchar](31) NOT NULL,
	[CheckDate]			[datetime] NOT NULL,
	[PayWithDocument]	[varchar](21) NOT NULL,
	[CheckAmount]		[numeric](19, 5) NOT NULL,
	[CompanyName]		[varchar](65) NOT NULL,
	[CompanyId]			[varchar](5) NOT NULL,
	[Address]			[varchar](202) NULL,
	[Source]			[varchar](2) NOT NULL,
	[DistType]			[int] NOT NULL,
	[DetailAmount]		[numeric](19, 5) NOT NULL,
	[DistRef]			[varchar](1) NOT NULL,
	[SortDate]			[varchar](8) NULL,
	[HireDate]			[datetime] NULL,
	[TerminationDate]	[datetime] NULL,
	[DocType]			[smallint] NOT NULL,
	[LastPayDate]		[datetime] NULL,
	[Dex_Row_id]		[int] NOT NULL,
	[PostEdDt]			[datetime] NOT NULL,
	[PayType]			[smallint] NOT NULL,
	[Division]			[varchar](4) NULL,
	[DivisionName]		[varchar](84) NULL,
	[Row]				[bigint] NULL)

IF @JustAbove = 0
	SET @JustAbove = Null

SET	@Query = 'SELECT RTRIM(VendorId) AS VendorId
      ,RTRIM(CASE WHEN VendorType = ''DRV'' AND dbo.AT(''#'', VendName, 1) > 0 THEN LEFT(VendName, dbo.AT(''#'', VendName, 1) - 1) ELSE VendName END) AS VendName
      ,Ten99Type
      ,Is1099
      ,VendorType
      ,RTRIM(VchrNmbr) AS VchrNmbr
      ,RTRIM(DocTyNam) AS RTRIM
      ,DocDate
      ,RTRIM(DocNumbr) AS DocNumbr
      ,DocAmnt
      ,CurTrxAm
      ,Un1099AM
      ,TrxDscrn
      ,CheckDate
      ,PayWithDocument
      ,CheckAmount
      ,RTRIM(CompanyName) AS CompanyName
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
	  ,ROW_NUMBER() OVER (PARTITION BY VchrNmbr ORDER BY VendorId, VchrNmbr, PayType DESC) AS Row 
INTO	##tmpData
FROM ' + @Company + '.dbo.View_VendorRecords WHERE DocAmnt <> 0'

IF @1099 > 0
BEGIN
	SET	@Query = @Query + CASE WHEN @1099 = 1 THEN ' AND Ten99Type = 1' ELSE 'AND Ten99Type > 1' END
END

IF @StartDate IS NOT Null AND @EndDate IS NOT Null
BEGIN
	SET	@Query = @Query + ' AND CheckDate BETWEEN ''' + CONVERT(Char(10), @StartDate, 101) + ''' AND ''' + CONVERT(Char(10), @EndDate, 101) + ''''
	--SET	@Query = @Query + 'AND ((VendorType = ''DRV'' AND CheckDate BETWEEN ''' + CONVERT(Char(10), @StartDate, 101) + ''' AND ''' + CONVERT(Char(10), @EndDate, 101) + ''''
	--SET	@Query = @Query + ') OR (VendorType <> ''DRV'' AND CheckDate BETWEEN ''' + CONVERT(Char(10), @StartDate, 101) + ''' AND ''' + CONVERT(Char(10), @EndDate, 101) + ''''
	--SET	@Query = @Query + '))' -- AND (LastPayDate <= ''' +  CONVERT(Char(10), @EndDate, 101) + ''' OR LastPayDate IS NULL)'
END
ELSE
BEGIN
	IF @StartDate IS NOT Null
	BEGIN
		SET	@Query = @Query + ' AND CheckDate = ''' + CONVERT(Char(10), @StartDate, 101) + ''''
		--SET	@Query = @Query + ' AND CheckDate = ''' + CONVERT(Char(10), @StartDate, 101) + ''''
		--SET	@Query = @Query + ' AND (LastPayDate <= ''' +  CONVERT(Char(10), @StartDate, 101) + ''' OR LastPayDate IS NULL)'
	END

	IF @EndDate IS NOT Null
	BEGIN
		SET	@Query = @Query + ' AND CheckDate = ''' + CONVERT(Char(10), @EndDate, 101) + ''''
		--SET	@Query = @Query + ' AND CheckDate = ''' + CONVERT(Char(10), @EndDate, 101) + ''''
		--SET	@Query = @Query + ' AND (LastPayDate <= ''' +  CONVERT(Char(10), @EndDate, 101) + ''' OR LastPayDate IS NULL)'
	END
END

IF @VendType IS NOT Null
BEGIN
	SET	@Query = @Query + ' AND VendorType = ''' + RTRIM(@VendType) + ''''
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

IF @OnlyBonus = 1
BEGIN
	SET	@Query = @Query + ' AND (PATINDEX(''%SIGN%'', DocNumbr) > 0 OR PATINDEX(''%REFER%'', DocNumbr) > 0 OR PATINDEX(''%BONUS%'', DocNumbr) > 0)'
END

SET	@Query = @Query + ' ORDER BY VendorId, PayType DESC, PayWithDocument, VchrNmbr, DocDate'

PRINT @Query

--INSERT INTO @tbl1099
EXECUTE(@Query)

SELECT	*
FROM	(
		SELECT	DATA.*, 
				Ten99Amount
		FROM	##tmpData DATA
				INNER JOIN (SELECT VendorId, SUM(Un1099AM) AS Ten99Amount FROM ##tmpData WHERE Row = 1 AND Source = 'GP' GROUP BY VendorId) S1099 ON DATA.VendorId = S1099.VendorId
		) DATA
WHERE	@JustAbove IS Null
		OR (@JustAbove IS NOT Null AND Ten99Amount >= @JustAbove)
ORDER BY DocDate, DocNumbr

DROP TABLE ##tmpData