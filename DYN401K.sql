ALTER PROCEDURE DYN401K 
	@DBName VARCHAR(5),
	@StartDate VARCHAR(25), 
	@EndDate VARCHAR(25),
	@StartDednCode VARCHAR(7),
	@EndDednCode VARCHAR(7),
	@StartBeneCode VARCHAR(7),
	@EndBeneCode VARCHAR(7),
	@LoanCode VARCHAR(7),
	@EmpOptions SMALLINT,
	@UserID VARCHAR(30)   
AS
DECLARE @SQLStr VARCHAR(500)

SET @SQLStr = 'EXECUTE ' + @DBName + '..Load401K ' + CHAR(39) + @StartDate + CHAR(39) + ',' + CHAR(39) + @EndDate 
SET @SQLStr = @SQLStr + CHAR(39) + ',' + CHAR(39) + @StartDednCode + CHAR(39) + ',' + CHAR(39) +  @EndDednCode
SET @SQLStr = @SQLStr + CHAR(39) + ',' + CHAR(39) + @StartBeneCode + CHAR(39) + ',' + CHAR(39) +  @EndBeneCode
SET @SQLStr = @SQLStr + CHAR(39) + ',' + CHAR(39) + @LoanCode + CHAR(39) + ',' + LTRIM(STR(@EmpOptions))
SET @SQLStr = @SQLStr + ',' + CHAR(39) +  @UserID + CHAR(39) 

PRINT @SQLStr 

EXECUTE (@SQLStr)

GO
