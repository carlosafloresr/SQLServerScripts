EXECUTE ILSSQL01.Intranet.dbo.USP_Query_RCMRDepot 'SELECT * FROM Invoices WHERE Inv_No = 462898', '@curInvoice'

SELECT * FROM @curInvoice

DROP TABLE @curInvoice