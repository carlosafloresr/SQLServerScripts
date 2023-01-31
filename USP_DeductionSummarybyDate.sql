ALTER PROCEDURE USP_DeductionSummarybyDate
	@IniDate	DateTime,
	@EndDate	DateTime
AS
DECLARE	@DateIni	DateTime,
	@DateEnd	DateTime

SELECT	@DateIni = CONVERT(Char(10), @IniDate, 101) + ' 12:00:00 AM'
SELECT	@DateEnd = CONVERT(Char(10), @EndDate, 101) + ' 11:59:59 PM'

SELECT	UPR30300.PAYROLCD, 
	UPR30300.UPRTRXAM, 
	UPR30300.CHEKDATE, 
	UPR30300.PYRLRTYP, 
	UPR30300.EMPLOYID, 
	UPR30300.CHEKNMBR, 
	UPR00100.LASTNAME, 
	UPR00100.FRSTNAME, 
	UPR00100.DEPRTMNT, 
	GL00100.ACTNUMBR_1, 
	GL00100.ACTNUMBR_2, 
	GL00100.ACTNUMBR_3,
	CONVERT(Char(10), @IniDate, 101) AS StartDate,
	CONVERT(Char(10), @EndDate, 101) AS EndDate
FROM   	UPR30300 
	INNER JOIN UPR00100 ON UPR30300.EMPLOYID = UPR00100.EMPLOYID
	INNER JOIN (SELECT DISTINCT PAYROLCD, MAX(ACTINDX) AS ACTINDX FROM UPR40500 GROUP BY PAYROLCD) UPR40500 ON UPR30300.PAYROLCD = UPR40500.PAYROLCD
	INNER JOIN GL00100 ON UPR40500.ACTINDX = GL00100.ACTINDX
WHERE  	UPR30300.PYRLRTYP = 2 AND 
	UPR30300.CHEKDATE BETWEEN @DateIni AND @DateEnd
ORDER BY UPR30300.PAYROLCD, UPR00100.DEPRTMNT
GO

--EXECUTE USP_DeductionSummarybyDate '03/08/2007', '03/29/2007'

--SELECT * FROM UPR30300