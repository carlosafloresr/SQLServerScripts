CREATE VIEW View_AllCompanies
AS
SELECT 	CmpanyId, 
	InterId, 
	CmpnyNam,
	LocatnNm, 
	Address1, 
	Address2, 
	City, 
	State, 
	ZipCode,
	Phone1,
	Phone2,
	TypeOfBusiness 
FROM 	Dynamics.dbo.SY01500