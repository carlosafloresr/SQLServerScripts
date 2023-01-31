/*
EXECUTE USP_KarmakApprovalPriority 2,'JKING',1
*/
ALTER PROCEDURE USP_KarmakApprovalPriority
		@Level		Int,
		@UserId		Varchar(25),
		@MoveUp		Int
AS
DECLARE	@Priority1	Int,
		@Priority2	Int
		
SET		@Priority1	= (SELECT Priority FROM KarmakApprovals WHERE ApprovalLevel = @Level AND UserId = @UserId)
IF @MoveUp = 1
	SET	@Priority2	= (SELECT TOP 1 Priority FROM KarmakApprovals WHERE ApprovalLevel = @Level AND Priority < @Priority1)
ELSE
	SET	@Priority2	= (SELECT TOP 1 Priority FROM KarmakApprovals WHERE ApprovalLevel = @Level AND Priority > @Priority1)

SELECT	* 
FROM	KarmakApprovals 
WHERE	ApprovalLevel = @Level