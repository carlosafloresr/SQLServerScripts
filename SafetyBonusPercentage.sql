USE [GPCustom]
GO
/****** Object:  UserDefinedFunction [dbo].[SafetyBonusPercentage]    Script Date: 12/29/2021 1:45:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
PRINT [dbo].SafetyBonusPercentage('GIS', '02/27/2011','12/01/2012','01/24/2011', '01/23/2013', .03)
PRINT [dbo].SafetyBonusPercentage('DNJ', '02/27/2011',NULL,'01/27/2005', '07/25/2013', .02)
PRINT [dbo].SafetyBonusPercentage('HMIS', 'H50170', '01/01/2022',NULL,'09/10/2021', '07/25/2022', .01)
*/
ALTER FUNCTION [dbo].[SafetyBonusPercentage] (@Company Varchar(5), @VendorId Varchar(12), @StartDate Date, @GrandfatherDate Date, @HireDate Date, @PayDate Date, @Rate Decimal(10,2))
RETURNS Decimal(10,2)
BEGIN
	DECLARE	@ReturnValue			Decimal(10, 2),
			@PayPeriods				Int,
			@BonusPayDate			DateTime,
			@HireAge				Decimal(10, 3),
			@Division				Varchar(3),
			@ExpirationDate			Date,
			@BonusReactivationDate	Date

	SELECT	@Division = Division 
	FROM	VendorMaster
	WHERE	Company = @Company
			AND VendorId = @VendorId

	SELECT	@ExpirationDate			= BonusExpirationDate,
			@BonusReactivationDate	= BonusReactivationDate
	FROM	SafetyBonusParametersByDivision
	WHERE	Company = @Company
			AND Division = @Division

	SET @ExpirationDate = ISNULL(@ExpirationDate, '12/31/2099')

	IF @Company = 'GIS'
	BEGIN
		SET @PayPeriods		= (SELECT PayPeriods FROM SafetyBonusParameters WHERE Company = @Company)
		SET @BonusPayDate	= dbo.FindBonusPeriodDates(@Company, @HireDate, @PayPeriods, @PayDate)
		SET @HireAge		= CAST(DATEDIFF(dd, @HireDate, @PayDate) / 365.00 AS Decimal(10, 3))

		IF @PayDate < @StartDate OR @PayDate >= @ExpirationDate
			SET @ReturnValue = 0.000
		ELSE
		BEGIN
			IF @HireDate <= ISNULL(@GrandfatherDate, '01/01/1900')
				SET @ReturnValue = CASE WHEN @HireAge < 1.51 THEN 0.02 ELSE 0.03 END
			ELSE
				SET @ReturnValue = CASE WHEN @HireAge < 1.001 THEN 0.01 WHEN @HireAge BETWEEN 1.001 AND 2.000 THEN 0.02 ELSE 0.03 END
		END
	END
	ELSE
	BEGIN
		IF @Company = 'DNJ'
		BEGIN
			IF DATEADD(dd, -7, @PayDate) >= @ExpirationDate AND @PayDate <= ISNULL(@BonusReactivationDate, @ExpirationDate)
				SET @ReturnValue = 0.000
			ELSE
				SET @ReturnValue = @Rate
		END
		ELSE
		BEGIN
			IF @Company = 'AIS'
				SET @ReturnValue = CASE WHEN @PayDate >= @StartDate THEN @Rate ELSE 0.00 END
			ELSE
				SET @ReturnValue = CASE WHEN @PayDate >= @StartDate THEN @Rate ELSE 0.00 END
		END
	END

	RETURN @ReturnValue
END

/*
print  [dbo].SafetyBonusPercentage('GIS', '02/27/2011','12/01/2012','01/24/2011', '01/23/2013', .03)
print  [dbo].SafetyBonusPercentage('DNJ', '02/27/2011',NULL,'01/27/2005', '07/25/2013', .02)
print DATEDIFF(dd, '07/13/2010', '07/25/2013')
print CAST(DATEDIFF(dd, '07/13/2010', '07/25/2011') / 365 AS Decimal(10, 5))
*/