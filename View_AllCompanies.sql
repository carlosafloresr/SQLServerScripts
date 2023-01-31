USE [DYNAMICS]
GO

/****** Object:  View [dbo].[View_AllCompanies]    Script Date: 1/25/2022 2:32:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
SELECT * FROM View_AllCompanies
*/
ALTER VIEW [dbo].[View_AllCompanies]
AS
SELECT 	CmpanyId, 
		InterId, 
		CmpnyNam,
		LocatNId,
		LocatnNm, 
		Address1, 
		Address2, 
		City, 
		State, 
		ZipCode,
		Phone1,
		Phone2,
		TypeOfBusiness,
		TaxRegTN
FROM 	Dynamics.dbo.SY01500

GO


