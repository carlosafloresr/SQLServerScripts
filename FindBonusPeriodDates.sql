USE [GPCustom]
GO
/****** Object:  UserDefinedFunction [dbo].[FindBonusPeriodDates]    Script Date: 12/29/2021 1:24:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
PRINT dbo.FindBonusPeriodDates('AIS', '07/13/2010', 2, '07/11/2016')
PRINT dbo.FindBonusPeriodDates('HMIS', '01/24/2011', 2, '05/16/2022')
*/
ALTER FUNCTION [dbo].[FindBonusPeriodDates] (@Company Varchar(5), @HireDate Datetime, @Periods Int, @PayDate Datetime)
RETURNS Datetime
BEGIN
	DECLARE	@ReturnValue	Datetime,
			@Anniversary	Datetime,
			@NextAnniver	Datetime,
			@BenStartDate	Datetime,
			@TempText		Varchar(25),
			@PayPeriodType	Char(1),
			@PayStartMonth	SmallInt
			
	--SELECT	@BenStartDate = VarD
	--FROM	GPCustom.dbo.[Parameters]
	--WHERE	ParameterCode = 'SAFBON_STARTDATE'

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
			SET	@TempText		= CAST(MONTH(@HireDate) AS Varchar(2)) + '/' + CAST(DAY(@HireDate) AS Varchar(2)) + '/' + CAST(YEAR(@PayDate) - 1 AS Varchar(4))	
			--SET	@NextAnniver	= CAST(CAST(MONTH(@HireDate) AS Varchar(2)) + '/' + CAST(DAY(@HireDate) AS Varchar(2)) + '/' + CAST(YEAR(@PayDate) AS Varchar(4)) AS Datetime)
		END
		ELSE
		BEGIN
			SET	@NextAnniver	=  CAST(MONTH(@HireDate) AS Varchar(2)) + '/' + CAST(DAY(@HireDate) AS Varchar(2)) + '/' + CAST(YEAR(@PayDate) + 1 AS Varchar(4))
		END

		IF ISDATE(@TempText) = 1
			SET @Anniversary = CAST(@TempText AS Datetime)
		ELSE
			SET @Anniversary = CAST(GETDATE() AS Datetime)
	
		IF @Periods = 2
		BEGIN
			IF @PayDate BETWEEN @Anniversary AND DATEADD(mm, 6, @Anniversary) --@Anniversary + 182
				SET @ReturnValue = DATEADD(mm, 6, @Anniversary)
			ELSE
				SET @ReturnValue  = DATEADD(mm, 12, @Anniversary)
		END
		ELSE
		BEGIN
			IF @Periods = 1
				SET @ReturnValue = @NextAnniver

			IF @Periods = 3
			BEGIN
				SET @ReturnValue =  CASE WHEN @PayDate BETWEEN @Anniversary AND @Anniversary + 121 THEN @Anniversary + 121
									WHEN @PayDate BETWEEN @Anniversary + 121 AND @Anniversary + 242 THEN @Anniversary + 242
									ELSE @NextAnniver END
			END

			IF @Periods = 4
			BEGIN
				SET @ReturnValue =  CASE WHEN @PayDate BETWEEN @Anniversary AND @Anniversary + 91 THEN @Anniversary + 91
									WHEN @PayDate BETWEEN @Anniversary + 92 AND @Anniversary + 182 THEN @Anniversary + 182
									WHEN @PayDate BETWEEN @Anniversary + 183 AND @Anniversary + 273 THEN @Anniversary + 273
									ELSE @NextAnniver END
			END
		END
	END
	ELSE
	BEGIN
		-- By Type DATE [D]

		DECLARE	@BonusPayDate1	Date = CAST(CAST(YEAR(@PayDate) AS Varchar) + '/' + CAST(@PayStartMonth AS Varchar) + '/1' AS Date)
		DECLARE @BonusPayDate2	Date = DATEADD(mm, 6, @BonusPayDate1)
		DECLARE @BonusPayDate3	Date = CAST(CAST(YEAR(@PayDate) + 1 AS Varchar) + '/' + CAST(@PayStartMonth AS Varchar) + '/1' AS Date)

		WHILE DATENAME(Weekday, @BonusPayDate1) <> 'Thursday'
		BEGIN
			SET @BonusPayDate1 = DATEADD(dd, 1, @BonusPayDate1)
		END

		WHILE DATENAME(Weekday, @BonusPayDate2) <> 'Thursday'
		BEGIN
			SET @BonusPayDate2 = DATEADD(dd, 1, @BonusPayDate2)
		END

		WHILE DATENAME(Weekday, @BonusPayDate3) <> 'Thursday'
		BEGIN
			SET @BonusPayDate3 = DATEADD(dd, 1, @BonusPayDate3)
		END

		SET @ReturnValue =	CASE WHEN @PayDate <= @BonusPayDate1 THEN @BonusPayDate1
								 WHEN @PayDate > @BonusPayDate1 AND @PayDate <= @BonusPayDate2 THEN @BonusPayDate2
								 ELSE @BonusPayDate3 END
	END

	RETURN @ReturnValue
END