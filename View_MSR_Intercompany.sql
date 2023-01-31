USE [Integrations]
GO

/****** Object:  View [dbo].[View_MSR_Intercompany]    Script Date: 05/12/2010 13:06:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_MSR_Intercompany]
AS
SELECT	MSR.MSR_IntercompanyId
		,MSR.BatchId
		,MSR.DocNumber
		,ZUM.DocNumberTotal
		,CAST(MSR.DocNumber AS Varchar(12)) + ' [$' + CAST(ZUM.DocNumberTotal AS Varchar(12)) + ']' AS DocNumberDisplay
		,MSR.InvoiceNumber
		,MSR.Customer
		,MSR.InvoiceTotal
		,MSR.Chassis
		,MSR.Container
		,MSR.CO_MAR
		,MSR.CO_REP
		,MSR.CO_RPL
		,MSR.OO_MAR
		,MSR.OO_REP
		,MSR.OO_RPL
		,MSR.Account1
		,MSR.Account2
		,MSR.Account3
		,CASE WHEN MSR.Description IS Null THEN
			'INV ' + CAST(MSR.InvoiceNumber AS Varchar(12)) +
			CASE WHEN MSR.CO_MAR = 0 THEN '' ELSE ' COM&R' END + 
			CASE WHEN MSR.CO_REP = 0 THEN '' ELSE ' COREPA' END + 
			CASE WHEN MSR.CO_RPL = 0 THEN '' ELSE ' COREPL' END + 
			CASE WHEN MSR.OO_MAR = 0 THEN '' ELSE ' OOM&R' END + 
			CASE WHEN MSR.OO_REP = 0 THEN '' ELSE ' OOREPA' END + 
			CASE WHEN MSR.OO_RPL = 0 THEN '' ELSE ' OOREPL' END
		ELSE MSR.Description END AS [Description]
		,HDR.PostingDate
		,CASE WHEN MSR.CO_MAR = 0 THEN 0 ELSE 1 END + 
		CASE WHEN MSR.CO_REP = 0 THEN 0 ELSE 1 END + 
		CASE WHEN MSR.CO_RPL = 0 THEN 0 ELSE 1 END + 
		CASE WHEN MSR.OO_MAR = 0 THEN 0 ELSE 1 END + 
		CASE WHEN MSR.OO_REP = 0 THEN 0 ELSE 1 END + 
		CASE WHEN MSR.OO_RPL = 0 THEN 0 ELSE 1 END AS Records
		,CASE WHEN MSR.Amount1 + MSR.Amount2 + MSR.Amount3 = 0 THEN MSR.InvoiceTotal ELSE MSR.Amount1 END AS Amount1
		,MSR.Amount2
		,MSR.Amount3
		,HDR.Processed
FROM	MSR_Intercompany MSR
		INNER JOIN MSR_IntercompanyBatch HDR ON MSR.BatchId =  HDR.BatchId
		INNER JOIN (SELECT	BatchId
							,DocNumber
							,SUM(InvoiceTotal) AS DocNumberTotal
					FROM	MSR_Intercompany
					GROUP BY BatchId
							,DocNumber) ZUM ON MSR.BatchId = ZUM.BatchId AND MSR.DocNumber = ZUM.DocNumber
/*
SELECT * FROM View_MSR_Intercompany
*/
GO


