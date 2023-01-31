-- SELECT Account, Description FROM GPCustom.dbo.IMCG_Accounts
-- UPDATE IMCG_Accounts SET Account = LEFT(Account, 1) + '-' + SUBSTRING(Account, 2, 2) + '-' + SUBSTRING(Account, 4, 4)
-- SELECT * FROM GL00100

UPDATE	GL00100
SET		UsrDefS1 = RTRIM(LEFT(GL.UserDefine, 50))
		--,Active = CASE WHEN GL.Inactive = 1 THEN 0 ELSE 1 END
FROM	(
SELECT	ActIndx
		,AcctNumber
		,UserDefine
FROM	GPCustom.dbo.NDS_Accounts
		LEFT JOIN GL00105 GL ON RTRIM(AcctNumber) = ActNumSt
WHERE	AcctNumber IS NOT NULL ) GL
WHERE	GL00100.ActIndx = GL.ActIndx

-- SELECT * FROM GL00100 WHERE ACTINDX = 2553

/*
SELECT * FROM GL00105 WHERE ACTNUMST = '1-02-6050'

UPDATE	GL00100
SET		UsrDefS1 = RTRIM(UserDef1)
WHERE	UsrDefS1 = ''

UPDATE	nds.dbo.GL00100
SET		nds.dbo.GL00100.UsrDefS1 = RTRIM(recs.UsrDefS1)
from	(select * from nds_restored.dbo.GL00100 where UsrDefS1 <> '') recs
WHERE	nds.dbo.GL00100.UsrDefS1 = '' AND
		nds.dbo.GL00100.ActIndx = recs.ActIndx


UPDATE	GL00100
SET		UserDef1 = ''
*/