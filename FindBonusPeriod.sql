USE [GPCustom]
GO
/****** Object:  UserDefinedFunction [dbo].[FindBonusPeriod]    Script Date: 12/29/2021 12:49:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
PRINT dbo.FindBonusPeriod('AIS', '01/24/2011', 2, '05/10/2015')
PRINT dbo.FindBonusPeriod('HMIS', '01/24/2011', 2, '12/16/2021')
*/
ALTER FUNCTION [dbo].[FindBonusPeriod] (@Company Varchar(5), @HireDate Date, @Periods Int, @PayDate Date)
RETURNS Char(6)
BEGIN
	DECLARE	@ReturnValue	Char(6),
			@Anniversary	Datetime,
			@NextAnniver	Datetime,
			@BenStartDate	Datetime,
			@TempText		Varchar(25),
			@PayPeriodType	Char(1),
			@PayStartMonth	SmallInt

	SELECT	@BenStartDate	= StartDate,
			@PayPeriodType	= PayPeriodType,
			@PayStartMonth	= ByDateStartingMonth
	FROM	SafetyBonusParameters 
	WHERE	Company = @Company
	
	IF @PayPeriodType = 'A'
	BEGIN
		-- By Type ANNIVERSARY [A]
		IF DAY(@HireDate) = 29 AND MONTH(@HireDate) = 2
			SET @HireDate = CAST(CAST(MONTH(@HireDate) AS Varchar(2)) + '/28/' + CAST(YEAR(@HireDate) AS Varchar(4)) AS Datetime)
	
		SET	@Anniversary	= CAST(CAST(MONTH(@HireDate) AS Varchar(2)) + '/' + CAST(DAY(@HireDate) AS Varchar(2)) + '/' + CAST(YEAR(@PayDate) AS Varchar(4)) AS Datetime)
		SET @TempText		= CAST(@Anniversary AS Varchar(25))

		IF @PayDate < @Anniversary
		BEGIN
			SET	@TempText	= CAST(MONTH(@HireDate) AS Varchar(2)) + '/' + CAST(DAY(@HireDate) AS Varchar(2)) + '/' + CAST(YEAR(@PayDate) - 1 AS Varchar(4))
		END
		ELSE
		BEGIN
			SET	@NextAnniver = CAST(CAST(MONTH(@HireDate) AS Varchar(2)) + '/' + CAST(DAY(@HireDate) AS Varchar(2)) + '/' + CAST(YEAR(@PayDate) + 1 AS Varchar(4)) AS Datetime)
		END
	
		IF ISDATE(@TempText) = 1
			SET @Anniversary = CAST(@TempText AS Datetime)
		ELSE
			SET @Anniversary = CAST(GETDATE() AS Datetime)
	
		IF @Periods = 2
		BEGIN
			IF @PayDate BETWEEN @Anniversary AND DATEADD(mm, 6, @Anniversary)
				SET @ReturnValue = CAST(YEAR(@Anniversary) AS Char(4)) + '-1'
			ELSE
				SET @ReturnValue = CAST(YEAR(@Anniversary) AS Char(4)) + '-2'
		END
		ELSE
		BEGIN
			IF @Periods = 1
				SET @ReturnValue = CAST(YEAR(@Anniversary) AS Char(4))

			IF @Periods = 3
			BEGIN
				SET @ReturnValue =  CASE WHEN @PayDate BETWEEN @Anniversary AND @Anniversary + 121 THEN CAST(YEAR(CAST(@Anniversary AS Datetime)) AS Char(4)) + '-1'
									WHEN @PayDate BETWEEN @Anniversary + 121 AND @Anniversary + 242 THEN CAST(YEAR(CAST(@Anniversary AS Datetime)) AS Char(4)) + '-2'
									ELSE CAST(YEAR(CAST(@Anniversary AS Datetime)) AS Char(4)) + '-3' END
			END

			IF @Periods = 4
			BEGIN
				SET @ReturnValue =  CASE WHEN @PayDate BETWEEN @Anniversary AND @Anniversary + 91 THEN CAST(YEAR(CAST(@Anniversary AS Datetime)) AS Char(4)) + '-1'
									WHEN @PayDate BETWEEN @Anniversary + 92 AND @Anniversary + 182 THEN CAST(YEAR(CAST(@Anniversary AS Datetime)) AS Char(4)) + '-2'
									WHEN @PayDate BETWEEN @Anniversary + 183 AND @Anniversary + 273 THEN CAST(YEAR(CAST(@Anniversary AS Datetime)) AS Char(4)) + '-3'
									ELSE CAST(YEAR(CAST(@Anniversary AS Datetime)) AS Char(4)) + '-4' END
			END
		END
	END
	ELSE
	BEGIN
		-- By Type DATE [D]
		
		DECLARE	@BonusPayDate1	Date = CAST(CAST(YEAR(@PayDate) AS Varchar) + '/' + CAST(@PayStartMonth AS Varchar) + '/1' AS Date)
		DECLARE	@BonusPayDate2	Date = CAST(CAST(YEAR(@PayDate) + IIF(@PayStartMonth + 6 > 12, 1, 0) AS Varchar) + '/' + CAST(IIF(@PayStartMonth + 6 > 12, (@PayStartMonth + 6) - 12, @PayStartMonth + 6) AS Varchar) + '/1' AS Date)
		DECLARE	@BonusPayDate3	Date = CAST(CAST(YEAR(@PayDate) + 1 AS Varchar) + '/' + CAST(@PayStartMonth AS Varchar) + '/1' AS Date)

		WHILE DATENAME(Weekday, @BonusPayDate1) <> 'Thursday'
		BEGIN
			SET @BonusPayDate1 = DATEADD(dd, 1, @BonusPayDate1)
		END

		WHILE DATENAME(Weekday, @BonusPayDate2) <> 'Thursday'
		BEGIN
			SET @BonusPayDate2 = DATEADD(dd, 1, @BonusPayDate2)
		END

		SET @ReturnValue =	CASE WHEN @PayDate <= @BonusPayDate1 THEN CAST(YEAR(@BonusPayDate1) AS Varchar) + '-1'
								 WHEN @PayDate > @BonusPayDate1 AND @PayDate <= @BonusPayDate2 THEN CAST(YEAR(@BonusPayDate2) AS Varchar) + '-2'
								 ELSE CAST(YEAR(@BonusPayDate3) AS Varchar) + '-1' END
	END

	RETURN @ReturnValue
END