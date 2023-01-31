ALTER VIEW View_SO_OpenItems
AS
SELECT	SO.Dex_Row_Id AS RowId,
	SO.CustNmbr,
	SO.CustName,
	SO.DocNumbr,
	SO.RmdTypal,
	SO.DocDate,
	SO.DueDate,
	SO.TrxDscrn,
	SO.CsPOrNbr,
	SO.SlsAmnt,
	AppliedAmount = ISNULL((SELECT SUM(AP.ActualApplyToAmount) FROM RM20201 AP WHERE SO.CustNmbr = AP.CustNmbr AND SO.DocNumbr = AP.ApToDcNm AND SO.RmdTypal = AP.ApToDcTy), 0),
	SO.SlsAmnt - ISNULL((SELECT SUM(AP.ActualApplyToAmount) FROM RM20201 AP WHERE SO.CustNmbr = AP.CustNmbr AND SO.DocNumbr = AP.ApToDcNm AND SO.RmdTypal = AP.ApToDcTy), 0) AS OpenBalance,
	AP.ApFrDcNm,
	AP.ApFrDcDt,
	CASE WHEN AP.ApFrDcTy = 9 THEN 'P' WHEN AP.ApFrDcTy = 7 THEN 'C' ELSE Null END AS ApFrDcTy,
	DATEDIFF(d, SO.DocDate, GETDATE()) AS DocAge,
	CAST(YEAR(SO.DocDate) AS Char(4)) + '_' + CASE WHEN MONTH(SO.DocDate) < 10 THEN '0' ELSE '' END + RTRIM(CAST(MONTH(SO.DocDate) AS Char(2))) + '_' +
	CASE WHEN DAY(SO.DocDate) < 10 THEN '0' ELSE '' END + RTRIM(CAST(DAY(SO.DocDate) AS Char(2))) AS SortField
FROM	SOP30200 SO
	LEFT JOIN RM20201 AP ON SO.CustNmbr = AP.CustNmbr AND SO.DocNumbr = AP.ApToDcNm AND SO.RmdTypal = AP.ApToDcTy
WHERE	SO.RmdTypal = 1

-- SELECT * FROM SOP10102 WHERE SopNumbe LIKE 'DM%'
SELECT * FROM RM20201 WHERE APTODCNM LIKE 'DM%'
SELECT * FROM SOP30200 WHERE SopNumbe LIKE 'DM%'
SELECT * FROM RM20101 WHERE RMDTYPAL = 9 AND CUSTNMBR = '4386'
/*
SELECT * FROM RM20101
SELECT	SO.CustNmbr,
	SO.DocNumbr,
	SO.SlsAmnt,
	AppliedAmount = isnull((SELECT SUM(AP.ActualApplyToAmount) FROM RM20201 AP WHERE SO.CustNmbr = AP.CustNmbr AND SO.DocNumbr = AP.ApToDcNm AND SO.RmdTypal = AP.ApToDcTy), 0)
FROM	RM20101 RM
select	* from RM20101

SELECT * FROM RM00101
SELECT CustNmbr, ApToDcTy, ApToDcNm, SUM(ActualApplyToAmount) AS ActualApplyToAmount FROM RM20201 GROUP BY CustNmbr, ApToDcTy, ApToDcNm
SELECT * FROM RM20201 where AppToAmt <> OrApToAm

SELECT	*
FROM	RM20101
*/

