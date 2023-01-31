CREATE VIEW View_1099Transactions
AS
SELECT	VchrNmbr
		,VendorId
		,DocDate
		,PostEdDt
		,DocNumbr
		,DocAmnt
		,Un1099Am
		,TrxDscrn
		,Dex_Row_id
		,'PM20000' AS SrcTable
FROM	PM20000
UNION
SELECT	VchrNmbr
		,VendorId
		,DocDate
		,PostEdDt
		,DocNumbr
		,DocAmnt
		,Un1099Am
		,TrxDscrn
		,Dex_Row_id
		,'PM30200' AS SrcTable
FROM	PM30200
WHERE	VoidPDate > '1/1/2000'
		AND BchSourc = 'PM_Trxent'

-- SELECT * FROM AIS.dbo.View_1099Transactions WHERE LEFT(VchrNmbr,17) = 'FSI09010613530001'