SELECT	CompanyId,
		DivisionName
FROM	View_Divisions
WHERE	INACTIVE = 0 AND CompanyId NOT IN ('ATEST','NDS','PTS','FI','RCCL','RCMR','IMCC','GSA')
ORDER BY 1,2