/*
EXECUTE USP_Find_Repair_SWSData 'MAEC517291', '03/02/2020'
*/
ALTER PROCEDURE USP_Find_Repair_SWSData
	@EquipmentId	Varchar(15),
	@EstimateDate	Date
AS
SET NOCOUNT ON

DECLARE	@Query		Varchar(MAX),
		@Status		Char(1) = 'E'

SET @Query = 'SELECT EQM.Cmpy_No AS CompanyNum, 
				EQM.OrCode AS ProNumber, 
				EQM.DropDT AS DropDate, 
				MOV.Dr_Code AS DriverId, 
				DRV.Div_Code AS Division
			FROM TRK.EqMast EQM 
				INNER JOIN TRK.Move MOV ON EQM.Cmpy_No = MOV.Cmpy_No AND EQM.Or_No = MOV.Or_No
				LEFT JOIN TRK.Driver DRV ON EQM.Cmpy_No = DRV.Cmpy_No AND MOV.Dr_Code = DRV.Code
			WHERE EQM.Code = ''' + RTRIM(@EquipmentId) + ''' 
				AND EQM.DropDT <= ''' + CONVERT(Char(10), @EstimateDate, 101) + ''' 
				AND MOV.Status = ''' + @Status + ''' 
			ORDER BY DropDT DESC LIMIT 1'

EXECUTE USP_QuerySWS @Query, '##tmpSWSData1'

SELECT	@EquipmentId AS EquipmentId
		,@EstimateDate AS EstimateDate
		,*
FROM	##tmpSWSData1

DROP TABLE ##tmpSWSData1