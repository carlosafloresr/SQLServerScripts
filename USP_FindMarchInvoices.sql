/*
SELECT * FROM MarchSales
EXECUTE USP_FindMarchInvoices
*/
ALTER PROCEDURE USP_FindMarchInvoices
AS
SELECT	RECS.*,
		Parts - PartsTotal AS Difference
FROM	(
		SELECT	INV.inv_no
				,INV.acct_no
				,INV.inv_total
				,INV.sale_tax
				,INV.Parts
				,PartsTotal = (SELECT SUM(part_total) FROM Sale WHERE Sale.Inv_No = INV.Inv_No)
		FROM	Invoices INV
		WHERE	INV.Inv_No IN (SELECT inv_no FROM ReceivedSales)
		) RECS
WHERE	Parts <> PartsTotal

/*
select * FROM Invoices where inv_no = 806292
select * FROM Sale where inv_no = 806292
*/