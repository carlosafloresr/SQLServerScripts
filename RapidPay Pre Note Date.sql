/*
UPDATE	SY06000
SET		SY06000.EFTPRENOTEDATE = DATA.PreNoteDate
FROM	(
		SELECT	SYS.VENDORID,
				VND.VNDCLSID,
				SYS.ADRSCODE,
				SYS.EFTUSEMASTERID,
				SYS.EFTBANKTYPE,
				SYS.BANKNAME,
				SYS.EFTBANKACCT,
				SYS.EFTTRANSITROUTINGNO,
				SYS.EFTPRENOTEDATE,
				SYS.DEX_ROW_ID,
				RAP.RP_EffectiveDate,
				DATEADD(dd, -5, RAP.RP_EffectiveDate) AS PreNoteDate
		FROM	AIS.dbo.SY06000 SYS
				INNER JOIN AIS.dbo.PM00200 VND ON SYS.VENDORID = VND.VENDORID
				INNER JOIN GPCUSTOM.DBO.GPVENDORMASTER RAP ON SYS.VENDORID = RAP.VENDORID AND RAP.RAPIDPAY = 1
		WHERE	SYS.ADRSCODE = 'REMIT'
		) DATA
WHERE	SY06000.DEX_ROW_ID = DATA.DEX_ROW_ID
		AND SY06000.EFTPRENOTEDATE < '01/01/1900'

SELECT TOP 100 * FROM GPCUSTOM.DBO.GPVENDORMASTER WHERE VENDORID = '1151'
*/
DECLARE @Company			Varchar(5),
		@Query				Varchar(MAX)

DECLARE @tblGPData			Table (
		COMPANY				Varchar(5),
		VENDORID			Varchar(15),
		VENDCLASS			Varchar(15),
		ADRSCODE			Varchar(15),
		EFTUSEMASTERID		Smallint,
		EFTBANKTYPE			Smallint,
		BANKNAME			Varchar(30),
		EFTBANKACCT			Varchar(30),
		EFTTRANSITROUTINGNO	Varchar(30),
		EFTPRENOTEDATE		Date,
		DEX_ROW_ID			Int,
		IsRapidPay			Varchar(3),
		INACTIVE			Bit)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT LTRIM(RTRIM(CompanyId))
FROM	GPCustom.dbo.Companies 
WHERE	CompanyId IN (SELECT CompanyId FROM GPCustom.dbo.Companies_Parameters WHERE ParameterCode = 'RAISTONE' AND ParBit = 1)

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT ''' + @Company + ''' AS Company,
		SYS.VENDORID,
		VND.VNDCLSID,
		SYS.ADRSCODE,
		SYS.EFTUSEMASTERID,
		SYS.EFTBANKTYPE,
		SYS.BANKNAME,
		SYS.EFTBANKACCT,
		SYS.EFTTRANSITROUTINGNO,
		CAST(SYS.EFTPRENOTEDATE AS Date) AS EFTPRENOTEDATE,
		SYS.DEX_ROW_ID,
		IIF(RAP.RAPIDPAY = 1, ''YES'', ''NO'') AS IsRapidPay,
		SYS.INACTIVE
FROM	' + @Company + '.dbo.SY06000 SYS
		INNER JOIN ' + @Company + '.dbo.PM00200 VND ON SYS.VENDORID = VND.VENDORID
		LEFT JOIN GPCUSTOM.DBO.GPVENDORMASTER RAP ON SYS.VENDORID = RAP.VENDORID AND RAP.RAPIDPAY = 1 AND RAP.Company = ''' + @Company + ''' 
WHERE	VND.VNDCLSID = ''TRDR'' 
ORDER BY 10, 6'

	INSERT INTO @tblGPData 
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies 

SELECT	*
FROM	@tblGPData
ORDER BY Company, IsRapidPay, VendorId

/*
UPDATE	SY06000
SET		EFTPRENOTEDATE = DATEADD(dd, -5, '05/18/2022')
WHERE	DEX_ROW_ID = 634
*/