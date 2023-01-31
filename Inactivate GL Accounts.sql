
/*
SELECT * FROM GL00100
select * from GPCustom.dbo.rcmr_accounts
SELECT * FROM GL00105 WHERE ActNumSt IN (SELECT Account FROM GPCustom..Accounts)
update GPCustom.dbo.Accounts set Account = LTRIM(RTRIM(Account))
*/

UPDATE	GL00100
SET		GL00100.Active = 0
FROM	(
SELECT	ActIndx,
		ActNumSt
FROM	GL00105
		INNER JOIN GPCustom.dbo.FI_Accoumts ON ActNumSt = AccountNumber) ACT
WHERE	GL00100.ActIndx = ACT.ActIndx