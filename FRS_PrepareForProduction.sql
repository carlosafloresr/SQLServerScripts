USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[FRS_PrepareForProduction]    Script Date: 6/16/2022 10:04:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[FRS_PrepareForProduction]
AS
UPDATE	Parameters
SET		VarC = 'FI'
WHERE	ParameterCode = 'NEWPORT_FRS_COMPANY'

DELETE	[findata-intg-ms.imcc.com].Integrations.dbo.FRS_Integrations

--DELETE	LENSASQL002.Manifest.dbo.Transactions

--DELETE	LENSASQL002.Manifest.dbo.AdditionalValues
