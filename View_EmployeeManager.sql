CREATE VIEW View_EmployeeManager
AS
SELECT	EMPL.EmployId, 
		RTRIM(EMPL.frstname) + ' ' + RTRIM(EMPL.lastname) AS Name, 
		SUP1.EmployId AS Super_Id,
		RTRIM(SUP2.FrstName) + ' ' + RTRIM(SUP2.LastName) AS SuperName
FROM	UPR00100 EMPL
		LEFT OUTER JOIN UPR41700 SUP1 ON EMPL.supervisorcode_i = SUP1.supervisorcode_i
		LEFT OUTER JOIN UPR00100 SUP2 ON SUP1.EmployId = SUP2.EmployId
WHERE	EMPL.inactive = 0