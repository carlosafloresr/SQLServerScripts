/*
EXECUTE USP_EquipmentTagProgram_GetNewId 'DNJ'
*/
ALTER PROCEDURE USP_EquipmentTagProgram_GetNewId
		@Company		Varchar(5)
AS
DECLARE	@Prefix			Char(3),
		@CompanyNumber	Char(2)

SET @CompanyNumber = ISNULL((SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company), 0)

SET @Prefix = CASE	WHEN @Company = 'AIS'  THEN 'A' 
					WHEN @Company = 'DNJ'  THEN 'D'
					WHEN @Company = 'FI'   THEN 'F'
					WHEN @Company = 'GIS'  THEN 'G'
					WHEN @Company = 'IMC'  THEN 'I' 
					WHEN @Company = 'MCCP' THEN 'M' 
					WHEN @Company = 'NDS'  THEN 'N' 
				ELSE 'O' END + 'M-'

SELECT	@Prefix + dbo.PADL(ISNULL(MAX(CAST(RIGHT(UnitNumber, 4) AS Int) + 1), 1), 4, '0') AS UnitNumber
FROM	EquipmentTags 
WHERE	cmpy_no = @CompanyNumber
		AND LEFT(UnitNumber, 3) = @Prefix