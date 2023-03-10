USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_CreateBatch_Requirements]    Script Date: 6/9/2021 5:35:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_OOS_CreateBatch_Requirements 'PTS', '08/08/2019'
EXECUTE USP_OOS_CreateBatch_Requirements 'IMC', '06/10/2021'
*/
ALTER PROCEDURE [dbo].[USP_OOS_CreateBatch_Requirements]
		@Company	Varchar(5),
		@PayDate	Date
AS 
DECLARE	@DateIni	Date,
		@DateEnd	Date,
		@BatchId	Varchar(15),
		@DPY		Bit = 0,
		@FPT		Bit = 0,
		@Query		Varchar(Max),
		@Counter	Int = 0

DECLARE	@tblFuel	Table (RecordCounter Int)

SET		@DateIni	= GPCustom.dbo.DayFwdBack(@PayDate, 'P', 'Saturday')

IF DATENAME(Weekday, @PayDate) = 'Thursday'
	SET @DateEnd = @PayDate
ELSE
	SET @DateEnd = GPCustom.dbo.DayFwdBack(@PayDate, 'N', 'Thursday')

SET @Query = N'SELECT COUNT(*) FROM ' + RTRIM(@Company) + '.dbo.PM20000 WHERE BACHNUMB LIKE ''FPT_%'' AND DOCDATE = ''' + CAST(@DateIni AS Varchar) + ''''

INSERT INTO @tblFuel
EXECUTE(@Query)

SET @Counter = ISNULL((SELECT RecordCounter FROM @tblFuel),0)

SET @FPT = IIF(@Counter > 0, 1, 0)

IF @Company = 'PTS'
BEGIN
	SET @DateIni = DATEADD(dd, -7, @DateIni)
	SET @DateEnd = DATEADD(dd, -7, @DateEnd)
END

PRINT @DateIni

SET @DPY = IIF(EXISTS(SELECT BATCHID FROM GPCUSTOM.dbo.View_Integration_AP WHERE Company = @Company AND WeekEndDate BETWEEN @DateIni AND @DateEnd), 1, 0)

SELECT	@FPT AS Fuel,
		@DPY AS Drayage