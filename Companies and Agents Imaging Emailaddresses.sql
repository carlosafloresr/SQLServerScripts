/*
EXECUTE USP_Company_ImagingEmailadress 1
*/
ALTER PROCEDURE USP_Company_ImagingEmailadress
		@CompanyNumber	Int
AS
SELECT	'imaging' + IIF(VCA.Agent = 0, '', '.' + Agent) + '@' + CPY.WebAddress AS Emailaddress
FROM	Companies CPY
		LEFT JOIN View_CompaniesAndAgents VCA ON CPY.CompanyId = VCA.CompanyId
WHERE	CPY.WebAddress IS NOT Null
		AND CPY.IsTest = 0
		AND CPY.Trucking = 1
		AND IIF(VCA.Agent = 0, VCA.CompanyNumber, VCA.Agent) = @CompanyNumber