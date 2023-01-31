USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_ImportSWSAgentsandDivisions]    Script Date: 10/24/2017 1:26:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ImportSWS_CustomerParameters
*/
ALTER PROCEDURE [dbo].[USP_ImportSWS_CustomerParameters]
AS
SET NOCOUNT OFF

DECLARE	@tblCustomers Table
	(CompanyNumber		Int,
	CustomerNumber		Varchar(25))

INSERT INTO @tblCustomers
EXECUTE USP_QuerySWS 'SELECT Cmpy_No, Code FROM COM.BillTo WHERE DlyInvEmail =  ''Y'''

UPDATE	CustomerMaster
SET		DailyInvoicing = DATA.DlyInvEmail
FROM	(
		SELECT	DAT.CompanyId, 
				DAT.CustomerNumber,
				CASE WHEN DAT.CompanyId IS Null THEN 0 ELSE 1 END AS DlyInvEmail
		FROM	CustomerMaster CMA
				LEFT JOIN (
							SELECT	COM.CompanyId, 
									TBL.CompanyNumber,
									TBL.CustomerNumber
							FROM	@tblCustomers TBL
									INNER JOIN View_CompaniesAndAgents COM ON TBL.CompanyNumber = CASE WHEN COM.Agent = 0 THEN COM.CompanyNumber ELSE COM.Agent END
						  ) DAT ON CMA.CompanyId = DAT.CompanyId AND CMA.CustNmbr = DAT.CustomerNumber
		) DATA
WHERE	CustomerMaster.CompanyId = DATA.CompanyId
		AND CustomerMaster.CustNmbr = DATA.CustomerNumber
		AND CustomerMaster.DailyInvoicing <> DATA.DlyInvEmail
		
GO