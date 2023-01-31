SELECT	CNTRLNUM AS VCHRNMBR, 
		DOCTYPE, 
		DOCNUMBR 
INTO	##PMMoveDebitOpenToHist 
FROM	PM00400 
WHERE	CNTRLNUM = 'XXXX' and DOCTYPE = 'X'

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
select 
a.VCHRNMBR, a.VENDORID, a.DOCTYPE, a.DOCDATE, a.DOCNUMBR, a.DOCAMNT,                                                                                                                                                                                          
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
from PM20000 a
join ##PMMoveDebitOpenToHist b on a.VCHRNMBR = b.VCHRNMBR and a.DOCTYPE = b.DOCTYPE
delete a
from PM20000 a 
join ##PMMoveDebitOpenToHist b on a.VCHRNMBR = b.VCHRNMBR and a.DOCTYPE = b.DOCTYPE
-- update keys 
update a set a.DCSTATUS = 3
from PM00400 a 
join ##PMMoveDebitOpenToHist b on a.CNTRLNUM = b.VCHRNMBR and a.DOCTYPE = b.DOCTYPE
-- move dist from open to hist
insert into PM30600
(DOCTYPE,VCHRNMBR,DSTSQNUM,CNTRLTYP,CRDTAMNT,DEBITAMT,                                                                                                                                                                                                          
DSTINDX,DISTTYPE,CHANGED,USERID,PSTGSTUS,VENDORID,                                                                                                                                                                                                             
TRXSORCE,PSTGDATE,CURNCYID,CURRNIDX,ORCRDAMT,ORDBTAMT,                                                                                                                                                                                                         
APTVCHNM,APTODCTY,SPCLDIST,DistRef)
select 
b.DOCTYPE, a.VCHRNMBR, a.DSTSQNUM, a.CNTRLTYP, a.CRDTAMNT, a.DEBITAMT,                                                                                                                                                                                        
a.DSTINDX, a.DISTTYPE, a.CHANGED, a.USERID, a.PSTGSTUS, a.VENDORID,                                                                                                                                                                                           
a.TRXSORCE, a.PSTGDATE, a.CURNCYID, a.CURRNIDX, a.ORCRDAMT, a.ORDBTAMT,                                                                                                                                                                                       
a.APTVCHNM, a.APTODCTY, a.SPCLDIST, a.DistRef
from PM10100 a
join PM00400 b on a.VCHRNMBR = b.CNTRLNUM and a.CNTRLTYP = b.CNTRLTYP
join ##PMMoveDebitOpenToHist c on a.VCHRNMBR = c.VCHRNMBR and b.DOCTYPE = c.DOCTYPE
delete a 
from PM10100 a
join PM00400 b on a.VCHRNMBR = b.CNTRLNUM and a.CNTRLTYP = b.CNTRLTYP
join ##PMMoveDebitOpenToHist c on a.VCHRNMBR = c.VCHRNMBR and b.DOCTYPE = c.DOCTYPE
-- move tax records from open to hist
insert into PM30700
(VENDORID,VCHRNMBR,DOCTYPE,BACHNUMB,TAXDTLID,BKOUTTAX,                                                                                                                                                                                                          
TAXAMNT,ORTAXAMT,PCTAXAMT,ORPURTAX,FRTTXAMT,ORFRTTAX,                                                                                                                                                                                                          
MSCTXAMT,ORMSCTAX,ACTINDX,TRXSORCE,TDTTXPUR,ORTXBPUR,                                                                                                                                                                                                          
TXDTTPUR,ORTOTPUR,CURRNIDX)
select
a.VENDORID, a.VCHRNMBR, a.DOCTYPE, a.BACHNUMB, a.TAXDTLID, a.BKOUTTAX,                                                                                                                                                                                        
a.TAXAMNT, a.ORTAXAMT, a.PCTAXAMT, a.ORPURTAX, a.FRTTXAMT, a.ORFRTTAX,                                                                                                                                                                                        
a.MSCTXAMT, a.ORMSCTAX, a.ACTINDX, a.TRXSORCE, a.TDTTXPUR, a.ORTXBPUR,                                                                                                                                                                                        
a.TXDTTPUR, a.ORTOTPUR, a.CURRNIDX
from PM10500 a
join ##PMMoveDebitOpenToHist b on a.VCHRNMBR = b.VCHRNMBR and a.DOCTYPE = b.DOCTYPE
delete a 
from PM10500 a 
join ##PMMoveDebitOpenToHist b on a.VCHRNMBR = b.VCHRNMBR and a.DOCTYPE = b.DOCTYPE
-- move applied records
insert into PM30300
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
select
a.VENDORID, a.DOCDATE, a.DATE1, a.GLPOSTDT, a.TIME1, a.APTVCHNM,                                                                                                                                                                                              
a.APTODCTY, a.APTODCNM, a.APTODCDT, a.ApplyToGLPostDate, a.CURNCYID, a.CURRNIDX,                                                                                                                                                                              
a.APPLDAMT, a.DISTKNAM, a.DISAVTKN, a.WROFAMNT, a.ORAPPAMT, a.ORDISTKN,                                                                                                                                                                                       
a.ORDATKN, a.ORWROFAM, a.APTOEXRATE, a.APTODENRATE, a.APTORTCLCMETH, a.APTOMCTRXSTT,                                                                                                                                                                          
a.VCHRNMBR, a.DOCTYPE, a.APFRDCNM, a.ApplyFromGLPostDate, a.FROMCURR, a.APFRMAPLYAMT,                                                                                                                                                                         
a.APFRMDISCTAKEN, a.APFRMDISCAVAIL, a.APFRMWROFAMT, a.ActualApplyToAmount, a.ActualDiscTakenAmount, a.ActualDiscAvailTaken,                                                                                                                                   
a.ActualWriteOffAmount, a.APFRMEXRATE, a.APFRMDENRATE, a.APFRMRTCLCMETH, a.APFRMMCTRXSTT, a.PPSAMDED,                                                                                                                                                         
a.GSTDSAMT, a.TAXDTLID, a.POSTED, a.TEN99AMNT, a.RLGANLOS, a.APYFRMRNDAMT,                                                                                                                                                                                    
a.APYTORNDAMT, a.APYTORNDDISC, a.OAPYFRMRNDAMT, a.OAPYTORNDAMT, a.OAPYTORNDDISC, a.Settled_Gain_CreditCurrT,                                                                                                                                                  
a.Settled_Loss_CreditCurrT, a.Settled_Gain_DebitCurrTr, a.Settled_Loss_DebitCurrTr, a.Settled_Gain_DebitDiscAv, a.Settled_Loss_DebitDiscAv, a.Revaluation_Status
from PM10200 a
join ##PMMoveDebitOpenToHist b on a.APTVCHNM = b.VCHRNMBR and a.APTODCTY = b.DOCTYPE
left join PM30300 c on a.APTVCHNM = c.APTVCHNM and a.APTODCTY = c.APTODCTY and a.VCHRNMBR = c.VCHRNMBR and a.DOCTYPE = c.DOCTYPE
where c.VCHRNMBR is null
-- delete apply records that should not be in open
delete a
from PM10200 a
join ##PMMoveDebitOpenToHist b on a.APTVCHNM = b.VCHRNMBR and a.APTODCTY = b.DOCTYPE
join (select t1.CNTRLNUM, t1.DOCTYPE 
from PM00400 t1
join (select distinct t2.VCHRNMBR, t2.DOCTYPE 
from PM10200 t2
join ##PMMoveDebitOpenToHist t3 on t2.APTVCHNM = t3.VCHRNMBR and t2.APTODCTY = t3.DOCTYPE) t4
  on t1.CNTRLNUM = t4.VCHRNMBR and t1.DOCTYPE = t4.DOCTYPE
where t1.DCSTATUS <> 2) c on a.VCHRNMBR = c.CNTRLNUM and a.DOCTYPE = c.DOCTYPE