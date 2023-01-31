USE GPCustom
GO
/*
EXECUTE USP_AP_RemoveHold_Process
*/
ALTER PROCEDURE USP_AP_RemoveHold_Process
AS
-- Cycle all HOLD companies to remove the HOLD on those transactions now with documents in FileBound
SET NOCOUNT ON

DECLARE	@Company	Varchar(5)

DECLARE curAPHolds CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT [CompanyId] FROM GPCustom.dbo.Companies_Parameters WHERE ParameterCode = 'FSI_AP_Hold' AND ParBit = 1 AND Inactive = 0 ORDER BY 1

OPEN curAPHolds 
FETCH FROM curAPHolds INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE dbo.USP_AP_RemoveHold @Company

	FETCH FROM curAPHolds INTO @Company
END

CLOSE curAPHolds
DEALLOCATE curAPHolds
