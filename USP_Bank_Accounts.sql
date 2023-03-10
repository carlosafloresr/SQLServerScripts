USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_Bank_Accounts]    Script Date: 5/1/2020 10:13:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Bank_Accounts 1
*/
ALTER PROCEDURE [dbo].[USP_Bank_Accounts]
		@JustCompanies	Bit = 0
AS
DECLARE	@Query			Varchar(MAX) = '',
		@Company		Varchar(5),
		@CompanyId		Int,
		@CompanyName	Varchar(100)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(InterId),
		CmpanyId,
		RTRIM(CmpnyNam)
FROM	DYNAMICS.dbo.View_AllCompanies
WHERE	InterId NOT IN ('ABS','ATEST','FI','RCMR')
		AND InterId NOT LIKE 'HIS%'
ORDER BY CmpnyNam

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company, @CompanyId, @CompanyName

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF @JustCompanies = 0
	BEGIN
		SET @Query = @Query + CASE WHEN @Query = '' THEN '' ELSE CHAR(13) + 'UNION ' + CHAR(13) END + N'SELECT	''' + RTRIM(@Company) + ''' AS Company,
				RTRIM(CHEKBKID) AS CHEKBKID, 
				RTRIM(BNKACTNM) AS BNKACTNM, 
				' + RTRIM(CAST(@CompanyId AS Varchar)) + ' AS CMPANYID, 
				Last_Reconciled_Date, 
				RTRIM(ACTNUMST) AS ACTNUMST, 
				INACTIVE
		FROM    ' + RTRIM(@Company) + '.dbo.CM00100 WITH (NOLOCK) 
				LEFT OUTER JOIN ' + RTRIM(@Company) + '.dbo.GL00105 ON CM00100.ACTINDX = GL00105.ACTINDX
		WHERE   RTRIM(BNKACTNM) <> '''''
	END
	ELSE
	BEGIN
		SET @Query = @Query + CASE WHEN @Query = '' THEN '' ELSE CHAR(13) + 'UNION ' + CHAR(13) END 
			+ N'SELECT	DISTINCT ''' + RTRIM(@Company) + ''' AS Company, ''' + @CompanyName + ''' AS CompanyName
		FROM    ' + RTRIM(@Company) + '.dbo.CM00100 WITH (NOLOCK) 
		WHERE   RTRIM(BNKACTNM) <> '''''
	END

	FETCH FROM curCompanies INTO @Company, @CompanyId, @CompanyName
END

CLOSE curCompanies
DEALLOCATE curCompanies

IF @Query <> ''
BEGIN
	IF @JustCompanies = 1
		SET @Query = @Query + ' ORDER BY 2'

	EXECUTE(@Query)
END