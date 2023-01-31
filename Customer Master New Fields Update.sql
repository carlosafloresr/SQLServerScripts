DECLARE @Query				Varchar(2000),
		@Company			Varchar(5)

DECLARE @tblCustData		Table (
		COMPANY				Varchar(5),
		CUSTNMBR			Varchar(15),
		STMTNAME			Varchar(65),
		ADRSCODE			Varchar(15),
		CHEKBKID			Varchar(15),
		CRLMTAMT			Numeric(12,2),
		CRLMTTYP			Smallint,
		MXWOFTYP			Smallint,
		MXWROFAM			Numeric(12,2),
		TAXEXMT1			Varchar(25),
		TAXEXMT2			Varchar(25),
		TXRGNNUM			Varchar(25),
		STMTCYCL			Smallint,
		BALNCTYP			Smallint,
		BANKNAME			Varchar(31),
		BNKBRNCH			Varchar(21),
		COMMENT1			Varchar(31),
		COMMENT2			Varchar(31),
		USERDEF1			Varchar(21),
		USERDEF2			Varchar(21),
		COUNTRY				Varchar(61),
		CPRCSTNM			Varchar(15),
		CRLMTPAM			numeric(19, 5),
		CRLMTPER			smallint,
		CURNCYID			Varchar(15),
		CUSTDISC			smallint,
		FAX					Varchar(21),
		PHONE2				Varchar(21),
		PHONE3				Varchar(21),
		FNCHATYP			smallint,
		FNCHPCNT			smallint,
		FINCHDLR			numeric(19, 5),
		MINPYTYP			smallint,
		MINPYDLR			numeric(19, 5),
		MINPYPCT			smallint,
		PRBTADCD			Varchar(15),
		PRSTADCD			Varchar(15),
		PRCLEVEL			Varchar(11),
		SHRTNAME			Varchar(15),
		STADDRCD			Varchar(15))

DECLARE OOS_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT RTRIM(CompanyId)
FROM	CustomerMaster
WHERE	CompanyId NOT IN ('', 'ATEST','GSA','IMCT','TISO')

OPEN OOS_Companies 
FETCH FROM OOS_Companies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT ''' + RTRIM(@Company) + ''',
		RTRIM([CUSTNMBR]),
		RTRIM([STMTNAME]),
		RTRIM([ADRSCODE]),
		RTRIM([CHEKBKID]),
		[CRLMTAMT],
		[CRLMTTYP],
		[MXWOFTYP],
		[MXWROFAM],
		RTRIM([TAXEXMT1]),
		RTRIM([TAXEXMT2]),
		RTRIM([TXRGNNUM]),
		[STMTCYCL],
		BALNCTYP,
		RTRIM(BANKNAME),
		RTRIM(BNKBRNCH),
		RTRIM(COMMENT1),
		RTRIM(COMMENT2),
		RTRIM(USERDEF1),
		RTRIM(USERDEF2),
		RTRIM(COUNTRY),
		RTRIM(CPRCSTNM),
		CRLMTPAM,
		CRLMTPER,
		RTRIM(CURNCYID),
		CUSTDISC,
		RTRIM(FAX),
		RTRIM(PHONE2),
		RTRIM(PHONE3),
		FNCHATYP,
		FNCHPCNT,
		FINCHDLR,
		MINPYTYP,
		MINPYDLR,
		MINPYPCT,
		RTRIM(PRBTADCD),
		RTRIM(PRSTADCD),
		RTRIM(PRCLEVEL),
		RTRIM(SHRTNAME),
		RTRIM(STADDRCD)
	FROM ' + RTRIM(@Company) + '.dbo.RM00101'

	INSERT INTO @tblCustData
	EXECUTE(@Query)

	FETCH FROM OOS_Companies INTO @Company
END

CLOSE OOS_Companies
DEALLOCATE OOS_Companies

UPDATE 	CustomerMaster
SET		CustomerMaster.STMTNAME	= DATA.STMTNAME,
		CustomerMaster.ADRSCODE	= DATA.ADRSCODE,
		CustomerMaster.CHEKBKID	= DATA.CHEKBKID,
		CustomerMaster.CRLMTAMT = DATA.CRLMTAMT,
		CustomerMaster.CRLMTTYP = DATA.CRLMTTYP,
		CustomerMaster.MXWOFTYP = DATA.MXWOFTYP,
		CustomerMaster.MXWROFAM = DATA.MXWROFAM,
		CustomerMaster.TAXEXMT1 = DATA.TAXEXMT1,
		CustomerMaster.TAXEXMT2 = DATA.TAXEXMT2,
		CustomerMaster.TXRGNNUM = DATA.TXRGNNUM,
		CustomerMaster.STMTCYCL = DATA.STMTCYCL,
		CustomerMaster.BALNCTYP = DATA.BALNCTYP,
		CustomerMaster.BANKNAME = DATA.BANKNAME,
		CustomerMaster.BNKBRNCH = DATA.BNKBRNCH,
		CustomerMaster.COMMENT1 = DATA.COMMENT1,
		CustomerMaster.COMMENT2 = DATA.COMMENT2,
		CustomerMaster.USERDEF1 = DATA.USERDEF1,
		CustomerMaster.USERDEF2 = DATA.USERDEF2,
		CustomerMaster.COUNTRY  = DATA.COUNTRY,
		CustomerMaster.CPRCSTNM = DATA.CPRCSTNM,
		CustomerMaster.CRLMTPAM = DATA.CRLMTPAM,
		CustomerMaster.CRLMTPER = DATA.CRLMTPER,
		CustomerMaster.CURNCYID = DATA.CURNCYID,
		CustomerMaster.CUSTDISC = DATA.CUSTDISC,
		CustomerMaster.FAX		= DATA.FAX,
		CustomerMaster.PHONE2   = DATA.PHONE2,
		CustomerMaster.PHONE3   = DATA.PHONE3,
		CustomerMaster.FNCHATYP = DATA.FNCHATYP,
		CustomerMaster.FNCHPCNT = DATA.FNCHPCNT,
		CustomerMaster.FINCHDLR = DATA.FINCHDLR,
		CustomerMaster.MINPYTYP = DATA.MINPYTYP,
		CustomerMaster.MINPYDLR = DATA.MINPYDLR,
		CustomerMaster.MINPYPCT = DATA.MINPYPCT,
		CustomerMaster.PRBTADCD = DATA.PRBTADCD,
		CustomerMaster.PRSTADCD = DATA.PRSTADCD,
		CustomerMaster.PRCLEVEL = DATA.PRCLEVEL,
		CustomerMaster.SHRTNAME = DATA.SHRTNAME,
		CustomerMaster.STADDRCD = DATA.STADDRCD
FROM	@tblCustData DATA
WHERE	CustomerMaster.CompanyId = DATA.COMPANY
		AND CustomerMaster.CustNmbr = DATA.CUSTNMBR

SELECT	TOP 1000 *
FROM	CustomerMaster
WHERE	CompanyId NOT IN ('', 'ATEST','GSA','IMCT','TISO')