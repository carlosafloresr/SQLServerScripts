DECLARE	@BACHNUMB	Varchar(25) = 'DEX202193165834',
		@VCHNUMWK	Varchar(25) = 'IDV21090302714739',
		@TRXSORCE	Varchar(20) = 'PMTRX00068780'

INSERT INTO [dbo].[PM20000]
           ([VCHRNMBR]
           ,[VENDORID]
           ,[DOCTYPE]
           ,[DOCDATE]
           ,[DOCNUMBR]
           ,[DOCAMNT]
           ,[CURTRXAM]
           ,[DISTKNAM]
           ,[DISCAMNT]
           ,[DSCDLRAM]
           ,[BACHNUMB]
           ,[TRXSORCE]
           ,[BCHSOURC]
           ,[DISCDATE]
           ,[DUEDATE]
           ,[PORDNMBR]
           ,[TEN99AMNT]
           ,[WROFAMNT]
           ,[DISAMTAV]
           ,[TRXDSCRN]
           ,[UN1099AM]
           ,[BKTPURAM]
           ,[BKTFRTAM]
           ,[BKTMSCAM]
           ,[VOIDED]
           ,[HOLD]
           ,[CHEKBKID]
           ,[DINVPDOF]
           ,[PPSAMDED]
           ,[PPSTAXRT]
           ,[PGRAMSBJ]
           ,[GSTDSAMT]
           ,[POSTEDDT]
           ,[PTDUSRID]
           ,[MODIFDT]
           ,[MDFUSRID]
           ,[PYENTTYP]
           ,[CARDNAME]
           ,[PRCHAMNT]
           ,[TRDISAMT]
           ,[MSCCHAMT]
           ,[FRTAMNT]
           ,[TAXAMNT]
           ,[TTLPYMTS]
           ,[CURNCYID]
           ,[PYMTRMID]
           ,[SHIPMTHD]
           ,[TAXSCHID]
           ,[PCHSCHID]
           ,[FRTSCHID]
           ,[MSCSCHID]
           ,[PSTGDATE]
           ,[DISAVTKN]
           ,[CNTRLTYP]
           ,[NOTEINDX]
           ,[PRCTDISC]
           ,[RETNAGAM]
           ,[ICTRX]
           ,[Tax_Date]
           ,[PRCHDATE]
           ,[CORRCTN]
           ,[SIMPLIFD]
           ,[BNKRCAMT]
           ,[APLYWITH]
           ,[Electronic]
           ,[ECTRX]
           ,[DocPrinted]
           ,[TaxInvReqd]
           ,[VNDCHKNM]
           ,[BackoutTradeDisc]
           ,[CBVAT]
           ,[VADCDTRO]
           ,[TEN99TYPE]
           ,[TEN99BOXNUMBER]
           ,[PONUMBER])
SELECT	[VCHNUMWK]
		,[VENDORID]
		,[DOCTYPE]
		,[DOCDATE]
		,[DOCNUMBR]
		,[DOCAMNT]
		,[DOCAMNT] AS [CURTRXAM]
		,0 AS [DISTKNAM]
		,0 AS [DISCAMNT]
		,0 AS [DSCDLRAM]
		,[BACHNUMB]
		,@TRXSORCE AS [TRXSORCE]
		,'PM_Trxent' AS [BCHSOURC]
		,[DISCDATE]
		,[DUEDATE]
		,[PORDNMBR]
		,[TEN99AMNT]
		,[WROFAMNT]
		,[DISAMTAV]
		,[TRXDSCRN]
		,[UN1099AM]
		,[BKTPURAM]
		,[BKTFRTAM]
		,[BKTMSCAM]
		,0 AS [VOIDED]
		,0 AS [HOLD]
		,[CHEKBKID]
		,'01/01/1900' AS [DINVPDOF]
		,[PPSAMDED]
		,[PPSTAXRT]
		,[PGRAMSBJ]
		,[GSTDSAMT]
		,[PSTGDATE]
		,[PTDUSRID]
		,[MODIFDT]
		,[MDFUSRID]
		,0 AS [PYENTTYP]
		,[CARDNAME]
		,[PRCHAMNT]
		,[TRDISAMT]
		,0 AS [MSCCHAMT]
		,0 AS [FRTAMNT]
		,0 AS [TAXAMNT]
		,0 AS [TTLPYMTS]
		,[CURNCYID]
		,[PYMTRMID]
		,[SHIPMTHD]
		,[TAXSCHID]
		,[PCHSCHID]
		,[FRTSCHID]
		,[MSCSCHID]
		,[PSTGDATE]
		,[DISTKNAM]
		,[CNTRLTYP]
		,[NOTEINDX]
		,[PRCTDISC]
		,[RETNAGAM]
		,[ICTRX]
		,[Tax_Date]
		,[PRCHDATE]
		,[CORRCTN]
		,[SIMPLIFD]
		,[BNKRCAMT]
		,[APLYWITH]
		,[Electronic]
		,[ECTRX]
		,[DocPrinted]
		,[TaxInvReqd]
		,[CHEKNMBR]
		,[BackoutTradeDisc]
		,[CBVAT]
		,[VADCDTRO]
		,[TEN99TYPE]
		,[TEN99BOXNUMBER]
		,[PORDNMBR]
FROM	[dbo].[PM10000]
WHERE	BACHNUMB = @BACHNUMB
		AND VCHNUMWK = @VCHNUMWK

UPDATE	PM10100
SET		TRXSORCE	= DATA.TRXSORCE,
		PSTGSTUS	= 2
FROM	(
		SELECT	PH.TRXSORCE, PD.DEX_ROW_ID
		FROM	PM20000 PH
				INNER JOIN PM10100 PD ON PH.VCHRNMBR = PD.VCHRNMBR
		WHERE	PH.BACHNUMB = @BACHNUMB
				AND PD.TRXSORCE = ''
		) DATA
WHERE	PM10100.DEX_ROW_ID = DATA.DEX_ROW_ID

UPDATE	PM00400
SET		DCSTATUS = 2
WHERE	CNTRLNUM = @VCHNUMWK
