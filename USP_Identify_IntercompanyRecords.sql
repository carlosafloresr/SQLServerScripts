USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_Identify_IntercompanyRecords]    Script Date: 04/01/2010 15:12:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_Identify_IntercompanyRecords] 
	@BatchId		Varchar(25),
	@Integration	Varchar(6) = 'FSI'
AS

-- ********* FSI INTEGRATION *********
IF @Integration = 'FSI'
BEGIN
	UPDATE	FSI_ReceivedDetails
	SET		Intercompany = 1
	FROM	(
	SELECT	HED.BatchId,
			DET.CustomerNumber
	FROM	FSI_ReceivedDetails DET
			INNER JOIN FSI_ReceivedHeader HED ON DET.BatchId = HED.BatchId
			INNER JOIN FSI_Intercompany_ARAP CUS ON DET.CustomerNumber = CUS.Account AND HED.Company = CUS.Company AND CUS.RecordType = 'C') CUS
	WHERE	FSI_ReceivedDetails.BatchId = CUS.BatchId
			AND FSI_ReceivedDetails.CustomerNumber = CUS.CustomerNumber
			AND FSI_ReceivedDetails.BatchId = @BatchId

	UPDATE	FSI_ReceivedSubDetails
	SET		VndIntercompany = 1
	FROM	(
	SELECT	HED.Company,
			SUB.BatchId,
			SUB.DetailId,
			SUB.RecordCode
	FROM	FSI_ReceivedSubDetails SUB
			INNER JOIN FSI_ReceivedDetails DET ON sub.BatchId = DET.BatchId AND SUB.DetailId = DET.DetailId
			INNER JOIN FSI_ReceivedHeader HED ON DET.BatchId = HED.BatchId
			INNER JOIN FSI_Intercompany_ARAP VND ON SUB.RecordCode = VND.Account AND HED.Company = VND.Company AND VND.RecordType = 'V'
	WHERE	SUB.RecordType = 'VND') VND
	WHERE	FSI_ReceivedSubDetails.BatchId = VND.BatchId
			AND FSI_ReceivedSubDetails.DetailId = VND.DetailId
			AND FSI_ReceivedSubDetails.RecordCode = VND.RecordCode
			AND FSI_ReceivedSubDetails.BatchId = @BatchId
END

-- ********* MSR INTEGRATION *********
IF @Integration = 'MSR'
BEGIN
	UPDATE	MSR_ReceviedTransactions 
	SET		Intercompany = dbo.IsCustomerIntercompany('RCMR', Customer, '11000')
	WHERE	BatchId = @BatchId
			AND Company = 'RCMR'
END