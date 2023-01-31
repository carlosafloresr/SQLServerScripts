SELECT	TMP.Trx_Date,
		TMP.JRNL_NO,
		TMP.Distribution_Reference,
		TMP.AP_Period,
		TMP.Pro,
		TMP.Amount,
		XCB.ProNumber AS Report_Pro,
		XCB.Amount AS Report_Amount
		--IIF(XCB.Matched = 1, 'YES', 'NO') AS Report_Matched
FROM	tmpXCB_December TMP
		LEFT OUTER JOIN GP_XCB_Prepaid XCB ON TMP.JRNL_NO = XCB.JournalNo AND TMP.Amount = XCB.Amount AND TMP.Pro = XCB.ProNumber
WHERE	TRX_DATE IS NOT NULL
--where	tmp.amount = 1980
AND XCB.Amount is null
order by TMP.JRNL_NO DESC

/*
SELECT	sum(amount), count(*)
FROM	tmpXCB_December
WHERE	TRX_DATE IS NOT NULL

SELECT	*
FROM	tmpXCB_December
where	amount = 1980
*/
 -- UPDATE tmpXCB_December SET JRNL_NO = REPLACE(JRNL_NO, '.00', '') WHERE AMOUNT = '0.00'