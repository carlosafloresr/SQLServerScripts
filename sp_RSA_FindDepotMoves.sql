/*
EXECUTE sp_RSA_FindDepotMoves 'TLXZ431203'
*/
ALTER PROCEDURE sp_RSA_FindDepotMoves (@Equipment Varchar(12))
AS
DECLARE	@Query		Varchar(2000),
		@DateLimit	Varchar(10) = CAST(DATEADD(dd, -180, CAST(GETDATE() AS Date)) AS Varchar)

SET @Query = N'
SELECT	EIR.Code,
	STA.DMStatus_Code,
	EIR.EDate,
	EIR.ETime,
	STA.ULogin,
	STA.Seq,
	EIR.DMEqMast_Code_Chassis,
	EIR.DMBillTo_Code_Chassis,
	EIR.DMEqType_Code_Chassis,
	EIR.DMEqMast_Code_Container,
	EIR.DMBillTo_Code_Container,
	EIR.DMEqType_Code_Container,
	EIR.DMSite_Code,
	EIR.Trucker_Code,
	EIR.Driver_code,
	EIR.Truck_Code,
	EIR.Pro
FROM	Public.DMEqMast EQU
	INNER JOIN Public.DMEqStatus STA ON EQU.Code = STA.DMEqMast_Code
	INNER JOIN Public.EIR EIR ON STA.RefCode = EIR.Code
WHERE	EQU.Code = ''' + @Equipment + ''' AND EIR.EDate >= ''' + @DateLimit + '''
ORDER BY STA.Seq DESC, EIR.EDate DESC'

EXECUTE USP_QuerySWS @Query, '##tmpMoves'

SELECT	Code,
		DMStatus_Code,
		CAST(CAST(EDate AS Varchar) + ' ' + CAST(ETime AS Varchar) AS Datetime) AS EIR_Date,
		REPLACE(REPLACE(REPLACE(ULogin, '-EIR ', ''), '+EIR ', ''), ':', '') AS EIRInfo,
		Seq AS Sequence,
		DMSite_Code AS Depot,
		DMEqMast_Code_Chassis,
		DMEqType_Code_Chassis,
		DMBillTo_Code_Chassis,
		DMEqMast_Code_Container,
		DMEqType_Code_Container,
		DMBillTo_Code_Container,
		Trucker_Code,
		Driver_code,
		Truck_Code,
		Pro AS ProNumber
FROM	##tmpMoves
ORDER BY Seq DESC, CAST(CAST(EDate AS Varchar) + ' ' + CAST(ETime AS Varchar) AS Datetime) DESC

DROP TABLE ##tmpMoves