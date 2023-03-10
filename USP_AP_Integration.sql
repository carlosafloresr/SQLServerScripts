USE [FB]
GO
/****** Object:  StoredProcedure [dbo].[USP_AP_Integration]    Script Date: 4/29/2020 8:50:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AP_Integration 66, '11871', 'AIS19074', '04/28/2020'
*/
ALTER PROCEDURE [dbo].[USP_AP_Integration]
		@ProjectID		Int,
		@VendorID		Varchar(15),
		@DocumentNum	Varchar(30),
		@PostingDate	Date
AS
SET NOCOUNT ON

DECLARE	@tblAccount		Table (GLAccount Varchar(15))
DECLARE @tblAP			Table (Counter Int)

DECLARE	@Query			Varchar(1000),
		@CreditAccount	Varchar(15),
		@Integration	Varchar(6) = 'DXP',
		@Company		Varchar(5),
		@BatchId		Varchar(15) = 'DEX' + dbo.FormatDateYMD(GETDATE(), 1, 1, 1),
		@VCHNUMWK		Varchar(17),
		@DOCNUMBR		Varchar(30) = @DocumentNum,
		@DOCTYPE		Smallint = 1,
		@DOCAMNT		Numeric(18,2),
		@DOCDATE		Datetime,
		@PSTGDATE		Datetime = @PostingDate,
		@CHRGAMNT		Numeric(18,2),
		@TEN99AMNT		Numeric(18,2),
		@PRCHAMNT		Numeric(18,2),
		@TRXDSCRN		Varchar(30),
		@CURNCYID		Varchar(15) = 'USD2',
		@RATETPID		Varchar(15) = 'AVERAGE',
		@EXCHDATE		Datetime = '01/01/2007',
		@RATEEXPR		Smallint = 0,
		@CREATEDIST		Smallint = 0,
		@DISTTYPE		Smallint = 6,
		@ACTNUMST		Varchar(15),
		@DEBITAMT		Numeric(18,2),
		@CRDTAMNT		Numeric(18,2),
		@DISTREF		Varchar(30),
		@RecordId		Bigint,
		@ProNumber		Varchar(15) = Null,
		@Container		Varchar(25) = Null,
		@Chassis		Varchar(25) = Null,
		@PopUpId		Int = 0,
		@DriverId		Varchar(15) = Null,
		@PORDNMBR		Varchar(20) = Null,
		@nErrNum		Smallint = 0,
		@sErrMsg		Varchar(200),
		@APExists		Smallint = 0

SELECT	@Company = RTRIM(Company)
FROM	SECSQL01T.GPCustom.dbo.DexCompanyProjects
WHERE	ProjectId = @ProjectID
		AND ProjectType = 'AP'

SET @Query = N'SELECT COUNT(*) FROM SECSQL01T.' + @Company + '.dbo.PM00400 WHERE VendorId = ''' + @VendorID + ''' AND DOCNUMBR = ''' + @DocumentNum + ''''

INSERT INTO @tblAP
EXECUTE(@Query)

SET @APExists = (SELECT COUNT(*) FROM @tblAP)

SELECT	@VCHNUMWK = 'IDV' + REPLACE(dbo.FormatDateYMD(GETDATE(), 1, 1, 1), '_', '') + dbo.PADL([FileID], 8, '0'),
		@ACTNUMST = SUBSTRING([KeyGroup3], IIF(@Company = 'NDS', 2, 1), IIF(@Company = 'NDS', 2, 1)) + '-' + RIGHT(RTRIM([KeyGroup3]), 2) + '-' + LEFT([KeyGroup1], 4)
FROM	[FB].[dbo].[View_DEXDocuments]
WHERE	ProjectID = @ProjectID
		AND Field8 = @VendorID
		AND Field4 = @DocumentNum

SELECT	@RecordId = [FileID]
		,@Chassis = [Field3]
		,@CHRGAMNT = [Field5]
		,@PRCHAMNT = [Field5]
		,@DOCAMNT = [Field5]
		,@TEN99AMNT = [Field5]
		,@DEBITAMT = [Field5]
		,@CRDTAMNT = 0
		,@DOCDATE = [Field10]
		,@ProNumber = [Field11]
		,@TRXDSCRN = RTRIM([Field13])
		,@DISTREF = RTRIM([Field13])
		,@Container = RTRIM([Field14])
		,@PORDNMBR = RTRIM([Field16])
		,@PopUpId = IIF([KeyGroup10] <> '0' AND [KeyGroup10] <> '', [KeyGroup10], Null)
FROM	[FB].[dbo].[View_DEXDocuments]
WHERE	ProjectID = @ProjectID
		AND Field8 = @VendorID
		AND Field4 = @DocumentNum

SET @Query = N'SELECT RTRIM(B.ACTNUMST) FROM PRISQL01P.' + @Company + '.dbo.PM00200 AS A INNER JOIN PRISQL01P.' + @Company + '.dbo.GL00105 AS B ON A.PMAPINDX = B.ACTINDX AND VendorId = ''' + @VendorID + ''''

INSERT INTO @tblAccount
EXECUTE(@Query)

SET @CreditAccount = (SELECT GLAccount FROM @tblAccount)

IF @APExists > 0
BEGIN
	SET @nErrNum = 1
	SET @sErrMsg = 'The invoice [' + RTRIM(@DocumentNum) + '] from the vendor id [' + RTRIM(@VendorID) + '] already exists in Great Plains AP!'
END

IF @nErrNum > 0
BEGIN	
	RAISERROR (@sErrMsg, 11, 1);
	RETURN 1
END
ELSE
BEGIN
	-- DEBIT
	EXECUTE SECSQL04T.Integrations.dbo.USP_Integrations_AP @Integration,
	@Company,
	@BatchId,
	@VCHNUMWK,
	@VendorID,
	@DOCNUMBR,
	@DOCTYPE,
	@DOCAMNT,
	@DOCDATE,
	@PSTGDATE,
	@CHRGAMNT,
	@TEN99AMNT,
	@PRCHAMNT,
	@TRXDSCRN,
	@CURNCYID,
	@RATETPID,
	@EXCHDATE,
	@RATEEXPR,
	@CREATEDIST,
	@DISTTYPE,
	@ACTNUMST,
	@DEBITAMT,
	@CRDTAMNT,
	@DISTREF,
	@RecordId,
	@ProNumber,
	@Container,
	@Chassis,
	@PopUpId,
	@DriverId,
	@PORDNMBR

	SET @ACTNUMST = @CreditAccount
	SET @CRDTAMNT = @DEBITAMT
	SET @DEBITAMT = 0
	SET @DISTTYPE = 2

	-- CREDIT
	EXECUTE SECSQL04T.Integrations.dbo.USP_Integrations_AP @Integration,
	@Company,
	@BatchId,
	@VCHNUMWK,
	@VendorID,
	@DOCNUMBR,
	@DOCTYPE,
	@DOCAMNT,
	@DOCDATE,
	@PSTGDATE,
	@CHRGAMNT,
	@TEN99AMNT,
	@PRCHAMNT,
	@TRXDSCRN,
	@CURNCYID,
	@RATETPID,
	@EXCHDATE,
	@RATEEXPR,
	@CREATEDIST,
	@DISTTYPE,
	@ACTNUMST,
	@DEBITAMT,
	@CRDTAMNT,
	@DISTREF,
	@RecordId,
	@ProNumber,
	@Container,
	@Chassis,
	@PopUpId,
	@DriverId,
	@PORDNMBR

	RETURN 0
END