/****** Object:  View [dbo].[View_Accounts]    Script Date: 4/9/2018 1:26:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_Accounts]
AS
SELECT 	ActIndx, 
	RTRIM(ActNumbr_1) + '-' + RTRIM(ActNumbr_2) + '-' + ActNumbr_3 AS Account,
	ActDescr,
	Active,
	UsrDefS1
FROM 	GL00100
GO


