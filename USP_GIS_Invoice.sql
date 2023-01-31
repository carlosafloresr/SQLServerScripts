/*
EXECUTE USP_GIS_Invoice '520'
*/
ALTER PROCEDURE USP_GIS_Invoice
		@Invoice	Varchar(15)
AS
SELECT	INV.acct_no,
		INV.inv_date,
		INV.rep_date,
		INV.inv_total,
		INV.labor,
		INV.labor_hour,
		SAL.Tires,
		SAL.NonTires,
		INV.parts,
		INV.sale_tax,
		INV.chassis,
		INV.container,
		INV.genset_no
FROM	GIS_Invoices INV
		INNER JOIN (
				SELECT	inv_no,
						SUM(IIF(IsTire = 1, part_total, 0)) AS Tires,
						SUM(IIF(IsTire = 0, part_total, 0)) AS NonTires
				FROM	(
						SELECT	SAL.inv_no,
								SAL.part_no,
								SAL.descript,
								SAL.unit_price,
								SAL.part_total,
								IIF(TIR.part_no IS Null, 0, 1) AS IsTire
						FROM	GIS_Sale SAL
								LEFT JOIN GIS_Tires TIR ON SAL.part_no = TIR.part_no
						WHERE	SAL.INV_NO = @Invoice
						) DATA
				GROUP BY inv_no
		) SAL ON INV.inv_no = SAL.inv_no
WHERE	INV.Invoice_alpha = @Invoice

-- 406