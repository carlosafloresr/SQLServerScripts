USE [Integrations]
GO

DECLARE	@BatchId		Varchar(22) = '1FSI20141218_1056',
		@CurrentValue	Varchar(15) = '236',
		@NewValue		Varchar(15) = '11478'

UPDATE	Integrations.dbo.FSI_ReceivedSubDetails 
SET		RecordCode = @NewValue
WHERE	BatchId  = @BatchId
		AND RecordCode = @CurrentValue

DECLARE	@Company Varchar(5) = (SELECT Company FROM Integrations.dbo.FSI_ReceivedHeader WHERE BatchId = @BatchId)

IF EXISTS(SELECT BatchId FROM Integrations.dbo.ReceivedIntegrations WHERE Integration = 'FSI' AND BatchId = @BatchId)
	UPDATE Integrations.dbo.ReceivedIntegrations SET Status = 0 WHERE Integration = 'FSI' AND BatchId = @BatchId
ELSE
	INSERT INTO Integrations.dbo.ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES ('FSI', @Company, @BatchId, 'ILSGP01')

UPDATE Integrations.dbo.FSI_ReceivedHeader SET Status = 0 WHERE BatchId = @BatchId
UPDATE Integrations.dbo.FSI_ReceivedDetails SET Processed = 0 WHERE BatchId = @BatchId
UPDATE Integrations.dbo.FSI_ReceivedSubDetails SET Processed = 0, Verification = Null WHERE BatchId = @BatchId

--DELETE ReceivedIntegrations WHERE Integration = 'FSI' AND BatchId = @BatchId
--DELETE FSI_ReceivedHeader WHERE BatchId = @BatchId
--DELETE FSI_ReceivedDetails WHERE BatchId = @BatchId --AND FSI_ReceivedDetailId >= 1486992
--DELETE FSI_ReceivedSubDetails WHERE BatchId = @BatchId --AND FSI_ReceivedSubDetailId >= 6629283

--SELECT * FROM ReceivedIntegrations WHERE BATCHID = @BatchId
--SELECT * FROM FSI_ReceivedHeader WHERE BATCHID = @BatchId --ORDER BY InvoiceNumber --AND VoucherNumber = '12-13629'
--SELECT * FROM FSI_ReceivedDetails WHERE BATCHID = @BatchId ORDER BY detailid --AND LEN(VoucherNumber) > 17
--SELECT * FROM FSI_ReceivedSubDetails WHERE BATCHID = @BatchId --AND RecordType = 'VND' ORDER BY DetailId, FSI_ReceivedSubDetailId 
/*

UPDATE	Integrations.dbo.FSI_ReceivedSubDetails 
SET		RecordCode = '16812'
WHERE	BatchId  = '1FSI20141218_1056'
		AND RecordCode = '228'

SendXML Error: Sql procedure error codes returned:
Error Number = 190  Stored Procedure taRMTransaction  Error Description = Document number (DOCNUMBR) already exists in either RM00401, RM10301, RM20101 or RM30101
Node Identifier Parameters: taRMTransaction                                    
RMDTYPAL = 1
DOCNUMBR = 15_09_D9-106078-AB
DOCDATE = 1/15/2011
BACHNUMB = '1FSI20141125_1746'
CUSTNMBR = 8926
*/

--SELECT * FROM FSI_ReceivedSubDetails WHERE RecordType = 'VND'
--SELECT * FROM FSI_ReceivedDetails WHERE InvoiceDate = '3/5/2011'
--SELECT * FROM View_Integration_FSI WHERE BatchId = '2FSI110308_1747' AND InvoiceTotal <> 0 AND Processed = 0 ORDER BY FSI_ReceivedDetailId