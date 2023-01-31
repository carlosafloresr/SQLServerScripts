SELECT	*
FROM	DocumentRoute
WHERE	DocumentRouteId in (2119909,623139,623157)

UPDATE	DocumentRoute
SET		Finished = 1,
		Status = 1,
		Completed = GETDATE()
WHERE	DocumentRouteId IN (
		SELECT	DocumentRouteId
		FROM	View_DEXDocuments
		WHERE	ProjectID = 67
				AND RouteStepID = 917
				AND Finished = 1
				AND Completed = '01/01/1990'
				AND RoutedStatus = 1
)

/*
SELECT	*
FROM	View_DEXDocuments
WHERE	ProjectID = 63
		AND FileID = 1581806
		AND DocumentID = 2009417
		--AND RouteStepID = 917
		AND Finished = 1
		AND Completed = '01/01/1990'
		AND RoutedStatus = 1
*/