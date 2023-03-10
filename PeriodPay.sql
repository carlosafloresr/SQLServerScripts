USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDriverSafetyBonus]    Script Date: 01/18/2012 08:42:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_FindDriverSafetyBonus]
		@Company		Varchar(5),
		@VendorId		Varchar(10),
		@PayDate		Datetime
AS
IF DATENAME(weekday, @PayDate) <> 'Thursday'
	SET	@PayDate = dbo.TTOD(dbo.DayFwdBack(@PayDate,'N','Thursday'))

SELECT	*,
		ROW_NUMBER() OVER (PARTITION BY VendorId, BonusPayDate ORDER BY PayDate DESC) AS 'RowNumber'
FROM	(
		SELECT	SafetyBonusId
				,Company
				,VendorId
				,OldDriverId
				,VendorName
				,HireDate
				,Period
				,PayDate
				,BonusPayDate
				,Miles
				,ToPay
				,PeriodMiles
				,PeriodPay
				,PeriodToPay
				,SortColumn
				,WeeksCounter
				,Paid
				,LastRunWeek
		FROM	SafetyBonus
		WHERE	Company = @Company
				AND VendorId = @VendorId
				AND PayDate <= @PayDate
				AND SortColumn = 1
				AND Paid = 0
		UNION
		SELECT	SAF.SafetyBonusId
				,SAF.Company
				,SAF.VendorId
				,SAF.OldDriverId
				,SAF.VendorName
				,SAF.HireDate
				,SAF.Period
				,SAF.PayDate
				,SAF.BonusPayDate
				,SAF.Miles
				,SAF.ToPay
				,SAF.PeriodMiles + ISNULL(OLD.PeriodMiles, 0) AS PeriodMiles
				,SAF.PeriodPay + ISNULL(OLD.PeriodPay, 0) AS PeriodPay
				,SAF.PeriodToPay
				,SAF.SortColumn
				,SAF.WeeksCounter
				,SAF.Paid
				,SAF.LastRunWeek
		FROM	SafetyBonus SAF
				LEFT JOIN ( SELECT	Company,
									VendorId,
									Period,
									SUM(PeriodMiles) AS PeriodMiles,
									SUM(PeriodPay) AS PeriodPay
							FROM	SafetyBonus 
							WHERE	SortColumn = 1
							GROUP BY Company, VendorId, Period) OLD ON SAF.Company = OLD.Company AND SAF.VendorId = OLD.VendorId AND SAF.Period = OLD.Period
		WHERE	SAF.Company = @Company
				AND SAF.VendorId = @VendorId
				AND SAF.BonusPayDate > @PayDate - 60
				AND SAF.SortColumn = 0
				AND SAF.Paid = 0) RECS
ORDER BY
		SortColumn
		,PayDate DESC
		
/*
 052611DSDRVCK-1 DSDRV052611CK DSDRV052611DD DSDRV052611GMT 
060211DSDRVDD

EXECUTE USP_FindDriverSafetyBonus 'DNJ', 'D0222', '01/12/2012'

EXECUTE USP_CalculateSafetyBonusTable 'GIS', '6/2/2011'

SELECT	* 
FROM	SafetyBonus
WHERE	Company = 'GIS'
		AND VendorId = 'G0017'
		AND BonusPayDate > CAST('06/02/2011' AS Datetime) - 60
*/