DECLARE	@tblCustomers TABLE
	(CompanyId	varchar(6),
	CustNmbr	varchar(15),
	CustName	varchar(70),
	CustClas	varchar(15),
	Address1	varchar(65),
	Address2	varchar(65),
	City		varchar(75),
	[State]		varchar(29),
	Zip			varchar(20),
	Phone1		varchar(35),
	Inactive	bit,
	Hold		bit,
	CntCprsn	varchar(61),
	SalsTerr	varchar(15))

DECLARE	@Company	Varchar(5),
		@Query		Varchar(MAX)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyId)
FROM	Companies
WHERE	SWSCustomers = 1

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT ''' + @Company + ''',
			CustNmbr,
			CustName,
			CustClas,
			Address1,
			Address2,
			City,
			State,
			Zip,
			Phone1,
			Inactive,
			Hold,
			CntCprsn,
			SalsTerr
	FROM	' + @Company + '.dbo.RM00101 
	WHERE	CustName <> '''''

	INSERT INTO @tblCustomers
	EXECUTE(@Query)	

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

UPDATE	CustomerMaster
SET		CustomerMaster.CustName		= DATA.CustName,
		CustomerMaster.CustClas		= DATA.CustClas,
		CustomerMaster.Address1		= DATA.Address1,
		CustomerMaster.Address2		= DATA.Address2,
		CustomerMaster.City			= DATA.City,
		CustomerMaster.State		= DATA.State,
		CustomerMaster.Zip			= DATA.Zip,
		CustomerMaster.Phone1		= DATA.Phone1,
		CustomerMaster.Inactive		= DATA.Inactive,
		CustomerMaster.Hold			= DATA.Hold,
		CustomerMaster.CntCprsn		= DATA.CntCprsn,
		CustomerMaster.SalsTerr		= DATA.SalsTerr,
		CustomerMaster.Changed		= 1,
		CustomerMaster.Trasmitted	= 0,
		CustomerMaster.ChangedBy	= 'USER',
		CustomerMaster.Result		= ''
FROM	@tblCustomers DATA
WHERE	CustomerMaster.CompanyId = DATA.CompanyId
		AND CustomerMaster.CUSTNMBR = DATA.CUSTNMBR
		AND (CustomerMaster.CustName <> DATA.CustName
		OR CustomerMaster.CustClas <> DATA.CustClas
		OR CustomerMaster.Address1 <> DATA.Address1
		OR CustomerMaster.Address2 <> DATA.Address2
		OR CustomerMaster.City <> DATA.City
		OR CustomerMaster.State <> DATA.State
		OR CustomerMaster.Zip <> DATA.Zip
		OR CustomerMaster.Phone1 <> DATA.Phone1
		OR CustomerMaster.Inactive <> DATA.Inactive
		OR CustomerMaster.Hold <> DATA.Hold
		OR CustomerMaster.CntCprsn <> DATA.CntCprsn
		OR CustomerMaster.SalsTerr <> DATA.SalsTerr)

INSERT INTO CustomerMaster
		   (CompanyId,
			CustNmbr,
			CustName,
			CustClas,
			Address1,
			Address2,
			City,
			State,
			Zip,
			Phone1,
			Inactive,
			Hold,
			CntCprsn,
			SalsTerr,
			Changed,
			Trasmitted,
			ChangedBy,
			Result)
	SELECT	CompanyId,
			CustNmbr,
			CustName,
			CustClas,
			Address1,
			Address2,
			City,
			State,
			Zip,
			Phone1,
			Inactive,
			Hold,
			CntCprsn,
			SalsTerr,
			CAST(1 AS Bit) AS Changed,
			CAST(0 AS Bit) AS Trasmitted,
			'USER' AS ChangedBy,
			'' AS Result
	FROM	@tblCustomers
	WHERE	RTRIM(CompanyId) + RTRIM(CustNmbr) NOT IN (SELECT RTRIM(CompanyId) + RTRIM(CustNmbr) FROM CustomerMaster)
			AND Inactive = 0

SELECT	*
FROM	CustomerMaster
WHERE	Changed = 1