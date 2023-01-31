SELECT     MSR_IntercompanyId, BatchId, DocNumber, InvoiceNumber, Customer, InvoiceTotal, Chassis, Container, CO_MAR, CO_REP, CO_RPL, OO_MAR, OO_REP, OO_RPL, 
                      Account1, Account2, Account3, Amount1, Amount2, Amount3, Description1, Description2, Description3, PostingDate, ProNumber, Processed
FROM         MSR_Intercompany
WHERE     (Account1 = '1-08-6603') OR
                      (Account2 = '1-08-6603') OR
                      (Account3 = '1-08-6603')