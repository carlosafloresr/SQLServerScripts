-- SELECT * FROM Invoices WHERE Inv_No = '400429'

ALTER PROCEDURE USP_EliminateInvoiceDuplicates
AS
DELETE	Invoices
FROM	(
SELECT	Inv_No
		,MAX(InvoiceiD) AS LastRecord
FROM	Invoices
WHERE	Inv_No IN (	SELECT	Inv_No
					FROM	(SELECT	Inv_No, 
									COUNT(Inv_No) AS Counter 
							FROM	Invoices 
							GROUP BY Inv_No 
							HAVING COUNT(Inv_No) > 1) RECS)
GROUP BY Inv_No) RECS
WHERE	Invoices.Inv_No = Recs.Inv_No
		AND Invoices.InvoiceiD < Recs.LastRecord
GO

ALTER TABLE Invoices ADD InvoiceId Int IDENTITY PRIMARY KEY 

select count(Inv_No) FROM Invoices

execute USP_EliminateInvoiceDuplicates