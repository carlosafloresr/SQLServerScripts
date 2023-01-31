USE [Integrations]
GO

SET NOCOUNT ON

DECLARE @BatchId		Varchar(20) = 'APPLY',
		@Integration	Varchar(10) = 'APPLYAR',
		@Company		Varchar(5) = 'IMC',
		@Payment		Varchar(25) = '',
		@PostingDate	Date = GETDATE()

SET		@BatchId = @BatchId + dbo.PADL(MONTH(@PostingDate), 2, '0') + dbo.PADL(DAY(@PostingDate), 2, '0') + RIGHT(dbo.PADL(YEAR(@PostingDate), 4, '0'), 2) + dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0')

INSERT INTO [dbo].[Integrations_ApplyTo]
        ([Integration] 
		,[Company] 
		,[BatchId] 
		,[CustomerVendor] 
		,[ApplyFrom]
		,[ApplyTo]
        ,[ApplyAmount]
		,[WriteOffAmnt]
		,[RecordType]
		,[Processed]
		,[Notes]
		,[ToCreate]
		,[PostingDate])
SELECT	@Integration AS Integration, 
		Company, 
		@BatchId AS BatchId,
		CUSTNMBR, 
		DOCNUMBR, 
		REPLACE(DOCNUMBR, '-CRD', ''), 
		ABS(DOCAMNT), 
		0, 
		'AR', 
		0, 
		Null, 
		0, 
		@PostingDate
FROM	Integrations_AR
WHERE	BATCHID = 'SPCL-0819221349'

IF @@ERROR = 0
BEGIN
	PRINT @BatchId

	EXECUTE IntegrationsDB.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId
END