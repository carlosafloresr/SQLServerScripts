CREATE VIEW View_SafetyBonus
AS
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
		,SAF.PeriodMiles
		,SAF.PeriodPay
		,SAF.PeriodToPay
		,SAF.SortColumn
		,SAF.WeeksCounter
		,SAF.Paid
		,SAF.LastRunWeek
		,SAF.Percentage
		,SAF.Drayage
		,SAF.DrayageBonus
		,IIF(SBP.ByMileagePercent = 'M', SAF.PeriodPay, SAF.DrayageBonus) AS BonusPayAmount
FROM	SafetyBonus SAF
		INNER JOIN SafetyBonusParameters SBP ON SAF.Company = SBP.Company

GO


