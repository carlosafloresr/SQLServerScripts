SELECT * FROM PRIFBSQL01P.FB.dbo.Files WHERE ProjectID = 160 AND Status = 1 AND Field3 = '2021' --AND Field1 = 'AIS'

SELECT * FROM PRIFBSQL01P.FB.dbo.View_DEXDocuments WHERE ProjectID = 160 AND Status = 1 AND Field3 = '2021'



--SELECT * FROM PRIFBSQL01P.FB.dbo.Documents WHERE FileId IN (SELECT FileId FROM PRIFBSQL01P.FB.dbo.Files WHERE ProjectID = 160 AND Field1 = 'AIS' AND Field3 = '2021')