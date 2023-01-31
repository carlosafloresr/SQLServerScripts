/*
EXECUTE USP_FindSubmitedToGP 147
*/
CREATE PROCEDURE USP_FindSubmitedToGP
		@ProjectId Int
AS
SELECT	TOP (1000) *
FROM	[FB].[dbo].[View_DEXDocuments]
WHERE	ProjectID = @ProjectId
		AND RouteStepID IN (SELECT RouteStepID FROM View_Project_SendToGP WHERE ProjectID = @ProjectId)
		AND DateStarted > DATEADD(dd, -5, GETDATE())
ORDER BY DateStarted

/*
--SELECT	TOP 100 *
--FROM	DocumentRoute
--WHERE	DocumentID = 2601405

SELECT	*
FROM	ExtendedProperties
WHERE	ObjectID = 2056919
*/