SELECT	*
FROM	Mech
WHERE	mech_no in (
SELECT	DISTINCT Mechanic
FROM	Repairs
WHERE	ReceivedOn > '09/01/2016'
		AND EquipmentLocation = 'KANSAS')

UPDATE	Mech
SET		Password = '4*&*&%1',
		TimeStamp = GETDATE()
WHERE	mech_no in (
SELECT	DISTINCT Mechanic
FROM	Repairs
WHERE	ReceivedOn > '01/01/2016'
		AND EquipmentLocation = 'KANSAS')

SELECT	Mechanic, MAX(ReceivedOn)
FROM	Repairs
WHERE	ReceivedOn > '01/01/2016'
		AND EquipmentLocation = 'KANSAS'
GROUP BY Mechanic