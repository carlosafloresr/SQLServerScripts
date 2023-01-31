-- USP_SearchOnAllTables 'IMCG DEX'

--SELECT * FROM AaaUser WHERE FIRST_NAME = 'Carlos A. Flores'
--SELECT * FROM Arc_WorkOrder WHERE AUDITGROUPID = 7992
--SELECT * FROM RequestRI WHERE ITEMID = 7992
--SELECT * FROM WorkOrderStates WHERE OWNERID = 715

SELECT	WO.WorkOrderId,
		WO.Title,
		wo.*,
		ST.StatusId
FROM	WorkOrder WO
		INNER JOIN WorkOrderStates ST ON WO.WorkOrderId = ST.WorkOrderId
WHERE	ST.OWNERID = 715
		AND ST.StatusId = 1
		--AND WO.RequestId = 11447
ORDER BY WO.WorkOrderId

update WorkOrderStates
set StatusId = 4
where	WorkOrderId in (7384,
7722,
7982,
7992,
9171,
9691,
9696,
9969,
10023,
10040,
10088,
10108,
10137,
10172,
10178,
10194,
10196,
10200,
10216,
10246,
10272,
10308,
10322,
10331)