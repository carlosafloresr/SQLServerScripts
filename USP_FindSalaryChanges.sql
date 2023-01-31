/*
EXECUTE USP_FindSalaryChanges '41', 'SALARY'
*/
CREATE PROCEDURE dbo.USP_FindSalaryChanges
	@EmployeeId	Varchar(20),
	@SalCode	Varchar(15)
AS
SELECT	* 
FROM	(
		SELECT	TOP 4 EmployId, 
				HR.PayRcord, 
				EffectiveDate_I, 
				HR.PayRtAmt, 
				HR.PayUnit, 
				HR.PayPrPrd, 
				AnnualSalary_I, 
				ChangeReason_I, 
				PayType, 
				HR.CHANGEDATE_I 
		FROM	dbo.HRPSLH01 HR 
				INNER JOIN (SELECT	MAX(HR.PayRcord) AS PayRcord, 
									MAX(PayType) AS PayType 
							FROM	dbo.HRPSLH01 HR 
									INNER JOIN dbo.UPR40600 UP ON HR.PayRcord = UP.PayRcord AND PayType IN (1,2) 
							WHERE	EmployId = @EmployeeId
									AND HR.PayRcord = @SalCode
							) UP ON HR.PayRcord = UP.PayRcord 
		WHERE	EmployId = @EmployeeId
				AND HR.CHANGEREASON_I <> 'Weekly to Bi Weekly'
		ORDER BY EffectiveDate_I DESC) WH
ORDER BY CHANGEDATE_I