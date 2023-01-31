/*
select * from View_AllEmployees
*/
ALTER VIEW [dbo].[View_AllEmployees]
AS
SELECT 	UPR00100.EmployId,
		RTRIM(LastName) + ', ' + RTRIM(FrstName) + CASE WHEN MidlName = '' THEN '' ELSE ' ' + MidlName END AS EmployeeName, 
		UPR00100.Inactive,
		UPR00100.DeprtMnt AS DepartmentId,
		UPR40300.Dscriptn AS DepartmentName,
		UPR00100.SupervisorCode_I AS SupervisorId,
		UPR41700.Supervisor AS SupervisorName,
		UPR00100.JobTitle AS JobTitleId,
		UPR40301.Dscriptn AS JobTitle,
		UPR00100.LocatnId AS LocationId,
		SY00600.LocatnnM AS LocationName,
		UPR00100.Primary_Pay_Record AS PrimaryPayCode,
		CAST(CASE WHEN PATINDEX('%HOUR%', LH.PayUnit) > 0 THEN 1 ELSE 0 END AS Bit) AS Hourly,
		EmploymentType,
		UPR00100.StrtDate AS HireDate,
		LH.PayRtAmt AS PayRate,
		LH.PayPrPrd AS WeeklyPayRate,
		LH.AnnualSalary_I AS AnnualPayRate, 
		LH.EffectiveDate AS LastSalaryDate,
		CASE WHEN UPR40600.PAYUNPER = 1 THEN 7 ELSE 14 END AS DaysPerPayPeriod
FROM 	UPR00100
		LEFT JOIN UPR40300 ON UPR00100.DeprtMnt = UPR40300.DeprtMnt
		LEFT JOIN UPR41700 ON UPR00100.SupervisorCode_I = UPR41700.SupervisorCode_I
		LEFT JOIN UPR40301 ON UPR00100.JobTitle = UPR40301.JobTitle
		INNER JOIN Dynamics.dbo.View_AllCompanies DYN ON DYN.InterId = DB_NAME()
		LEFT JOIN SY00600 ON UPR00100.LocatnId = SY00600.LocatnId AND DYN.CmpanyId = SY00600.CmpanyId
		LEFT JOIN UPR40600 ON UPR00100.Primary_Pay_Record = UPR40600.PAYRCORD
		LEFT JOIN (SELECT 	HR.EmployId, 
							PR.PayRtAmt,
							HR.PayUnit, 
							HR.PayPrPrd, 
							HR.AnnualSalary_I, 
							HR.EffectiveDate_I AS EffectiveDate
					FROM 	HRPSLH01 HR
							INNER JOIN UPR00100 VE ON HR.EmployId = VE.EmployId AND VE.Primary_Pay_Record = HR.PayRcord
							INNER JOIN UPR00400 PR ON HR.EmployId = PR.EmployId AND HR.PayRcord = PR.PayRcord
							INNER JOIN (SELECT 	H1.EmployId, 
										MAX(H1.EffectiveDate_I) AS EffectiveDate
									FROM 	HRPSLH01 H1
										INNER JOIN UPR00100 VE ON H1.EmployId = VE.EmployId AND VE.Primary_Pay_Record = H1.PayRcord
									GROUP BY H1.EmployId) W1 ON HR.EmployId = W1.EmployId AND HR.EffectiveDate_I = W1.EffectiveDate) LH ON UPR00100.EmployId = LH.EmployId
GO


