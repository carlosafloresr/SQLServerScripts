--SELECT	*
--FROM	Repairs

UPDATE	Repairs
SET		Status = 0
WHERE	InvoiceNumber IS NULL
		AND Status > 1
		AND ReceivedOn > '10/03/2013'

SELECT	*
FROM	Repairs
WHERE	Equipment IN ('XNOZ720077','TNPZ522685','ECMU460668','TNPZ120641')