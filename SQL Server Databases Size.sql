-- select * from View_AllCompanies

SELECT	CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) As UsedSpaceInGB,
		CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00)) As UsedSpaceInMB
FROM	master.sys.master_files