-- select * from SY03300
--select distinct pymtrmid from pm00200 order by pymtrmid

-- SELECT * FROM EscrowAccounts
-- select * from imct.dbo.GL00105

insert into EscrowAccounts
	   (CompanyID,
		Fk_EscrowModuleId,
		AccountIndex,
		AccountNumber)
SELECT	'FIDMO',
		Fk_EscrowModuleId,
		AccountIndex,
		AccountNumber 
FROM	EscrowAccounts
WHERE	CompanyID = 'FI'

UPDATE	EscrowAccounts
SET		AccountIndex = ActIndx
FROM	(SELECT	AccountNumber,
				ActIndx,
				CompanyID
		FROM	EscrowAccounts EA
				INNER JOIN AIS.dbo.GL00105 GL ON EA.AccountNumber = GL.ActNumSt
		WHERE	CompanyID = 'AIS') OT
WHERE	EscrowAccounts.CompanyID = OT.CompanyID AND
		EscrowAccounts.AccountNumber = OT.AccountNumber