ALTER VIEW View_AR_OpenCredits
AS
SELECT	RM.Dex_Row_Id AS RowId,
	RM.CustNmbr,
	CU.CustName,
	RM.DocNumbr,
	RM.RmdTypal,
	RM.DocDate,
	RM.TrxDscrn,
	RM.OrTrxAmt AS Amount,
	AppliedAmount = ISNULL((SELECT SUM(AP.ActualApplyToAmount) FROM RM20201 AP WHERE RM.CustNmbr = AP.CustNmbr AND RM.DocNumbr = AP.ApFrDcNm AND RM.RmdTypal = AP.ApFrDcTy), 0),
	RM.OrTrxAmt - ISNULL((SELECT SUM(AP.ActualApplyToAmount) FROM RM20201 AP WHERE RM.CustNmbr = AP.CustNmbr AND RM.DocNumbr = AP.ApFrDcNm AND RM.RmdTypal = AP.ApFrDcTy), 0) AS Available,
	AP.ApToDcNm,
	AP.ApToDcDt,
	AP.ApToDcTy,
	AP.ActualApplyToAmount,
	SO.TrxDscrn AS Reference,
	CASE WHEN RM.RmdTypal = 9 THEN 'P' WHEN RM.RmdTypal = 7 THEN 'C' ELSE Null END AS DocType,
	DATEDIFF(d, RM.DocDate, GETDATE()) AS DocAge,
	CAST(YEAR(RM.DocDate) AS Char(4)) + '_' + CASE WHEN MONTH(RM.DocDate) < 10 THEN '0' ELSE '' END + RTRIM(CAST(MONTH(RM.DocDate) AS Char(2))) + '_' +
	CASE WHEN DAY(RM.DocDate) < 10 THEN '0' ELSE '' END + RTRIM(CAST(DAY(RM.DocDate) AS Char(2))) AS SortField
FROM	RM20101 RM
	INNER JOIN RM00101 CU ON RM.CustNmbr = CU.CustNmbr
	LEFT JOIN RM20201 AP ON RM.CustNmbr = AP.CustNmbr AND RM.DocNumbr = AP.ApFrDcNm AND RM.RmdTypal = AP.ApFrDcTy
	LEFT JOIN RM20101 SO ON SO.CustNmbr = AP.CustNmbr AND SO.DocNumbr = AP.ApToDcNm AND SO.RmdTypal = AP.ApToDcTy
WHERE	RM.RmdTypal IN (7,9)

select * from View_AR_OpenCredits where DocNumbr = 'CRD-5-08314'