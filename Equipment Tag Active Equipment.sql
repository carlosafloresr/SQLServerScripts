SELECT COM.CompanyId, TAG.* FROM GPCustom.dbo.EquipmentTags TAG INNER JOIN View_CompaniesAndAgents COM ON tag.cmpy_no = com.CompanyNumber 
WHERE	make IN ('FRHT','MACK','WSTST')
		AND div_code IN ('9','8','13','23')
		AND status <> 'I'
ORDER BY COM.CompanyId, TAG.div_code, TAG.UnitNumber

--SELECT DISTINCT MAKE FROM GPCustom.dbo.EquipmentTags

