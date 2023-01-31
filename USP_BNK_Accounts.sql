/*
EXECUTE USP_BNK_Accounts
*/
ALTER PROCEDURE USP_BNK_Accounts
AS
DECLARE	@Query			Varchar(MAX),
		@Company		Varchar(5)

DECLARE	@tblAccounts	Table (
		CHEKBKID				Varchar(30), 
		BNKACTNM				Varchar(100), 
		CMPANYID				Int,
		DBName					Varchar(5),
		Last_Reconciled_Date	Date, 
		ACTNUMST				Varchar(30), 
		INACTIVE				Int)

DECLARE curDynamicsCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT 	RTRIM(InterId)
FROM 	Dynamics.dbo.SY01500
WHERE	CmpnyNam NOT LIKE '%TEST%'
		AND CmpnyNam NOT LIKE '%HISTORI%'

OPEN curDynamicsCompanies 
FETCH FROM curDynamicsCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT CM.CHEKBKID, 
		CM.BNKACTNM, 
		CM.CMPANYID,
		RTRIM(SY.InterId) AS DBName,
		CM.Last_Reconciled_Date, 
		RTRIM(GL.ACTNUMST) AS ACTNUMST, 
		CM.INACTIVE
FROM    ' + @Company + '.dbo.CM00100 CM WITH (NOLOCK)
		INNER JOIN Dynamics.dbo.SY01500 SY ON CM.CMPANYID = SY.CMPANYID
		LEFT OUTER JOIN ' + @Company + '.dbo.GL00105 GL ON CM.ACTINDX = GL.ACTINDX
WHERE   INACTIVE = 0 
		AND RTRIM(BNKACTNM) <> '''''
		
	INSERT INTO @tblAccounts
	EXECUTE(@Query)

	FETCH FROM curDynamicsCompanies INTO @Company
END

CLOSE curDynamicsCompanies
DEALLOCATE curDynamicsCompanies

SELECT	*
FROM	@tblAccounts
ORDER BY DBName, BNKACTNM