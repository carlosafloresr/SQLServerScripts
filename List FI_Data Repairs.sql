SELECT	*
FROM	Repairs
WHERE	WorkOrder = 'HH999-00010'

SELECT	*
FROM	RepairsDetails
WHERE	Fk_RepairId IN (
						SELECT	RepairId
						FROM	Repairs
						WHERE	WorkOrder = 'HH999-00010'
						)

/*
USP_DeleteRepair 2033

HH011-00189
HH011-00188
HH011-00187
HH011-00186
HH011-00185
*/