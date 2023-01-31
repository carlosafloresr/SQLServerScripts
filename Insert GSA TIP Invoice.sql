/*
EXECUTE USP_FIX_TIPTransactions 
		@VendorId			= '243',
		@ApplyFrom			= 'TIP0417181259',
		@ApplyFromAmount	= 32744.00,
		@ApplyInvoice		= 'TIP0417181259D',
		@ApplyInvoiceAmnt	= 1600.00
*/
ALTER PROCEDURE USP_FIX_TIPTransactions
		@VendorId			Varchar(15),
		@ApplyFrom			Varchar(30),
		@ApplyFromAmount	Numeric(10,2),
		@ApplyInvoice		Varchar(30),
		@ApplyInvoiceAmnt	Numeric(10,2)
AS
DECLARE	@VoucherNo			Varchar(30),
		@SourceVoucher		Varchar(30),
		@TRXSORCE			Varchar(30),
		@APTODCDT			Date,
		@DataLocation		SmallInt

DECLARE	@tblDocuments		Table (DocNumber Varchar(30))

INSERT INTO @tblDocuments
SELECT	RTRIM(APTODCNM)
FROM	PM30300 
WHERE	DOCTYPE = APTODCTY 
		AND APFRDCNM = @ApplyFrom

SELECT	@DataLocation = DCSTATUS
FROM	PM00400
WHERE	DOCNUMBR = @ApplyFrom

IF @DataLocation = 2
	SELECT	@VoucherNo	= RTRIM(VCHRNMBR),
			@TRXSORCE	= RTRIM(TRXSORCE),
			@APTODCDT	= DOCDATE
	FROM	PM20000
	WHERE	DOCNUMBR = @ApplyFrom
ELSE
	SELECT	@VoucherNo	= RTRIM(VCHRNMBR),
			@TRXSORCE	= RTRIM(TRXSORCE),
			@APTODCDT	= DOCDATE
	FROM	PM30200
	WHERE	DOCNUMBR = @ApplyFrom

SET @SourceVoucher	= @VoucherNo
SET @VoucherNo		= @VoucherNo + '_FX'
SET @TRXSORCE		= REPLACE(@TRXSORCE, 'PMTRX00', 'PMTRX11')

PRINT '      New Voucher: ' + @VoucherNo
PRINT '  New Transaction: ' + @TRXSORCE

BEGIN TRANSACTION

UPDATE	PM30200
SET		DOCAMNT = @ApplyFromAmount
WHERE	DOCNUMBR = @ApplyFrom
		AND DOCAMNT <> @ApplyFromAmount

UPDATE	PM30600
SET		CRDTAMNT = @ApplyFromAmount
WHERE	VCHRNMBR = @ApplyFrom
		AND CRDTAMNT > 0
		AND CRDTAMNT <> @ApplyFromAmount

UPDATE	PM30600
SET		DEBITAMT = @ApplyFromAmount
WHERE	VCHRNMBR = @ApplyFrom
		AND DEBITAMT > 0
		AND DEBITAMT <> @ApplyFromAmount

IF @DataLocation = 2
	INSERT INTO PM30200 
		(VCHRNMBR,VENDORID,DOCTYPE,DOCDATE,DOCNUMBR,DOCAMNT,                                                                                                                                                                                                            
		CURTRXAM,DISTKNAM,DISCAMNT,DSCDLRAM,BACHNUMB,TRXSORCE,                                                                                                                                                                                                         
		BCHSOURC,DISCDATE,DUEDATE,PORDNMBR,TEN99AMNT,WROFAMNT,                                                                                                                                                                                                         
		DISAMTAV,TRXDSCRN,UN1099AM,BKTPURAM,BKTFRTAM,BKTMSCAM,                                                                                                                                                                                                         
		VOIDED,HOLD,CHEKBKID,DINVPDOF,PPSAMDED,PPSTAXRT,                                                                                                                                                                                                               
		PGRAMSBJ,GSTDSAMT,POSTEDDT,PTDUSRID,MODIFDT,MDFUSRID,                                                                                                                                                                                                          
		PYENTTYP,CARDNAME,PRCHAMNT,TRDISAMT,MSCCHAMT,FRTAMNT,                                                                                                                                                                                                          
		TAXAMNT,TTLPYMTS,CURNCYID,PYMTRMID,SHIPMTHD,TAXSCHID,                                                                                                                                                                                                          
		PCHSCHID,FRTSCHID,MSCSCHID,PSTGDATE,DISAVTKN,CNTRLTYP,                                                                                                                                                                                                         
		NOTEINDX,PRCTDISC,RETNAGAM,VOIDPDATE,ICTRX,Tax_Date,                                                                                                                                                                                                           
		PRCHDATE,CORRCTN,SIMPLIFD,APLYWITH,Electronic,ECTRX,                                                                                                                                                                                                           
		DocPrinted,TaxInvReqd,VNDCHKNM,BackoutTradeDisc,CBVAT)
	SELECT	@VoucherNo AS VCHRNMBR, a.VENDORID, 1 AS DOCTYPE, a.DOCDATE, @ApplyInvoice AS DOCNUMBR, 
			@ApplyInvoiceAmnt AS DOCAMNT,                                                                                                                                                                                          
			0 AS CURTRXAM, a.DISTKNAM, a.DISCAMNT, a.DSCDLRAM, a.BACHNUMB, @TRXSORCE AS TRXSORCE,                                                                                                                                                                                       
			a.BCHSOURC, a.DISCDATE, a.DUEDATE, a.PORDNMBR, a.TEN99AMNT, a.WROFAMNT,                                                                                                                                                                                       
			a.DISAMTAV, a.TRXDSCRN, a.UN1099AM, a.BKTPURAM, a.BKTFRTAM, a.BKTMSCAM,                                                                                                                                                                                       
			a.VOIDED, a.HOLD, a.CHEKBKID, a.DINVPDOF, a.PPSAMDED, a.PPSTAXRT,                                                                                                                                                                                             
			a.PGRAMSBJ, a.GSTDSAMT, a.POSTEDDT, a.PTDUSRID, a.MODIFDT, a.MDFUSRID,                                                                                                                                                                                        
			a.PYENTTYP, a.CARDNAME, a.PRCHAMNT, a.TRDISAMT, a.MSCCHAMT, a.FRTAMNT,                                                                                                                                                                                        
			a.TAXAMNT, a.TTLPYMTS, a.CURNCYID, a.PYMTRMID, a.SHIPMTHD, a.TAXSCHID,                                                                                                                                                                                        
			a.PCHSCHID, a.FRTSCHID, a.MSCSCHID, a.PSTGDATE, a.DISAVTKN, a.CNTRLTYP,                                                                                                                                                                                       
			a.NOTEINDX, a.PRCTDISC, a.RETNAGAM, '1900-01-01', a.ICTRX, a.Tax_Date,                                                                                                                                                                                         
			a.PRCHDATE, a.CORRCTN, a.SIMPLIFD, a.APLYWITH, a.Electronic, a.ECTRX,                                                                                                                                                                                         
			a.DocPrinted, a.TaxInvReqd, a.VNDCHKNM, a.BackoutTradeDisc, a.CBVAT
	FROM	PM20000 A
	WHERE	DOCNUMBR = @ApplyFrom
			AND @ApplyInvoice NOT IN (SELECT DOCNUMBR FROM PM30200 WHERE VENDORID = @VendorId AND DOCNUMBR = @ApplyInvoice)
ELSE
	INSERT INTO PM30200 
		(VCHRNMBR,VENDORID,DOCTYPE,DOCDATE,DOCNUMBR,DOCAMNT,                                                                                                                                                                                                            
		CURTRXAM,DISTKNAM,DISCAMNT,DSCDLRAM,BACHNUMB,TRXSORCE,                                                                                                                                                                                                         
		BCHSOURC,DISCDATE,DUEDATE,PORDNMBR,TEN99AMNT,WROFAMNT,                                                                                                                                                                                                         
		DISAMTAV,TRXDSCRN,UN1099AM,BKTPURAM,BKTFRTAM,BKTMSCAM,                                                                                                                                                                                                         
		VOIDED,HOLD,CHEKBKID,DINVPDOF,PPSAMDED,PPSTAXRT,                                                                                                                                                                                                               
		PGRAMSBJ,GSTDSAMT,POSTEDDT,PTDUSRID,MODIFDT,MDFUSRID,                                                                                                                                                                                                          
		PYENTTYP,CARDNAME,PRCHAMNT,TRDISAMT,MSCCHAMT,FRTAMNT,                                                                                                                                                                                                          
		TAXAMNT,TTLPYMTS,CURNCYID,PYMTRMID,SHIPMTHD,TAXSCHID,                                                                                                                                                                                                          
		PCHSCHID,FRTSCHID,MSCSCHID,PSTGDATE,DISAVTKN,CNTRLTYP,                                                                                                                                                                                                         
		NOTEINDX,PRCTDISC,RETNAGAM,VOIDPDATE,ICTRX,Tax_Date,                                                                                                                                                                                                           
		PRCHDATE,CORRCTN,SIMPLIFD,APLYWITH,Electronic,ECTRX,                                                                                                                                                                                                           
		DocPrinted,TaxInvReqd,VNDCHKNM,BackoutTradeDisc,CBVAT)
	SELECT	@VoucherNo AS VCHRNMBR, a.VENDORID, 1 AS DOCTYPE, a.DOCDATE, @ApplyInvoice AS DOCNUMBR, 
			@ApplyInvoiceAmnt AS DOCAMNT,                                                                                                                                                                                          
			0 AS CURTRXAM, a.DISTKNAM, a.DISCAMNT, a.DSCDLRAM, a.BACHNUMB, @TRXSORCE AS TRXSORCE,                                                                                                                                                                                       
			a.BCHSOURC, a.DISCDATE, a.DUEDATE, a.PORDNMBR, a.TEN99AMNT, a.WROFAMNT,                                                                                                                                                                                       
			a.DISAMTAV, a.TRXDSCRN, a.UN1099AM, a.BKTPURAM, a.BKTFRTAM, a.BKTMSCAM,                                                                                                                                                                                       
			a.VOIDED, a.HOLD, a.CHEKBKID, a.DINVPDOF, a.PPSAMDED, a.PPSTAXRT,                                                                                                                                                                                             
			a.PGRAMSBJ, a.GSTDSAMT, a.POSTEDDT, a.PTDUSRID, a.MODIFDT, a.MDFUSRID,                                                                                                                                                                                        
			a.PYENTTYP, a.CARDNAME, a.PRCHAMNT, a.TRDISAMT, a.MSCCHAMT, a.FRTAMNT,                                                                                                                                                                                        
			a.TAXAMNT, a.TTLPYMTS, a.CURNCYID, a.PYMTRMID, a.SHIPMTHD, a.TAXSCHID,                                                                                                                                                                                        
			a.PCHSCHID, a.FRTSCHID, a.MSCSCHID, a.PSTGDATE, a.DISAVTKN, a.CNTRLTYP,                                                                                                                                                                                       
			a.NOTEINDX, a.PRCTDISC, a.RETNAGAM, '1900-01-01', a.ICTRX, a.Tax_Date,                                                                                                                                                                                         
			a.PRCHDATE, a.CORRCTN, a.SIMPLIFD, a.APLYWITH, a.Electronic, a.ECTRX,                                                                                                                                                                                         
			a.DocPrinted, a.TaxInvReqd, a.VNDCHKNM, a.BackoutTradeDisc, a.CBVAT
	FROM	PM30200 A
	WHERE	DOCNUMBR = @ApplyFrom
			AND @ApplyInvoice NOT IN (SELECT DOCNUMBR FROM PM30200 WHERE VENDORID = @VendorId AND DOCNUMBR = @ApplyInvoice)

IF @DataLocation = 2
	INSERT INTO PM30600
		(DOCTYPE,VCHRNMBR,DSTSQNUM,CNTRLTYP,CRDTAMNT,DEBITAMT,                                                                                                                                                                                                          
		DSTINDX,DISTTYPE,CHANGED,USERID,PSTGSTUS,VENDORID,                                                                                                                                                                                                             
		TRXSORCE,PSTGDATE,CURNCYID,CURRNIDX,ORCRDAMT,ORDBTAMT,                                                                                                                                                                                                         
		APTVCHNM,APTODCTY,SPCLDIST,DistRef)
	SELECT	1 AS DOCTYPE, @VoucherNo AS VCHRNMBR, a.DSTSQNUM, a.CNTRLTYP, 
			a.DEBITAMT AS CRDTAMNT, a.CRDTAMNT AS DEBITAMT,                                                                                                                                                                                        
			a.DSTINDX, a.DISTTYPE, a.CHANGED, a.USERID, a.PSTGSTUS, a.VENDORID,                                                                                                                                                                                           
			@TRXSORCE AS TRXSORCE, a.PSTGDATE, a.CURNCYID, a.CURRNIDX, a.ORCRDAMT, a.ORDBTAMT,                                                                                                                                                                                       
			a.APTVCHNM, a.APTODCTY, a.SPCLDIST, a.DistRef
	FROM	PM10100 a
	WHERE	VCHRNMBR = @SourceVoucher
			AND Vendorid = @VendorId
			AND @VoucherNo NOT IN (SELECT VCHRNMBR FROM PM30600 WHERE VENDORID = @VendorId AND VCHRNMBR = @VoucherNo)
ELSE
	INSERT INTO PM30600
		(DOCTYPE,VCHRNMBR,DSTSQNUM,CNTRLTYP,CRDTAMNT,DEBITAMT,                                                                                                                                                                                                          
		DSTINDX,DISTTYPE,CHANGED,USERID,PSTGSTUS,VENDORID,                                                                                                                                                                                                             
		TRXSORCE,PSTGDATE,CURNCYID,CURRNIDX,ORCRDAMT,ORDBTAMT,                                                                                                                                                                                                         
		APTVCHNM,APTODCTY,SPCLDIST,DistRef)
	SELECT	1 AS DOCTYPE, @VoucherNo AS VCHRNMBR, a.DSTSQNUM, a.CNTRLTYP, 
			IIF(a.DEBITAMT > 0, @ApplyInvoiceAmnt, 0) AS CRDTAMNT, IIF(a.CRDTAMNT > 0, @ApplyInvoiceAmnt, 0) AS DEBITAMT,                                                                                                                                                                                        
			a.DSTINDX, a.DISTTYPE, a.CHANGED, a.USERID, a.PSTGSTUS, a.VENDORID,                                                                                                                                                                                           
			@TRXSORCE AS TRXSORCE, a.PSTGDATE, a.CURNCYID, a.CURRNIDX, a.ORCRDAMT, a.ORDBTAMT,                                                                                                                                                                                       
			a.APTVCHNM, a.APTODCTY, a.SPCLDIST, a.DistRef
	FROM	PM30600 a
	WHERE	VCHRNMBR = @SourceVoucher
			AND Vendorid = @VendorId
			AND @VoucherNo NOT IN (SELECT VCHRNMBR FROM PM30600 WHERE VENDORID = @VendorId AND VCHRNMBR = @VoucherNo)

IF NOT EXISTS(SELECT DOCNUMBR FROM PM00400 WHERE VENDORID = @VendorId AND DOCNUMBR = @ApplyInvoice)
BEGIN
	INSERT INTO PM00400 (CNTRLNUM, CNTRLTYP, DCSTATUS, DOCTYPE, VENDORID, DOCNUMBR, TRXSORCE, DOCDATE)
	SELECT	@VoucherNo AS CNTRLNUM, CNTRLTYP, 3, 1, VENDORID, @ApplyInvoice, @TRXSORCE, DOCDATE
	FROM	PM00400
	WHERE	DOCNUMBR = @ApplyFrom
END

SELECT	a.VENDORID, a.DOCDATE, a.DATE1, a.GLPOSTDT, a.TIME1, @VoucherNo AS APTVCHNM,                                                                                                                                                                        
		1 AS APTODCTY, @ApplyInvoice AS APTODCNM, @APTODCDT AS APTODCDT, @APTODCDT AS ApplyToGLPostDate, 
		a.CURNCYID, a.CURRNIDX, a.APPLDAMT, a.DISTKNAM, a.DISAVTKN, a.WROFAMNT, a.ORAPPAMT, a.ORDISTKN,                                                                                                                                                                                       
		a.ORDATKN, a.ORWROFAM, a.APTOEXRATE, a.APTODENRATE, a.APTORTCLCMETH, a.APTOMCTRXSTT, APTVCHNM AS VCHRNMBR, a.DOCTYPE, 
		APTODCNM AS APFRDCNM, a.ApplyFromGLPostDate, a.FROMCURR, a.APFRMAPLYAMT,                                                                                                                                                                         
		a.APFRMDISCTAKEN, a.APFRMDISCAVAIL, a.APFRMWROFAMT, a.ActualApplyToAmount, a.ActualDiscTakenAmount, a.ActualDiscAvailTaken,                                                                                                                                   
		a.ActualWriteOffAmount, a.APFRMEXRATE, a.APFRMDENRATE, a.APFRMRTCLCMETH, a.APFRMMCTRXSTT, a.PPSAMDED,                                                                                                                                                         
		a.GSTDSAMT, a.TAXDTLID, a.POSTED, a.TEN99AMNT, a.RLGANLOS, a.APYFRMRNDAMT,                                                                                                                                                                                    
		a.APYTORNDAMT, a.APYTORNDDISC, a.OAPYFRMRNDAMT, a.OAPYTORNDAMT, a.OAPYTORNDDISC, a.Settled_Gain_CreditCurrT,                                                                                                                                                  
		a.Settled_Loss_CreditCurrT, a.Settled_Gain_DebitCurrTr, a.Settled_Loss_DebitCurrTr, a.Settled_Gain_DebitDiscAv, a.Settled_Loss_DebitDiscAv, a.Revaluation_Status
INTO	GPCustom.dbo.GSA_ApplyToRecords
FROM	PM30300 a
WHERE	APFRDCNM = @ApplyFrom
		AND APTODCNM IN (SELECT DocNumber FROM @tblDocuments)

DELETE	PM30300
WHERE	APFRDCNM = @ApplyFrom
		AND APTODCNM IN (SELECT DocNumber FROM @tblDocuments)

INSERT INTO PM30300
		(VENDORID,DOCDATE,DATE1,GLPOSTDT,TIME1,APTVCHNM,                                                                                                                                                                                                                
		APTODCTY,APTODCNM,APTODCDT,ApplyToGLPostDate,CURNCYID,CURRNIDX,                                                                                                                                                                                                
		APPLDAMT,DISTKNAM,DISAVTKN,WROFAMNT,ORAPPAMT,ORDISTKN,                                                                                                                                                                                                         
		ORDATKN,ORWROFAM,APTOEXRATE,APTODENRATE,APTORTCLCMETH,APTOMCTRXSTT,                                                                                                                                                                                            
		VCHRNMBR,DOCTYPE,APFRDCNM,ApplyFromGLPostDate,FROMCURR,APFRMAPLYAMT,                                                                                                                                                                                           
		APFRMDISCTAKEN,APFRMDISCAVAIL,APFRMWROFAMT,ActualApplyToAmount,ActualDiscTakenAmount,ActualDiscAvailTaken,                                                                                                                                                     
		ActualWriteOffAmount,APFRMEXRATE,APFRMDENRATE,APFRMRTCLCMETH,APFRMMCTRXSTT,PPSAMDED,                                                                                                                                                                           
		GSTDSAMT,TAXDTLID,POSTED,TEN99AMNT,RLGANLOS,APYFRMRNDAMT,                                                                                                                                                                                                      
		APYTORNDAMT,APYTORNDDISC,OAPYFRMRNDAMT,OAPYTORNDAMT,OAPYTORNDDISC,Settled_Gain_CreditCurrT,                                                                                                                                                                    
		Settled_Loss_CreditCurrT,Settled_Gain_DebitCurrTr,Settled_Loss_DebitCurrTr,Settled_Gain_DebitDiscAv,Settled_Loss_DebitDiscAv,Revaluation_Status)
SELECT	*
FROM	GPCustom.dbo.GSA_ApplyToRecords

UPDATE	PM30200
SET		CURTRXAM = 0
WHERE	DOCNUMBR IN (SELECT DocNumber FROM @tblDocuments)

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	DROP TABLE GPCustom.dbo.GSA_ApplyToRecords
	PRINT @ApplyFrom + ' - Completed'
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	PRINT @ApplyFrom + ' - Failed'
END