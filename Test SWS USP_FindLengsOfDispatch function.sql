/*
EXECUTE USP_PullMoveInformation 'CAXU497025'
*/
ALTER PROCEDURE USP_PullMoveInformation (@Equipment Varchar(15))
AS
DECLARE	@DateMin	Datetime,
		@DateMax	Datetime,
		@Query		Varchar(200)

SET	@Query = 'select * from USP_FindLengsOfDispatch(''' + @Equipment + ''');'

EXECUTE USP_QuerySWS @Query, '##TempMoves'

SELECT	Company,
		BillTo,
		MoveType,
		Division,
		DateOfInterchange,
		CAST(CONVERT(Char(10), RecDate, 101) + ' ' + CAST(DATEPART(hh, RecTime) AS Varchar(2)) + ':' + CAST(DATEPART(mi, RecTime) AS Varchar(2)) AS Datetime) AS MoveDateTime,
		CASE WHEN MoveType LIKE 'I' THEN ConsLPCode ELSE ShipLPCode END AS LPCode,
		ProNumber,
		PrincipalCode,
		EquipmentSizeType,
		CAST(CASE WHEN IsReefer = 'Y' THEN 1 ELSE 0 END AS Bit) AS IsReefer
INTO	#TempData
FROM	##TempMoves
WHERE	NRP LIKE 'Y'

SET @DateMin = (SELECT MIN(MoveDateTime) FROM #TempData)
SET @DateMax = (SELECT MAX(MoveDateTime) FROM #TempData)

SELECT	TOP 1 Company,
		BillTo,
		MoveType,
		Division,
		DateOfInterchange,
		@DateMin AS StartMoveDate,
		@DateMax AS EndMoveDate,
		DATEDIFF(dd, @DateMin, @DateMax) AS MoveDays,
		LPCode,
		ProNumber,
		PrincipalCode,
		EquipmentSizeType,
		IsReefer
FROM	#TempData

DROP TABLE #TempData
DROP TABLE ##TempMoves