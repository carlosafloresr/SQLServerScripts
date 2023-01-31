DECLARE	@Company		Varchar(5) = 'AIS',
		@DriverId		Varchar(15) = 'A50157',
		@Year			Int = 2017

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
		@tmpHTML		Varchar(MAX) = '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;width: 660;">' + CHAR(13)

SELECT	@CpyTaxId		= RTRIM(TaxRegTN),
		@CompanyName	= UPPER(RTRIM(CmpnyNam)),
		@CpyAddress1	= RTRIM(Address1),
		@CpyAddress2	= RTRIM(Address2),
		@CpyCity		= RTRIM(City),
		@CpyState		= RTRIM(State),
		@CpyZipCode		= RTRIM(ZipCode),
		@CpyPhone		= RTRIM(Phone1)
FROM	DYNAMICS.dbo.View_AllCompanies 
WHERE	InterId			= DB_NAME()

SELECT	@VendorId		= RTRIM(v.VENDORID),
		@VendorName		= UPPER(RTRIM(v.VENDNAME)),
		@TotalPayments	= CAST(COALESCE(hp.Pmts,0) + COALESCE(op.Pmts,0) AS Numeric(10,2)),
		@TaxId			= v.TXIDNMBR,
		@Address1		= IIF(v.ADDRESS2 = '', v.ADDRESS1, v.ADDRESS2),
		@Address2		= v.ADDRESS3,
		@City			= UPPER(RTRIM(v.CITY)),
		@State			= RTRIM(v.[STATE]),
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
						  END
FROM	PM00200 v
		LEFT OUTER JOIN (SELECT	VENDORID, 
								SUM(DOCAMNT) AS Pmts
						FROM	PM30200
						WHERE	DOCTYPE = 6 
								AND VOIDED = 0
								AND YEAR(DOCDATE) = @Year
						GROUP BY VENDORID) hp ON v.VENDORID = hp.VENDORID
		LEFT OUTER JOIN (SELECT	VENDORID, 
								SUM(DOCAMNT) AS Pmts
						FROM	PM20000
						WHERE	DOCTYPE = 6 
								AND VOIDED = 0
								AND YEAR(DOCDATE) = @Year
						GROUP BY VENDORID) op ON v.VENDORID = op.VENDORID
WHERE	v.TEN99TYPE <> 1
		AND v.VNDCLSID = 'DRV'
		AND COALESCE(hp.Pmts,0) + COALESCE(op.Pmts,0) <> 0
		AND v.VENDORID = @DriverId

IF GPCustom.dbo.AT('#', @VendorName, 1) > 0
	SET @VendorName = RTRIM(LEFT(@VendorName, GPCustom.dbo.AT('#', @VendorName, 1) - 1))

-- DRIVER ADDRESS
SET @Address01 = RTRIM(@Address1) + CHAR(13)

IF @Address2 <> ''
	SET @Address01 = @Address01 + RTRIM(@Address2)

IF @City <> ''
	SET @Address02 = RTRIM(@City)

IF @State <> ''
	SET @Address02 = @Address02 + ', ' + RTRIM(@State)

IF @ZipCode <> ''
	SET @Address02 = @Address02 + ' ' + RTRIM(@ZipCode)

-- COMPANY ADDRESS
SET @CompanyData = @CompanyName + CHAR(13)

SET @CompanyData = @CompanyData + RTRIM(@CpyAddress1) + CHAR(13)

IF @Address2 <> ''
	SET @CompanyData = @CompanyData + RTRIM(@CpyAddress2) + CHAR(13)

IF @City <> ''
	SET @CompanyData = @CompanyData + RTRIM(@CpyCity)

IF @State <> ''
	SET @CompanyData = @CompanyData + ', ' + RTRIM(@CpyState)

IF @ZipCode <> ''
	SET @CompanyData = @CompanyData + ' ' + RTRIM(@CpyZipCode)

SELECT	@Year AS ReportYear,
		@CpyTaxId AS Payers_TaxId,
		@CompanyData AS Payer_Data,
		@VendorId AS DriverId,
		@VendorName AS DriverName,
		@TotalPayments AS FederalIncome,
		@TaxId AS Recipients_TaxId,
		@Address01 AS Recipients_Address1,
		@Address02 AS Recipients_Address2,
		@Phone AS Recipients_Telephone,
		@Ten99Type AS Ten99Type

PRINT @CompanyData

--SET @tmpHTML = @tmpHTML + '<tr><td style="width: 100%;"><table><tr>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<td style="text-align:center; width: 498px; background-color:Black; color: White;">1099-MISC</td>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<td style="text-align:center;  width: 140px; background-color:White; color: Black; font-size: 26pt; font-weight: bold;">' + CAST(@Year AS Varchar) + '</td>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '</tr></table></td></tr>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<tr><td><table><tr>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<td style="text-align:center; width: 70px; background-color:Silver">Driver Id</td><td style="width: 70px; color:Blue">' + @VendorId + '</td>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<td style="text-align:center; width: 90px; background-color:Silver">Driver Name</td><td style="width: 200px;color:Blue">' + @VendorName + '</td>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<td style="text-align:center; width: 60px; background-color:Silver">TAX ID</td><td style="width: 100px; color:Blue; text-align:center;">' + @TaxId + '</td>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '</tr></table></td></tr>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<tr><td><table><tr>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<td style="text-align:center; width: 100px; background-color:Silver">1099 Type</td><td style="width: 304px;color:Blue">' + @Ten99Type + '</td>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<td style="text-align:center; width: 90px; background-color:Silver">Total Paid</td><td style="width: 110px;color:Blue; text-align:right;">$ ' + FORMAT(@TotalPayments,'N','en-us') + '</td>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '</tr></table></td></tr>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<tr><td><table><tr>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<td style="text-align:center; width: 100px; background-color:Silver">Address</td><td style="width: 304px;color:Blue">' + @Address + '</td>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '<td style="text-align:center; width: 90px; background-color:Silver">Phone</td><td style="width: 150px;color:Blue; text-align:center;">' + GPCustom.dbo.FormatPhoneNumber(@Phone) + '</td>' + CHAR(13)
--SET @tmpHTML = @tmpHTML + '</tr></table></td></tr>' + CHAR(13)

--SET @tmpHTML = @tmpHTML + '</table>'

--PRINT @tmpHTML