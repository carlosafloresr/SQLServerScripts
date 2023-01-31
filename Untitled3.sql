CREATE VIEW View_AllEmployees
AS
SELECT 	UPR00100.EmployId ,
	RTRIM(LastName) + ', ' + RTRIM(FrstName) + CASE WHEN MidlName = '' THEN '' ELSE ' ' + MidlName END AS EmployeeName, 
	Inactive,
	UPR00100.DeprtMnt AS DepartmentId,
	UPR40300.Dscriptn AS DepartmentName,
	UPR00100.SupervisorCode_I AS SupervisorId,
	UPR41700.Supervisor AS SupervisorName,
	UPR00100.JobTitle AS JobTitleId,
	UPR40301.Dscriptn AS JobTitle,
	UPR00100.LocatnId AS LocationId,
	SY00600.LocatnnM AS LocationName,
	CAST(CASE WHEN PATINDEX('%HOUR%', UPR00100.EmplClas) > 0 THEN 1 ELSE 0 END AS Bit) AS Hourly
FROM 	UPR00100
	LEFT JOIN UPR40300 ON UPR00100.DeprtMnt = UPR40300.DeprtMnt
	LEFT JOIN UPR41700 ON UPR00100.SupervisorCode_I = UPR41700.SupervisorCode_I
	LEFT JOIN UPR40301 ON UPR00100.JobTitle = UPR40301.JobTitle
	LEFT JOIN SY00600 ON UPR00100.LocatnId = SY00600.LocatnId