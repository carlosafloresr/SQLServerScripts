USE [Integrations]
GO

DECLARE	@BatchId		varchar(25) = '6_FPT_20180127',
		@Policy			varchar(200) = null,
		@FileName		varchar(50) = 'EFS_306858_111_20180127.dat'

DECLARE	@tmpBatchId		varchar(25),
		@CarrierId		varchar(50),
		@CardPolicy		varchar(50),
		@ReportedCarrier varchar(50),
		@TrxId			varchar(50),
		@CardNumber		varchar(50),
		@VendorId		varchar(51),
		@TransDate		smalldatetime,
		@FuelAmount		numeric(38,4),
		@AdditiveAmount numeric(38,4),
		@OilAmount		numeric(38,4),
		@SalesTax		numeric(38,4),
		@Fees			numeric(17,4),
		@Discount		numeric(38,4),
		@Cash			numeric(38,4),
		@CashFee		numeric(38,4),
		@InvoiceTotal	numeric(38,4),
		@Balance		numeric(38,4),
		@TotalFuel		numeric(38,4),
		@Verification	int,
		@Processed		bit,
		@Card			varchar(6),
		@Unit			varchar(50),
		@Location		varchar(100),
		@Gallons		numeric(38,4),
		@AuthCode		varchar(50),
		@TSNum			varchar(4),
		@DriverName		varchar(50),
		@Tax			numeric(38,4),
		@MiscAmt		numeric(38,4),
		@RefrAmt		numeric(38,4),
		@TransTime		varchar(5),
		@TimeZone		varchar(50),
		@RepairAmount	decimal(17,4),
		@RapidLog		bit,
		@Division		varchar(50),
		@CardPolicy2	varchar(50)

DECLARE	@tblFuel		Table (
	[CarrierId]			[varchar](50) NULL,
	[CardPolicy]		[varchar](50) NULL,
	[ReportedCarrier]	[varchar](50) NULL,
	[TrxId]				[varchar](50) NULL,
	[CardNumber]		[varchar](50) NULL,
	[BatchId]			[varchar](25) NULL,
	[VendorId]			[varchar](51) NULL,
	[TransDate]			[smalldatetime] NULL,
	[FuelAmount]		[numeric](38, 4) NULL,
	[AdditiveAmount]	[numeric](38, 4) NULL,
	[OilAmount]			[numeric](38, 4) NULL,
	[SalesTax]			[numeric](38, 4) NULL,
	[Fees]				[numeric](17, 4) NULL,
	[Discount]			[numeric](38, 4) NULL,
	[Cash]				[numeric](38, 4) NULL,
	[CashFee]			[numeric](38, 4) NULL,
	[InvoiceTotal]		[numeric](38, 4) NULL,
	[Balance]			[numeric](38, 4) NULL,
	[TotalFuel]			[numeric](38, 4) NULL,
	[Verification]		[int] NULL,
	[Processed]			[bit] NULL,
	[Card]				[varchar](6) NULL,
	[Unit]				[varchar](50) NOT NULL,
	[Location]			[varchar](100) NOT NULL,
	[Gallons]			[numeric](38, 4) NULL,
	[AuthCode]			[varchar](50) NULL,
	[TSNum]				[varchar](4) NULL,
	[DriverName]		[varchar](50) NOT NULL,
	[Tax]				[numeric](38, 4) NULL,
	[MiscAmt]			[numeric](38, 4) NULL,
	[RefrAmt]			[numeric](38, 4) NULL,
	[TransTime]			[varchar](5) NULL,
	[TimeZone]			[varchar](50) NOT NULL,
	[RepairAmount]		[decimal](17, 4) NULL,
	[RapidLog]			[bit] NULL,
	[Division]			[varchar](50) NOT NULL,
	[CardPolicy2]		[varchar](50) NULL)

DELETE	FPT_ReceivedDetails
WHERE	BatchId = @BatchId

INSERT INTO @tblFuel
EXECUTE USP_FPT_EFSTrx @BatchId, @Policy, @FileName

--SELECT	*
--FROM	@tblFuel
--WHERE	VendorId IN (SELECT VendorId FROM LENSASQL001.GPCustom.dbo.VendorMaster WHERE Company = 'HMIS')

DECLARE curFuelData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	@tblFuel

OPEN curFuelData 
FETCH FROM curFuelData INTO @CarrierId, @CardPolicy, @ReportedCarrier, @TrxId, @CardNumber, @tmpBatchId, @VendorId, @TransDate, @FuelAmount, @AdditiveAmount,
							@OilAmount, @SalesTax, @Fees, @Discount, @Cash, @CashFee, @InvoiceTotal, @Balance, @TotalFuel, @Verification,
							@Processed, @Card, @Unit, @Location, @Gallons, @AuthCode, @TSNum, @DriverName, @Tax, @MiscAmt, @RefrAmt, @TransTime,
							@TimeZone, @RepairAmount, @RapidLog, @Division, @CardPolicy2
BEGIN TRANSACTION

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF @VendorId = '1281'
		SET @VendorId = '52230'

	IF @VendorId = '1640'
		SET @VendorId = '60312'

	IF @VendorId = '1733'
		SET @VendorId = '51703'

	IF @VendorId = '1773'
		SET @VendorId = '53341'

	IF @VendorId = '1776'
		SET @VendorId = '61779'

	IF @VendorId = '1778'
		SET @VendorId = '61793'

	IF @VendorId = '1790'
		SET @VendorId = '61811'

	IF @VendorId = '1793B'
		SET @VendorId = '61867'

	IF @VendorId = '1812'
		SET @VendorId = '61924'

	IF @VendorId = '1814'
		SET @VendorId = '61864'

	IF @VendorId = '1820'
		SET @VendorId = '61956'

	IF @VendorId = '1822'
		SET @VendorId = '60398'

	IF @VendorId = '1835'
		SET @VendorId = '62037'

	IF @VendorId = '1848'
		SET @VendorId = '62092'

	IF @VendorId = '1850'
		SET @VendorId = '61885'

	IF @VendorId = '1855'
		SET @VendorId = '60775'

	IF @VendorId = '1856'
		SET @VendorId = '62122'

	IF @VendorId = '1858'
		SET @VendorId = '62072'

	IF @VendorId = '1859'
		SET @VendorId = '62059'

	IF @VendorId = '1860'
		SET @VendorId = '61650'

	IF @VendorId = '1861'
		SET @VendorId = '62137'

	IF @VendorId = '1864'
		SET @VendorId = '62141'

	IF @VendorId = '1866'
		SET @VendorId = '62147'

	IF @VendorId = '91576'
		SET @VendorId = '61991'

	IF @VendorId = '91595'
		SET @VendorId = '62100'

	IF @VendorId = '91598'
		SET @VendorId = '62007'

	IF @VendorId = '91599'
		SET @VendorId = '62107'

	IF @VendorId = '91601'
		SET @VendorId = '62085'

	IF @VendorId = '91605'
		SET @VendorId = '61894A'

	IF @VendorId = '91606'
		SET @VendorId = '62138'

	IF @VendorId = '91608'
		SET @VendorId = '62145'

	IF EXISTS(SELECT VendorId FROM LENSASQL001.GPCustom.dbo.VendorMaster WHERE Company = 'HMIS' AND VendorId = @VendorId)
	BEGIN
		EXECUTE USP_FPT_ReceivedDetails @BatchId,  @VendorId, @TransDate, @FuelAmount, @AdditiveAmount,
								@OilAmount, @SalesTax, @Fees, @Discount, @Cash, @CashFee, @InvoiceTotal, @Balance, @TotalFuel, @Verification,
								@Processed, @Card, @Unit, @Location, @Gallons, @AuthCode, @TSNum, @DriverName, @Tax, @MiscAmt, @RefrAmt, @TransTime,
								@TimeZone, @RepairAmount, @RapidLog, @Division
	END

	FETCH FROM curFuelData INTO @CarrierId, @CardPolicy, @ReportedCarrier, @TrxId, @CardNumber, @tmpBatchId, @VendorId, @TransDate, @FuelAmount, @AdditiveAmount,
								@OilAmount, @SalesTax, @Fees, @Discount, @Cash, @CashFee, @InvoiceTotal, @Balance, @TotalFuel, @Verification,
								@Processed, @Card, @Unit, @Location, @Gallons, @AuthCode, @TSNum, @DriverName, @Tax, @MiscAmt, @RefrAmt, @TransTime,
								@TimeZone, @RepairAmount, @RapidLog, @Division, @CardPolicy2
END

CLOSE curFuelData
DEALLOCATE curFuelData

IF @@ERROR = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION