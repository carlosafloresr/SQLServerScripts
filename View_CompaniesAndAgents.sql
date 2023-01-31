/*
SELECT * FROM View_CompaniesAndAgents
*/
CREATE VIEW View_CompaniesAndAgents
AS
SELECT	DISTINCT COM.CompanyId,
		COM.CompanyNumber,
		ISNULL(AGE.Agent, 0) AS Agent,
		ISNULL(AGE.AgentName, COM.CompanyName) AS Name
FROM	GPCustom.dbo.Companies COM
		LEFT JOIN GPCustom.dbo.Agents AGE ON COM.CompanyId = AGE.Company
WHERE	COM.CompanyNumber <> 0
		AND COM.IsTest = 0