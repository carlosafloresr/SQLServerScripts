SELECT	CASE WHEN LEN(Bill_Id) = 6 THEN 'T' + SUBSTRING(Bill_Id, 2, 5) ELSE 'T' + Bill_Id END AS CUSTNMBR,
		LEFT(RTRIM(Name_ln_1), 64) AS CUSTNAME,
		'MISC' AS Class,
		'MAIN' AS AdrsCode,
		Addr_ln_1 AS ADDRESS1,
		ISNULL(Addr_ln_2,'') AS ADDRESS2,
		CITY,
		STA.Name AS STATE,
		ISNULL(Zip, '') AS ZIPCODE,
		REPLACE(PHONE, '-', '') AS PHONE,
		0 AS Inactive
INTO	#TempData
FROM	GPCustom.dbo.OIS_BillTo BILL
		LEFT JOIN GPCustom.dbo.States STA ON BILL.State = STA.Description
WHERE	CASE WHEN LEN(Bill_Id) = 6 THEN 'T' + SUBSTRING(Bill_Id, 2, 5) ELSE 'T' + Bill_Id END NOT IN (SELECT CustNmbr FROM RM00101)
		AND Name_ln_1 <> ''
		AND Bill_Id IN ('115388',
'130633',
'143160',
'141645',
'127160',
'107254',
'101292',
'143005',
'144167',
'140027',
'111617',
'110617',
'101425',
'123872',
'100285',
'123407',
'126135',
'100066',
'124325',
'108279',
'119855',
'116096',
'130676',
'121443',
'101891',
'7777',
'106948',
'5010',
'148366')
ORDER BY 1

BEGIN TRANSACTION

INSERT INTO RM00101
	   (CUSTNMBR,
		CUSTNAME, 
		CUSTCLAS,
		AdrsCode,
		ADDRESS1,
		ADDRESS2,
		CITY,
		STATE,
		ZIP,
		PHONE1,
		INACTIVE)
SELECT	*
FROM	#TempData

IF @@ERROR = 0
BEGIN
	UPDATE	RM00101
	SET		StmtName = CustName,
			Kpdsthst = 1,
			Kpcalhst = 1,
			Kperhist = 1,
			Kptrxhst = 1,
			Crlmttyp = 1,
			Revalue_Customer = 1,
			OrderFulFillDefault = 1
	WHERE	CUSTNMBR IN (SELECT CUSTNMBR FROM #TempData)
END

IF @@ERROR = 0
BEGIN
	INSERT INTO dbo.RM00102
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
			Fax)
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
			Fax
	FROM	dbo.RM00101
	WHERE	CUSTNMBR IN (SELECT CUSTNMBR FROM #TempData)
END

IF @@ERROR = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION

DROP TABLE #TempData
/*
UPDATE	RM00101
SET		RM00101.STATE = DATA.Name
FROM	(
		SELECT	CASE WHEN LEN(Bill_Id) = 6 THEN 'T' + SUBSTRING(Bill_Id, 2, 5) ELSE 'T' + Bill_Id END AS CustomerId,
				STA.Name
		FROM	GPCustom.dbo.OIS_BillTo BILL
				LEFT JOIN GPCustom.dbo.States STA ON BILL.State = STA.Description
		WHERE	BILL.Name_ln_1 <> ''
				AND STA.Name IS NOT Null
		) DATA
WHERE	RM00101.CUSTNMBR = DATA.CustomerId

UPDATE	RM00102
SET		RM00102.STATE = DATA.Name
FROM	(
		SELECT	CASE WHEN LEN(Bill_Id) = 6 THEN 'T' + SUBSTRING(Bill_Id, 2, 5) ELSE 'T' + Bill_Id END AS CustomerId,
				STA.Name
		FROM	GPCustom.dbo.OIS_BillTo BILL
				LEFT JOIN GPCustom.dbo.States STA ON BILL.State = STA.Description
		WHERE	BILL.Name_ln_1 <> ''
				AND STA.Name IS NOT Null
		) DATA
WHERE	RM00102.CUSTNMBR = DATA.CustomerId

UPDATE	CustomerMaster
SET		CustomerMaster.State = TP.Name,
		CustomerMaster.Changed = 1,
		CustomerMaster.Trasmitted = 0
FROM	(SELECT	CASE WHEN LEN(Bill_Id) = 6 THEN 'T' + SUBSTRING(Bill_Id, 2, 5) ELSE 'T' + Bill_Id END AS CustomerId,
							STA.Name
					FROM	GPCustom.dbo.OIS_BillTo BILL
							LEFT JOIN GPCustom.dbo.States STA ON BILL.State = STA.Description
					WHERE	BILL.Name_ln_1 <> ''
							AND STA.Name IS NOT Null
		) TP 
WHERE	CustomerMaster.CustNmbr = TP.CustomerId

/*
DELETE	CustomerMaster
WHERE	CustNmbr IN (
					SELECT	CASE WHEN LEN(Bill_Id) = 6 THEN 'T' + SUBSTRING(Bill_Id, 2, 5) ELSE 'T' + Bill_Id END AS CustomerId
					FROM	GPCustom.dbo.OIS_BillTo BILL
					WHERE	BILL.Name_ln_1 <> ''
							AND BILL.Inactive = 1)
*/
*/