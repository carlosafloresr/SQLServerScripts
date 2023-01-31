SELECT	TT.Name,
		CASE TS.StateType
			WHEN 3 THEN 'Processing'
			WHEN 5 THEN 'Complete'
			WHEN 7 THEN 'Error'
		END AS StateType,
		TS.Progress,
		TR.ID AS TrigerID,
		TR.IsEnabled,
		TR.Interval,
		CASE TR.UnitOfMeasure
			WHEN 2 THEN 'Minutes'
			ELSE 'Seconds'
		END AS IntervalType
FROM	Scheduling.Task TT
		INNER JOIN Scheduling.TaskState TS ON TT.Id = TS.TaskId
		JOIN Scheduling.[Trigger] TR ON TR.Id = TT.TriggerId
WHERE	IsEnabled <> 0
		AND TT.TypeId = '55D3F71A-2618-4EAE-9AA6-D48767B974D8'
		