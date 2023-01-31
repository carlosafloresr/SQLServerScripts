DECLARE	@Company				Varchar(5) = DB_NAME(),
		@Year					Int = 2019

DECLARE @tbl1099Vendors			Table (
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
		ValidPeriod				Bit,
		Counter					Int)

DECLARE @tbl1099Forms			Table (
		VendorID				char(15) NOT NULL,
		VndChkNm				varchar(65) NULL,
		TxIDNmbr				char(11) NOT NULL,
		Address1				char(61) NOT NULL,
		Address2				char(61) NOT NULL,
		City					char(35) NOT NULL,
		State					char(29) NOT NULL,
		ZipCode					char(11) NOT NULL,
		UserDef1				char(21) NOT NULL,
		CompanyName				char(65) NULL,
		TaxRegTn				char(25) NULL,
		CoAddress				varchar(123) NULL,
		CoCity					char(35) NULL,
		CoState					char(29) NULL,
		CoZipCode				char(11) NULL,
		Year1					smallint NOT NULL,
		Ten99Type				smallint NOT NULL,
		AmtpDlif				numeric(10, 2) NULL)

INSERT INTO @tbl1099Vendors
EXECUTE USP_Driver_1099 @Company, NULL, @Year, 0

INSERT INTO @tbl1099Forms
	SELECT 	PM00202.VendorID,
			UPPER(RTRIM(CASE  WHEN GPCustom.dbo.AT('#', VndChkNm, 1) > 10 THEN LEFT(VndChkNm, GPCustom.dbo.AT('#', VndChkNm, 1) - 1) 
						WHEN GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VndChkNm, 1) > 0 THEN LEFT(VndChkNm, GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VndChkNm, 1) - 1)
			ELSE VndChkNm END)) AS VndChkNm,
			PM00200.TxIDNmbr,
			PM00200.Address1,
			PM00200.Address2,
			PM00200.City,
			PM00200.State,
			PM00200.ZipCode,
			PM00200.UserDef1,
			SY01500.CmpnyNam AS CompanyName,
			SY01500.TaxRegTn,
			RTRIM(SY01500.Address1) + ' ' + SY01500.Address2 AS CoAddress,
			SY01500.City AS CoCity,
			SY01500.State AS CoState,
			SY01500.ZipCode AS CoZipCode,
			Year1,
			PM00200.Ten99Type,
			SUM(Ten99Alif) AS AmtpDlif
	FROM 	dbo.PM00202 PM00202
			INNER JOIN dbo.PM00200 PM00200 ON PM00202.VendorID = PM00200.VendorID
			LEFT JOIN Dynamics.dbo.SY01500 SY01500 ON SY01500.InterId = @Company
	WHERE 	HistType = 0
			AND PM00200.Ten99Type > 1
			AND PM00202.Year1 = @Year
			AND PM00200.VndClsId IN ('DRV','MSC','MSCO','TRD','MSCE')
	GROUP BY 
			PM00202.VendorID,
			UPPER(RTRIM(CASE  WHEN GPCustom.dbo.AT('#', VndChkNm, 1) > 10 THEN LEFT(VndChkNm, GPCustom.dbo.AT('#', VndChkNm, 1) - 1) 
						WHEN GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VndChkNm, 1) > 0 THEN LEFT(VndChkNm, GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VndChkNm, 1) - 1)
			ELSE VndChkNm END)),
			PM00200.VndChkNm,
			PM00200.TxIDNmbr,
			PM00200.Address1,
			PM00200.Address2,
			PM00200.City,
			PM00200.State,
			PM00200.ZipCode,
			PM00200.UserDef1,
			SY01500.CmpnyNam,
			SY01500.TaxRegTn,
			RTRIM(SY01500.Address1) + ' ' + SY01500.Address2,
			SY01500.City,
			SY01500.State,
			SY01500.ZipCode,
			Year1,
			PM00200.Ten99Type
	HAVING	SUM(Ten99Alif) > 599.99
	ORDER BY
			PM00202.VendorID

--SELECT	*
--FROM	@tbl1099Vendors

--SELECT	*
--FROM	@tbl1099Forms

SELECT	VND.DriverId,
		VND.FederalIncome,
		FRM.AmtpDlif,
		VND.FederalIncome - FRM.AmtpDlif AS Difference
FROM	@tbl1099Vendors VND
		INNER JOIN @tbl1099Forms FRM ON VND.DriverId = FRM.VendorId