EXECUTE USP_QueryFIDepot N'SELECT ACCT_NO, ACCT_NAME, PHONE_NO, FAX_nO, INVEMAIL1 FROM ACCOUNTS WHERE DEPOT_LOC = ''FIROAD'' ORDER BY ACCT_NO', '##tmpCustomers'

SELECT	RTRIM(Acct_No) AS Acct_No,
		RTRIM(Acct_Name) AS Name,
		REPLACE(Phone_No, '-', '') AS Phone,
		REPLACE(Fax_No, '-', '') AS Fax,
		LOWER(RTRIM(CASE WHEN dbo.AT(',', InvEmail1, 1) > 0 THEN LEFT(InvEmail1, dbo.AT(',', InvEmail1, 1) - 1) ELSE InvEmail1 END)) AS Email
INTO	#tmpCustNew
FROM	##tmpCustomers

UPDATE	Customers
SET		Customers.Name	= DATA.Name,
		Customers.Phone	= CASE WHEN DATA.Phone = '' THEN Null ELSE DATA.Phone END,
		Customers.Email	= CASE WHEN DATA.Email = '' THEN Null ELSE DATA.Email END
FROM	(
		SELECT * FROM #tmpCustNew
		) DATA
WHERE	Customers.AcctNo = DATA.Acct_No

INSERT INTO Customers (AcctNo, Name, Phone, Email)
SELECT	Acct_No,
		Name,
		CASE WHEN Phone = '' THEN Null ELSE Phone END,
		CASE WHEN Email = '' THEN Null ELSE Email END
FROM	#tmpCustNew
WHERE	Acct_No NOT IN (SELECT AcctNo FROM Customers)

DROP TABLE #tmpCustNew
DROP TABLE ##tmpCustomers