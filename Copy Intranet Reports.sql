/*
SELECT FullPath, REPLACE(FullPath, '\\ILSWEB\website', '\\ilsweb01\intranet')  FROM Reports

UPDATE	Reports
SET		 FullPath = REPLACE(FullPath, '\\ILSWEB\website', '\\ilsweb01\intranet')

UPDATE	Reports
SET		ReportName = REPLACE(ReportName, 'rcmr ', 'RCMR ')
WHERE	ReportFolder = 'RCMR REPORTS'

SELECT * FROM Reports
*/
INSERT INTO Reports (ReportName, ReportFolder, ReportType, FullPath, Parent, Company, Inactive, CustomFilter)
SELECT	REPLACE(ReportName, 'rcmr ', 'IMCC ')
		,'IMCC REPORTS' AS ReportFolder
		,'C'
		,REPLACE(FullPath, 'RCMR ', 'IMCC ') AS FullPath
		,35652 AS Parent
		,Company
		,Inactive
		,CustomFilter
FROM	Reports 
WHERE	ReportFolder = 'RCMR REPORTS'