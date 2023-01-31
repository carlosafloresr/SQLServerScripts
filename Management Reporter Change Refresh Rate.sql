SELECT	t.id AS TaskID
		, t.name
		, ts.StateType
		, ts.Progress
		, ts.LastRunTime
		, ts.NextRunTime
		, tr.IsEnabled
		, tr.Interval
		, tr.UnitOfMeasure
		, tr.id AS TriggerID
FROM	scheduling.Task t 
		JOIN scheduling.TaskState ts ON t.id = ts.TaskId
		JOIN Scheduling.[trigger] tr ON t.TriggerId = tr.id
WHERE	TypeId = '55D3F71A-2618-4EAE-9AA6-D48767B974D8'
ORDER BY t.Name

/*
UPDATE	scheduling.[trigger] 
SET		Interval = 5 
WHERE	id = '6136EA1C-B914-4B5A-BEAC-EB9355D7BBEA'
*/