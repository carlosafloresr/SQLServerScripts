DECLARE	@DocNmbr	Varchar(25),
		@VendorId	Varchar(15)

DECLARE curDocuments CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	APT.DocNumbr, APT.VendorId
	FROM	PM20000 APT
			LEFT JOIN (SELECT	VendorId, ApToDcnm, SUM(ActualApplyToAmount) AS ApplyAmount, COUNT(ApToDcnm) AS Counter
						FROM	PM10200
						GROUP BY VendorId, ApToDcnm) APL
			ON APT.DocNumbr = APL.ApToDcnm AND APT.VendorId = APL.VendorId
			LEFT JOIN (SELECT	VendorId, ApToDcnm, SUM(ActualApplyToAmount) AS ApplyAmount, COUNT(ApToDcnm) AS Counter
						FROM	PM30300
						GROUP BY VendorId, ApToDcnm) AP2
			ON APT.DocNumbr = AP2.ApToDcnm AND APT.VendorId = AP2.VendorId
	WHERE	APT.DocAmnt <> APT.CurTrxAm
			AND APT.DocType = 1
			AND APL.Counter IS Null
	ORDER BY APT.DocDate

OPEN curDocuments 
FETCH FROM curDocuments INTO @DocNmbr, @VendorId

BEGIN TRANSACTION

WHILE @@FETCH_STATUS = 0 
BEGIN
	BEGIN TRANSACTION
	
	INSERT INTO PM10200
			(VENDORID
			,DOCDATE
			,DATE1
			,GLPOSTDT
			,TIME1
			,APTVCHNM
			,APTODCTY
			,APTODCNM
			,APTODCDT
			,ApplyToGLPostDate
			,CURNCYID
			,CURRNIDX
			,APPLDAMT
			,DISTKNAM
			,DISAVTKN
			,WROFAMNT
			,ORAPPAMT
			,ORDISTKN
			,ORDATKN
			,ORWROFAM
			,APTOEXRATE
			,APTODENRATE
			,APTORTCLCMETH
			,APTOMCTRXSTT
			,VCHRNMBR
			,DOCTYPE
			,APFRDCNM
			,ApplyFromGLPostDate
			,FROMCURR
			,APFRMAPLYAMT
			,APFRMDISCTAKEN
			,APFRMDISCAVAIL
			,APFRMWROFAMT
			,ActualApplyToAmount
			,ActualDiscTakenAmount
			,ActualDiscAvailTaken
			,ActualWriteOffAmount
			,APFRMEXRATE
			,APFRMDENRATE
			,APFRMRTCLCMETH
			,APFRMMCTRXSTT
			,PPSAMDED
			,GSTDSAMT
			,TAXDTLID
			,POSTED
			,TEN99AMNT
			,RLGANLOS
			,APYFRMRNDAMT
			,APYTORNDAMT
			,APYTORNDDISC
			,OAPYFRMRNDAMT
			,OAPYTORNDAMT
			,OAPYTORNDDISC
			,Settled_Gain_CreditCurrT
			,Settled_Loss_CreditCurrT
			,Settled_Gain_DebitCurrTr
			,Settled_Loss_DebitCurrTr
			,Settled_Gain_DebitDiscAv
			,Settled_Loss_DebitDiscAv
			,Revaluation_Status)
	SELECT	VENDORID
			,DOCDATE
			,DATE1
			,GLPOSTDT
			,TIME1
			,APTVCHNM
			,APTODCTY
			,APTODCNM
			,APTODCDT
			,ApplyToGLPostDate
			,CURNCYID
			,CURRNIDX
			,APPLDAMT
			,DISTKNAM
			,DISAVTKN
			,WROFAMNT
			,ORAPPAMT
			,ORDISTKN
			,ORDATKN
			,ORWROFAM
			,APTOEXRATE
			,APTODENRATE
			,APTORTCLCMETH
			,APTOMCTRXSTT
			,VCHRNMBR
			,DOCTYPE
			,APFRDCNM
			,ApplyFromGLPostDate
			,FROMCURR
			,APFRMAPLYAMT
			,APFRMDISCTAKEN
			,APFRMDISCAVAIL
			,APFRMWROFAMT
			,ActualApplyToAmount
			,ActualDiscTakenAmount
			,ActualDiscAvailTaken
			,ActualWriteOffAmount
			,APFRMEXRATE
			,APFRMDENRATE
			,APFRMRTCLCMETH
			,APFRMMCTRXSTT
			,PPSAMDED
			,GSTDSAMT
			,TAXDTLID
			,POSTED
			,TEN99AMNT
			,RLGANLOS
			,APYFRMRNDAMT
			,APYTORNDAMT
			,APYTORNDDISC
			,OAPYFRMRNDAMT
			,OAPYTORNDAMT
			,OAPYTORNDDISC
			,Settled_Gain_CreditCurrT
			,Settled_Loss_CreditCurrT
			,Settled_Gain_DebitCurrTr
			,Settled_Loss_DebitCurrTr
			,Settled_Gain_DebitDiscAv
			,Settled_Loss_DebitDiscAv
			,Revaluation_Status
	FROM	PM30300 
	WHERE	APTODCNM = @DocNmbr 
			AND VendorId = @VendorId

	UPDATE	PM00400 
	SET		DcStatus = 2
	WHERE	DcStatus = 3 
			AND DocNumbr IN (SELECT DocNumbr FROM PM10200 WHERE VendorId = @VendorId)

	DELETE	PM30300 
	WHERE	APTODCNM = @DocNmbr 
			AND VendorId = @VendorId

	IF @@ERROR = 0
		COMMIT TRANSACTION
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		PRINT 'Error on Driver: ' + @VendorId
	END

	FETCH FROM curDocuments INTO @DocNmbr, @VendorId
END

CLOSE curDocuments
DEALLOCATE curDocuments