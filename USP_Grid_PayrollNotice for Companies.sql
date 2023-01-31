ALTER PROCEDURE [dbo].[USP_Grid_PayrollNotice]
	@Company	Char(6),
	@BatchId	Char(15) = Null,
	@RecordId	Int = Null,
	@MainGrid	Bit = 0
AS
IF @MainGrid = 0 OR @MainGrid IS Null
BEGIN
	SELECT	PayrollNoticeId,
			PayrollNoticeId AS RecordId,
			BatchId, 
			PN.Company,
			AC.CmpnyNam,
			PN.EmployeeId,
			AE.EmployeeName,
			PN.NoticeType,
			CASE WHEN PN.NoticeType = 1 THEN 'New Employee'
				WHEN PN.NoticeType = 2 THEN 'Promotion / Demotion'
				WHEN PN.NoticeType = 3 THEN 'Transfer (Non-Pay)'
				WHEN PN.NoticeType = 4 THEN 'Annual Review'
				WHEN PN.NoticeType = 5 THEN '90-Day Review'
			ELSE 'Other (Non-Pay)' END ChangeType,
			EmploymentDate, 
			PN.EffectiveDate, 
			PN.Supervisor,
			SU.Supervisor AS NewSupervisorName,
			PN.Location,
			LO.LocatnnM AS NewLocation,
			PN.GridClassification,
			GT1.JobPosition AS CurrentGridClass,
			GT1.MinSalary AS CurrentMinSalary,
			GT1.MidSalary AS CurrentMidSalary,
			GT1.MaxSalary AS CurrentMaxSalary,
			GT2.JobPosition AS NewGridClass,
			GT2.MinSalary AS NewMinSalary,
			GT2.MidSalary AS NewMidSalary,
			GT2.MaxSalary AS NewMaxSalary,
			PN.DOLStatus, 
			PEM.DOL_Status AS NewDOLStatus,
			PN.MBO_Eligible, 
			PN.MBO_Percentage,
			PE.MBO_Eligible AS MBO_Eligible_Current,
			PE.MBO_Percentage AS MBO_Percentage_Current,
			DepartmentId AS CurrentDepartment,
			DepartmentName AS CurrentDeptoName,
			SupervisorName AS CurrentSupervisorName,
			AE.JobTitle AS CurrentJobTitle,
			AE.LocationName AS CurrentLocation,
			AE.EmploymentType,
			CASE WHEN AE.EmploymentType = 1 THEN 'FT' ELSE 'PT' END AS CurrentFTPT,
			AE.Hourly,
			PN.Department,
			DEP.Dscriptn AS NewDepartmentName,
			PN.JobPosition,
			JBP.Dscriptn AS NewJobTitle,
			PN.Amount, 
			PN.Anual, 
			PN.Increase,
			CASE WHEN PN.FTPT = 'F' THEN 'FT' WHEN PN.FTPT IS NULL THEN '' ELSE 'PT' END AS FTPT, 
			PN.Comments, 
			PN.RecommendedBy, 
			PN.ApprovedBy1, 
			PN.ApprovedBy2, 
			PN.Submitted, 
			PN.EnteredBy, 
			PN.EnteredOn, 
			PN.ChangedBy, 
			PN.ChangedOn,
			AE.PayRate,
			AE.WeeklyPayRate,
			AE.AnnualPayRate, 
			AE.LastSalaryDate,
			CAST(AE.PayRate AS Numeric(9,2)) AS CurrentPayRate,
			CAST(PN.Amount AS Numeric(9,2)) AS NewPayRate
	FROM	GPCustom.dbo.PayrollNotice PN
			LEFT JOIN View_AllEmployees AE ON PN.EmployeeId = AE.EmployId
			LEFT JOIN GPCustom.dbo.Payroll_Employees PE ON PN.EmployeeId = PE.EmployeeId AND PE.Company = RTRIM(@Company)
			LEFT JOIN UPR41700 SU ON PN.Supervisor = SU.SupervisorCode_I
			INNER JOIN Dynamics.dbo.View_AllCompanies DYN ON DYN.InterId = DB_NAME()
			LEFT JOIN SY00600 LO ON PN.Location = LO.LocatnId AND DYN.CmpanyId = LO.CmpanyId
			--LEFT JOIN SY00600 LO ON PN.Location = LO.LocatnId
			LEFT JOIN UPR40300 DEP ON PN.Department = DEP.DeprtMnt
			LEFT JOIN UPR40301 JBP ON PN.JobPosition = JBP.JobTitle
			LEFT JOIN Dynamics.dbo.View_AllCompanies AC ON PN.Company = AC.InterId
			LEFT JOIN GPCustom.dbo.Payroll_Employees PEM ON PN.EmployeeId = PEM.EmployeeId AND PN.Company = PEM.Company
			LEFT JOIN GPCustom.dbo.Payroll_GridTitle GT1 ON PEM.GridClassification = GT1.Payroll_GridTitleId
			LEFT JOIN GPCustom.dbo.Payroll_GridTitle GT2 ON PN.GridClassification = GT2.Payroll_GridTitleId
	WHERE	(@BatchId IS NOT Null AND BatchId = @BatchId) OR
			(@RecordId IS NOT Null AND PayrollNoticeId = @RecordId)
	ORDER BY AE.EmployeeName
END
ELSE
BEGIN
	SELECT	DISTINCT PayrollNoticeId,
			PayrollNoticeId AS RecordId,
			BatchId, 
			PN.Company,
			AC.CmpnyNam,
			PN.EmployeeId,
			AE.EmployeeName,
			PN.NoticeType,
			CASE WHEN PN.NoticeType = 1 THEN 'New Employee'
				WHEN PN.NoticeType = 2 THEN 'Promotion / Demotion'
				WHEN PN.NoticeType = 3 THEN 'Transfer (Non-Pay)'
				WHEN PN.NoticeType = 4 THEN 'Annual Review'
				WHEN PN.NoticeType = 5 THEN '90-Day Review'
			ELSE 'Other (Non-Pay)' END ChangeType,
			EmploymentDate, 
			PN.EffectiveDate, 
			PN.Supervisor,
			SU.Supervisor AS NewSupervisorName,
			PN.Location,
			LO.LocatnnM AS NewLocation,
			PN.GridClassification,
			GT1.JobPosition AS CurrentGridClass,
			GT1.MinSalary AS CurrentMinSalary,
			GT1.MidSalary AS CurrentMidSalary,
			GT1.MaxSalary AS CurrentMaxSalary,
			GT2.JobPosition AS NewGridClass,
			GT2.MinSalary AS NewMinSalary,
			GT2.MidSalary AS NewMidSalary,
			GT2.MaxSalary AS NewMaxSalary,
			PN.DOLStatus, 
			PEM.DOL_Status AS NewDOLStatus,
			PN.MBO_Eligible, 
			PN.MBO_Percentage,
			PE.MBO_Eligible AS MBO_Eligible_Current,
			PE.MBO_Percentage AS MBO_Percentage_Current,
			DepartmentId AS CurrentDepartment,
			DepartmentName AS CurrentDeptoName,
			SupervisorName AS CurrentSupervisorName,
			AE.JobTitle AS CurrentJobTitle,
			AE.LocationName AS CurrentLocation,
			AE.EmploymentType,
			CASE WHEN AE.EmploymentType = 1 THEN 'FT' ELSE 'PT' END AS CurrentFTPT,
			AE.Hourly,
			PN.Department,
			DEP.Dscriptn AS NewDepartmentName,
			PN.JobPosition,
			JBP.Dscriptn AS NewJobTitle,
			PN.Amount, 
			PN.Anual, 
			PN.Increase,
			CASE WHEN PN.FTPT = 'F' THEN 'FT' WHEN PN.FTPT IS NULL THEN '' ELSE 'PT' END AS FTPT, 
			PN.Comments, 
			PN.RecommendedBy, 
			PN.ApprovedBy1, 
			PN.ApprovedBy2, 
			PN.Submitted, 
			PN.EnteredBy, 
			PN.EnteredOn, 
			PN.ChangedBy, 
			PN.ChangedOn,
			AE.PayRate,
			AE.WeeklyPayRate,
			AE.AnnualPayRate, 
			CAST(AE.PayRate AS Numeric(9,2)) AS CurrentPayRate,
			CAST(PN.Amount AS Numeric(9,2)) AS NewPayRate
	FROM	GPCustom.dbo.PayrollNotice PN
			LEFT JOIN View_AllEmployees AE ON PN.EmployeeId = AE.EmployId
			LEFT JOIN GPCustom.dbo.Payroll_Employees PE ON PN.EmployeeId = PE.EmployeeId AND PE.Company = RTRIM(@Company)
			LEFT JOIN UPR41700 SU ON PN.Supervisor = SU.SupervisorCode_I
			INNER JOIN Dynamics.dbo.View_AllCompanies DYN ON DYN.InterId = DB_NAME()
			LEFT JOIN SY00600 LO ON PN.Location = LO.LocatnId AND DYN.CmpanyId = LO.CmpanyId
			--LEFT JOIN SY00600 LO ON PN.Location = LO.LocatnId
			LEFT JOIN UPR40300 DEP ON PN.Department = DEP.DeprtMnt
			LEFT JOIN UPR40301 JBP ON PN.JobPosition = JBP.JobTitle
			LEFT JOIN Dynamics.dbo.View_AllCompanies AC ON PN.Company = AC.InterId
			LEFT JOIN GPCustom.dbo.Payroll_Employees PEM ON PN.EmployeeId = PEM.EmployeeId AND PN.Company = PEM.Company
			LEFT JOIN GPCustom.dbo.Payroll_GridTitle GT1 ON PEM.GridClassification = GT1.Payroll_GridTitleId
			LEFT JOIN GPCustom.dbo.Payroll_GridTitle GT2 ON PN.GridClassification = GT2.Payroll_GridTitleId
	WHERE	(@BatchId IS NOT Null AND BatchId = @BatchId) OR
			(@RecordId IS NOT Null AND PayrollNoticeId = @RecordId)
	ORDER BY AE.EmployeeName
END