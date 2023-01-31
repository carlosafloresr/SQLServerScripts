UPDATE	Repairs
SET		BIDStatus		= DAT.BIDStatus,
		PrivateRemarks	= DAT.PrivateRemarks
FROM	FI_Data_OLD.dbo.Repairs DAT
WHERE	Repairs.RepairId = DAT.RepairId

SELECT	*
FROM	FI_Data.dbo.Repairs

SELECT	*
FROM	FI_Data_OLD.dbo.Repairs