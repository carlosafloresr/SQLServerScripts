DECLARE	@TicketId	Int

DECLARE Tickets CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	T.Id
FROM	Tickets T
		LEFT JOIN DriverInfo D ON T.IdVendorInfo = D.Id
WHERE	D.OriginTitle IS NULL
		AND T.IdVendorInfo > 0

OPEN Tickets 
FETCH FROM Tickets INTO @TicketId

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE sp_RSA_FindOriginAndDestination @TicketId

	FETCH FROM Tickets INTO @TicketId
END

CLOSE Tickets
DEALLOCATE Tickets