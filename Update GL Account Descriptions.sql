-- SELECT Account, Description FROM GPCustom.dbo.IMCG_Accounts
-- UPDATE IMCG_Accounts SET Account = LEFT(Account, 1) + '-' + SUBSTRING(Account, 2, 2) + '-' + SUBSTRING(Account, 4, 4)
-- SELECT * FROM GL00100

UPDATE	GL00100
SET		ActDescr = LEFT(GL.Description, 50)
		--,Active = CASE WHEN GL.Inactive = 1 THEN 0 ELSE 1 END
FROM	(
SELECT	ActIndx
		,AccountNumber
		,Description
		--,Inactive
FROM	GPCustom.dbo.IMC_Accounts
		LEFT JOIN GL00105 GL ON AccountNumber = ActNumSt
WHERE	AccountNumber IS NOT NULL ) GL
WHERE	GL00100.ActIndx = GL.ActIndx

-- SELECT * FROM GL00100 WHERE ACTINDX = 2553

/*
SELECT * FROM GL00105 WHERE ACTNUMST = '1-02-6050'
*/