USE [DepotSystemsViews]
GO
/****** Object:  StoredProcedure [dbo].[USP_InvoiceDetails]    Script Date: 11/10/2022 1:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_InvoiceDetails '1851956', 1
EXECUTE USP_InvoiceDetails '1760419', 1
EXECUTE USP_InvoiceDetails '1834217', 1
*/
ALTER PROCEDURE [dbo].[USP_InvoiceDetails]
		@Invoice		Varchar(12),
		@ForceCreation	Bit = 0,
		@HideActivity	Bit = 0
AS
SET NOCOUNT ON

DECLARE	@EIRI			Varchar(12) = '0',
		@ReturnValue	Int = 0

IF EXISTS(SELECT InvoiceNumber FROM MRInvoices_AP WHERE InvoiceNumber = @Invoice AND ModifiedOn IS Null AND Accepted = 0)
	OR NOT EXISTS(SELECT InvoiceNumber FROM MRInvoices_AP WHERE InvoiceNumber = @Invoice) 
	OR @ForceCreation = 1
BEGIN
	DECLARE @tblEquip	Table (Equipment Varchar(15))

	DECLARE @tblFleet	Table (Equipment Varchar(15))

	DECLARE @tblDepots	Table (
			DepotLoc	Varchar(20),
			GLAccount	Varchar(15))

	DECLARE @tblParts	Table (
			unique_key	Int,
			PartNumber	Varchar(25),
			Description	Varchar(100),
			BIN			Varchar(20),
			Category	Varchar(15),
			CDEX_COMPO	Varchar(10))

	DECLARE @tblSWS		Table (
			Division	Char(2),
			Pro			Varchar(12),
			Companion	Varchar(15),
			DriverId	Varchar(12),
			DriverType	Char(1),
			DriverDiv	Char(2),
			MoveDate	Datetime,
			OrderNum	Int Null)

	DECLARE @tblDepot	Table (
			EIRI		Varchar(12),
			Companion	Varchar(12),
			ErrorCode	Varchar(12),
			DriverId	Varchar(12),
			ProNumber	Varchar(15),
			IngateDate	Datetime,
			Division	Char(2) Null,
			DriverType	Char(1) Null,
			OrderNum	Int Null)

	DECLARE @Query		Varchar(MAX),
			@Chassis	Varchar(15),
			@Container	Varchar(15),
			@Companion	Varchar(15) = '',
			@RepDate	Datetime,
			@RepDate2	Datetime,
			@ProNumber	Varchar(15) = '',
			@DriverId	Varchar(12) = '',
			@DriverType	Varchar(20) = 'N/A',
			@DriverDiv	Char(2) = '',
			@EqType		Varchar(20),
			@EqOwner	Varchar(20),
			@CompanyEq	Bit = 0,
			@UserId		Varchar(25) = 'Auto-Generate',
			@VendorId	Varchar(15) = '1000331',
			@VendorName	Varchar(100),
			@Customer	Varchar(12),
			@IsDepot	Bit = 0,
			@DepotError	Varchar(2) = '',
			@DEP_LOC	Varchar(15),
			@TotalAmnt	Numeric(10,2) = 0,
			@TmpDesc	Varchar(100) = '',
			@PartsTax	Numeric(10,2) = 0,
			@LaborTax	Numeric(10,2) = 0,
			@TotParts	Numeric(10,2) = 0,
			@TotLabor	Numeric(10,2) = 0,
			@InvParts	Numeric(10,2) = 0,
			@InvLabor	Numeric(10,2) = 0,
			@FleetEq	Varchar(15) = '',
			@OrderNum	Int,
			@tmpProNum	Varchar(15) = '',
			@OverRoad	bit = 0,
			@tmpString	Varchar(50) = '',
			@DistId		Int = 0,
			@DistAcct	Varchar(15) = '',
			@DistDesc	Varchar(30) = '',
			@DistAmnt	Numeric(10,2) = 0.0,
			@DistDept	Char(2) = '',
			@PopupId	int = 0,
			@EffDate	Date = GETDATE(),
			@DrvType	Char(1) = '',
			@RepairCode	Varchar(10) = '',
			@RecordId	Int = 0,
			@Monitoring	Bit = 0,
			@TempVaue	Varchar(10) = ''

	DECLARE	@tblGPRecs	Table (
			Company		Varchar(5),
			GLAccount	Varchar(15),
			Descript	Varchar(30),
			Debit		Numeric(10,2),
			Credit		Numeric(10,2),
			RepCode		Varchar(10))

	DECLARE	@tblDS5Data	Table (
			InvoiceNumber	varchar(25) NULL,
			ACCT_NO			varchar(10) NULL,
			DEPOT_LOC		varchar(15) NULL,
			invoice_date	datetime NULL,
			repair_date		datetime NULL,
			Estimate_alpha	varchar(25) NULL,
			INV_TYPE		varchar(1) NULL,
			INV_TOTAL		numeric(12, 3) NULL,
			UNIT_TYPE		varchar(9) NOT NULL,
			EqOwner			varchar(20) NULL,
			CONTAINER		varchar(15) NULL,
			CHASSIS			varchar(15) NULL,
			GENSET_NO		varchar(15) NULL,
			ProNumber		varchar(15) NULL,
			DriverId		varchar(12) NULL,
			DriverType		varchar(20) NULL,
			DriverDiv		char(2) NULL,
			SIZE			varchar(10) NULL,
			LABOR_HOUR		numeric(7, 2) NULL,
			LABOR			numeric(12, 3) NULL,
			PARTS			numeric(12, 3) NULL,
			SALE_TAX		numeric(12, 3) NULL,
			CDXLRATE		numeric(8, 2) NULL,
			BIN				varchar(20) NULL,
			Category		varchar(15) NULL,
			PART_NO			varchar(30) NULL,
			DESCRIPT		varchar(75) NULL,
			Component		varchar(75) NULL,
			PART_TOTAL		numeric(12, 3) NULL,
			CDEX_PARTY		varchar(2) NULL,
			ITEMTOT			numeric(12, 3) NULL,
			CDEX_DAMAG		varchar(2) NULL,
			Damage			varchar(75) NULL,
			CDEX_REPAI		varchar(2) NULL,
			Repair			varchar(75) NULL,
			CDEX_LOCAT		varchar(4) NULL,
			RLABOR			numeric(12, 3) NULL,
			RLABOR_QTY		numeric(12, 3) NULL,
			INV_MECH		varchar(10) NULL,
			REAL_COST		numeric(7, 2) NULL,
			unique_key		bigint NOT NULL)

	INSERT INTO @tblDepots (DepotLoc, GLAccount) VALUES ('MEMPHIS', '3-09')
	INSERT INTO @tblDepots (DepotLoc, GLAccount) VALUES ('DALLAS', '3-03')
	INSERT INTO @tblDepots (DepotLoc, GLAccount) VALUES ('FT.WORTH', '3-19')
	INSERT INTO @tblDepots (DepotLoc, GLAccount) VALUES ('NASHVILLE', '3-07')
	INSERT INTO @tblDepots (DepotLoc, GLAccount) VALUES ('HOUSTON', '3-08')

	SELECT	@VendorName = UPPER(RTRIM(VendName))
	FROM	PRISQL01P.IMC.dbo.PM00200 
	WHERE	VENDORID = @VendorId

	SELECT	@Chassis	= RTRIM(Chassis),
			@Container	= RTRIM(Container),
			@RepDate	= Repair_Date,
			@EqType		= UNIT_TYPE,
			@Customer	= RTRIM(ACCT_NO),
			@DEP_LOC	= DEPOT_LOC,
			@TotalAmnt	= INV_TOTAL,
			@PartsTax	= SALE_TAX1,
			@LaborTax	= SALE_TAX2,
			@InvParts	= PARTS,
			@InvLabor	= LABOR
	FROM	DepotSystemsIMCMNR.dbo.Invoices
	WHERE	Invoice_alpha = @Invoice
			AND row_status = 'N'

	IF EXISTS(SELECT SAL.PART_NO FROM DepotSystemsIMCMNR.dbo.Sale SAL, DepotSystemsIMCMNR.dbo.Invoices HDR WHERE HDR.unique_key = SAL.invoices_key AND HDR.Invoice_alpha = @Invoice AND SAL.row_status = 'N' AND SAL.PART_NO = 'SC')
		SET @OverRoad = 1
	
	SET @RepDate2 = CAST(CONVERT(Char(10), @RepDate, 101) + ' 23:59:00' AS Datetime)

	IF LEN(@Chassis) IN (10,11) AND dbo.AT(' ', RTRIM(@Chassis), 1) = 0
	BEGIN
		IF ISNUMERIC(LEFT(@Chassis, 4)) = 0 AND ISNUMERIC(RIGHT(@Chassis, IIF(LEN(@Chassis) = 11, 7, 6))) = 1
			SET @Chassis = LEFT(@Chassis, 10)
	END
	ELSE
	BEGIN
		IF dbo.AT('DIESEL T', @Chassis, 1) > 0
			SET @Chassis = 'DIESEL TRUCK'

		IF dbo.AT('TRUCK-', @Chassis, 1) > 0
			SET @IsDepot = 1
		ELSE
			IF PATINDEX('% %', @Chassis) > 0
			BEGIN
				print @Chassis
				SET @FleetEq = RIGHT(@Chassis, LEN(@Chassis) - PATINDEX('% %', @Chassis))
			
				IF @FleetEq <> ''
					SET @IsDepot = 1
					print @FleetEq
			END
	END

	IF @OverRoad = 0
	BEGIN
		INSERT INTO @tblDepot -- DEPOT CHECK
		EXECUTE USP_SWS_DataInquiry 1, @Chassis, '', @RepDate

		SET @tmpProNum = ISNULL((SELECT ProNumber FROM @tblDepot), '')

		IF ((SELECT COUNT(*) FROM @tblDepot) = 0 AND @Container <> '') OR @tmpProNum NOT LIKE '%-%' OR @tmpProNum = '' --IN ('TRANSFER','UNKNOWN')
		BEGIN
			IF (SELECT COUNT(*) FROM @tblDepot) = 0 OR @tmpProNum = ''
			BEGIN
				DELETE @tblDepot

				INSERT INTO @tblDepot -- DEPOT CHECK
				EXECUTE USP_SWS_DataInquiry 1, @Chassis, '', @RepDate2
			END
			ELSE
				DELETE @tblDepot

			IF (SELECT COUNT(*) FROM @tblDepot) = 0
			BEGIN
				DELETE @tblDepot

				SET @TempVaue = LEFT(@Container, 10)

				INSERT INTO @tblDepot
				EXECUTE USP_SWS_DataInquiry 1, '', @TempVaue, @RepDate
			END

			IF (SELECT COUNT(*) FROM @tblDepot) > 0
			BEGIN
				SET @ProNumber = ISNULL((SELECT TOP 1 ProNumber FROM @tblDepot WHERE ProNumber IN ('TRANSFER','UNKNOWN')),'')
			
				IF (SELECT TOP 1 LEFT(Companion, 6) FROM @tblDepot) = LEFT(@Chassis, 6)
				BEGIN
					SET @Chassis = (SELECT TOP 1 Companion FROM @tblDepot)
					SET @IsDepot = IIF(@ProNumber = '', 1, 0)
				END
			END
		END
	
		IF (SELECT COUNT(*) FROM @tblDepot) > 0
		BEGIN
			SELECT	@Companion	= Companion, 
					@EIRI		= EIRI,
					@DepotError	= ErrorCode,
					@DriverId	= DriverId,
					@DriverDiv	= ISNULL(Division,''),
					@DriverType	= CASE WHEN DriverType = 'C' THEN 'Company Driver' ELSE 'Owner Opearator' END,
					@ProNumber	= IIF(ProNumber IN ('TRANSFER','UNKNOWN'), '', RTRIM(ProNumber)),
					@OrderNum	= IIF(OrderNum > 0, OrderNum, Null)
			FROM	@tblDepot
		
			IF LEN(@Companion) < 5 AND @Container = ''
			BEGIN
				SET @Companion = ''
				SET @Container = ''
			END
		END
	
		IF @Companion <> '' AND (@Chassis = '' OR @Container = '')
		BEGIN
			IF @Chassis <> ''
				SET @Container = @Companion
			ELSE
				SET @Chassis = @Companion
		END

		IF @Customer IN ('MEMIDE','NASIDE','DALIMC','FTWIMC')
			SET @IsDepot = 1
	END

	IF @IsDepot = 0 OR @OverRoad = 1
	BEGIN
		SET @TempVaue = LEFT(@Chassis, 10)

		INSERT INTO @tblSWS
		EXECUTE USP_SWS_DataInquiry 0, @Chassis, '', @RepDate, @OrderNum

		IF (SELECT COUNT(*) FROM @tblSWS) = 0
		BEGIN
			INSERT INTO @tblSWS
			EXECUTE USP_SWS_DataInquiry 0, @Chassis, @Container, @RepDate2, @OrderNum
		END
		
		IF (SELECT COUNT(*) FROM @tblSWS) = 0
		BEGIN
			PRINT 'NOT IN SWS'
		END
		ELSE
		BEGIN
			SELECT	@Companion	= IIF(@Companion = '', Companion, @Companion),
					@ProNumber	= CAST(CAST(Division AS Int) AS Varchar) + '-' + RTRIM(Pro),
					@DriverId	= IIF(ISNULL(@DriverId,'') = '', DriverId, @DriverId),
					@DriverType	= CASE WHEN DriverType = 'C' THEN 'Company Driver' ELSE 'Owner Opearator' END,
					@DriverDiv	= ISNULL(DriverDiv,'')
			FROM	@tblSWS
		END
	END

	INSERT INTO @tblParts
	SELECT	unique_key,
			PART_NO,
			DESCRIPT,
			BIN,
			CASE WHEN DESCRIPT IN ('FUEL','FUEL SURCHARGE','SERVICE CALL AND FUEL SURCHARGE') THEN 'FUEL'
			WHEN DESCRIPT LIKE '%DECAL%' THEN 'DECAL'
			WHEN DESCRIPT = 'MONITORING' THEN 'MONITORING'
			WHEN PART_NO IN ('TI','GPS','IDC') THEN 'PEOPLENET'
			WHEN BIN = 'TIRE' THEN 'TIRE'
			WHEN BIN IN ('TUB','TUBE') THEN 'TIRE-REPA'
			WHEN PART_NO IN ('FMCSA','FMCSAK','FMCSAMN','FMCSAUP') THEN 'FHWA/FMCSA'
			WHEN PART_NO = 'NP' OR @Chassis IN (SELECT [Value] FROM BuildingRepairConcepts) THEN 'M&R_BUILDING'
			WHEN BIN IN ('AP01','G01','P01','P01C','P01U','TF','TFAH','PS01','TFM') THEN 'DRY-RUN'
			WHEN BIN = 'REEFER' THEN 'REEFER'
			WHEN BIN = '' THEN 'MISC'
			ELSE 'MECHANICAL' END AS Category,
			CDEX_COMPO
	FROM	DepotSystemsIMCMNR.dbo.DeaParts 
	WHERE	row_status = 'N'
	ORDER BY BIN, PART_NO
	
	IF @DriverDiv IN ('23','29','46')
		SET @DriverDiv = '09'

	IF @Companion <> '' AND (@Chassis = '' OR @Container = '')
		BEGIN
			IF @Chassis <> ''
				SET @Container = @Companion
			ELSE
				SET @Chassis = @Companion
		END

	IF (@DriverId = '999' AND @DriverDiv = '') OR @DriverDiv = ''
		SET @DriverDiv = (SELECT RIGHT(GLAccount, 2) FROM @tblDepots WHERE DepotLoc = @DEP_LOC)

	IF @DriverDiv = ''
		SET @DriverDiv = 'NF'

	IF @IsDepot = 1
		SET @ProNumber = ''

	IF @FleetEq = ''
	BEGIN
		SET @Query = 'SELECT Code FROM TRK.Trailer WHERE Code = ''' + @Chassis + ''''
	
		INSERT INTO @tblEquip
		EXECUTE USP_QuerySWS @Query
	END
	ELSE
	BEGIN
		SET @Query = 'SELECT Code FROM TRK.Tractor WHERE Code = ''' + @FleetEq + ''''
	
		INSERT INTO @tblFleet
		EXECUTE USP_QuerySWS @Query
	END
	
	IF @Chassis LIKE '% TRUCK%'
		SET @EqOwner = 'YARD'
	ELSE
	BEGIN
		IF (SELECT COUNT(*) FROM @tblFleet) > 0 OR (LEFT(@Chassis, 6) = 'TRUCK ' AND dbo.AT('IMC', @Customer, 1) > 0)
			SET @EqOwner = 'FLEET'
		ELSE
		BEGIN
			IF (SELECT COUNT(*) FROM @tblEquip) > 0 OR @Chassis IN (SELECT [Value] FROM BuildingRepairConcepts) OR dbo.AT('IMC', @Customer, 1) > 0
				SET @EqOwner = 'COMPANY'
			ELSE
				SET @EqOwner = 'CUSTOMER'
		END
	END

	IF @HideActivity = 0
	BEGIN
		PRINT 'Over the Road: ' + IIF(@OverRoad = 1, 'YES', 'NO')
		PRINT '     Customer: ' + @Customer
		PRINT '      Chassis: ' + @Chassis
		PRINT '    Container: ' + @Container
		PRINT '    Eq. Owner: ' + @EqOwner
		PRINT '     Is Depot: ' + IIF(@IsDepot = 1, 'YES','NO')
		PRINT '         EIRI: ' + ISNULL(@EIRI,'')
		PRINT '   Pro Number: ' + ISNULL(@ProNumber,'')
		PRINT '    Driver Id: ' + ISNULL(@DriverId,'')
		PRINT '     Division: ' + @DriverDiv
		PRINT ' Fleet Number: ' + ISNULL(@FleetEq,'')
	END

	INSERT INTO @tblDS5Data
	SELECT	DISTINCT HDR.Invoice_alpha AS InvoiceNumber,
			HDR.ACCT_NO,
			HDR.DEPOT_LOC,
			HDR.invoice_date,
			HDR.repair_date,
			HDR.Estimate_alpha,
			HDR.INV_TYPE,
			HDR.INV_TOTAL,
			CASE HDR.UNIT_TYPE 
				WHEN 'R' THEN 'CHASSIS' 
				WHEN 'C' THEN 'CONTAINER'
				WHEN 'A' THEN 'GENSET'
				WHEN 'F' THEN 'REEFER'
				ELSE 'UNKNOWN'
			END AS UNIT_TYPE,
			@EqOwner AS EqOwner,
			@Container AS CONTAINER,
			@Chassis AS CHASSIS,
			HDR.GENSET_NO,
			@ProNumber AS ProNumber,
			@DriverId AS DriverId,
			@DriverType	AS DriverType,
			@DriverDiv AS DriverDiv,
			HDR.SIZE,
			HDR.LABOR_HOUR,
			HDR.LABOR,
			HDR.PARTS,
			HDR.SALE_TAX,
			HDR.CDXLRATE,
			DPA.BIN,
			CASE WHEN DPA.Category = 'TIRE' AND CDEX_REPAI = 'RP' THEN 'TIRE-REPL'
			WHEN DPA.Category = 'TIRE' AND CDEX_REPAI <> 'RP' THEN 'TIRE-REPA'
			ELSE DPA.Category END AS Category,
			SAL.PART_NO,
			SAL.DESCRIPT,
			CMP.descriptio AS Component,
			SAL.PART_TOTAL,
			SAL.CDEX_PARTY,
			SAL.ITEMTOT,
			SAL.CDEX_DAMAG,
			DAM.descriptio AS Damage,
			SAL.CDEX_REPAI,
			REP.descriptio AS Repair,
			SAL.CDEX_LOCAT,
			SAL.RLABOR,
			SAL.RLABOR_QTY,
			SAL.INV_MECH,
			SAL.REAL_COST,
			HDR.unique_key
	FROM	DepotSystemsIMCMNR.dbo.Invoices HDR
			LEFT JOIN DepotSystemsIMCMNR.dbo.Sale SAL ON HDR.unique_key = SAL.invoices_key AND SAL.row_status = 'N'
			LEFT JOIN @tblParts DPA ON SAL.deaparts_key = DPA.unique_key OR SAL.PART_NO = DPA.PartNumber
			LEFT JOIN DepotSystemsIMCMNR.dbo.damage_list DAM ON SAL.CDEX_DAMAG = DAM.code AND DAM.edi_type = 'CEDEX'
			LEFT JOIN DepotSystemsIMCMNR.dbo.repair_list REP ON SAL.CDEX_REPAI = REP.code AND REP.edi_type = 'CEDEX'
			LEFT JOIN DepotSystemsIMCMNR.dbo.component_list CMP ON DPA.CDEX_COMPO = CMP.code AND CMP.edi_type = 'CEDEX' AND CMP.unit_type = 'CHASSIS'
	WHERE	HDR.Invoice_alpha = @Invoice
			AND HDR.row_status = 'N'
			AND SAL.ITEMTOT <> 0
			AND HDR.invoice_date >= DATEADD(dd, -30, GETDATE())

	DECLARE	@DEPOT_LOC		Varchar(15),
			@invoice_date	Date,
			@INV_TOTAL		Numeric(10,2),
			@SALE_TAX		Numeric(10,2),
			@Category		Varchar(15),
			@UNIT_TYPE		Varchar(15),
			@GENSET_NO		Varchar(15),
			@ITEMTOT		Numeric(10,2),
			@PartLocation	Varchar(10),
			@GLAccount		Varchar(15),
			@GLDescript		Varchar(40) = '',
			@tmpText		Varchar(30) = '',
			@CatCounter		Smallint = 0,
			@TaxTotal		Numeric(10,3) = 0.000,
			@TaxItem		Numeric(10,3) = 0.000,
			@Counter		Smallint = 0

	SET @CatCounter = (SELECT COUNT(*) FROM (SELECT DISTINCT Category, IIF(Category LIKE 'TIRE%', CDEX_LOCAT, '') AS PartLocation FROM @tblDS5Data) DATA)

	DECLARE curRepairDetails CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	DEPOT_LOC,
			invoice_date,
			INV_TOTAL,
			SALE_TAX,
			Category,
			UNIT_TYPE,
			EqOwner,
			CONTAINER,
			CHASSIS,
			GENSET_NO,
			ProNumber,
			DriverId,
			DriverType,
			DriverDiv,
			IIF(Category LIKE 'TIRE%', CDEX_LOCAT, '') AS PartLocation,
			SUM(ITEMTOT) AS ITEMTOT,
			SUM(PART_TOTAL) AS TOTPARTS,
			SUM(RLABOR) AS TOTLABOT
	FROM	@tblDS5Data
	GROUP BY
			DEPOT_LOC,
			invoice_date,
			INV_TOTAL,
			SALE_TAX,
			Category,
			UNIT_TYPE,
			EqOwner,
			CONTAINER,
			CHASSIS,
			GENSET_NO,
			ProNumber,
			DriverId,
			DriverType,
			DriverDiv,
			IIF(Category LIKE 'TIRE%', CDEX_LOCAT, '')
	HAVING	SUM(ITEMTOT) <> 0

	IF @HideActivity = 0
	BEGIN
		SELECT	DEPOT_LOC,
				invoice_date,
				INV_TOTAL,
				SALE_TAX,
				Category,
				UNIT_TYPE,
				EqOwner,
				CONTAINER,
				CHASSIS,
				GENSET_NO,
				ProNumber,
				DriverId,
				DriverType,
				DriverDiv,
				IIF(Category LIKE 'TIRE%', CDEX_LOCAT, '') AS PartLocation,
				SUM(ITEMTOT) AS ITEMTOT,
				SUM(PART_TOTAL) AS TOTPARTS,
				SUM(RLABOR) AS TOTLABOT
		FROM	@tblDS5Data
		GROUP BY
				DEPOT_LOC,
				invoice_date,
				INV_TOTAL,
				SALE_TAX,
				Category,
				UNIT_TYPE,
				EqOwner,
				CONTAINER,
				CHASSIS,
				GENSET_NO,
				ProNumber,
				DriverId,
				DriverType,
				DriverDiv,
				IIF(Category LIKE 'TIRE%', CDEX_LOCAT, '')

		SELECT * FROM @tblDS5Data
	END

	OPEN curRepairDetails 
	FETCH FROM curRepairDetails INTO @DEPOT_LOC, @invoice_date, @INV_TOTAL, @SALE_TAX, @Category, @UNIT_TYPE,
				@EqOwner, @CONTAINER, @CHASSIS, @GENSET_NO, @ProNumber, @DriverId, @DriverType, @DriverDiv, 
				@PartLocation, @ITEMTOT, @TotParts, @TotLabor

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF @Chassis IN (SELECT [Value] FROM BuildingRepairConcepts)
			SET @Category = 'M&R_BUILDING'

		IF @HideActivity = 0
			PRINT '     Category: ' + @Category

		SET @Counter	= @Counter + 1
		SET @TaxItem	= 0

		IF @LaborTax <> 0
			SET @TaxItem = ROUND((@TotLabor / @InvLabor) * @LaborTax, 2)

		IF @PartsTax <> 0
			SET @TaxItem = @TaxItem + ROUND((@TotParts / @InvParts) * @PartsTax, 2)

		SET @TaxTotal	= @TaxTotal + @TaxItem
		
		IF @Counter = @CatCounter AND @TaxTotal <> @SALE_TAX
		BEGIN
			SET @TaxItem = @TaxItem - (@TaxTotal - @SALE_TAX)
		END

		SET @RepairCode = (SELECT TOP 1 CDEX_REPAI FROM @tblDS5Data WHERE Category LIKE @Category + '%' ORDER BY ITEMTOT DESC)

		BEGIN TRY	
			IF @Category LIKE 'TIRE%'
			BEGIN
				IF @IsDepot = 0
				BEGIN
					SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + SUBSTRING(CDEX_LOCAT, 2, 10) + '|' + CDEX_DAMAG FROM @tblDS5Data WHERE Category LIKE 'TIRE%' AND CDEX_LOCAT = @PartLocation  ORDER BY ITEMTOT DESC)

					IF @ProNumber = ''
					BEGIN
						IF @EqOwner = 'COMPANY'
							SET @GLDescript = @DriverId + '|' + @tmpText + '|' + @Chassis
						ELSE
							SET @GLDescript = LEFT('|' + IIF(LEFT(@DriverType,1) = 'C', LEFT(@DriverType,1) + '|', '') + @DriverId + '|' + @tmpText, 30)
					END
					ELSE
						IF ISNULL(@ProNumber, '') <> ''
						BEGIN
							IF @EqOwner = 'COMPANY'
								SET @GLDescript = @DriverId + '|' + @tmpText + '|' + @Chassis
							ELSE
								SET @GLDescript = LEFT(@DriverDiv + '|' + IIF(LEFT(@DriverType,1) = 'C', LEFT(@DriverType,1) + '|', '') + @DriverId + '|' + @tmpText, 30)
						END
						ELSE
							SET @GLDescript = LEFT(dbo.PADL(LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1), 2, '0') + '|' + IIF(LEFT(@DriverType,1) = 'C', LEFT(@DriverType,1) + '|', '') + @DriverId + '|' + @tmpText, 30)

						IF @EqOwner = 'COMPANY' AND LEN(@GLDescript) > 30
						SET @GLDescript = REPLACE(@GLDescript, @DriverId + '|', '')
				END
				ELSE
				BEGIN
					SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + SUBSTRING(CDEX_LOCAT, 2, 10) + '|' + CDEX_DAMAG + IIF(@EqOwner = 'FLEET', '|' + @FleetEq, '-NNOI') FROM @tblDS5Data WHERE Category LIKE 'TIRE%' AND CDEX_LOCAT = @PartLocation  ORDER BY ITEMTOT DESC)
					SET @GLDescript = LEFT(@tmpText, 30)
				END
			
				IF @UNIT_TYPE = 'CHASSIS' AND @IsDepot = 0
					SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner = 'CUSTOMER', 'TRUCKING', 'CHASSIS'))
				ELSE
					SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner IN ('FLEET', 'YARD'), @EqOwner, IIF(@IsDepot = 1,'DEPOT', 'TRUCKING')))
			END
		
			IF @Category = 'MECHANICAL'
			BEGIN
				IF @IsDepot = 0
				BEGIN
					SET @TmpDesc	= (SELECT TOP 1 DESCRIPT FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)
					SET @TmpDesc	= REPLACE(REPLACE(REPLACE(@TmpDesc, 'REPLACE ', ''), 'REMOVE ', ''), ',', '')
				
					IF dbo.AT(' ', @TmpDesc, 1) = 0
						SET @TmpDesc	= @TmpDesc
					ELSE
					BEGIN
						IF LEN(RTRIM(LEFT(@TmpDesc, dbo.AT(' ', @TmpDesc, 1)))) < 3 AND dbo.AT(' ', @TmpDesc, 2) > 0
							SET @TmpDesc	= RTRIM(LEFT(@TmpDesc, dbo.AT(' ', @TmpDesc, 2)))
						ELSE
							SET @TmpDesc	= RTRIM(LEFT(@TmpDesc, dbo.AT(' ', @TmpDesc, 1)))
					END
				
					SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + @TmpDesc + '|' + CDEX_DAMAG FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)

					IF @ProNumber <> ''
					BEGIN
						IF @EqOwner = 'COMPANY'
							SET @GLDescript = @DriverId + '|' + @tmpText + '|' + @Chassis
						ELSE
							IF @DriverType = 'N/A'
								SET @GLDescript = @tmpText
							ELSE
								SET @GLDescript = LEFT(@DriverDiv + '|' + IIF(LEFT(@DriverType, 1) = 'C', LEFT(@DriverType, 1) + '|', '') + IIF(@DriverId <> '', @DriverId + '|', '') + @tmpText, 30)
						END
					ELSE
						IF @DriverType = 'N/A'
							SET @GLDescript = @tmpText
						ELSE
							SET @GLDescript = LEFT(dbo.PADL(LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1), 2, '0') + '|' + IIF(LEFT(@DriverType,1) = 'C', LEFT(@DriverType,1) + '|', '') + @DriverId + '|' + @tmpText, 30)

					IF @EqOwner = 'COMPANY' AND LEN(@GLDescript) > 30
						SET @GLDescript = REPLACE(@GLDescript, @DriverId + '|', '')
				END
				ELSE
				BEGIN
					SET @TmpDesc	= (SELECT TOP 1 DESCRIPT FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)
					SET @TmpDesc	= REPLACE(REPLACE(REPLACE(@TmpDesc, 'REPLACE ', ''), 'REMOVE ', ''), ',', '')
				
					IF dbo.AT(' ', @TmpDesc, 1) = 0
						SET @TmpDesc	= @TmpDesc
					ELSE
					BEGIN
						IF LEN(RTRIM(LEFT(@TmpDesc, dbo.AT(' ', @TmpDesc, 1)))) < 3 AND dbo.AT(' ', @TmpDesc, 2) > 0
							SET @TmpDesc	= RTRIM(LEFT(@TmpDesc, dbo.AT(' ', @TmpDesc, 2)))
						ELSE
							SET @TmpDesc	= RTRIM(LEFT(@TmpDesc, dbo.AT(' ', @TmpDesc, 1)))
					END

					IF dbo.AT('INSTALL', (SELECT TOP 1 DESCRIPT FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC), 1) > 0
						SET @TmpDesc = 'INSTALL ' + @TmpDesc

					SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + @TmpDesc + '|' + CDEX_DAMAG + IIF(@EqOwner = 'FLEET', '|' + @FleetEq, '-NNOI') FROM @tblDS5Data WHERE Category = 'MECHANICAL' ORDER BY ITEMTOT DESC)
					SET @GLDescript = LEFT(@tmpText, 30)
				END
			
				IF @UNIT_TYPE = 'CHASSIS' AND @IsDepot = 0
					SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner = 'CUSTOMER', 'TRUCKING', 'CHASSIS'))
				ELSE
					SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner IN ('FLEET', 'YARD'), @EqOwner, IIF(@IsDepot = 1,'DEPOT', 'TRUCKING')))
			END

			IF @Category = 'FHWA/FMCSA'
			BEGIN
				SET @TmpDesc	= (SELECT TOP 1 DESCRIPT FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)
				SET @TmpDesc	= REPLACE(REPLACE(REPLACE(@TmpDesc, 'REPLACE ', ''), 'REMOVE ', ''), ',', '')
				SET @TmpDesc	= IIF(dbo.AT(' ', @TmpDesc, 1 ) = 0, @TmpDesc, RTRIM(LEFT(@TmpDesc, dbo.AT(' ', @TmpDesc, 1))))
				SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + @TmpDesc + '|' + CDEX_DAMAG FROM @tblDS5Data WHERE Category = 'FHWA/FMCSA' ORDER BY ITEMTOT DESC)

				IF @EqOwner = 'COMPANY'
					SET @GLDescript = @DriverId + '|' + @tmpText + '|' + @Chassis
				ELSE
					SET @GLDescript = LEFT(dbo.PADL(LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1), 2, '0') + '|' + IIF(LEFT(@DriverType,1) = 'C', LEFT(@DriverType,1) + '|', '') + @DriverId + '|' + @tmpText, 30)

				IF @UNIT_TYPE = 'CHASSIS'
					SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner = 'CUSTOMER', 'TRUCKING', 'CHASSIS'))
				ELSE
					SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = 'TRUCKING')
			END

			IF @Category = 'REEFER'
			BEGIN
				IF @IsDepot = 0
				BEGIN
					SET @TmpDesc	= (SELECT TOP 1 DESCRIPT FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)
					SET @TmpDesc	= REPLACE(REPLACE(REPLACE(@TmpDesc, 'REPLACE ', ''), 'REMOVE ', ''), ',', '')
					SET @TmpDesc	= IIF(dbo.AT(' ', @TmpDesc, 1 ) = 0, @TmpDesc, RTRIM(LEFT(@TmpDesc, dbo.AT(' ', @TmpDesc, 1))))
					SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + @TmpDesc + '|' + CDEX_DAMAG FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)

					IF @ProNumber <> ''
						SET @GLDescript = LEFT(@DriverDiv + '|' + IIF(LEFT(@DriverType,1) = 'C', LEFT(@DriverType,1) + '|', '') + IIF(@DriverId <> '', @DriverId + '|', '') + @tmpText, 30)
					ELSE
						SET @GLDescript = LEFT(dbo.PADL(LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1), 2, '0') + '|' + IIF(LEFT(@DriverType,1) = 'C', LEFT(@DriverType,1) + '|', '') + @DriverId + '|' + @tmpText, 30)
				END
				ELSE
				BEGIN
					SET @TmpDesc	= (SELECT TOP 1 DESCRIPT FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)
					SET @TmpDesc	= REPLACE(REPLACE(REPLACE(@TmpDesc, 'REPLACE ', ''), 'REMOVE ', ''), ',', '')
					SET @TmpDesc	= IIF(dbo.AT(' ', @TmpDesc, 1 ) = 0, @TmpDesc, RTRIM(LEFT(@TmpDesc, dbo.AT(' ', @TmpDesc, 1))))
					SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + @TmpDesc + '|' + CDEX_DAMAG + IIF(@EqOwner = 'FLEET', '|' + @FleetEq, '') FROM @tblDS5Data WHERE Category = 'REEFER' ORDER BY ITEMTOT DESC)
					SET @GLDescript = LEFT(@tmpText, 30)
				END

				IF @UNIT_TYPE = 'CHASSIS' AND @IsDepot = 0
					SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner = 'CUSTOMER', 'TRUCKING', 'CHASSIS'))
				ELSE
					SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner IN ('FLEET', 'YARD'), @EqOwner, 'TRUCKING'))
			END
		
			IF @IsDepot = 0 OR @EqOwner = 'FLEET'
				SET @GLAccount	= REPLACE(REPLACE(@GLAccount, 'DD', @DriverDiv), 'X-XX', (SELECT GLAccount FROM @tblDepots WHERE DepotLoc = @DEPOT_LOC))
			ELSE
				SET @GLAccount	= REPLACE(@GLAccount, LEFT(@GLAccount, 4), (SELECT GLAccount FROM @tblDepots WHERE DepotLoc = @DEPOT_LOC))

			IF @Category = 'M&R_BUILDING'
			BEGIN
				SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-####|' + CDEX_DAMAG FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)
				SET @tmpString	= (SELECT TOP 1 LEFT(DESCRIPT, dbo.AT(' ', DESCRIPT, 1)) FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)
			
				IF (SELECT TOP 1 DESCRIPT FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC) LIKE '%INSTALLER%'
					SET @GLDescript = LEFT(REPLACE(@tmpText, '####', 'INSTALL ' + @Chassis), 30)
				ELSE
					SET @GLDescript = LEFT(REPLACE(@tmpText, '####', @tmpString + @Chassis), 30)
			
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = 'YARD')
				SET @GLAccount	= REPLACE(@GLAccount, LEFT(@GLAccount, 4), (SELECT GLAccount FROM @tblDepots WHERE DepotLoc = @DEPOT_LOC))
			END

			IF @Category = 'MONITORING'
			BEGIN
				SET @GLAccount	= '1-03-6005'
				SET @GLDescript = 'Monitoring'
			END

			IF @Category = 'DECAL'
			BEGIN
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = 'FLEET')
				SET @GLAccount	= REPLACE(@GLAccount, 'DD', @DriverDiv)
				SET @GLDescript = 'Decal Installation'
			END

			IF @Category = 'PEOPLENET'
			BEGIN
				SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-####|' + CDEX_DAMAG FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)
				SET @tmpString	= (SELECT TOP 1 LEFT(DESCRIPT, dbo.AT(' ', DESCRIPT, 1)) FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)

				SET @GLDescript = LEFT(REPLACE(@tmpText, '####', 'INSTALL TABLET') + '|' + @FleetEq, 30)
			
				--IF (SELECT TOP 1 DESCRIPT FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC) LIKE '%INSTALLER%'
				--	SET @GLDescript = LEFT(REPLACE(@tmpText, '####', 'INSTALL ') + '|' + @Chassis, 30)
				--ELSE
				--	SET @GLDescript = LEFT(REPLACE(@tmpText, '####', @tmpString + @Chassis), 30)
			
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = 'FLEET')
				--SET @GLAccount	= REPLACE(@GLAccount, LEFT(@GLAccount, 4), (SELECT GLAccount FROM @tblDepots WHERE DepotLoc = @DEPOT_LOC))
			END

			IF @Category = 'FUEL'
			BEGIN
				SET @GLDescript = (SELECT TOP 1 CDEX_REPAI + '-FUEL-' + CDEX_DAMAG FROM @tblDS5Data WHERE Category = @Category ORDER BY ITEMTOT DESC)
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@IsDepot = 1, 'YARD', 'FLEET'))
			END
		END TRY
		BEGIN CATCH
			SET @GLDescript = '** UNABLE TO MATCH IT ***'
		END CATCH

		SET @Monitoring = IIF(EXISTS(SELECT TOP 1 DESCRIPT FROM @tblDS5Data WHERE Category = @Category AND DESCRIPT = 'MONITORING'), 1, 0)

		IF LEFT(@GLAccount, 4) = '1-11'
			SET @GLAccount = REPLACE(@GLAccount, '1-11', '1-XX')
		ELSE
		BEGIN
			IF @EqOwner = 'FLEET' AND @Category <> 'PEOPLENET'
				SET @GLAccount = '2-XX-' + RIGHT(@GLAccount, 4)

			IF @Category = 'REEFER'
				SET @GLAccount = '1' + RIGHT(@GLAccount, 8)

			IF dbo.AT('DD', @GLAccount, 1) > 0
				SET @GLAccount = REPLACE(@GLAccount, 'DD', @DriverDiv)
		END

		IF @Monitoring = 1 --AND dbo.AT('XX', @GLAccount, 1) > 0
			SET @GLAccount = '1-03-' + RIGHT(@GLAccount, 4)
		
		INSERT INTO @tblGPRecs
		SELECT	'IMC' AS Company,
				@GLAccount,
				@GLDescript,
				@ITEMTOT + @TaxItem,
				0,
				@RepairCode

		FETCH FROM curRepairDetails INTO @DEPOT_LOC, @invoice_date, @INV_TOTAL, @SALE_TAX, @Category, @UNIT_TYPE,
				@EqOwner, @CONTAINER, @CHASSIS, @GENSET_NO, @ProNumber, @DriverId, @DriverType, @DriverDiv,
				@PartLocation, @ITEMTOT, @TotParts, @TotLabor
	END
	
	CLOSE curRepairDetails
	DEALLOCATE curRepairDetails

	SET @RecordId = ISNULL((SELECT TOP 1 MRInvoices_APId FROM MRInvoices_AP WHERE InvoiceNumber = @Invoice), 0)

	IF @RecordId > 0
	BEGIN
		UPDATE	MRInvoices_AP
		SET		Field1		= DATA.VendorName,
				Field2		= DATA.InvDate,
				Field3		= DATA.CHASSIS,
				Field4		= DATA.InvoiceNumber,
				Field5		= DATA.INV_TOTAL,
				Field8		= DATA.VendorId,
				Field9		= DATA.UniqueId,
				Field10		= DATA.RcvDate,
				Field11		= DATA.ProNumber,
				Field13		= DATA.Descript,
				Field14		= DATA.CONTAINER,
				Field16		= DATA.Field16,
				Field17		= ISNULL(DATA.GLAcct, ''),
				Field18		= DATA.Depto,
				Field20		= DATA.Amount,
				EIRI		= DATA.EIRI,
				DriverId	= DATA.DriverNum,
				DrvDivision	= DATA.DriverDiv,
				DrvType		= DATA.DriverType,
				UserId		= DATA.UserId
		FROM	(
				SELECT	@VendorName AS VendorName,
						CAST(Invoice_date AS Date) AS InvDate,
						CHASSIS,
						InvoiceNumber,
						INV_TOTAL,
						@VendorId AS VendorId,
						@VendorId + '_' + InvoiceNumber AS UniqueId,
						CAST(Invoice_date AS Date) AS RcvDate,
						ISNULL(ProNumber,'') AS ProNumber,
						ISNULL(DAT.Descript,'') AS Descript,
						CONTAINER,
						'' AS Field16,
						ISNULL(RIGHT(DAT.GLAccount, 4),'') AS GLAcct,
						REPLACE(ISNULL(LEFT(DAT.GLAccount, 4),''), '-', '') AS Depto,
						INV_TOTAL AS Amount,
						@EIRI AS EIRI,
						@UserId AS UserId,
						@DriverId AS DriverNum,
						@DriverType AS DriverType,
						@DriverDiv AS DriverDiv
				FROM	@tblDS5Data
						INNER JOIN (SELECT TOP 1 * FROM @tblGPRecs) DAT ON DAT.Debit <> 0
				) DATA
		WHERE	MRInvoices_AP.MRInvoices_APId = @RecordId
	END
	ELSE
	BEGIN
		INSERT INTO MRInvoices_AP
				([InvoiceNumber]
				,[Field1]
				,[Field2]
				,[Field3]
				,[Field4]
				,[Field5]
				,[Field8]
				,[Field9]
				,[Field10]
				,[Field11]
				,[Field13]
				,[Field14]
				,[Field16]
				,[Field17]
				,[Field18]
				,[Field20]
				,[EIRI]
				,[DriverId]
				,[DrvDivision]
				,[DrvType]
				,[EqOwner]
				,[UserId])
		SELECT	InvoiceNumber,
				@VendorName,
				CAST(Invoice_date AS Date),
				CHASSIS,
				InvoiceNumber,
				INV_TOTAL,
				@VendorId,
				@VendorId + '_' + InvoiceNumber,
				CAST(Invoice_date AS Date),
				ISNULL(ProNumber,''),
				ISNULL(DAT.Descript,''),
				CONTAINER,
				'',
				ISNULL(RIGHT(DAT.GLAccount, 4),''),
				ISNULL(REPLACE(ISNULL(LEFT(DAT.GLAccount, 4),''), '-', ''), ''),
				INV_TOTAL,
				@EIRI,
				@DriverId,
				@DriverDiv,
				@DriverType,
				@EqOwner,
				@UserId
		FROM	@tblDS5Data
				INNER JOIN (SELECT TOP 1 * FROM @tblGPRecs) DAT ON DAT.Debit <> 0
	END

	IF (SELECT COUNT(*) FROM @tblGPRecs) > 0
	BEGIN
		DELETE	MRInvoices_Distribution 
		WHERE	InvoiceNumber = @Invoice
		
		INSERT INTO MRInvoices_Distribution
				(InvoiceNumber,
				GLAccount,
				Description,
				Amount,
				UserId,
				RepairCode)
		SELECT	@Invoice,
				ISNULL(GLAccount,''),
				ISNULL(Descript,''),
				ISNULL(Debit,0), 
				@UserId,
				RepCode
		FROM	@tblGPRecs

		UPDATE	MRInvoices_AP
		SET		Field13 = DATA.Descript,
				Field17 = ISNULL(DATA.Acct,''),
				Field18 = ISNULL(DATA.Depto,''),
				EqOwner = @EqOwner
		FROM	(
				SELECT	TOP 1 RIGHT(GLAccount, 4) AS Acct,
						REPLACE(LEFT(GLAccount, 4), '-', '') AS Depto,
						ISNULL(Descript,'') AS Descript
				FROM	@tblGPRecs
				ORDER BY Debit DESC
				) DATA
		WHERE	InvoiceNumber = @Invoice
	END

	DECLARE @tblExpAccounts Table (Account Char(4), RepType Varchar(30), DrvType Char(1), Recovery Char(1))

	DECLARE @RepType	Char(1)

	INSERT INTO @tblExpAccounts
	SELECT	[Account]
			,[RepairType]
			,[DriverType]
			,[Recovery]
	FROM	PRISQL01P.GPCustom.dbo.ExpenseRecoveryAccounts

	DELETE	PRISQL01P.GPCustom.dbo.DEX_ER_PopUps
	WHERE	DEX_ER_PopUpsId IN (SELECT PopUpId FROM MRInvoices_Distribution WHERE InvoiceNumber = @Invoice AND PopUpId > 0)

	DECLARE @OtherType Int = 0

	DECLARE curDistribution CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	MRInvoices_DistributionId,
			GLAccount,
			Description,
			Amount
	FROM	MRInvoices_Distribution
	WHERE	InvoiceNumber = @Invoice

	OPEN curDistribution 
	FETCH FROM curDistribution INTO @DistId, @DistAcct, @DistDesc, @DistAmnt

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		EXECUTE @OtherType = PRISQL01P.GPCustom.dbo.USP_FindPopUpType 'IMC', @DistAcct

		IF RIGHT(@DistAcct, 4) IN (SELECT Account FROM @tblExpAccounts) OR @OtherType = 20
		BEGIN
			SET @DrvType = IIF(LEFT(@DriverType, 1) = 'C', '1', '2')
			SET @DistDept = IIF(SUBSTRING(@DistAcct, 3, 2) IN ('','XX'), '', SUBSTRING(@DistAcct, 3, 2))

			--SELECT	@RepType = LEFT(RepType, 1)
			--FROM	@tblExpAccounts
			--WHERE	Account = RIGHT(@DistAcct, 4)

			SET @RepType = ''

			EXECUTE @PopupId = PRISQL01P.GPCustom.dbo.USP_DEX_ER_PopUps 0, 'IMC', @Invoice,
								@VendorId, @ProNumber, @DistDesc, 0, @DistAmnt, @Invoice,
								@EffDate, @invoice_date, @Container, @Chassis, @RepairCode, 'N',
								@DriverId, @DrvType, @RepType, @DistAcct, Null, 'Open', Null, 
								0, 0, 'AP', 0, 1, Null, @DistDept

			IF ISNULL(@PopupId, 0) > 0
				UPDATE MRInvoices_Distribution SET PopUpId = @PopupId WHERE MRInvoices_DistributionId = @DistId
		END

		FETCH FROM curDistribution INTO @DistId, @DistAcct, @DistDesc, @DistAmnt
	END

	CLOSE curDistribution
	DEALLOCATE curDistribution

	IF @HideActivity = 0
	BEGIN
		SELECT	RIGHT(GLAccount, 4) AS Acct,
				REPLACE(LEFT(GLAccount, 4), '-', '') AS Depto,
				ISNULL(Descript,'') AS Descript,
				Debit
		FROM	@tblGPRecs
		ORDER BY Debit DESC
	END

	SET @ReturnValue = CAST(@EIRI AS Int)
END
ELSE
BEGIN
	IF EXISTS(SELECT InvoiceNumber FROM MRInvoices_AP WHERE InvoiceNumber = @Invoice)
	BEGIN
		SET @ReturnValue = (SELECT TOP 1 EIRI FROM MRInvoices_AP WHERE InvoiceNumber = @Invoice ORDER BY CreatedOn DESC)
	END
END

PRINT @ReturnValue

RETURN @ReturnValue
/*
TRUNCATE TABLE MRInvoices_AP
TRUNCATE TABLE MRInvoices_Distribution

SELECT	distinct sal.*
FROM	DepotSystemsIMCMNR.dbo.Invoices HDR
		LEFT JOIN DepotSystemsIMCMNR.dbo.Sale SAL ON HDR.unique_key = SAL.invoices_key AND SAL.row_status = 'N'
WHERE	HDR.Invoice_alpha = '1800153'
		AND HDR.row_status = 'N'

EXECUTE USP_QuerySWS 'SELECT Code FROM TRK.Trailer WHERE Code = ''KKTU787636'''
EXECUTE USP_QuerySWS 'SELECT Code FROM TRK.Trailer WHERE Code = ''TIFU426216'''
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Driver WHERE code = ''9002'''
EXECUTE USP_QuerySWS 'SELECT * FROM eir WHERE code = 9077611'
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Order WHERE div_code = ''08'' and pro = ''177876'''
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Move WHERE Or_No = 8177876'
EXECUTE USP_QuerySWS 'SELECT * FROM eir WHERE dmeqmast_code_chassis = ''APMZ426364'' AND edate <= ''04/28/2020'' AND eirtype = ''I'' ORDER BY edate DESC, etime DESC LIMIT 10'

EXECUTE USP_QuerySWS 'SELECT O.Div_Code, O.Pro, M.Tl_Code AS Companion, M.Dr_Code, D.Type, D.Div_Code AS DriverDiv
FROM	TRK.Move M 
		INNER JOIN TRK.Order O ON M.Or_No = O.No 
		LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = M.Cmpy_No
WHERE	M.Ch_Code = ''APMZ426364'' AND M.Tl_Code = ''EISU913511'' AND M.ADate <= ''04/28/2020'' ORDER BY M.ADate DESC LIMIT 1'

*/