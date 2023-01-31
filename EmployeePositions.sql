SELECT	EmployId,
		EmployeeName,
		DepartmentId,
		DepartmentName,
		GPCustom.dbo.Payroll_GridTitle.JobPosition
FROM	IILS.dbo.View_AllEmployees
		LEFT JOIN GPCustom.dbo.Payroll_Employees ON EmployId = Payroll_EmployeeId
		LEFT JOIN GPCustom.dbo.Payroll_GridTitle ON GridClassification = Payroll_GridTitleId
ORDER BY 
		JobPosition,
		EmployeeName