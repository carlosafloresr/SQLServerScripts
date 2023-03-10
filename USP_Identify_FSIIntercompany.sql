USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_Identify_FSIIntercompany]    Script Date: 1/30/2023 2:56:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Identify_FSIIntercompany '1FSI20210305_1612'
*/
ALTER PROCEDURE [dbo].[USP_Identify_FSIIntercompany] 
	@BatchId		Varchar(25),
	@Integration	Varchar(6) = 'FSI'
AS
DECLARE @Company Varchar(5)

SET @Company = (SELECT Company FROM FSI_ReceivedHeader WHERE BatchId = @BatchId)

UPDATE	FSI_ReceivedDetails
SET		Intercompany = 1,
		ICB = ICB_Type
FROM	(
		SELECT	DISTINCT HED.BatchId,
				DET.CustomerNumber,
				DET.InvoiceNumber,
				CUS.TransType,
				IIF(EXISTS(SELECT AR.Company FROM FSI_Intercompany_ARAP AR WHERE AR.Company = @Company AND AR.Account = DET.CustomerNumber AND AR.RecordType = 'C'), 1, 0) AS ICB_Type
		FROM	FSI_ReceivedDetails DET
				INNER JOIN FSI_ReceivedHeader HED ON DET.BatchId = HED.BatchId
				INNER JOIN FSI_Intercompany_ARAP CUS ON DET.CustomerNumber = CUS.Account AND HED.Company = CUS.Company AND CUS.RecordType = 'C' AND CUS.ForGLIntegration = 1 AND CUS.TransType = IIF(DET.ICB = 1, 'ICB', 'FRG')
		WHERE	DET.BatchId = @BatchId
				--AND ((IIF(EXISTS(SELECT AR.Company FROM FSI_Intercompany_ARAP AR WHERE AR.Company = @Company AND AR.Account = DET.CustomerNumber AND AR.RecordType = 'C'), 1, 0) = 1 AND CUS.TransType = 'ICB')
				--OR (DET.ICB = 0 AND CUS.TransType = 'FRG'))
		) CUS
WHERE	FSI_ReceivedDetails.BatchId = CUS.BatchId
		AND FSI_ReceivedDetails.CustomerNumber = CUS.CustomerNumber
		AND FSI_ReceivedDetails.InvoiceNumber = CUS.InvoiceNumber
		AND ICB_Type = 1

UPDATE	FSI_ReceivedSubDetails
SET		VndIntercompany = 1,
		ICB = ICB_Type
FROM	(
		SELECT	HED.Company,
				SUB.BatchId,
				SUB.DetailId,
				SUB.RecordCode,
				IIF(EXISTS(SELECT AR.Company FROM FSI_Intercompany_ARAP AR WHERE AR.Company = @Company AND AR.Account = SUB.RecordCode AND AR.RecordType = 'V'), 1, 0) AS ICB_Type
		FROM	FSI_ReceivedSubDetails SUB
				INNER JOIN FSI_ReceivedDetails DET ON sub.BatchId = DET.BatchId AND SUB.DetailId = DET.DetailId
				INNER JOIN FSI_ReceivedHeader HED ON DET.BatchId = HED.BatchId
				INNER JOIN FSI_Intercompany_ARAP VND ON SUB.RecordCode = VND.Account AND HED.Company = @Company AND VND.RecordType = 'V' AND VND.TransType = 'ICB' --AND VND.ForGLIntegration = 1 AND VND.TransType = IIF(SUB.ICB = 1, 'ICB', 'FRG')
		WHERE	SUB.BatchId = @BatchId
				AND SUB.RecordType = 'VND'
				AND SUB.AccCode <> 'DEM'
				--AND ((IIF(EXISTS(SELECT AR.Company FROM FSI_Intercompany_ARAP AR WHERE AR.Company = @Company AND AR.Account = SUB.RecordCode AND AR.RecordType = 'V'), 1, 0) = 1 AND VND.TransType = 'ICB')
				--OR (SUB.ICB = 0 AND VND.TransType = 'FRG'))
		) VND
WHERE	FSI_ReceivedSubDetails.BatchId = VND.BatchId
		AND FSI_ReceivedSubDetails.DetailId = VND.DetailId
		AND FSI_ReceivedSubDetails.RecordCode = VND.RecordCode
		AND ICB_Type = 1