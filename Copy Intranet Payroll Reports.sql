INSERT INTO Reports
	(ReportName
	,ReportFolder
	,ReportType
	,FullPath
	,Parent
	,Company
	,Inactive
	,CustomFilter)
SELECT	REPLACE(ReportName, 'GIS ', 'NDJ ') AS ReportName
		,'DNJ REPORTS' AS ReportFolder
		,ReportType
		,REPLACE(FullPath, 'GIS ', 'DNJ ') AS FullPath
		,'010910' AS Parent
		,Company
		,Inactive
		,CustomFilter
FROM	Reports	
WHERE	ReportFolder = 'GIS REPORTS'