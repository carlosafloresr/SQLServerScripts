/*
EXECUTE USP_CollectionManagers
*/
CREATE PROCEDURE [dbo].[USP_CollectionManagers]
AS
UPDATE	RM00101 
SET		UserDef1 = CN.UserName
FROM   (SELECT	CustNmbr, 
				UserName 
		FROM	CN00500 CN
				INNER JOIN Dynamics.dbo.SY01400 SY ON CN.CrdtMgr = SY.UserId) CN
WHERE	RM00101.CustNmbr = CN.CustNmbr