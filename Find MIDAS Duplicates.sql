select	Tablet, EquipmentLocation, Equipment, Mechanic, ISNULL(RepairRemarks, 'NONE') AS RepairRemarks, count(tablet) AS Counter
INTO	#tmpDuplicates
from	repairs
where	receivedon > '05/11/2015'
GROUP BY Tablet, EquipmentLocation, Equipment, Mechanic, ISNULL(RepairRemarks, 'NONE')
HAVING count(tablet) > 1
ORDER BY Tablet, EquipmentLocation, Equipment, Mechanic

SELECT	DAT.RepairId, REP.RepairId, REP.InvoiceNumber
FROM	Repairs REP,
		(
		SELECT	Tablet, EquipmentLocation, Equipment, Mechanic, RepairRemarks2, MIN(RepairId) AS RepairId
		FROM	(
				SELECT	REP.*,
						DUP.RepairRemarks AS RepairRemarks2
				FROM	Repairs REP
						INNER JOIN #tmpDuplicates DUP ON REP.Tablet = DUP.Tablet AND REP.EquipmentLocation = DUP.EquipmentLocation AND REp.Equipment = DUP.Equipment AND REP.Mechanic = DUP.Mechanic AND ISNULL(REP.RepairRemarks, 'NONE') = DUP.RepairRemarks
				WHERE	REP.ReceivedOn > '05/11/2015'
				) DATA
		GROUP BY Tablet, EquipmentLocation, Equipment, Mechanic, RepairRemarks2
		) DAT
WHERE	REP.ReceivedOn > '05/11/2015'
		AND REP.Tablet = DAT.Tablet 
		AND REP.EquipmentLocation = DAT.EquipmentLocation 
		AND REP.Equipment = DAT.Equipment 
		AND REP.Mechanic = DAT.Mechanic 
		AND ISNULL(REP.RepairRemarks, 'NONE') = DAT.RepairRemarks2
		AND REP.RepairId > DAT.RepairId

DROP TABLE #tmpDuplicates