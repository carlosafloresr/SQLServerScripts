DECLARE	@Query				Varchar(MAX),
		@Cmpy_No			int,
		@Company			varchar(5),
		@ProNumber			varchar(20),
		@InvoiceDate		date,
		@InvType			char(1),
		@Division			varchar(2),
		@InvoiceTotal		numeric(16,2),
		@VendorPay			numeric(16,2),
		@CustomerNo			varchar(6),
		@OrderNo			int,
		@Origin_LPCode		varchar(6),
		@Destination_LPCode varchar(6),
		@TrailerNo			varchar(10),
		@TrailerSize		varchar(5),
		@TrailerOwner		varchar(6),
		@ChassisNo			varchar(10),
		@ChassisOwner		varchar(6),
		@ReleaseNo			varchar(20),
		@ChassisSupply		varchar(1),
		@ChassisChoice		varchar(1),
		@UPC				varchar(6),
		@ChassisOut			date,
		@ChassisIn			date,
		@ChassisDays		int,
		@Sale				numeric(16,2),
		@Cost				numeric(16,2),
		@Profit				numeric(16,2),
		@PercProfit			numeric(28,2),
		@ChzFlags			varchar(10),
		@ChzVnAmt			numeric(16,2)

SET @Query = N'SELECT INV.Cmpy_No,
	INV.Code AS ProNumber,
	INV.InvDate AS InvoiceDate,
	INV.Type AS InvType,
	INV.Div_Code AS Division,
	INV.Total AS InvoiceTotal,
	INV.VendPay AS VendorPay,
	INV.Bt_Code AS CustomerNo,
	ORD.No AS OrderNo,
	INV.Shlp_Code AS Origin_LPCode,
	CASE WHEN ORD.TltLp_Code = '''' THEN INV.CnLp_Code ELSE ORD.TltLp_Code END AS Destination_LPCode,
	ORD.BillTl_Code AS TrailerNo,
	ORD.BillTl_Size AS TrailerSize,
	ORD.BillTl_EqOCode AS TrailerOwner,
	ORD.BillCh_Code AS ChassisNo,
	ORD.BillCh_EqOCode AS ChassisOwner,
	ORD.BillCh_RelNum AS ReleaseNo,
	ORD.ChzSupply AS ChassisSupply,
	ORD.ChzChoice AS ChassisChoice,
	ORD.BillCh_UpcEqOCode AS UPC,
	ORD.ChzStartDt AS ChassisOut,
	ORD.ChzStopDt AS ChassisIn,
	ORD.ChzUsageDays AS ChassisDays,
	ORD.ChzAmt AS Sale,
	ORD.ChzToTvn AS Cost,
	ORD.ChzProfit AS Profit,
	CASE WHEN ORD.ChzAmt <> 0 THEN ROUND((ORD.ChzProfit / ORD.ChzAmt) * 100, 2) ELSE 0 END AS PercProfit,
	ORD.ChzFlags,
	ORD.ChzVnAmt
FROM 	TRK.Invoice INV
	INNER JOIN TRK.Order ORD ON INV.Cmpy_No = ORD.Cmpy_No AND INV.Or_No = ORD.No
WHERE	INV.InvDate BETWEEN ''01/01/2014'' AND ''06/05/2014''
		AND ORD.ChzToTvn <> 0
		AND INV.Type = ''A''
ORDER BY
	INV.Cmpy_No,
	INV.InvDate,
	INV.Code'

EXECUTE GPCustom.dbo.USP_QuerySWS @Query, '##tmpSWS'

DECLARE Transactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Cmpy_No,
		CompanyId AS Company,
		ProNumber,
		InvoiceDate,
		InvType,
		Division,
		InvoiceTotal,
		VendorPay,
		CustomerNo,
		OrderNo,
		Origin_LPCode,
		Destination_LPCode,
		TrailerNo,
		TrailerSize,
		TrailerOwner,
		ChassisNo,
		ChassisOwner,
		ReleaseNo,
		ChassisSupply,
		ChassisChoice,
		UPC,
		ChassisOut,
		ChassisIn,
		ChassisDays,
		Sale,
		Cost,
		Profit,
		PercProfit,
		ChzFlags,
		ChzVnAmt
FROM	##tmpSWS
		INNER JOIN GPCustom.dbo.Companies ON CASE WHEN Cmpy_No > 9 THEN 10 ELSE Cmpy_No END = Companies.CompanyNumber

/*
SELECT	*
FROM	SWS_ScrubData
WHERE	Company = 'IMC'
		AND Division = '09'

-- truncate table SWS_ScrubData
*/

OPEN Transactions 
FETCH FROM Transactions INTO @Cmpy_No, @Company, @ProNumber, @InvoiceDate, @InvType, @Division, @InvoiceTotal, @VendorPay,
						@CustomerNo, @OrderNo, @Origin_LPCode, @Destination_LPCode, @TrailerNo, @TrailerSize, @TrailerOwner, @ChassisNo,
						@ChassisOwner, @ReleaseNo, @ChassisSupply, @ChassisChoice, @UPC, @ChassisOut, @ChassisIn, @ChassisDays,
						@Sale, @Cost, @Profit, @PercProfit, @ChzFlags, @ChzVnAmt

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF NOT EXISTS(SELECT ProNumber FROM SWS_ScrubData WHERE Company = @Company AND OrderNo = @OrderNo AND ProNumber = @ProNumber)
	BEGIN
		INSERT INTO [dbo].[SWS_ScrubData]
			   ([Cmpy_No],
				[Company],
				[ProNumber],
				[InvoiceDate],
				[InvType],
				[Division],
				[InvoiceTotal],
				[VendorPay],
				[CustomerNo],
				[OrderNo],
				[Origin_LPCode],
				[Destination_LPCode],
				[TrailerNo],
				[TrailerSize],
				[TrailerOwner],
				[ChassisNo],
				[ChassisOwner],
				[ReleaseNo],
				[ChassisSupply],
				[ChassisChoice],
				[UPC],
				[ChassisOut],
				[ChassisIn],
				[ChassisDays],
				[Sale],
				[Cost],
				[Profit],
				[PercProfit],
				[ChzFlags],
				[ChzVnAmt])
		 VALUES
			   (@Cmpy_No,
				@Company,
				@ProNumber,
				@InvoiceDate,
				@InvType,
				@Division,
				@InvoiceTotal,
				@VendorPay,
				@CustomerNo,
				@OrderNo,
				@Origin_LPCode,
				@Destination_LPCode,
				@TrailerNo,
				@TrailerSize,
				@TrailerOwner,
				@ChassisNo,
				@ChassisOwner,
				@ReleaseNo,
				@ChassisSupply,
				@ChassisChoice,
				@UPC,
				@ChassisOut,
				@ChassisIn,
				@ChassisDays,
				@Sale,
				@Cost,
				@Profit,
				@PercProfit,
				@ChzFlags,
				@ChzVnAmt)
	END
	ELSE
	BEGIN
		UPDATE	SWS_ScrubData
		SET		[ChassisOut]	= @ChassisOut,
				[ChassisIn]		= @ChassisIn,
				[ChassisDays]	= @ChassisDays,
				[Sale]			= @Sale,
				[Cost]			= @Cost,
				[Profit]		= @Profit,
				[PercProfit]	= @PercProfit,
				[ChzFlags]		= @ChzFlags,
				[ChzVnAmt]		= @ChzVnAmt,
				[Changed]		= 1
		WHERE	[Company]		= @Company 
				AND [OrderNo]	= @OrderNo 
				AND [ProNumber] = @ProNumber
				AND ([Cost] <> @Cost
				OR [Sale] <> @Sale
				OR [ChzVnAmt] <> @ChzVnAmt)
	END

	FETCH FROM Transactions INTO @Cmpy_No, @Company, @ProNumber, @InvoiceDate, @InvType, @Division, @InvoiceTotal, @VendorPay,
							@CustomerNo, @OrderNo, @Origin_LPCode, @Destination_LPCode, @TrailerNo, @TrailerSize, @TrailerOwner, @ChassisNo,
							@ChassisOwner, @ReleaseNo, @ChassisSupply, @ChassisChoice, @UPC, @ChassisOut, @ChassisIn, @ChassisDays,
							@Sale, @Cost, @Profit, @PercProfit, @ChzFlags, @ChzVnAmt
END

CLOSE Transactions
DEALLOCATE Transactions

DROP TABLE ##tmpSWS