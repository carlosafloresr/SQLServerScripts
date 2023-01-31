USE RCCL
GO 

/*
EXECUTE USP_Driver_1099 'IMCC', '274', 2021, 0, 'nec'
EXECUTE USP_Driver_1099 'GIS', 'G15038', 2021, 0
EXECUTE USP_Driver_1099 'AIS', NULL, 2022, 0 , 'MISC','DRV'
EXECUTE USP_Driver_1099 'GLSO','7824','2022',0,'NEC'
*/
ALTER PROCEDURE USP_Driver_1099
		@Company		Varchar(5),
		@DriverId		Varchar(15) = Null,
		@Year			Int = Null,
		@JustPeriods	Bit = 0,
		@Type1099		Varchar(5) = Null,
		@VendorClass	Varchar(10) = Null
AS
/*
========================================================================================================================
VERSION		MODIFIED	USER				MODIFICATION
========================================================================================================================
1.0			12/05/2019	Carlos A. Flores	Created for the 1099 printing
1.1			01/05/2023	Carlos A. Flores	Use GP field VENDDBA if not empty for vendor name
========================================================================================================================
*/
SET NOCOUNT ON

DECLARE	@HTML			Varchar(MAX),
		@VendorId		Varchar(15),
		@VendorName		Varchar(100),
		@TotalPayments	Numeric(10,2),
		@TaxId			Varchar(20),
		@Address1		Varchar(100),
		@Address2		Varchar(100),
		@City			Varchar(35),
		@State			Varchar(20),
		@ZipCode		Varchar(10),
		@Phone			Varchar(30),
		@Ten99Type		Varchar(30),
		@Ten99BoxNumber	Int,
		@Address01		Varchar(200) = '',
		@Address02		Varchar(200) = '',
		@CpyTaxId		Varchar(50),
		@CompanyName	Varchar(150),
		@CompanyData	Varchar(500),
		@CpyAddress1	Varchar(100),
		@CpyAddress2	Varchar(100),
		@CpyCity		Varchar(35),
		@CpyState		Varchar(20),
		@CpyZipCode		Varchar(10),
		@CpyPhone		Varchar(30),
		@ValidPeriod	Bit,
		@CompanyDriver	Bit,
		@WithDriverId	Bit = IIF(@DriverId IS Null, 0, 1),
		@CpyDrivers		Bit = ISNULL((SELECT WithDrivers FROM GPCustom.dbo.Companies WHERE CompanyId = @Company), 0),
		@tmpHTML		Varchar(MAX) = '<table border"1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;width: 660;">' + CHAR(13),
		@1099Type		Int = IIF(@Type1099 = 'NEC', 5, 4),
		@Str1099Type	Varchar(15) = IIF(@Type1099 = 'NEC', 'Withholding', 'Miscellaneous'),
		@IMC_HQ			Bit = 0,
		@Query			Varchar(MAX),
		@RapidPay		Bit = 0

DECLARE	@tblVendorList	Table (VendorId Varchar(15))

DECLARE @tblAddresses	Table (AddressId Varchar(30))

SET @Query = N'SELECT LOCATNID FROM ' + @Company + '.dbo.SY00600 WHERE LOCATNID IN (''IMC HQ'')'

INSERT INTO @tblAddresses
EXECUTE(@Query)

IF (SELECT COUNT(*) FROM @tblAddresses) > 0
	SET @IMC_HQ = 1

IF @Type1099 IS Null
	SET @Type1099 = 'MISC'

IF @VendorClass IS Null
	SET @VendorClass = 'ALL'

IF @CpyDrivers = 0 OR @VendorClass = 'ALL'
BEGIN
	INSERT INTO @tblVendorList
	SELECT	VENDORID
	FROM	PM00200
	WHERE	(@DriverId IS Null OR VENDORID = @DriverId)
			AND ((@Type1099 = 'NEC' AND TEN99TYPE = 5)
			OR (@Type1099 <> 'NEC' AND TEN99TYPE IN (1,4)))
END
ELSE
BEGIN
	INSERT INTO @tblVendorList
	SELECT	VENDORID
	FROM	PM00200
	WHERE	TEN99TYPE = @1099Type
			AND (((@VendorClass = 'DRV' 
			AND (@DriverId IS Null
			AND VNDCLSID = 'DRV' AND VENDORID IN (SELECT VENDORID FROM GPCustom.dbo.VendorMaster WHERE Company = DB_NAME() AND (TerminationDate IS Null OR TerminationDate > ('01/01/' + CAST(@Year AS Varchar)))))
			OR VENDORID = @DriverId))
			AND VNDCLSID = @VendorClass)
END

IF @JustPeriods = 0
BEGIN
	DECLARE @tblVendors				Table (
			ReportYear				Int,
			Payers_TaxId			Varchar(30),
			Payer_Data				Varchar(300),
			DriverId				Varchar(15),
			DriverName				Varchar(75),
			FederalIncome			Numeric(10,2),
			Recipients_TaxId		Varchar(30),
			Recipients_Address1		Varchar(75),
			Recipients_Address2		Varchar(75),
			Recipients_Telephone	Varchar(35),
			Ten99Type				Varchar(20),
			Ten99BoxNumber			Int,
			ValidPeriod				Bit)

	DECLARE	@tblCmpyAddress			Table (
			TaxRegTN				Varchar(30),
			CmpnyNam				Varchar(100),
			Address1				Varchar(100),
			Address2				Varchar(100),
			City					Varchar(50),
			State					Varchar(30),
			ZipCode					Varchar(20),
			Phone1					Varchar(30),
			LocatNId				Varchar(30))

	SET @Query = N'SELECT	VAL.TaxRegTN,
		VAL.CmpnyNam,
		ADR.Address1,
		ADR.Address2,
		ADR.City,
		ADR.State,
		ADR.ZipCode,
		ADR.Phone1,
		ADR.LocatNId
FROM	DYNAMICS.dbo.View_AllCompanies VAL
		INNER JOIN ' + @Company + '.dbo.SY00600 ADR ON VAL.CmpanyId = ADR.CmpanyId
WHERE	VAL.InterId = ''' + @Company + ''' 
		AND ADR.LOCATNID IN (''IMC HQ'',VAL.LocatNId)'

	INSERT INTO @tblCmpyAddress
	EXECUTE(@Query)

	SELECT	TOP 1 
			@CpyTaxId		= RTRIM(TaxRegTN),
			@CompanyName	= UPPER(RTRIM(CmpnyNam)),
			@CpyAddress1	= RTRIM(Address1),
			@CpyAddress2	= RTRIM(Address2),
			@CpyCity		= RTRIM(City),
			@CpyState		= RTRIM(State),
			@CpyZipCode		= RTRIM(ZipCode),
			@CpyPhone		= RTRIM(Phone1)
	FROM	@tblCmpyAddress 
	WHERE	(@IMC_HQ = 1 AND LocatNId = 'IMC HQ')
			OR (@IMC_HQ = 0 AND LocatNId <> 'IMC HQ')

	-- COMPANY ADDRESS
	SET @CompanyData = @CompanyName + CHAR(13)

	SET @CompanyData = @CompanyData + RTRIM(@CpyAddress1) + CHAR(13)

	IF @CpyAddress2 <> ''
		SET @CompanyData = @CompanyData + RTRIM(@CpyAddress2) + CHAR(13)

	IF @CpyCity <> ''
		SET @CompanyData = @CompanyData + RTRIM(@CpyCity)

	IF @CpyState <> ''
		SET @CompanyData = @CompanyData + ', ' + RTRIM(@CpyState)

	IF @CpyZipCode <> ''
		SET @CompanyData = @CompanyData + ' ' + RTRIM(@CpyZipCode)

	IF @DriverId IS Null
		SET @CompanyDriver = 0
	ELSE
		SET @CompanyDriver = IIF(EXISTS(SELECT VENDORID FROM PM00200 WHERE VENDORID = @DriverId), 0, 1)

	DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	LTRIM(RTRIM(VENDORID))
	FROM	@tblVendorList

	OPEN curData 
	FETCH FROM curData INTO @DriverId

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @RapidPay = ISNULL((SELECT RapidPay FROM GPCustom.dbo.GPVendorMaster WHERE Company = @Company AND VendorId = @DriverId AND RP_Active = 1),0)

		--IF @RapidPay = 0
		--BEGIN
		--	SET @RapidPay = IIF((SELECT COUNT(*) FROM GPCustom.dbo.GPVendorMaster WHERE Company = @Company AND VendorId = @DriverId AND VNDCHKNM IN (SELECT Factors FROM GPVendorMaster_FactoringList)) > 0, 1, 0)
		--END

		SELECT	DISTINCT 
				@VendorId		= RTRIM(v.VENDORID),
				@VendorName		= IIF(v.VENDDBA <> '', UPPER(RTRIM(v.VENDDBA)),	UPPER(RTRIM(CASE  WHEN GPCustom.dbo.AT('#', v.VendName, 1) > 10 THEN LEFT(v.VendName, GPCustom.dbo.AT('#', v.VendName, 1) - 1) 
								  WHEN GPCustom.dbo.AT(RTRIM(v.VendorID), v.VendName, 1) > 0 THEN LEFT(v.VendName, GPCustom.dbo.AT(RTRIM(v.VendorID), v.VendName, 1) - 1) ELSE v.VendName END))), --UPPER(RTRIM(IIF(@RapidPay = 1, v.VENDNAME, v.VNDCHKNM))),
				@TotalPayments	= CAST(COALESCE(hp.TEN99AMNT,0) AS Numeric(10,2)),
				@TaxId			= v.TXIDNMBR,
				@Address1		= IIF(ISNULL(ADRS.ADDRESS1, v.ADDRESS1) = '', ISNULL(ADRS.ADDRESS2, v.ADDRESS2), ISNULL(ADRS.ADDRESS1, v.ADDRESS1)),
				@Address2		= IIF(ISNULL(ADRS.ADDRESS3, v.ADDRESS3) = '', ISNULL(ADRS.ADDRESS2, v.ADDRESS2), ISNULL(ADRS.ADDRESS3, v.ADDRESS3)),
				@City			= UPPER(RTRIM(ISNULL(ADRS.CITY, v.CITY))),
				@State			= RTRIM(ISNULL(ADRS.[STATE], v.[STATE])),
				@ZipCode		= v.ZIPCODE,
				@Phone			= CASE v.PHNUMBR1 
									WHEN '' THEN ''
									WHEN '00000000000000' THEN ''
									ELSE LEFT(v.PHNUMBR1,3) + '-' + SUBSTRING(v.PHNUMBR1,4,3) + '-' + SUBSTRING(v.PHNUMBR1,7,4)
									+ CASE SUBSTRING(v.PHNUMBR1,11,4)
										WHEN '0000' THEN ''
										ELSE IIF(SUBSTRING(v.PHNUMBR1,11,4) <> '', ' Ext ' + SUBSTRING(v.PHNUMBR1,11,4), '') END
								  END,
				@Ten99Type		= CASE TEN99TYPE
									WHEN 1 THEN 'Not a 1099 Vendor'
									WHEN 2 THEN 'Dividend'
									WHEN 3 THEN 'Interest'
									WHEN 4 THEN 'Miscellaneous'
									WHEN 5 THEN 'Withholding'
								  END,
				@Ten99BoxNumber	= v.TEN99BOXNUMBER,
				@ValidPeriod	= IIF(hp.TEN99AMNT IS Null, 0, 1)
		FROM	PM00200 v
				INNER JOIN PM00300 ADRS ON v.VendorID = ADRS.VendorID AND ADRS.ADRSCODE = 'MAIN'
				LEFT OUTER JOIN (
								SELECT	VENDORID, SUM(TEN99AMNT) AS TEN99AMNT 
								FROM	PM00204 
								WHERE	YEAR1 = @Year
								GROUP BY VENDORID
								) hp ON v.VENDORID = hp.VENDORID AND COALESCE(hp.TEN99AMNT,0) <> 0
		WHERE	v.TEN99TYPE <> 1
				AND v.VENDORID = @DriverId

		IF GPCustom.dbo.AT('#', @VendorName, 1) > 0
			SET @VendorName = RTRIM(LEFT(@VendorName, GPCustom.dbo.AT('#', @VendorName, 1) - 1))

		IF GPCustom.dbo.AT(@DriverId, @VendorName, 1) > 0
			SET @VendorName = RTRIM(LEFT(@VendorName, GPCustom.dbo.AT(@DriverId, @VendorName, 1) - 1))

		SET @Address01 = RTRIM(@Address1)

		IF @Address2 <> ''
			SET @Address01 = @Address01 + CHAR(13) + RTRIM(@Address2)

		IF @City <> ''
			SET @Address02 = RTRIM(@City)

		IF @State <> ''
			SET @Address02 = @Address02 + ', ' + RTRIM(@State)

		IF @ZipCode <> ''
			SET @Address02 = @Address02 + ' ' + RTRIM(@ZipCode)

		IF GPCustom.dbo.AT(@VendorId, @Address01, 1) > 0
		BEGIN
			SET @Address01 = LTRIM(RTRIM(SUBSTRING(@Address01, GPCustom.dbo.AT(' ', @Address01, 1) + 1, 100)))
		END

		INSERT INTO @tblVendors
		SELECT	DISTINCT @Year AS ReportYear,
				@CpyTaxId AS Payers_TaxId,
				@CompanyData AS Payer_Data,
				@VendorId AS DriverId,
				UPPER(@VendorName) AS DriverName,
				@TotalPayments AS FederalIncome,
				@TaxId AS Recipients_TaxId,
				@Address01 AS Recipients_Address1,
				@Address02 AS Recipients_Address2,
				@Phone AS Recipients_Telephone,
				@Ten99Type AS Ten99Type,
				@Ten99BoxNumber AS Ten99BoxNumber,
				@ValidPeriod AS ValidPeriod

		FETCH FROM curData INTO @DriverId
	END

	CLOSE curData
	DEALLOCATE curData

	IF @CompanyDriver = 0
		SELECT	DISTINCT ReportYear,
				Payers_TaxId,
				Payer_Data,
				DriverId,
				DriverName,
				FederalIncome,
				Recipients_TaxId,
				Recipients_Address1,
				Recipients_Address2,
				Recipients_Telephone,
				Ten99Type,
				Ten99BoxNumber,
				ValidPeriod,
				Counter = (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM @tblVendors WHERE Ten99Type = @Str1099Type AND (@WithDriverId = 1 OR (@WithDriverId = 0 AND FederalIncome > 499.99))) DATA)
		FROM	@tblVendors
		WHERE	@WithDriverId = 1
				OR (@WithDriverId = 0
				AND FederalIncome > 499.99)
		ORDER BY DriverId
	ELSE
		SELECT	DISTINCT @Year AS ReportYear,
				@CpyTaxId AS Payers_TaxId,
				@CompanyData AS Payer_Data,
				@VendorId AS DriverId,
				'*** Company Driver ***' AS DriverName,
				0 AS FederalIncome,
				'' AS Recipients_TaxId,
				'' AS Recipients_Address1,
				'' AS Recipients_Address2,
				'' AS Recipients_Telephone,
				'' AS Ten99Type,
				3 AS Ten99BoxNumber,
				0 AS ValidPeriod,
				1 AS Counter
END
ELSE
BEGIN
	SELECT	DISTINCT YEAR1 AS FiscalPeriod
	FROM	PM00204 
	WHERE	VENDORID = @DriverId
			AND YEAR1 > 2014
			AND (YEAR1 < YEAR(GETDATE())
			OR (YEAR1 = YEAR(GETDATE()) 
			AND GETDATE() >= ('01/31/' + CAST(YEAR(GETDATE()) AS Varchar))))
END