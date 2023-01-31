UPDATE	CustomerMaster
SET		Changed = 1
WHERE	CustNmbr IN (
						SELECT	CustNmbr 
						FROM	View_CustomerMaster 
						WHERE	CustClas <> 'SUMMARY' 
								AND CompanyId = 'PTS'
								AND LEN(RTRIM(CustNmbr)) < 7
								--AND PymTrmDays NOT IN (0,30)
								AND SWSCustomers = 1
								AND Inactive = 0
								AND CustNmbr <> '' 
								AND CustNmbr <> '789*2'
						)

SELECT TOP 100 * FROM View_CustomerMaster WHERE CustClas <> 'SUMMARY' AND Changed = 1 AND SWSCustomers = 1 AND CustNmbr <> '' AND LEN(RTRIM(CustNmbr)) < 7 ORDER BY CompanyId, CustNmbr

update	CustomerMaster
set		Changed = 0
where	CustNmbr = '789*2'