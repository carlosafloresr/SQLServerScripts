DECLARE	@FiscalYear			Char(4) = '2021',
		@Company			Varchar(5) = 'AIS'

DECLARE	@Query				Varchar(MAX),
		@VendorID			Varchar(15),
		@VendName			Varchar(100),
		@TxIDNmbr			Varchar(15),
		@Address1			Varchar(75),
		@Address2			Varchar(75),
		@City				Varchar(30),
		@State				Char(2),
		@ZipCode			Varchar(15),
		@UserDef1			Varchar(50),
		@CompanyName		Varchar(100),
		@TaxRegTn			Varchar(15),
		@CoAddress			Varchar(70),
		@CoCity				Varchar(30),
		@CoState			Char(2),
		@CoZipCode			Varchar(15),
		@Year1				Char(4),
		@Ten99Type			Smallint,
		@AmtpDlif			Numeric(12,2),
		@locContact			Varchar(30) = 'KIP REED',
		@locPhone			Varchar(20) = '9017463730',
		@locEmail			Varchar(50) = 'kreed@imcc.com',
		@locTrnsCode		Varchar(10) = '58423',
		@Counter			Int = 0,
		@RecordType			char(1),
		@ItemNumber			smallint,
		@FieldPosition		smallint,
		@FieldLenght		smallint,
		@FieldDescription	varchar(200),
		@CreatedOn			datetime,
		@SourceValue		varchar(100),
		@FileText			Text = ''

DECLARE @tbl1099Data	Table (
		VendorID		Varchar(15),
		VendName		Varchar(100),
		TxIDNmbr		Varchar(15),
		Address1		Varchar(75),
		Address2		Varchar(75),
		City			Varchar(30),
		State			Char(2),
		ZipCode			Varchar(15),
		UserDef1		Varchar(50),
		CompanyName		Varchar(100),
		TaxRegTn		Varchar(15),
		CoAddress		Varchar(70),
		CoCity			Varchar(30),
		CoState			Char(2),
		CoZipCode		Varchar(15),
		Year1			Char(4),
		Ten99Type		Smallint,
		AmtpDlif		Numeric(12,2))

SET @Query = N'SELECT 	PM00202.VendorID,
			UPPER(RTRIM(CASE  WHEN GPCustom.dbo.AT(''#'', VendName, 1) > 10 THEN LEFT(VendName, GPCustom.dbo.AT(''#'', VendName, 1) - 1) 
						WHEN GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VendName, 1) > 0 THEN LEFT(VendName, GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VendName, 1) - 1)
			ELSE VendName END)) AS VendName,
			PM00200.TxIDNmbr,
			PM00200.Address1,
			PM00200.Address2,
			PM00200.City,
			PM00200.State,
			PM00200.ZipCode,
			PM00200.UserDef1,
			SY01500.CmpnyNam AS CompanyName,
			SY01500.TaxRegTn,
			RTRIM(SY01500.Address1) + '' '' + SY01500.Address2 AS CoAddress,
			SY01500.City AS CoCity,
			SY01500.State AS CoState,
			SY01500.ZipCode AS CoZipCode,
			Year1,
			PM00200.Ten99Type,
			SUM(Ten99Alif) AS AmtpDlif
	FROM 	' + @Company + '.dbo.PM00202 PM00202
			INNER JOIN ' + @Company + '.dbo.PM00200 PM00200 ON PM00202.VendorID = PM00200.VendorID
			LEFT JOIN Dynamics.dbo.SY01500 SY01500 ON SY01500.InterId = ''' + @Company + ''' 
	WHERE 	HistType = 0
			AND PM00200.Ten99Type > 1
			AND PM00202.Year1 = ''' + @FiscalYear + ''' 
	GROUP BY 
			PM00202.VendorID,
			UPPER(RTRIM(CASE  WHEN GPCustom.dbo.AT(''#'', VendName, 1) > 10 THEN LEFT(VendName, GPCustom.dbo.AT(''#'', VendName, 1) - 1) 
						WHEN GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VendName, 1) > 0 THEN LEFT(VendName, GPCustom.dbo.AT(RTRIM(PM00200.VendorID), VendName, 1) - 1)
			ELSE VendName END)),
			PM00200.VendName,
			PM00200.TxIDNmbr,
			PM00200.Address1,
			PM00200.Address2,
			PM00200.City,
			PM00200.State,
			PM00200.ZipCode,
			PM00200.UserDef1,
			SY01500.CmpnyNam,
			SY01500.TaxRegTn,
			RTRIM(SY01500.Address1) + '' '' + SY01500.Address2,
			SY01500.City,
			SY01500.State,
			SY01500.ZipCode,
			Year1,
			PM00200.Ten99Type
	HAVING	SUM(Ten99Alif) > 599.99
	ORDER BY
			PM00200.VendName'
INSERT INTO @tbl1099Data
EXECUTE(@Query)

DECLARE cur1099Data CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	@tbl1099Data

OPEN cur1099Data 
FETCH FROM cur1099Data INTO @VendorID, @VendName, @TxIDNmbr, @Address1, @Address2, @City, @State, @ZipCode,
							@UserDef1, @CompanyName, @TaxRegTn, @CoAddress, @CoCity, @CoState, @CoZipCode, @Year1, @Ten99Type, @AmtpDlif

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Counter = @Counter + 1

	IF @Counter = 1
	BEGIN
		DECLARE curFileFields CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	ItemNumber, FieldPosition, FieldLenght, SourceValue
		FROM	IRS_1099_ExportFile
		WHERE	RecordType = 'T'
				AND FiscalYear = @FiscalYear
		ORDER BY ItemNumber

		OPEN curFileFields 
		FETCH FROM curFileFields INTO @ItemNumber, @FieldPosition, @FieldLenght, @SourceValue

		WHILE @@FETCH_STATUS = 0 
		BEGIN

			FETCH FROM curFileFields INTO @ItemNumber, @FieldPosition, @FieldLenght, @SourceValue
		END

		CLOSE curFileFields
		DEALLOCATE curFileFields
	END

	FETCH FROM cur1099Data INTO @VendorID, @VendName, @TxIDNmbr, @Address1, @Address2, @City, @State, @ZipCode,
								@UserDef1, @CompanyName, @TaxRegTn, @CoAddress, @CoCity, @CoState, @CoZipCode, @Year1, @Ten99Type, @AmtpDlif
END

CLOSE cur1099Data
DEALLOCATE cur1099Data

--SELECT	*
--FROM	IRS_1099_ExportFile

-- UPDATE IRS_1099_ExportFile SET FISCALYEAR = '2021'