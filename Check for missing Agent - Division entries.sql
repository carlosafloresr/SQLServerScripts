SELECT	AG.*,
		DV.DivisionNumber
FROM	Agents AG
		LEFT JOIN Divisions DV ON AG.Company = DV.Fk_CompanyID AND AG.Division = DV.DivisionNumber