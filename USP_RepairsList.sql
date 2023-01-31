ALTER PROCEDURE USP_RepairsList (@ForSubmitting Bit = 0)
AS
SELECT	RepairId
		,Consecutive
		,RepairDate
		,EquipmentLocation
		,SubLocation
		,Equipment
		,EquipmentType
FROM	Repairs
WHERE	ForSubmitting = @ForSubmitting
ORDER BY Consecutive