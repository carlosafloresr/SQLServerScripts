SELECT	CmpnyNam AS CompanyName, interid AS CompanyId, IIF(versionBuild > 1200, 'Upgraded', 'Untouched') AS DBStatus
FROM	DYNAMICS.dbo.DU000020 VER
		INNER JOIN view_allcompanies CMP ON VER.companyID = CMP.CmpanyId
WHERE	VER.PRODID = 0
		AND CmpnyNam NOT LIKE '%HIST%'
		AND CmpnyNam NOT LIKE '%ARCHI%'
		AND CmpnyNam NOT LIKE '%TEST%'
ORDER BY 3 DESC, 1