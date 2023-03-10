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

/* 
-- LENSASQL001 
SELECT	* 
FROM	Scheduling.[trigger] 
WHERE	id IN ('32923C92-7E3F-41C1-8154-04B64C6CE67A',
			   '67EE9F71-7ADB-4352-BE40-176EFB85D5DD',
			   '3FD79C9A-359B-425E-BD1A-8CEB8D23AE07',
			   'C255A7CD-3F94-48B5-93FB-A066E5032DD0',
			   'BF4ADD4E-FB56-4796-9465-A95095EB7D5D',
			   'A05AAD53-87D4-43AB-B56C-C55383815825',
			   '2461D7B0-26A9-49F3-8DC7-C65F4B487E15',
			   '6F5D8408-E9A4-431B-A5A6-E145D2ABE4C3',
			   '0FC8359C-186E-463F-884B-F65EE7477640')
		AND Interval <> 1

UPDATE	Scheduling.[trigger]
SET		Interval = 180
WHERE	id IN ('32923C92-7E3F-41C1-8154-04B64C6CE67A',
			   '67EE9F71-7ADB-4352-BE40-176EFB85D5DD',
			   '3FD79C9A-359B-425E-BD1A-8CEB8D23AE07',
			   'C255A7CD-3F94-48B5-93FB-A066E5032DD0',
			   'BF4ADD4E-FB56-4796-9465-A95095EB7D5D',
			   'A05AAD53-87D4-43AB-B56C-C55383815825',
			   '2461D7B0-26A9-49F3-8DC7-C65F4B487E15',
			   '6F5D8408-E9A4-431B-A5A6-E145D2ABE4C3',
			   '0FC8359C-186E-463F-884B-F65EE7477640')
		AND Interval <> 1
*/

/*
-- LENSASQL003

SELECT	* 
FROM	Scheduling.[trigger] 
WHERE	id IN ('53A1E515-5BD2-4A0A-8890-2EA344405709',
				'5DC9C154-2927-4E4F-9DC0-30294C8C73A9',
				'6ACC1E47-F734-4839-8AD4-53CC22015F65',
				'F08C754E-0E05-457D-805F-6F6ED9514472',
				'92C0FE28-A0DC-4069-8C5A-7C8DD6BA951E',
				'83F40C7F-B1B9-4801-B25B-85A64B63BE1D',
				'D45E306D-CE82-4773-9150-ACB8B31CBCF5',
				'3CB19CB5-2225-4374-BF2D-CB7B47A75ECF',
				'582E4C8E-4C23-4793-BFAF-D08371575C1D')
		AND Interval <> 1

UPDATE	Scheduling.[trigger]
SET		Interval = 180
WHERE	id IN ('53A1E515-5BD2-4A0A-8890-2EA344405709',
				'5DC9C154-2927-4E4F-9DC0-30294C8C73A9',
				'6ACC1E47-F734-4839-8AD4-53CC22015F65',
				'F08C754E-0E05-457D-805F-6F6ED9514472',
				'92C0FE28-A0DC-4069-8C5A-7C8DD6BA951E',
				'83F40C7F-B1B9-4801-B25B-85A64B63BE1D',
				'D45E306D-CE82-4773-9150-ACB8B31CBCF5',
				'3CB19CB5-2225-4374-BF2D-CB7B47A75ECF',
				'582E4C8E-4C23-4793-BFAF-D08371575C1D')
		AND Interval <> 1
*/