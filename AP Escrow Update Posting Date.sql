UPDATE EscrowTransactions SET PostingDate = T1.PstgDate FROM (SELECT P1.* FROM EscrowTransactions LEFT JOIN AIS.dbo.PM10000 P1 ON 
EscrowTransactions.VoucherNumber = P1.Vchrnmbr WHERE CompanyID = 'AIS' AND P1.Vchrnmbr IS NOT Null) T1 WHERE VoucherNumber = T1.Vchrnmbr AND PostingDate IS NULL

UPDATE EscrowTransactions SET PostingDate = T1.PstgDate FROM (SELECT P1.* FROM EscrowTransactions LEFT JOIN AIS.dbo.PM20000 P1 ON 
EscrowTransactions.VoucherNumber = P1.Vchrnmbr WHERE CompanyID = 'AIS' AND P1.Vchrnmbr IS NOT Null) T1 WHERE VoucherNumber = T1.Vchrnmbr AND PostingDate IS NULL