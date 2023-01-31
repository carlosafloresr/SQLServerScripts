DECLARE	@BatchId		Varchar(15) = 'SPCL-' + GPCustom.dbo.PADL(MONTH(GETDATE()), 2, '0') + GPCustom.dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(GPCustom.dbo.PADL(YEAR(GETDATE()), 4, '0'), 2) + GPCustom.dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + GPCustom.dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0'),
		@Integration	Varchar(10) = 'SPCLAR', 
		@Company		Varchar(5) = DB_NAME()

INSERT INTO IntegrationsDB.Integrations.dbo.Integrations_AR
		([Integration]
		,[Company]
		,[BatchId]
		,[DOCNUMBR]
		,[DOCDESCR]
		,[CUSTNMBR]
		,[DOCDATE]
		,[DUEDATE]
		,[PostingDate]
		,[DOCAMNT]
		,[SLSAMNT]
		,[RMDTYPAL]
		,[ACTNUMST]
		,[DISTTYPE]
		,[DEBITAMT]
		,[CRDTAMNT]
		,[DistRef]
		,[ApplyTo]
		,[Division]
		,[ProNumber]
		,[VendorId]
		,[PopUpId]
		,[Processed]
		,[DistRecords]
		,[IntApToBal]
		,[GPAptoBal]
		,[WithApplyTo]
		,[Comment])
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		IIF(HDR.RMDTYPAL = 7, REPLACE(RTRIM(HDR.DOCNUMBR), 'CRD', 'DEB'), RTRIM(HDR.DOCNUMBR) + '-CRD') AS DOCNUMBR,
		'Credit for ' + RTRIM(HDR.DOCNUMBR) AS DOCDESCR,
		HDR.CUSTNMBR,
		HDR.DOCDATE,
		HDR.DUEDATE,
		HDR.POSTDATE,
		HDR.ORTRXAMT AS DOCAMNT,
		HDR.SLSAMNT,
		IIF(HDR.RMDTYPAL = 7, 1, 7) AS RMDTYPAL,
		RTRIM(ACT.ACTNUMST) AS ACTNUMST,
		CASE WHEN HDR.RMDTYPAL = 7 AND DET.DEBITAMT > 0 THEN 3
			 WHEN HDR.RMDTYPAL = 7 AND DET.CRDTAMNT > 0 THEN 9
			 WHEN HDR.RMDTYPAL = 1 AND DET.CRDTAMNT > 0 THEN 3
			 ELSE 19
		END AS DISTTYPE,
		DET.DEBITAMT AS CRDTAMNT,
		DET.CRDTAMNT AS DEBITAMT,
		'Credit for ' + RTRIM(HDR.DOCNUMBR) AS DISTREF,
		Null AS [ApplyTo],
		Null AS [Division],
		Null AS [ProNumber],
		Null AS [VendorId],
		0 AS [PopUpId],
		0 AS [Processed],
		0 AS [DistRecords],
		0 AS [IntApToBal],
		0 AS [GPAptoBal],
		0 AS [WithApplyTo],
		Null AS [Comment]
FROM	RM20101 HDR
		INNER JOIN RM10101 DET ON HDR.TRXSORCE = DET.TRXSORCE AND HDR.DOCNUMBR = DET.DOCNUMBR
		INNER JOIN GL00105 ACT ON DET.DSTINDX = ACT.ACTINDX
WHERE	HDR.BACHNUMB = 'FSIAR2208151625'
		AND HDR.VOIDSTTS = 0
		AND RIGHT(RTRIM(HDR.DOCNUMBR), 1) = 'Z'
		
IF @@ERROR = 0
BEGIN
	PRINT @BatchId

	EXECUTE IntegrationsDB.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId
END