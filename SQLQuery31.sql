USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_RetrieveRepairsPictures]    Script Date: 8/25/2014 4:03:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_RetrieveRepairsPictures 1, 1
*/
CREATE PROCEDURE [dbo].[USP_RetrieveRepairsPictures]
	@Consecutive	Int,
	@LineItem		Int = Null,
	@PictureId		Int = Null
AS
IF @LineItem IS Null AND @PictureId IS Null
BEGIN
	SELECT	*
			INTO #tmpData
	FROM	(
			SELECT	DISTINCT 0 AS RepairsPictureId,
					RP.Consecutive,
					RP.LineItem,
					'' AS PictureFileName, 
					'' AS PictureType,
					'Item # ' + CAST(RP.LineItem AS Varchar) AS [Type],
					0 AS TypeSort,
					Null AS Parent,
					'N' + dbo.PADL(RP.LineItem, 8, '0') AS Node,
					Null AS SavedOn,
					RTRIM(RD.PartDescription) AS PartDescription
			FROM	View_RepairsPicturesAll RP
					INNER JOIN RepairsDetails RD ON RP.Consecutive = RD.Consecutive AND RP.LineItem = RD.LineItem
			WHERE	RP.Consecutive = @Consecutive
					AND TypeSort < 5
			UNION
			SELECT	RepairsPictureId,
					Consecutive,
					LineItem,
					PictureFileName, 
					PictureType,
					[Type],
					TypeSort,
					'N' + dbo.PADL(LineItem, 8, '0') AS Parent,
					[Type] + dbo.PADL(RepairsPictureId, 8, '0') AS Node,
					SavedOn,
					'' AS PartDescription
			FROM	View_RepairsPictures 
			WHERE	Consecutive = @Consecutive
			) DATA

		SELECT	T1.*,
				ROW_NUMBER() OVER (PARTITION BY T1.PictureType ORDER BY T1.Parent, T1.SavedOn) AS RowNumber,
				Counter = (SELECT COUNT(*) FROM #tmpData T2 WHERE T2.LineItem = T1.LineItem AND T2.PictureType = T1.PictureType)
		FROM	#tmpData T1
		ORDER BY Consecutive, TypeSort, SavedOn

		DROP TABLE #tmpData
END
ELSE
BEGIN
	IF @LineItem IS NOT Null AND @PictureId IS Null
	BEGIN
		SELECT	*
				INTO #tmpData2
		FROM	(
				SELECT	RepairsPictureId,
						Consecutive,
						LineItem,
						PictureFileName, 
						PictureType,
						[Type],
						TypeSort,
						'N' + dbo.PADL(LineItem, 8, '0') AS Parent,
						[Type] + dbo.PADL(RepairsPictureId, 8, '0') AS Node,
						SavedOn,
						'' AS PartDescription
				FROM	View_RepairsPictures 
				WHERE	Consecutive = @Consecutive
						AND LineItem = @LineItem
				) DATA

		SELECT	T1.*,
				ROW_NUMBER() OVER (PARTITION BY T1.PictureType ORDER BY T1.Parent, T1.SavedOn) AS RowNumber,
				Counter = (SELECT COUNT(*) FROM #tmpData2 T2 WHERE T2.LineItem = T1.LineItem AND T2.PictureType = T1.PictureType)
		FROM	#tmpData2 T1
		ORDER BY Consecutive, TypeSort, SavedOn

		DROP TABLE #tmpData2
	END
	ELSE
	BEGIN
		SELECT	* 
		FROM	RepairsPictures
		WHERE	Consecutive = @Consecutive 
				AND LineItem = @LineItem
				AND RepairsPictureId = @PictureId
	END
END