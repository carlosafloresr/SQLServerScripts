alter VIEW View_DHP_Applicants
AS
SELECT	DHP_Applicants.*,
	dbo.PROPER(Address) AS Address,
	dbo.PROPER(City) AS City, 
	State, 
	ZipCode,
	dbo.PROPER(RTRIM(LastName) + ', ' + RTRIM(FirstName) + CASE WHEN MiddleName IS NULL THEN '' ELSE ' ' + MiddleName END) AS FullName,
	CASE
	    	WHEN DriverType = '1' THEN 'Company Driver'
		WHEN DriverType = '2' THEN 'Owner/Operator'
		WHEN DriverType = '3' THEN 'Driver For    '
		ELSE ''
	END AS DriverTypeDescription,
	Companies.CompanyName,
	View_Divisions.Division,
	CASE
		WHEN Race = 1 THEN 'White'
		WHEN Race = 2 THEN 'Black'
		WHEN Race = 3 THEN 'Hispanic'
		WHEN Race = 4 THEN 'Asian'
		WHEN Race = 5 THEN 'Amer Indian'
		WHEN Race = 6 THEN 'Phillipine'
	ELSE 'Other' END AS RaceDescription,
	CAST(DATEDIFF(Month, DateofBirth, ApplicationDate) / 12 AS Int) AS Age,
	ISNULL(Acc.AccidentsCount, 0) AS AccidentsCount
FROM    DHP_Applicants
	LEFT JOIN Companies ON DHP_Applicants.Fk_CompanyID = Companies.CompanyID
	LEFT JOIN View_Divisions ON DHP_Applicants.Fk_DivisionId = View_Divisions.DivisionId
	LEFT JOIN (SELECT Fk_DHP_ApplicantId, MIN(DHP_ApplicantAddressId) AS DHP_ApplicantAddressId FROM DHP_ApplicantAddresses GROUP BY Fk_DHP_ApplicantId) Addr1
		ON DHP_Applicants.DHP_ApplicantId = Addr1.Fk_DHP_ApplicantId
	LEFT JOIN DHP_ApplicantAddresses ON Addr1.DHP_ApplicantAddressId = DHP_ApplicantAddresses.DHP_ApplicantAddressId
	LEFT JOIN (SELECT Fk_DHP_ApplicantId, COUNT(Fk_DHP_ApplicantId) AS AccidentsCount FROM DHP_ApplicantSafetyRecords GROUP BY Fk_DHP_ApplicantId) Acc ON DHP_Applicants.DHP_ApplicantId = Acc.Fk_DHP_ApplicantId
