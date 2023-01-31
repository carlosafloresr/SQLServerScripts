USE [GIS]
GO

DECLARE @Document	Varchar(30) = 'ACH3905360555',
		@RmdType	Smallint,
		@DCStatus	Smallint

DECLARE @tblRecords	Table (RecordId Int)

SELECT	@RmdType  = RMDTYPAL,
		@DCStatus = DCSTATUS
FROM	RM00401 
WHERE	DOCNUMBR = @Document

IF @DCStatus = 2
BEGIN
	BEGIN TRANSACTION

	INSERT INTO @tblRecords
	SELECT	DEX_ROW_ID
	FROM	[dbo].[RM30201]
	WHERE	((@RmdType > 6 AND APFRDCNM = @Document) OR (@RmdType < 6 AND APTODCNM = @Document))
			AND RTRIM(APTODCNM) + '_' + RTRIM(APFRDCNM) NOT IN (SELECT RTRIM(APTODCNM) + '_' + RTRIM(APFRDCNM) FROM RM20201)

	INSERT INTO [dbo].[RM20201]
			([CUSTNMBR]
			,[CPRCSTNM]
			,[TRXSORCE]
			,[DATE1]
			,[TIME1]
			,[GLPOSTDT]
			,[POSTED]
			,[TAXDTLID]
			,[APTODCNM]
			,[APTODCTY]
			,[APTODCDT]
			,[ApplyToGLPostDate]
			,[CURNCYID]
			,[CURRNIDX]
			,[APPTOAMT]
			,[DISTKNAM]
			,[DISAVTKN]
			,[WROFAMNT]
			,[ORAPTOAM]
			,[ORDISTKN]
			,[ORDATKN]
			,[ORWROFAM]
			,[APTOEXRATE]
			,[APTODENRATE]
			,[APTORTCLCMETH]
			,[APTOMCTRXSTT]
			,[APFRDCNM]
			,[APFRDCTY]
			,[APFRDCDT]
			,[ApplyFromGLPostDate]
			,[FROMCURR]
			,[APFRMAPLYAMT]
			,[APFRMDISCTAKEN]
			,[APFRMDISCAVAIL]
			,[APFRMWROFAMT]
			,[ActualApplyToAmount]
			,[ActualDiscTakenAmount]
			,[ActualDiscAvailTaken]
			,[ActualWriteOffAmount]
			,[APFRMEXRATE]
			,[APFRMDENRATE]
			,[APFRMRTCLCMETH]
			,[APFRMMCTRXSTT]
			,[APYFRMRNDAMT]
			,[APYTORNDAMT]
			,[APYTORNDDISC]
			,[OAPYFRMRNDAMT]
			,[OAPYTORNDAMT]
			,[OAPYTORNDDISC]
			,[GSTDSAMT]
			,[PPSAMDED]
			,[RLGANLOS]
			,[Settled_Gain_CreditCurrT]
			,[Settled_Loss_CreditCurrT]
			,[Settled_Gain_DebitCurrTr]
			,[Settled_Loss_DebitCurrTr]
			,[Settled_Gain_DebitDiscAv]
			,[Settled_Loss_DebitDiscAv]
			,[Revaluation_Status])
	SELECT	[CUSTNMBR]
			,[CPRCSTNM]
			,[TRXSORCE]
			,[DATE1]
			,[TIME1]
			,[GLPOSTDT]
			,[POSTED]
			,[TAXDTLID]
			,[APTODCNM]
			,[APTODCTY]
			,[APTODCDT]
			,[ApplyToGLPostDate]
			,[CURNCYID]
			,[CURRNIDX]
			,[APPTOAMT]
			,[DISTKNAM]
			,[DISAVTKN]
			,[WROFAMNT]
			,[ORAPTOAM]
			,[ORDISTKN]
			,[ORDATKN]
			,[ORWROFAM]
			,[APTOEXRATE]
			,[APTODENRATE]
			,[APTORTCLCMETH]
			,[APTOMCTRXSTT]
			,[APFRDCNM]
			,[APFRDCTY]
			,[APFRDCDT]
			,[ApplyFromGLPostDate]
			,[FROMCURR]
			,[APFRMAPLYAMT]
			,[APFRMDISCTAKEN]
			,[APFRMDISCAVAIL]
			,[APFRMWROFAMT]
			,[ActualApplyToAmount]
			,[ActualDiscTakenAmount]
			,[ActualDiscAvailTaken]
			,[ActualWriteOffAmount]
			,[APFRMEXRATE]
			,[APFRMDENRATE]
			,[APFRMRTCLCMETH]
			,[APFRMMCTRXSTT]
			,[APYFRMRNDAMT]
			,[APYTORNDAMT]
			,[APYTORNDDISC]
			,[OAPYFRMRNDAMT]
			,[OAPYTORNDAMT]
			,[OAPYTORNDDISC]
			,[GSTDSAMT]
			,[PPSAMDED]
			,[RLGANLOS]
			,[Settled_Gain_CreditCurrT]
			,[Settled_Loss_CreditCurrT]
			,[Settled_Gain_DebitCurrTr]
			,[Settled_Loss_DebitCurrTr]
			,[Settled_Gain_DebitDiscAv]
			,[Settled_Loss_DebitDiscAv]
			,[Revaluation_Status]
	FROM	[dbo].[RM30201]
	WHERE	DEX_ROW_ID IN (SELECT RecordId FROM @tblRecords)

	IF @@ERROR = 0
	BEGIN
		DELETE	[dbo].[RM30201]
		WHERE	DEX_ROW_ID IN (SELECT RecordId FROM @tblRecords)

		COMMIT TRANSACTION
	END
	ELSE
		ROLLBACK TRANSACTION

END