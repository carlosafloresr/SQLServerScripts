/*
SELECT * FROM IMCT.dbo.RM00102

SELECT * FROM IMCT.dbo.RM00101
*/

INSERT INTO RM00102
	   (CustNmbr,
		AdrsCode,
		CntcPrsn,
		Address1,
		Address2,
		Address3,
		Country,
		City,
		State,
		Zip,
		Phone1,
		Phone2,
		Phone3,
		Fax,
		SLPRSNID,
		UPSZONE,
		SHIPMTHD,
		TAXSCHID,
		MODIFDT,
		CREATDDT,
		GPSFOINTEGRATIONID,
		INTEGRATIONSOURCE,
		INTEGRATIONID,
		CCode,
		DECLID,
		LOCNCODE,
		SALSTERR,
		USERDEF1,
		USERDEF2)
SELECT	CustNmbr,
		AdrsCode,
		CntcPrsn,
		Address1,
		Address2,
		Address3,
		Country,
		City,
		State,
		Zip,
		Phone1,
		Phone2,
		Phone3,
		Fax,
		SLPRSNID,
		UPSZONE,
		SHIPMTHD,
		TAXSCHID,
		MODIFDT,
		CREATDDT,
		GPSFOINTEGRATIONID,
		INTEGRATIONSOURCE,
		INTEGRATIONID,
		CCode,
		DECLID,
		'',
		SALSTERR,
		'',
		''
FROM	RM00101
WHERE	CustNmbr NOT IN (SELECT CustNmbr FROM dbo.RM00102)


UPDATE	RM00102
SET		CntcPrsn	= RM00101.CntcPrsn,
		Address1	= RM00101.Address1,
		Address2	= RM00101.Address2,
		Address3	= RM00101.Address3,
		Country		= RM00101.Country,
		City		= RM00101.City,
		State		= RM00101.State,
		Zip			= RM00101.Zip,
		Phone1		= RM00101.Phone1,
		Phone2		= RM00101.Phone2,
		Phone3		= RM00101.Phone3,
		Fax			= RM00101.Fax
FROM	RM00101
WHERE	RM00102.CustNmbr = RM00102.CustNmbr

/*
SELECT * FROM FPT_ReceivedDetails WHERE BatchId = '4_FPT_20080323' AND LEFT(VendorId, 2) = '04'

UPDATE FPT_ReceivedDetails SET VendorId = 'A' + SUBSTRING(VendorId, 3, 4) WHERE BatchId = '4_FPT_20080323' AND LEFT(VendorId, 2) = '04'
*/