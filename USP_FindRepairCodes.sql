/*
EXECUTE USP_FindRepairCodes 'TIRES'
*/
ALTER PROCEDURE USP_FindRepairCodes (@Category Varchar(40) = NULL)
AS
IF @Category = '' OR @Category IS NULL
BEGIN
	SELECT	RepairCode
			,RTRIM(Description) + '  [' + RTRIM(RepairCode) + ']' AS Description
	FROM	RepairCodes 
	WHERE	Category IS Null
	ORDER BY Description
END
ELSE
BEGIN
	SELECT	RepairCode
			,RTRIM(Description) + '  [' + RTRIM(RepairCode) + ']' AS Description
	FROM	RepairCodes 
	WHERE	Category = @Category 
	ORDER BY Description
END