/*
EXECUTE USP_FindDamageCodes 'TIRES'
*/
ALTER PROCEDURE USP_FindDamageCodes (@Category Varchar(40) = NULL)
AS
IF @Category = '' OR @Category IS NULL
BEGIN
	SELECT	DamageCode
			,RTRIM(Description) + '  [' + RTRIM(DamageCode) + ']' AS Description
	FROM	DamageCodes 
	WHERE	Category IS Null
	ORDER BY Description
END
ELSE
BEGIN
	SELECT	DamageCode
			,RTRIM(Description) + '  [' + RTRIM(DamageCode) + ']' AS Description
	FROM	DamageCodes 
	WHERE	Category = @Category 
	ORDER BY Description
END