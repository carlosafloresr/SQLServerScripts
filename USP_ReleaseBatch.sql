CREATE PROCEDURE USP_ReleaseBatch (@BatchId Varchar(30))
AS
UPDATE	SY00500
SET		Mkdtopst = 0, BRKDNALL = 0, BchSttus = 0, PostToGL = 0, ErrState = 0 
WHERE	BACHNUMB = @BatchId

DELETE	Dynamics.dbo.SY00801 WHERE RSRCID = @BatchId

DELETE	Dynamics.dbo.SY00800 WHERE POSTING = 1 AND BACHNUMB = @BatchId

GO