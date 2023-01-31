/****** Script for SelectTopNRows command from SSMS  ******/
SELECT	INTA.*,
		GLA1.ACTIVE
FROM	[GPCustom].[dbo].[IntercompanyReport_Accounts] INTA
		INNER JOIN OIS..GL00105 GLA5 ON INTA.Account = GLA5.ACTNUMST
		INNER JOIN OIS..GL00100 GLA1 ON GLA5.ACTINDX = GLA1.ACTINDX
WHERE	INTA.Company = 'OIS'

