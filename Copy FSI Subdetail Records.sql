USE [Integrations]
GO

SELECT	[BatchId]
		,[DetailId]
		,[RecordType]
		,[RecordCode]
		,[Reference]
		,[ChargeAmount1]
		,[ChargeAmount2]
		,[ReferenceCode]
		,[Verification]
		,[Processed]
		,[VndIntercompany]
		,[VendorDocument]
		,[VendorReference]
INTO	#tmpData
FROM	FSI_ReceivedSubDetails
WHERE	Batchid IN ('9FSI20170109_1344')

BEGIN TRANSACTION

DELETE	FSI_ReceivedSubDetails
WHERE	Batchid IN ('9FSI20170109_1344')

INSERT INTO [dbo].[FSI_ReceivedSubDetails]
           ([BatchId]
           ,[DetailId]
           ,[RecordType]
           ,[RecordCode]
           ,[Reference]
           ,[ChargeAmount1]
           ,[ChargeAmount2]
           ,[ReferenceCode]
           ,[Verification]
           ,[Processed]
           ,[VndIntercompany]
           ,[VendorDocument]
           ,[VendorReference])
SELECT * FROM #tmpData

IF @@ERROR = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION

DROP TABLE #tmpData