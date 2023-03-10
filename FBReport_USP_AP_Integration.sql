USE [FB]
GO
/****** Object:  StoredProcedure [dbo].[FBReport_USP_AP_Integration]    Script Date: 9/22/2021 1:51:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE FBReport_USP_AP_Integration 66, '11871', 'AIS19074', '04/28/2020'
*/
ALTER PROCEDURE [dbo].[FBReport_USP_AP_Integration]
		@ProjectID		Int,
		@VendorID		Varchar(15),
		@DocumentNum	Varchar(20),
		@PostingDate	Date,
		@BatchId		Varchar(15)
AS
SET NOCOUNT ON

DECLARE	@tblAccount		Table (GLAccount Varchar(15))
DECLARE @tblAP			Table (Counter Int)

DECLARE	@Query			Varchar(1000),
		@CreditAccount	Varchar(15),
		@Integration	Varchar(6) = 'DXP',
		@Company		Varchar(5),
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
		@APExists		Smallint = 0,
		@ExtPropertyID	Int = 0,
		@Error_Number	Int = 0,
		@Error_Message	Varchar(500) = '',
		@Continue		Bit = 1

SELECT	@Company = RTRIM(Company)
FROM	PRISQL01P.GPCustom.dbo.DexCompanyProjects
WHERE	ProjectId = @ProjectID
		AND ProjectType = 'AP'

SET @Query = N'SELECT COUNT(*) FROM PRISQL01P.' + @Company + '.dbo.PM00400 WHERE VendorId = ''' + @VendorID + ''' AND DOCNUMBR = ''' + @DocumentNum + ''''

INSERT INTO @tblAP
EXECUTE(@Query)

SET @APExists = (SELECT Counter FROM @tblAP)

SELECT	@VCHNUMWK = 'IDV' + REPLACE(dbo.FormatDateYMD(GETDATE(), 0, 1, 1), '_', '') + dbo.PADL([FileID], 8, '0'),
		@ACTNUMST = SUBSTRING([KeyGroup3], IIF(@Company = 'NDS', 2, 1), IIF(@Company = 'NDS', 2, 1)) + '-' + RIGHT(RTRIM([KeyGroup3]), 2) + '-' + [PropertyValue]
FROM	[FB].[dbo].[View_DEXDocuments]
WHERE	ProjectID = @ProjectID
		AND Field8 = @VendorID
		AND Field4 = @DocumentNum

SET @Query = N'SELECT RTRIM(B.ACTNUMST) FROM PRISQL01P.' + @Company + '.dbo.PM00200 AS A INNER JOIN PRISQL01P.' + @Company + '.dbo.GL00105 AS B ON A.PMAPINDX = B.ACTINDX AND VendorId = ''' + @VendorID + ''''

INSERT INTO @tblAccount
EXECUTE(@Query)

SET @CreditAccount = (SELECT GLAccount FROM @tblAccount)
IF @CreditAccount IS Null
BEGIN
       SET @nErrNum = 1
       SET @sErrMsg = 'The vendor [' + RTRIM(@VendorID) + '] does not have a default payables account!'
END

IF @APExists > 0
BEGIN
	SET @nErrNum = 1
	SET @sErrMsg = 'The invoice [' + RTRIM(@DocumentNum) + '] from the vendor id [' + RTRIM(@VendorID) + '] already exists in Great Plains AP!'
END

IF @nErrNum > 0
BEGIN	
	RAISERROR (@sErrMsg, 11, 1)
	RETURN 1
END
ELSE
BEGIN
	DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	DISTINCT ExtendedPropertyID
	FROM	[FB].[dbo].[View_DEXDocuments]
	WHERE	ProjectID = @ProjectID
			AND Field8 = @VendorID
			AND Field4 = @DocumentNum
			AND ExtendedPropertyID IS NOT Null -- Added on 09/22/2021 by CFLORES to ignore uncoded transactions

	BEGIN TRANSACTION

	OPEN curData 
	FETCH FROM curData INTO @ExtPropertyID

	WHILE @@FETCH_STATUS = 0 AND @Continue = 1
	BEGIN
		-- DEBIT
		SELECT	@RecordId = [FileID]
				,@Chassis = [Field3]
				,@CHRGAMNT = [Field5]
				,@PRCHAMNT = [Field5]
				,@DOCAMNT = [Field5]
				,@TEN99AMNT = [Field5]
				,@DEBITAMT = CAST(KeyGroup4 AS Numeric(10,2))
				,@CRDTAMNT = 0
				,@DOCDATE = [Field10]
				,@ProNumber = [Field11]
				,@TRXDSCRN = RTRIM([Field13])
				,@DISTREF = RTRIM([KeyGroup5])
				,@Container = RTRIM([Field14])
				,@PORDNMBR = RTRIM([Field16])
				,@ACTNUMST = SUBSTRING([KeyGroup3], IIF(@Company = 'NDS', 2, 1), IIF(@Company = 'NDS', 2, 1)) + '-' + RIGHT(RTRIM([KeyGroup3]), 2) + '-' + [PropertyValue]
				,@PopUpId = IIF([KeyGroup10] <> '0' AND [KeyGroup10] <> '', [KeyGroup10], Null)
		FROM	[FB].[dbo].[View_DEXDocuments]
		WHERE	ProjectID = @ProjectID
				AND Field8 = @VendorID
				AND Field4 = @DocumentNum
				AND ExtendedPropertyID = @ExtPropertyID

		BEGIN TRY
			EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_AP @Integration,
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
		END TRY
		BEGIN CATCH
			SET @Error_Number	= ERROR_NUMBER()
			SET @Error_Message	= ERROR_MESSAGE()
			SET @Continue = 0
		END CATCH

		FETCH FROM curData INTO @ExtPropertyID
	END

	CLOSE curData
	DEALLOCATE curData	

	IF @Continue = 1
	BEGIN
		SET @ACTNUMST = @CreditAccount
		SET @CRDTAMNT = @DOCAMNT
		SET @DEBITAMT = 0
		SET @DISTTYPE = 2

		-- CREDIT
		EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_AP @Integration,
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
		@TRXDSCRN,
		@RecordId,
		@ProNumber,
		@Container,
		@Chassis,
		@PopUpId,
		@DriverId,
		@PORDNMBR

		COMMIT TRANSACTION

		RETURN 0
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR (@Error_Message, 11, 1)
	RETURN 1
	END
END