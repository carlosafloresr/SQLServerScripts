-- SELECT * FROM PM00200
-- SELECT * FROM PM00300

SELECT	VENDORID,
		VENDNAME,
		VNDCHKNM,
		VENDSHNM,
		VADDCDPR,
		VADCDPAD,
		VADCDSFR,
		VADCDTRO,
		VNDCLSID,
		VNDCNTCT,
		ADDRESS1,
		ADDRESS2,
		ADDRESS3,
		CITY,
		STATE,
		ZIPCODE,
		COUNTRY,
		PHNUMBR1,
		PHNUMBR2,
		PHONE3,
		FAXNUMBR,
		UPSZONE,
		SHIPMTHD,
		TAXSCHID,
		ACNMVNDR,
		TXIDNMBR,
		VENDSTTS,
		CURNCYID,
		TXRGNNUM,
		PARVENID,
		TRDDISCT,
		TEN99TYPE,
		MINORDER,
		PYMTRMID,
		MINPYTYP,
		MINPYPCT,
		MINPYDLR,
		MXIAFVND,
		MAXINDLR,
		COMMENT1,
		COMMENT2,
		USERDEF1,
		USERDEF2,
		CRLMTDLR,
		PYMNTPRI,
		KPCALHST,
		KGLDSTHS,
		KPERHIST,
		KPTRXHST,
		HOLD,
		PTCSHACF,
		CREDTLMT,
		WRITEOFF,
		MXWOFAMT,
		SBPPSDED,
		PPSTAXRT,
		DXVARNUM,
		CRTCOMDT,
		CRTEXPDT,
		RTOBUTKN,
		XPDTOBLG,
		PRSPAYEE,
		PMAPINDX,
		PMCSHIDX,
		PMDAVIDX,
		PMDTKIDX,
		PMFINIDX,
		PMMSCHIX,
		PMFRTIDX,
		PMTAXIDX,
		PMWRTIDX,
		PMPRCHIX,
		PMRTNGIX,
		PMTDSCIX,
		ACPURIDX,
		PURPVIDX,
		NOTEINDX,
		CHEKBKID,
		MODIFDT,
		CREATDDT,
		RATETPID,
		Revalue_Vendor,
		Post_Results_To,
		FREEONBOARD,
		GOVCRPID,
		GOVINDID,
		DISGRPER,
		DUEGRPER,
		DOCFMTID,
		TaxInvRecvd,
		USERLANG,
		WithholdingType,
		WithholdingFormType,
		WithholdingEntityType,
		TaxFileNumMode,
		BRTHDATE,
		LaborPmtType,
		CCode,
		DECLID,
		CBVAT
FROM	PM00200
WHERE	VENDORID NOT IN (SELECT VENDORID FROM PM00200)

INSERT INTO PM00300
	   (VENDORID,
		ADRSCODE,
		VNDCNTCT,
		ADDRESS1,
		ADDRESS2,
		ADDRESS3,
		CITY,
		STATE,
		ZIPCODE,
		COUNTRY,
		UPSZONE,
		PHNUMBR1,
		PHNUMBR2,
		PHONE3,
		FAXNUMBR,
		SHIPMTHD,
		TAXSCHID,
		CCode,
		DECLID)
SELECT	VENDORID,
		'MAIN' AS ADRSCODE,
		VNDCNTCT,
		ADDRESS1,
		ADDRESS2,
		ADDRESS3,
		CITY,
		STATE,
		ZIPCODE,
		COUNTRY,
		UPSZONE,
		PHNUMBR1,
		PHNUMBR2,
		PHONE3,
		FAXNUMBR,
		SHIPMTHD,
		TAXSCHID,
		CCode,
		DECLID
FROM	PM00200
WHERE	VENDORID NOT IN (SELECT VENDORID FROM PM00300)