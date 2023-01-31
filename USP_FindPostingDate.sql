/*
EXECUTE USP_FindPostingDate 'IMC', 'AP', '03/15/2022'
*/
ALTER PROCEDURE USP_FindPostingDate
		@Company		Varchar(5),
		@Series			Char(2),
		@PostingDate	Date
AS
SET NOCOUNT ON

DECLARE @Query			Varchar(2000),
		@CmpyNumber		Int,
		@PostDateNew	Date,
		@PeriodClosed	Bit,
		@ReturnDate		Date,
		@GLSeries		Smallint

SET @GLSeries = (CASE WHEN @Series = 'AR' THEN 3 WHEN @Series = 'AP' THEN 4 ELSE 2 END)

DECLARE @tblFiscalPrd	Table (PeriodClosed Bit, StartDate Date, EndDate Date)
DECLARE @tblActiveDate	Table (ClosingDate Date)

SET @ReturnDate = @PostingDate
SET @CmpyNumber = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)
SET @Query		= N'SELECT InvDate FROM Com.Company WHERE No = ' + CAST(@CmpyNumber AS Varchar)

INSERT INTO @tblActiveDate
EXECUTE USP_QuerySWS_ReportData @Query

SET @PostDateNew = (SELECT ClosingDate FROM @tblActiveDate)

--IF DATEPART(WEEKDAY, GETDATE()) > 4
--BEGIN
--	IF @ReturnDate > @PostDateNew
--		SET @ReturnDate = @PostDateNew
--END

SET @Query = N'SELECT TOP 1 CLOSED, PERIODDT, PERDENDT FROM ' + RTRIM(@Company) + '.dbo.SY40100 WHERE SERIES = ' + CAST(@GLSeries AS Varchar) + ' AND PERIODID > 0 AND ''' + CONVERT(Char(10), @PostingDate, 101) + ''' BETWEEN PERIODDT AND PERDENDT'

INSERT INTO @tblFiscalPrd
EXECUTE(@Query)

SET @PeriodClosed = (SELECT PeriodClosed FROM @tblFiscalPrd)

IF @PeriodClosed = 1
	SET @ReturnDate = (SELECT DATEADD(dd, -1, StartDate) FROM @tblFiscalPrd)

SELECT @ReturnDate AS ReturnDate