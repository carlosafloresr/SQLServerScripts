DECLARE	@Document	Varchar(25) = 'ACH3905360555'

BEGIN TRANSACTION

INSERT INTO dbo.RM20101
		(CUSTNMBR,
		CPRCSTNM,
		DOCNUMBR,
		CHEKNMBR,
		BACHNUMB,
		BCHSOURC,
		TRXSORCE,
		RMDTYPAL,
		CSHRCTYP,
		CBKIDCRD,
		CBKIDCSH,
		CBKIDCHK,
		DUEDATE,
		DOCDATE,
		POSTDATE,
		PSTUSRID,
		GLPOSTDT,
		LSTEDTDT,
		LSTUSRED,
		ORTRXAMT,
		CURTRXAM,
		SLSAMNT,
		COSTAMNT,
		FRTAMNT,
		MISCAMNT,
		TAXAMNT,
		COMDLRAM,
		CASHAMNT,
		DISTKNAM,
		DISAVAMT,
		DISAVTKN,
		DISCRTND,
		DISCDATE,
		DSCDLRAM,
		DSCPCTAM,
		WROFAMNT,
		TRXDSCRN,
		CSPORNBR,
		SLPRSNID,
		SLSTERCD,
		DINVPDOF,
		PPSAMDED,
		GSTDSAMT,
		DELETE1,
		AGNGBUKT,
		VOIDSTTS,
		VOIDDATE,
		TAXSCHID,
		CURNCYID,
		PYMTRMID,
		SHIPMTHD,
		TRDISAMT,
		SLSCHDID,
		FRTSCHID,
		MSCSCHID,
		NOTEINDX,
		Tax_Date,
		APLYWITH,
		SALEDATE,
		CORRCTN,
		SIMPLIFD,
		Electronic,
		ECTRX,
		BKTSLSAM,
		BKTFRTAM,
		BKTMSCAM,
		BackoutTradeDisc,
		Factoring,
		DIRECTDEBIT,
		ADRSCODE,
		EFTFLAG,
		DEX_ROW_TS)
SELECT	CUSTNMBR,
		CPRCSTNM,
		DOCNUMBR,
		CHEKNMBR,
		BACHNUMB,
		BCHSOURC,
		TRXSORCE,
		RMDTYPAL,
		CSHRCTYP,
		'',
		'',
		'',
		DUEDATE,
		DOCDATE,
		POSTDATE,
		PSTUSRID,
		GLPOSTDT,
		LSTEDTDT,
		LSTUSRED,
		ORTRXAMT,
		0,
		SLSAMNT,
		COSTAMNT,
		FRTAMNT,
		MISCAMNT,
		TAXAMNT,
		COMDLRAM,
		CASHAMNT,
		DISTKNAM,
		DISAVAMT,
		0,
		DISCRTND,
		DISCDATE,
		DSCDLRAM,
		DSCPCTAM,
		WROFAMNT,
		TRXDSCRN,
		CSPORNBR,
		SLPRSNID,
		SLSTERCD,
		DINVPDOF,
		PPSAMDED,
		GSTDSAMT,
		DELETE1,
		'',
		VOIDSTTS,
		VOIDDATE,
		TAXSCHID,
		CURNCYID,
		PYMTRMID,
		SHIPMTHD,
		TRDISAMT,
		SLSCHDID,
		FRTSCHID,
		MSCSCHID,
		NOTEINDX,
		Tax_Date,
		APLYWITH,
		SALEDATE,
		CORRCTN,
		SIMPLIFD,
		Electronic,
		ECTRX,
		BKTSLSAM,
		BKTFRTAM,
		BKTMSCAM,
		BackoutTradeDisc,
		Factoring,
		DIRECTDEBIT,
		ADRSCODE,
		EFTFLAG,
		DEX_ROW_TS
FROM	dbo.RM30101
WHERE	DOCNUMBR = @Document

-- Move RM Tax Work File , RM Tax History RM10601 > RM30601
INSERT INTO dbo.RM10601
		(BACHNUMB,
		RMDTYPAL,
		DOCNUMBR,
		CUSTNMBR,
		TAXDTLID,
		TRXSORCE,
		ACTINDX,
		BKOUTTAX,
		TAXAMNT,
		ORTAXAMT,
		STAXAMNT,
		ORSLSTAX,
		FRTTXAMT,
		ORFRTTAX,
		MSCTXAMT,
		ORMSCTAX,
		TAXDTSLS,
		ORTOTSLS,
		TDTTXSLS,
		ORTXSLS,
		POSTED,
		SEQNUMBR,
		CURRNIDX)   -- TXDTLPCTAMT
SELECT	BACHNUMB,
		RMDTYPAL,
		DOCNUMBR,
		CUSTNMBR,
		TAXDTLID,
		TRXSORCE,
		ACTINDX,
		0,
		TAXAMNT,
		ORTAXAMT,
		STAXAMNT,
		ORSLSTAX,
		FRTTXAMT,
		ORFRTTAX,
		MSCTXAMT,
		ORMSCTAX,
		TAXDTSLS,
		ORTOTSLS,
		TDTTXSLS,
		ORTXSLS,
		POSTED,
		SEQNUMBR,
		CURRNIDX
       --TXDTLPCTAMT
FROM	RM30601
WHERE	DOCNUMBR = @Document

--- Move RM Distribution Details , RM Tax History RM10601 > RM30601
INSERT INTO dbo.RM10101
		(TRXSORCE,
		POSTED,
		POSTEDDT,
		PSTGSTUS,
		CHANGED,
		DOCNUMBR,
		DCSTATUS,
		DISTTYPE,
		RMDTYPAL,
		SEQNUMBR,
		CUSTNMBR,
		DSTINDX,
		DEBITAMT,
		CRDTAMNT,
		PROJCTID,
		USERID,
		CATEGUSD,
		CURNCYID,
		CURRNIDX,
		ORCRDAMT,
		ORDBTAMT,
		DistRef)
SELECT	TRXSORCE,
		1,
		POSTEDDT,
		1,
		0,
		DOCNUMBR,
		1,
		DISTTYPE,
		RMDTYPAL,
		SEQNUMBR,
		CUSTNMBR,
		DSTINDX,
		DEBITAMT,
		CRDTAMNT,
		PROJCTID,
		USERID,
		CATEGUSD,
		CURNCYID,
		CURRNIDX,
		ORCRDAMT,
		ORDBTAMT,
		DistRef
FROM	dbo.RM30301
WHERE	DOCNUMBR = @Document

IF @@ERROR = 0
BEGIN
	DELETE FROM RM30301 WHERE DOCNUMBR = @Document
	DELETE FROM RM30601 WHERE DOCNUMBR = @Document
	DELETE FROM RM30101 WHERE DOCNUMBR = @Document

	COMMIT TRANSACTION
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
END