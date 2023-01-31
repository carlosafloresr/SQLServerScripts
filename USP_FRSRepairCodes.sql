/*
EXECUTE USP_FRSRepairCodes 'T', 'JC'
EXECUTE USP_FRSRepairCodes 'T', 'DC', 'FRS11'
EXECUTE USP_FRSRepairCodes 'T', 'RC', 'FRS11'

EXECUTE USP_FRSRepairCodes 'M', 'CA'
EXECUTE USP_FRSRepairCodes 'M', 'JC', 'BRAKES'
EXECUTE USP_FRSRepairCodes 'M', 'DC', 'BULB'
EXECUTE USP_FRSRepairCodes 'M', 'RC', 'LIGHTS', 'BULB'
EXECUTE USP_FRSRepairCodes 'M', 'DC', 'BRAKES', '1ABSPC'
EXECUTE USP_FRSRepairCodes 'M', 'RC', 'BRAKES', '1ABSPC' 
*/
ALTER PROCEDURE dbo.[USP_FRSRepairCodes]
		@PartType	Char(1),
		@CodeType	Char(2),
		@Category	Varchar(25) = NULL,
		@Code		Varchar(15) = NULL
AS
IF @CodeType = 'JC'
BEGIN
	IF @PartType = 'T'
	BEGIN
		SELECT	DISTINCT JOBC.JobCode AS Code,
				LTRIM(RTRIM(dbo.PROPER(JOBC.Description))) + ' [' + RTRIM(JOBC.JobCode) + ']' AS Description
		FROM	CodeRelations CODR
				INNER JOIN JobCodes JOBC ON CODR.ChildCode = JOBC.JobCode
				INNER JOIN CodeRelations CRRC ON CODR.Location = CRRC.Location AND CRRC.RelationType = 'RC' AND CODR.ChildCode = CRRC.ParentCode
		WHERE	CODR.Location = 'FIROAD'
				AND CODR.DeletedOn IS NULL
				AND CODR.RelationType = 'JC'
				AND CODR.Category = 'TIRES'
				AND CODR.Subcategory = 'REPLACE'
		ORDER BY 2
	END
	ELSE
	BEGIN
		SELECT	DISTINCT JOBC.JobCode AS Code,
				LTRIM(RTRIM(dbo.PROPER(JOBC.Description))) + ' [' + RTRIM(JOBC.JobCode) + ']' AS Description
				--RTRIM(CODR.Category) + ' - ' + RTRIM(dbo.PROPER(JOBC.Description)) + ' [' + RTRIM(JOBC.JobCode) + ']' AS Description
		FROM	CodeRelations CODR
				INNER JOIN JobCodes JOBC ON CODR.ChildCode = JOBC.JobCode
				INNER JOIN CodeRelations CRRC ON CODR.Location = CRRC.Location AND CODR.Category = CRRC.Category AND CODR.SubCategory = CRRC.SubCategory AND CRRC.RelationType = 'RC' AND CODR.ChildCode = CRRC.ParentCode
		WHERE	CODR.Location = 'FIROAD'
				AND CODR.RelationType = 'JC'
				AND CODR.Category = @Category
				AND CODR.DeletedOn IS NULL
		ORDER BY 2
	END
END

IF @CodeType = 'CA'
BEGIN
	IF @PartType = 'M'
	BEGIN
		SELECT	CODR.ChildCode AS Code,
				CODR.ChildCode AS Description
		FROM	CodeRelations CODR
		WHERE	CODR.Location = 'FIROAD'
				AND CODR.RelationType = 'CA'
				AND CODR.ChildCode <> 'TIRES'
				AND CODR.DeletedOn IS NULL
		ORDER BY 2
	END
END

IF @CodeType = 'DC'
BEGIN
	IF @PartType = 'T'
	BEGIN
		SELECT	DAMC.DamageCode AS Code,
				RTRIM(dbo.PROPER(DAMC.Description)) + ' [' + RTRIM(DAMC.DamageCode) + ']' AS Description
		FROM	CodeRelations CODR
				INNER JOIN CodeRelations CRDC ON CODR.Location = CRDC.Location AND CODR.Category = CRDC.Category AND CODR.SubCategory = CRDC.SubCategory AND CRDC.RelationType = 'DC' AND CODR.ChildCode = CRDC.ParentCode
				INNER JOIN DamageCodes DAMC ON CRDC.ChildCode = DAMC.DamageCode
		WHERE	CODR.Location = 'FIROAD'
				AND CODR.RelationType = 'RC'
				AND CODR.Category = 'TIRES'
				AND CODR.Subcategory = 'REPLACE'
				AND CODR.ParentCode = @Code
				AND CODR.DeletedOn IS NULL
		ORDER BY 2
	END
	ELSE
	BEGIN
		SELECT	DISTINCT DAMC.DamageCode AS Code,
				RTRIM(dbo.PROPER(DAMC.Description)) + ' [' + RTRIM(DAMC.DamageCode) + ']' AS Description
		FROM	CodeRelations CODR
				INNER JOIN CodeRelations CRDC ON CODR.Location = CRDC.Location AND CODR.Category = CRDC.Category AND CODR.SubCategory = CRDC.SubCategory AND CRDC.RelationType = 'DC' AND CODR.ChildCode = CRDC.ParentCode
				INNER JOIN DamageCodes DAMC ON CRDC.ChildCode = DAMC.DamageCode
		WHERE	CODR.Location = 'FIROAD'
				AND CODR.RelationType = 'RC'
				AND CODR.Category = @Category
				AND CODR.ParentCode = @Code
				AND CODR.DeletedOn IS NULL
		ORDER BY 2
	END
END

IF @CodeType = 'RC'
BEGIN
	IF @PartType = 'T'
	BEGIN
		SELECT	REPC.RepairCode AS Code,
				RTRIM(dbo.PROPER(REPC.Description)) + ' [' + RTRIM(REPC.RepairCode) + ']' AS Description
		FROM	CodeRelations CODR
				INNER JOIN RepairCodes REPC ON CODR.ChildCode = REPC.RepairCode
		WHERE	CODR.Location = 'FIROAD'
				AND CODR.RelationType = @CodeType
				AND CODR.Category = 'TIRES'
				AND CODR.Subcategory = 'REPLACE'
				AND CODR.ParentCode = @Code
				AND CODR.DeletedOn IS NULL
		ORDER BY 2
	END
	ELSE
	BEGIN
		SELECT	REPC.RepairCode AS Code,
				RTRIM(dbo.PROPER(REPC.Description)) + ' [' + RTRIM(REPC.RepairCode) + ']' AS Description
		FROM	CodeRelations CODR
				INNER JOIN RepairCodes REPC ON CODR.ChildCode = REPC.RepairCode
		WHERE	CODR.Location = 'FIROAD'
				AND CODR.RelationType = 'RC'
				AND CODR.Category = @Category
				AND CODR.ParentCode = @Code
				AND CODR.DeletedOn IS NULL
		ORDER BY 2
	END
END

/*
SELECT	*
FROM	CodeRelations
WHERE	Location = 'FIROAD'
		AND DeletedOn IS NULL
		AND RelationType = 'CA'
		AND ParentCode = '1ABSPC'
		AND Category = 'TIRES'
		AND Subcategory = 'REPLACE'
*/