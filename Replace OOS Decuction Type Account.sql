DECLARE	@Company	Varchar(5) = 'PTS',
		@ACTNUMST	Varchar(15) = '0-00-6170',
		@ACTINDX	Int,
		@Query		Varchar(Max)

DECLARE	@tblAccount Table (ACTINDX Int)

SET @Query = N'SELECT ACTINDX FROM ' + RTRIM(@Company) + '.dbo.GL00105 WHERE ACTNUMST = ''' + RTRIM(@ACTNUMST) + ''''

INSERT INTO @tblAccount
EXECUTE(@Query)

SET @ACTINDX = (SELECT ACTINDX FROM @tblAccount)

UPDATE	[GPCustom].[dbo].[OOS_DeductionTypes]
SET		CreditAccount = @ACTNUMST,
		CrdAcctIndex = @ACTINDX
WHERE	SpecialDeduction = 1
		and Company = @Company

