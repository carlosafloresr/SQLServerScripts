/*
EXECUTE USP_AP_MoveOpenToHistory 'TIP0724181512D', 1
*/
ALTER PROCEDURE USP_AP_MoveOpenToHistory
		@DocumentNumber	Varchar(30),
		@DocumentType	Smallint
AS
IF EXISTS(SELECT Id FROM tempdb.dbo.sysobjects WHERE xtype IN ('U') AND id = OBJECT_ID(N'tempdb..##PMMoveDebitOpenToHist'))
	DROP TABLE ##PMMoveDebitOpenToHist 

SELECT	CNTRLNUM AS VCHRNMBR, 
		DOCTYPE, 
		DOCNUMBR 
INTO	##PMMoveDebitOpenToHist 
FROM	PM00400 
WHERE	DOCNUMBR = @DocumentNumber
		AND DOCTYPE = @DocumentType

-- Insert open records to hist 
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
SELECT	a.VCHRNMBR, a.VENDORID, a.DOCTYPE, a.DOCDATE, a.DOCNUMBR, a.DOCAMNT,                                                                                                                                                                                          
		a.CURTRXAM, a.DISTKNAM, a.DISCAMNT, a.DSCDLRAM, a.BACHNUMB, a.TRXSORCE,                                                                                                                                                                                       
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
FROM	PM20000 a
		JOIN ##PMMoveDebitOpenToHist b ON a.VCHRNMBR = b.VCHRNMBR AND a.DOCTYPE = b.DOCTYPE

DELETE	APOPN
FROM	PM20000 APOPN 
		JOIN ##PMMoveDebitOpenToHist TMPTBL ON APOPN.VCHRNMBR = TMPTBL.VCHRNMBR AND APOPN.DOCTYPE = TMPTBL.DOCTYPE

-- Update keys 
UPDATE	DOCMAS
SET		DOCMAS.DCSTATUS = 3
FROM	PM00400 DOCMAS 
		JOIN ##PMMoveDebitOpenToHist TMPTBL ON DOCMAS.CNTRLNUM = TMPTBL.VCHRNMBR AND DOCMAS.DOCTYPE = TMPTBL.DOCTYPE

-- move dist from open to hist
INSERT INTO PM30600
		(DOCTYPE,VCHRNMBR,DSTSQNUM,CNTRLTYP,CRDTAMNT,DEBITAMT,                                                                                                                                                                                                          
		DSTINDX,DISTTYPE,CHANGED,USERID,PSTGSTUS,VENDORID,                                                                                                                                                                                                             
		TRXSORCE,PSTGDATE,CURNCYID,CURRNIDX,ORCRDAMT,ORDBTAMT,                                                                                                                                                                                                         
		APTVCHNM,APTODCTY,SPCLDIST,DistRef)
SELECT	b.DOCTYPE, a.VCHRNMBR, a.DSTSQNUM, a.CNTRLTYP, a.CRDTAMNT, a.DEBITAMT,                                                                                                                                                                                        
		a.DSTINDX, a.DISTTYPE, a.CHANGED, a.USERID, a.PSTGSTUS, a.VENDORID,                                                                                                                                                                                           
		a.TRXSORCE, a.PSTGDATE, a.CURNCYID, a.CURRNIDX, a.ORCRDAMT, a.ORDBTAMT,                                                                                                                                                                                       
		a.APTVCHNM, a.APTODCTY, a.SPCLDIST, a.DistRef
FROM	PM10100 a
		JOIN PM00400 b ON a.VCHRNMBR = b.CNTRLNUM AND a.CNTRLTYP = b.CNTRLTYP
		JOIN ##PMMoveDebitOpenToHist c ON a.VCHRNMBR = c.VCHRNMBR AND b.DOCTYPE = c.DOCTYPE

DELETE a 
FROM	PM10100 a
		JOIN PM00400 b ON a.VCHRNMBR = b.CNTRLNUM AND a.CNTRLTYP = b.CNTRLTYP
		JOIN ##PMMoveDebitOpenToHist c ON a.VCHRNMBR = c.VCHRNMBR AND b.DOCTYPE = c.DOCTYPE

-- move tax records from open to hist
INSERT INTO PM30700
	(VENDORID,VCHRNMBR,DOCTYPE,BACHNUMB,TAXDTLID,BKOUTTAX,                                                                                                                                                                                                          
	TAXAMNT,ORTAXAMT,PCTAXAMT,ORPURTAX,FRTTXAMT,ORFRTTAX,                                                                                                                                                                                                          
	MSCTXAMT,ORMSCTAX,ACTINDX,TRXSORCE,TDTTXPUR,ORTXBPUR,                                                                                                                                                                                                          
	TXDTTPUR,ORTOTPUR,CURRNIDX)
SELECT	a.VENDORID, a.VCHRNMBR, a.DOCTYPE, a.BACHNUMB, a.TAXDTLID, a.BKOUTTAX,                                                                                                                                                                                        
		a.TAXAMNT, a.ORTAXAMT, a.PCTAXAMT, a.ORPURTAX, a.FRTTXAMT, a.ORFRTTAX,                                                                                                                                                                                        
		a.MSCTXAMT, a.ORMSCTAX, a.ACTINDX, a.TRXSORCE, a.TDTTXPUR, a.ORTXBPUR,                                                                                                                                                                                        
		a.TXDTTPUR, a.ORTOTPUR, a.CURRNIDX
FROM	PM10500 a
		JOIN ##PMMoveDebitOpenToHist b ON a.VCHRNMBR = b.VCHRNMBR AND a.DOCTYPE = b.DOCTYPE

DELETE	a 
FROM	PM10500 a 
		JOIN ##PMMoveDebitOpenToHist b ON a.VCHRNMBR = b.VCHRNMBR AND a.DOCTYPE = b.DOCTYPE

-- move applied records
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
SELECT	a.VENDORID, a.DOCDATE, a.DATE1, a.GLPOSTDT, a.TIME1, a.APTVCHNM,                                                                                                                                                                                              
		a.APTODCTY, a.APTODCNM, a.APTODCDT, a.ApplyToGLPostDate, a.CURNCYID, a.CURRNIDX,                                                                                                                                                                              
		a.APPLDAMT, a.DISTKNAM, a.DISAVTKN, a.WROFAMNT, a.ORAPPAMT, a.ORDISTKN,                                                                                                                                                                                       
		a.ORDATKN, a.ORWROFAM, a.APTOEXRATE, a.APTODENRATE, a.APTORTCLCMETH, a.APTOMCTRXSTT,                                                                                                                                                                          
		a.VCHRNMBR, a.DOCTYPE, a.APFRDCNM, a.ApplyFromGLPostDate, a.FROMCURR, a.APFRMAPLYAMT,                                                                                                                                                                         
		a.APFRMDISCTAKEN, a.APFRMDISCAVAIL, a.APFRMWROFAMT, a.ActualApplyToAmount, a.ActualDiscTakenAmount, a.ActualDiscAvailTaken,                                                                                                                                   
		a.ActualWriteOffAmount, a.APFRMEXRATE, a.APFRMDENRATE, a.APFRMRTCLCMETH, a.APFRMMCTRXSTT, a.PPSAMDED,                                                                                                                                                         
		a.GSTDSAMT, a.TAXDTLID, a.POSTED, a.TEN99AMNT, a.RLGANLOS, a.APYFRMRNDAMT,                                                                                                                                                                                    
		a.APYTORNDAMT, a.APYTORNDDISC, a.OAPYFRMRNDAMT, a.OAPYTORNDAMT, a.OAPYTORNDDISC, a.Settled_Gain_CreditCurrT,                                                                                                                                                  
		a.Settled_Loss_CreditCurrT, a.Settled_Gain_DebitCurrTr, a.Settled_Loss_DebitCurrTr, a.Settled_Gain_DebitDiscAv, a.Settled_Loss_DebitDiscAv, a.Revaluation_Status
FROM	PM10200 a
		JOIN ##PMMoveDebitOpenToHist b ON a.APTVCHNM = b.VCHRNMBR AND a.APTODCTY = b.DOCTYPE
		LEFT JOIN PM30300 c ON a.APTVCHNM = c.APTVCHNM AND a.APTODCTY = c.APTODCTY AND a.VCHRNMBR = c.VCHRNMBR AND a.DOCTYPE = c.DOCTYPE
WHERE	c.VCHRNMBR IS Null

-- delete apply records that should not be in open
DELETE	a
FROM	PM10200 a
		JOIN ##PMMoveDebitOpenToHist b ON a.APTVCHNM = b.VCHRNMBR AND a.APTODCTY = b.DOCTYPE
		JOIN (SELECT	t1.CNTRLNUM, t1.DOCTYPE 
			  FROM		PM00400 t1
						JOIN (SELECT	DISTINCT t2.VCHRNMBR, t2.DOCTYPE 
							  FROM		PM10200 t2
										JOIN ##PMMoveDebitOpenToHist t3 ON t2.APTVCHNM = t3.VCHRNMBR AND t2.APTODCTY = t3.DOCTYPE) t4 ON t1.CNTRLNUM = t4.VCHRNMBR AND t1.DOCTYPE = t4.DOCTYPE
			  WHERE	t1.DCSTATUS <> 2
			  ) c ON a.VCHRNMBR = c.CNTRLNUM AND a.DOCTYPE = c.DOCTYPE