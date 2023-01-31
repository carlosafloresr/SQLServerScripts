USE [DepotSystemsViews]
GO
/****** Object:  StoredProcedure [dbo].[USP_InvoiceDetails_Test]    Script Date: 5/12/2020 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_InvoiceDetails_Test '1779054'
*/
ALTER PROCEDURE [dbo].[USP_InvoiceDetails_Test]
		@Invoice		Varchar(12),
		@ForceCreation	Bit = 0
AS
SET NOCOUNT ON

IF @ForceCreation = 1
BEGIN
	--DELETE MRInvoices_AP WHERE InvoiceNumber = @Invoice
	--DELETE MRInvoices_Distribution WHERE InvoiceNumber = @Invoice
	PRINT 'TEST'
END

IF 5 > 1
BEGIN
	DECLARE @tblEquip	Table (Equipment Varchar(15))

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
			DriverDiv	Char(2))

	DECLARE @tblDepot	Table (
			EIRI		Varchar(12),
			Companion	Varchar(12),
			ErrorCode	Varchar(12))

	DECLARE @Query		Varchar(MAX),
			@Chassis	Varchar(15),
			@Container	Varchar(15),
			@Companion	Varchar(15) = '',
			@RepDate	Date,
			@ProNumber	Varchar(15),
			@DriverId	Varchar(12),
			@DriverType	Varchar(20),
			@DriverDiv	Char(2) = '',
			@EqType		Varchar(20),
			@EqOwner	Varchar(20),
			@CompanyEq	Bit = 0,
			@UserId		Varchar(25) = 'Auto-Generate',
			@VendorId	Varchar(15) = '1000331',
			@VendorName	Varchar(100),
			@Customer	Varchar(12),
			@IsDepot	Bit,
			@DepotError	Varchar(2) = ''

	DECLARE	@tblGPRecs	Table (
			Company		Varchar(5),
			GLAccount	Varchar(15),
			Descript	Varchar(30),
			Debit		Numeric(10,2),
			Credit		Numeric(10,2))

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

	INSERT INTO @tblParts
	SELECT	unique_key,
			PART_NO,
			DESCRIPT,
			BIN,
			CASE WHEN DESCRIPT IN ('FUEL','FUEL SURCHARGE','SERVICE CALL AND FUEL SURCHARGE') THEN 'FUEL'
			WHEN BIN = 'TIRE' THEN 'TIRE'
			WHEN BIN = '' THEN 'MECHANICAL'
			WHEN BIN IN ('FMCSA','FMCSAK','FMCSAMN','FMCSAUP') THEN 'FHWA/FMCSA'
			WHEN BIN IN ('AP01','G01','P01','P01C','P01U','TF','TFAH','PS01','TFM') THEN 'DRY-RUN'
			ELSE 'MECHANICAL' END AS Category,
			CDEX_COMPO
	FROM	DepotSystemsIMCMNR.dbo.DeaParts 
	WHERE	row_status = 'N'
	ORDER BY BIN, PART_NO

	SELECT	@Chassis	= RTRIM(Chassis),
			@Container	= RTRIM(Container),
			@RepDate	= Repair_Date,
			@EqType		= UNIT_TYPE,
			@Customer	= RTRIM(ACCT_NO)
	FROM	DepotSystemsIMCMNR.dbo.Invoices
	WHERE	Invoice_alpha = @Invoice
			AND row_status = 'N'

	IF @Customer IN ('MEMIDE','NASIDE')
		SET @IsDepot = 1
	ELSE
		SET @IsDepot = 0

	PRINT 'Chassis: ' + ISNULL(@Chassis,'')
	PRINT 'Container: ' + ISNULL(@Container,'')

	IF @IsDepot = 0
	BEGIN -- TRUCKING
		IF @Chassis <> '' AND @Container <> ''
		BEGIN		
			SET @Query = N'SELECT O.Div_Code, O.Pro, M.Tl_Code AS Companion, M.Dr_Code, D.Type, D.Div_Code AS DriverDiv
						FROM	TRK.Move M 
								INNER JOIN TRK.Order O ON M.Or_No = O.No 
								LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = M.Cmpy_No
						WHERE	M.Ch_Code = ''' + @Chassis + ''' AND M.ADate <= ''' + CONVERT(Char(10), @RepDate, 101) + ''' ORDER BY M.ADate DESC LIMIT 1'
		END
		ELSE
			IF @Chassis = '' OR @Container = ''
			BEGIN
				IF @Chassis <> ''
					SET @Query = N'SELECT O.Div_Code, O.Pro, M.Tl_Code AS Companion, M.Dr_Code, D.Type, D.Div_Code AS DriverDiv
							FROM	TRK.Move M 
									INNER JOIN TRK.Order O ON M.Or_No = O.No 
									LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = M.Cmpy_No
							WHERE	M.Ch_Code = ''' + @Chassis + ''' AND M.Tl_Code = ''' + @Container + ''' AND M.ADate <= ''' + CONVERT(Char(10), @RepDate, 101) + ''' ORDER BY M.ADate DESC LIMIT 1'
				ELSE
					SET @Query = N'SELECT O.Div_Code, O.Pro, M.Ch_Code AS Companion, M.Dr_Code, D.Type, D.Div_Code AS DriverDiv
								FROM	TRK.Move M 
										INNER JOIN TRK.Order O ON M.Or_No = O.No 
										LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = M.Cmpy_No
								WHERE	M.Tl_Code = ''' + @Container + ''' AND M.ADate <= ''' + CONVERT(Char(10), @RepDate, 101) + ''' ORDER BY M.ADate DESC LIMIT 1'
			END

		INSERT INTO @tblSWS
		EXECUTE USP_QuerySWS @Query

		IF (SELECT COUNT(*) FROM @tblSWS) > 0
		BEGIN
			SELECT	@Companion	= Companion, 
					@ProNumber	= CAST(CAST(Division AS Int) AS Varchar) + '-' + RTRIM(Pro),
					@DriverId	= DriverId,
					@DriverType	= CASE WHEN DriverType = 'O' THEN 'Owner Opearator' ELSE 'Company Driver' END,
					@DriverDiv	= ISNULL(DriverDiv,'')
			FROM	@tblSWS
		END
	END
	ELSE
	BEGIN -- DEPOT ERRORS CHECK
		IF @Chassis <> '' AND @Container <> ''
		BEGIN		
			SET @Query = N'SELECT Code, DMEqMast_Code_Container, DMStatus_Code_Chassis FROM Eir 
							WHERE cmpy_no = 1 AND dmeqmast_code_chassis = ''' + @Chassis + ''' 
							AND edate <= ''' + CONVERT(Char(10), @RepDate, 101) + ''' AND eirtype = ''I'' AND status = ''R'' ORDER BY edate DESC, etime DESC LIMIT 1'
		END
		ELSE
			IF @Chassis = '' OR @Container = ''
			BEGIN
				IF @Chassis <> ''
					SET @Query = N'SELECT Code, DMEqMast_Code_Container, DMStatus_Code_Chassis FROM Eir 
							WHERE cmpy_no = 1 AND dmeqmast_code_chassis = ''' + @Chassis + ''' 
							AND edate <= ''' + CONVERT(Char(10), @RepDate, 101) + ''' AND eirtype = ''I'' AND status = ''R'' ORDER BY edate DESC, etime DESC LIMIT 1'
				ELSE
					SET @Query = N'SELECT Code, DMEqMast_Code_Chassis, DMStatus_Code_Container FROM Eir 
							WHERE cmpy_no = 1 AND dmeqmast_code_container = ''' + @Container + ''' 
							AND edate <= ''' + CONVERT(Char(10), @RepDate, 101) + ''' AND eirtype = ''I'' AND status = ''R'' ORDER BY edate DESC, etime DESC LIMIT 1'
			END

		INSERT INTO @tblDepot
		EXECUTE USP_QuerySWS @Query

		IF (SELECT COUNT(*) FROM @tblSWS) > 0
		BEGIN
			SELECT	@Companion	= Companion, 
					@ProNumber	= 'EIRI:' + EIRI,
					@DriverId	= '',
					@DriverType	= 'N/A',
					@DriverDiv	= '',
					@DepotError	= ErrorCode
			FROM	@tblDepot
		END

		IF @DepotError = '03'
			SET @IsDepot = 0
		ELSE
			SET @IsDepot = 1
	END

	IF @Companion <> ''
		BEGIN
			IF @Chassis <> ''
				SET @Container = @Companion
			ELSE
				SET @Chassis = @Companion
		END

	SET @Query = 'SELECT Code FROM TRK.Trailer WHERE Code = ''' + IIF(@EqType = 'R', @Container, @Chassis) + ''''

	INSERT INTO @tblEquip
	EXECUTE USP_QuerySWS @Query

	IF (SELECT COUNT(*) FROM @tblEquip) > 0
		SET @EqOwner = 'COMPANY'
	ELSE
		SET @EqOwner = 'CUSTOMER'

	INSERT INTO @tblDS5Data
	SELECT	HDR.Invoice_alpha AS InvoiceNumber,
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
			'' AS BIN, --DPA.BIN,
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
			LEFT JOIN @tblParts DPA ON SAL.deaparts_key = DPA.unique_key
			LEFT JOIN DepotSystemsIMCMNR.dbo.damage_list DAM ON SAL.CDEX_DAMAG = DAM.code AND DAM.edi_type = 'CEDEX'
			LEFT JOIN DepotSystemsIMCMNR.dbo.repair_list REP ON SAL.CDEX_REPAI = REP.code AND REP.edi_type = 'CEDEX'
			LEFT JOIN DepotSystemsIMCMNR.dbo.component_list CMP ON DPA.CDEX_COMPO = CMP.code AND CMP.edi_type = 'CEDEX' AND CMP.unit_type = 'CHASSIS'
	WHERE	HDR.Invoice_alpha = @Invoice
			AND HDR.row_status = 'N'

	SELECT	*
	FROM	@tblDS5Data

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
			@GLDescript		Varchar(30) = '',
			@tmpText		Varchar(30) = '',
			@CatCounter		Smallint = 0,
			@TaxTotal		Numeric(10,2) = 0,
			@TaxItem		Numeric(10,2),
			@Counter		Smallint = 0

	SET @CatCounter = (SELECT COUNT(*) FROM (SELECT DISTINCT Category, IIF(Category LIKE 'TIRE%', CDEX_LOCAT, '') AS PartLocation FROM @tblDS5Data) DATA)
	PRINT 'Count: ' + CAST(@CatCounter AS Varchar)

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
			SUM(ITEMTOT) AS ITEMTOT
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
			SUM(ITEMTOT) AS ITEMTOT
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

	OPEN curRepairDetails 
	FETCH FROM curRepairDetails INTO @DEPOT_LOC, @invoice_date, @INV_TOTAL, @SALE_TAX, @Category, @UNIT_TYPE,
				@EqOwner, @CONTAINER, @CHASSIS, @GENSET_NO, @ProNumber, @DriverId, @DriverType, @DriverDiv, 
				@PartLocation, @ITEMTOT

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT 'Repair Type: ' + @Category
		PRINT 'Unit Type: ' + @UNIT_TYPE
		PRINT 'Invoice Type: ' + IIF(@IsDepot = 1,'DEPOT', 'TRUCKING')

		SET @Counter	= @Counter + 1
		SET @TaxItem	= ROUND(@SALE_TAX / @CatCounter, 2)
		SET @TaxTotal	= @TaxTotal + @TaxItem
	
		IF @Counter = @CatCounter AND @TaxTotal <> @SALE_TAX
			SET @TaxItem = @TaxItem - (@TaxTotal - @SALE_TAX)
	
		IF @Category LIKE 'TIRE%'
		BEGIN
			IF @IsDepot = 0
			BEGIN
				SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + SUBSTRING(CDEX_LOCAT, 2, 10) + '|' + Damage FROM @tblDS5Data WHERE Category LIKE 'TIRE%' AND CDEX_LOCAT = @PartLocation  ORDER BY PART_TOTAL DESC)
				SET @GLDescript = LEFT(LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1) + '|' + LEFT(@DriverType,1) + '|' + @DriverId + '|' + @tmpText, 30)
			END
			ELSE
			BEGIN
				SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + SUBSTRING(CDEX_LOCAT, 2, 10) + '-NNOI' FROM @tblDS5Data WHERE Category LIKE 'TIRE%' AND CDEX_LOCAT = @PartLocation  ORDER BY PART_TOTAL DESC)
				SET @GLDescript = @tmpText
			END
			
			IF @UNIT_TYPE = 'CHASSIS' AND @IsDepot = 0
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner = 'CUSTOMER', 'TRUCKING', 'CHASSIS'))
			ELSE
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@IsDepot = 1,'DEPOT', 'TRUCKING'))
		END
		
		IF @Category = 'MECHANICAL'
		BEGIN
			IF @IsDepot = 0
			BEGIN
				SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '|' + Damage FROM @tblDS5Data WHERE Category = 'MECHANICAL' ORDER BY PART_TOTAL DESC)
				SET @GLDescript = LEFT(LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1) + '|' + LEFT(@DriverType,1) + '|' + @DriverId + '|' + @tmpText, 30)
			END
			ELSE
			BEGIN
				SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '-' + Repair + '-NNOI' FROM @tblDS5Data WHERE Category = 'MECHANICAL' ORDER BY PART_TOTAL DESC)
				SET @GLDescript = @tmpText
			END

			IF @UNIT_TYPE = 'CHASSIS' AND @IsDepot = 0
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner = 'CUSTOMER', 'TRUCKING', 'CHASSIS'))
			ELSE
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = 'DEPOT')
		END

		IF @Category = 'FHWA/FMCSA'
		BEGIN
			SET @tmpText	= (SELECT TOP 1 CDEX_REPAI + '|' + Damage FROM @tblDS5Data WHERE Category = 'FHWA/FMCSA' ORDER BY PART_TOTAL DESC)
			SET @GLDescript = LEFT(LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1) + '|' + LEFT(@DriverType,1) + '|' + @DriverId + '|' + @tmpText, 30)
			
			IF @UNIT_TYPE = 'CHASSIS'
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = IIF(@EqOwner = 'CUSTOMER', 'TRUCKING', 'CHASSIS'))
			ELSE
				SET @GLAccount	= (SELECT GLAccount FROM GLMappings WHERE Category = @Category AND AccountType = 'TRUCKING')
		END

		SET @GLAccount	= REPLACE(REPLACE(@GLAccount, 'DD', @DriverDiv), 'X-XX', (SELECT GLAccount FROM @tblDepots WHERE DepotLoc = @DEPOT_LOC))

		INSERT INTO @tblGPRecs
		SELECT	'IMC' AS Company,
				@GLAccount,
				@GLDescript,
				@ITEMTOT + @TaxItem,
				0

		FETCH FROM curRepairDetails INTO @DEPOT_LOC, @invoice_date, @INV_TOTAL, @SALE_TAX, @Category, @UNIT_TYPE,
				@EqOwner, @CONTAINER, @CHASSIS, @GENSET_NO, @ProNumber, @DriverId, @DriverType, @DriverDiv,
				@PartLocation, @ITEMTOT
	END

	CLOSE curRepairDetails
	DEALLOCATE curRepairDetails

	select * from @tblGPRecs

	IF (SELECT COUNT(*) FROM @tblGPRecs) > 0
	BEGIN
		SELECT	@Invoice,
				ISNULL(GLAccount,''),
				ISNULL(Descript,''),
				ISNULL(Debit,0), 
				@UserId
		FROM	@tblGPRecs
	END
END