ALTER VIEW [dbo].[View_SO_OpenItems]
AS
SELECT	SO.Dex_Row_Id AS RowId,
		SO.CustNmbr,
		SO.CustName,
		SO.SopNumbe,
		SO.SopType,
		SO.DocDate,
		SO.DueDate,
		SO.Refrence,
		SO.CstPONbr,
		SO.SubTotal,
		AppliedAmount = ISNULL((SELECT SUM(AP.ActualApplyToAmount) FROM RM20201 AP WHERE SO.CustNmbr = AP.CustNmbr AND SO.SopNumbe = AP.ApToDcNm AND SO.SopType = AP.ApToDcTy), 0),
		SO.SubTotal - ISNULL((SELECT SUM(AP.ActualApplyToAmount) FROM RM20201 AP WHERE SO.CustNmbr = AP.CustNmbr AND SO.SopNumbe = AP.ApToDcNm AND SO.SopType = AP.ApToDcTy), 0) AS OpenBalance,
		AP.ApFrDcNm,
		AP.ApFrDcDt,
		AP.ActualApplyToAmount AS AppAmount,
		CASE WHEN AP.ApFrDcTy = 9 THEN 'P' WHEN AP.ApFrDcTy = 7 THEN 'C' ELSE Null END AS ApFrDcTy,
		DATEDIFF(d, SO.DocDate, GETDATE()) AS DocAge,
		CAST(YEAR(SO.DocDate) AS Char(4)) + '_' + CASE WHEN MONTH(SO.DocDate) < 10 THEN '0' ELSE '' END + RTRIM(CAST(MONTH(SO.DocDate) AS Char(2))) + '_' +
		CASE WHEN DAY(SO.DocDate) < 10 THEN '0' ELSE '' END + RTRIM(CAST(DAY(SO.DocDate) AS Char(2))) AS SortField
FROM	SOP30200 SO
		LEFT JOIN RM20201 AP ON SO.CustNmbr = AP.CustNmbr AND SO.SopNumbe = AP.ApToDcNm AND SO.SopType = AP.ApToDcTy
WHERE	SO.SopNumbe LIKE 'DM%'
UNION
SELECT	RM.Dex_Row_Id AS RowId,
		RM.CustNmbr,
		CU.CustName,
		RM.DocNumbr,
		RM.RmdTypal,
		RM.DocDate,
		RM.DueDate,
		RM.TrxDscrn,
		RM.CsPOrNbr,
		RM.SlsAmnt,
		AppliedAmount = ISNULL((SELECT SUM(AP.ActualApplyToAmount) FROM RM20201 AP WHERE RM.CustNmbr = AP.CustNmbr AND RM.DocNumbr = AP.ApToDcNm AND RM.RmdTypal = AP.ApToDcTy), 0),
		RM.SlsAmnt - ISNULL((SELECT SUM(AP.ActualApplyToAmount) FROM RM20201 AP WHERE RM.CustNmbr = AP.CustNmbr AND RM.DocNumbr = AP.ApToDcNm AND RM.RmdTypal = AP.ApToDcTy), 0) AS OpenBalance,
		AP.ApFrDcNm,
		AP.ApFrDcDt,
		AP.ActualApplyToAmount AS AppAmount,
		CASE WHEN AP.ApFrDcTy = 9 THEN 'P' WHEN AP.ApFrDcTy = 7 THEN 'C' ELSE Null END AS ApFrDcTy,
		DATEDIFF(d, RM.DocDate, GETDATE()) AS DocAge,
		CAST(YEAR(RM.DocDate) AS Char(4)) + '_' + CASE WHEN MONTH(RM.DocDate) < 10 THEN '0' ELSE '' END + RTRIM(CAST(MONTH(RM.DocDate) AS Char(2))) + '_' +
		CASE WHEN DAY(RM.DocDate) < 10 THEN '0' ELSE '' END + RTRIM(CAST(DAY(RM.DocDate) AS Char(2))) AS SortField
FROM	RM20101 RM
		INNER JOIN RM00101 CU ON RM.CustNmbr = CU.CustNmbr
		LEFT JOIN RM20201 AP ON RM.CustNmbr = AP.CustNmbr AND RM.DocNumbr = AP.ApToDcNm AND RM.RmdTypal = AP.ApToDcTy
WHERE	RM.RmdTypal IN (1,2,3) AND
		RM.DocNumbr LIKE 'DM%'

