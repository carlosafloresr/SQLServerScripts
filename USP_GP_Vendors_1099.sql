USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GP_Vendors_1099]    Script Date: 1/17/2023 2:20:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GP_Vendors_1099 'GLSO', 2022
*/
ALTER PROCEDURE [dbo].[USP_GP_Vendors_1099]
		@Company		Varchar(5),
		@Year			Int
AS
/*
========================================================================================================================
VERSION		MODIFIED	USER				MODIFICATION
========================================================================================================================
1.0			12/22/2022	Carlos A. Flores	Created for the IRS 1099 export file
========================================================================================================================
*/
SET NOCOUNT ON

DECLARE @Query			Varchar(MAX)

DECLARE @tblVndData		Table (
		VendorID		Varchar(20),
		VendName		Varchar(70),
		TxIDNmbr		Varchar(30),
		Address1		Varchar(70),
		Address2		Varchar(70),
		City			Varchar(50),
		State			Varchar(30),
		ZipCode			Varchar(25),
		UserDef1		Varchar(150),
		CompanyName		Varchar(100),
		TaxRegTn		Varchar(30),
		CoAddress		Varchar(100),
		CoCity			Varchar(50),
		CoState			Varchar(30),
		CoZipCode		Varchar(25),
		Year1			Int,
		Ten99Type		Smallint,
		AmtpDlif		Numeric(10,2))

SET @Query = N'SELECT 	RTRIM(PM00202.VendorID),
			IIF(PM00200.VENDDBA <> '''', UPPER(RTRIM(PM00200.VENDDBA)),	UPPER(RTRIM(CASE  WHEN GPCustom.dbo.AT(''#'', VendName, 1) > 10 THEN LEFT(VendName, GPCustom.dbo.AT(''#'', VendName, 1) - 1) 
						WHEN GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VendName, 1) > 0 THEN LEFT(VendName, GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VendName, 1) - 1)
			ELSE VendName END))) AS VendName,
			RTRIM(PM00200.TxIDNmbr),
			RTRIM(ISNULL(PM00300.Address1, PM00200.Address1)) AS Address1,
			RTRIM(ISNULL(PM00300.Address2, PM00200.Address2)) AS Address2,
			RTRIM(ISNULL(PM00300.City, PM00200.City)) AS City,
			RTRIM(ISNULL(PM00300.State, PM00200.State)) AS State,
			RTRIM(ISNULL(PM00300.ZipCode, PM00200.ZipCode)) AS ZipCode,
			RTRIM(PM00200.UserDef1),
			RTRIM(SY01500.CmpnyNam) AS CompanyName,
			RTRIM(SY01500.TaxRegTn),
			RTRIM(SY01500.Address1) + '' '' + RTRIM(SY01500.Address2) AS CoAddress,
			RTRIM(SY01500.City) AS CoCity,
			RTRIM(SY01500.State) AS CoState,
			RTRIM(SY01500.ZipCode) AS CoZipCode,
			Year1,
			PM00200.Ten99Type,
			SUM(Ten99Alif) AS AmtpDlif
	FROM 	' + @Company + '.dbo.PM00202 PM00202
			INNER JOIN ' + @Company + '.dbo.PM00200 PM00200 ON PM00202.VendorID = PM00200.VendorID
			INNER JOIN ' + @Company + '.dbo.PM00300 PM00300 ON PM00202.VendorID = PM00300.VendorID AND PM00300.ADRSCODE = ''MAIN''
			LEFT JOIN Dynamics.dbo.SY01500 SY01500 ON SY01500.InterId = ''' + @Company + ''' 
	WHERE 	HistType = 0
			AND PM00200.Ten99Type > 1
			AND PM00202.Year1 = 2022
	GROUP BY 
			PM00202.VendorID,
			IIF(PM00200.VENDDBA <> '''', UPPER(RTRIM(PM00200.VENDDBA)),	UPPER(RTRIM(CASE  WHEN GPCustom.dbo.AT(''#'', VendName, 1) > 10 THEN LEFT(VendName, GPCustom.dbo.AT(''#'', VendName, 1) - 1) 
						WHEN GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VendName, 1) > 0 THEN LEFT(VendName, GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VendName, 1) - 1)
			ELSE VendName END))),
			PM00200.VendName,
			PM00200.TxIDNmbr,
			RTRIM(ISNULL(PM00300.Address1, PM00200.Address1)),
			RTRIM(ISNULL(PM00300.Address2, PM00200.Address2)),
			RTRIM(ISNULL(PM00300.City, PM00200.City)),
			RTRIM(ISNULL(PM00300.State, PM00200.State)),
			RTRIM(ISNULL(PM00300.ZipCode, PM00200.ZipCode)),
			PM00200.UserDef1,
			SY01500.CmpnyNam,
			SY01500.TaxRegTn,
			RTRIM(SY01500.Address1) + '' '' + RTRIM(SY01500.Address2),
			SY01500.City,
			SY01500.State,
			SY01500.ZipCode,
			Year1,
			PM00200.Ten99Type
	HAVING	SUM(Ten99Alif) > 599.99
	ORDER BY
			PM00200.VendName'
--PRINT @Query
INSERT INTO @tblVndData
EXECUTE(@Query)

SELECT	VendorID,
		VendName,
		TxIDNmbr,
		IIF(GPCustom.dbo.AT(VendorID, Address1, 1) > 0, Address2, Address1) AS Address1,
		IIF(GPCustom.dbo.AT(VendorID, Address1, 1) > 0, '', Address2) AS Address2,
		City,
		State,
		ZipCode,
		UserDef1,
		CompanyName,
		TaxRegTn,
		CoAddress,
		CoCity,
		CoState,
		CoZipCode,
		Year1,
		Ten99Type,
		AmtpDlif
FROM	@tblVndData
ORDER BY VendName