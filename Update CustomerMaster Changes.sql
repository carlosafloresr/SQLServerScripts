-- UPDATE CustomerMaster SET Changed = 1, Trasmitted = 0 WHERE CompanyId = 'NDS' AND SalsTerr = '12'
-- UPDATE NDS.dbo.RM00101 SET SalsTerr = 11 WHERE RTRIM(SalsTerr) = ''
SELECT CustNmbr, SalsTerr FROM NDS.dbo.RM00101