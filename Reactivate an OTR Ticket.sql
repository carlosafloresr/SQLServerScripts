DECLARE	@TicketNumber	Int = 108833

UPDATE	Tickets 
SET		IdStatus = 3
WHERE	Id = @TicketNumber

UPDATE	VendorInfo 
SET		RepairCompletionDateTime = Null, 
		Status = 'NO' 
WHERE	IdRepairNumber = @TicketNumber

/*
SELECT	*
FROM	GPCustom.dbo.Tickets
WHERE Id IN (108833,108834,108835,108823)

SELECT	*
FROM	VendorInfo
WHERE	IdRepairNumber IN (108833,108834,108835,108823)
*/