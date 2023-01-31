CREATE PROCEDURE USP_EmployeeList
		@Status		Char(1),
		@SortOrder	Int
AS
SELECT	EM.EmployId,
		LEFT(RTRIM(RTRIM(EM.LastName) + ', ' + RTRIM(EM.FrstName) + ' ' + EM.MidlName), 45) AS EmployeeName,
		EM.LastName,
		EM.FrstName,
		EM.MidlName,
		AD.Address1,
		AD.Address2,
		AD.City,
		AD.State,
		AD.ZipCode,
		GPCustom.dbo.FormatPhoneNumber(AD.Phone1) AS Phone,
		CASE WHEN EM.Inactive = 1 THEN 'Inactive' ELSE 'Active' END AS Status
FROM	UPR00100 EM
		INNER JOIN UPR00102 AD ON EM.EmployId = AD.EmployId
WHERE	@Status = '0' 
		OR (@Status = 'A' AND EM.Inactive = 0)
		OR (@Status = 'I' AND EM.Inactive = 1)
ORDER BY 
		CASE WHEN @SortOrder = 1 THEN EM.EmployId ELSE LEFT(RTRIM(RTRIM(EM.LastName) + ', ' + RTRIM(EM.FrstName) + ' ' + EM.MidlName), 45) END

EXECUTE USP_EmployeeList '0', 2