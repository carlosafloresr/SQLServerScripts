SELECT	*
FROM	Repairs
WHERE	WorkOrder = 'HH021-02066'
-- Equipment = 'EMCZ161014'

SELECT	*
FROM	RepairsPictures
WHERE	Fk_RepairId = 102548

SELECT	*
FROM	View_RepairsDetails
WHERE	RepairId = 102548

/*
UPDATE	Repairs
SET		Status = 17,
		InvoiceNumber = -99
WHERE	WorkOrder = 'HH021-02167'

UPDATE	Repairs
SET		Status = 1,
		InvoiceNumber = '1151477'
WHERE	WorkOrder = 'HH088-00233'
*/