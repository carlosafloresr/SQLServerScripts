/*
EXECUTE USP_PullMoveInformationByProNumber '08-300289'
*/
ALTER PROCEDURE USP_PullMoveInformationByProNumber (@ProNumber Varchar(15))
AS
DECLARE	@DateMin	Datetime,
		@DateMax	Datetime,
		@Query		Varchar(200),
		@Division	Varchar(3),
		@Pro		Varchar(10)

SET		@Division	= LEFT(@ProNumber, PATINDEX('%-%', @ProNumber) - 1)
SET		@Pro		= RTRIM(REPLACE(@ProNumber, @Division + '-', ''))
SET		@Query		= 'SELECT * FROM USP_FindLengsOfDispatchByProNumber(''' + @Division + ''',''' + @Pro + ''');'
PRINT @Query
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
		CAST(CASE WHEN IsReefer = 'Y' THEN 1 ELSE 0 END AS Bit) AS IsReefer,
		EquipmentId
INTO	#TempData
FROM	##TempMoves
WHERE	NRP LIKE 'Y'

SET @DateMin = (SELECT MIN(MoveDateTime) FROM #TempData)
SET @DateMax = (SELECT MAX(MoveDateTime) FROM #TempData)

INSERT INTO PerDiemTestRecords
		(Company
		,BillTo
		,MoveType
		,Division
		,DateOfInterchange
		,StartMoveDate
		,EndMoveDate
		,MoveDays
		,LPCode
		,ProNumber
		,PrincipalCode
		,EquipmentSizeType
		,IsReefer
		,EquipmentId)
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
		IsReefer,
		EquipmentId
FROM	#TempData

DROP TABLE #TempData
DROP TABLE ##TempMoves