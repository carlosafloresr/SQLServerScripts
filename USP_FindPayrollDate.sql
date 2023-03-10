USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindPayrollDate]    Script Date: 10/24/2017 3:03:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindPayrollDate '10/21/2017', 'PTS'
*/
ALTER PROCEDURE [dbo].[USP_FindPayrollDate]
		@WeekDate		Datetime,
		@Company		Varchar(5) = Null
AS
DECLARE	@DelayWeeks		Int,
		@PayrollDate	Date

SELECT	@DelayWeeks = ParNumeric
FROM	View_Companies_Parameters
WHERE	ParameterCode = 'PayrollDelayWeeks'
		AND CompanyId = @Company

IF @DelayWeeks IS Null
	SET @DelayWeeks = 1

IF dbo.WeekDay(@WeekDate) = 5
	SET @PayrollDate = @WeekDate
ELSE
BEGIN
	IF dbo.WeekDay(@WeekDate) > 5
		SET @PayrollDate = dbo.DayFwdBack(@WeekDate,'N','Thursday')
	ELSE
		SET @PayrollDate = dbo.DayFwdBack(@WeekDate,'N','Thursday')
END

IF @DelayWeeks <> 1
	SET @PayrollDate = DATEADD(dd, -7 , @PayrollDate)

SELECT	@PayrollDate AS PayrollDate