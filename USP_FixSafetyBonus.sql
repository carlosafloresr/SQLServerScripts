USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FixSafetyBonus]    Script Date: 7/21/2022 5:21:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FixSafetyBonus 'GIS', 'A50651'
*/
ALTER PROCEDURE [dbo].[USP_FixSafetyBonus]
		@Company	Varchar(5),
		@VendorId	Varchar(15) = Null
AS
SET NOCOUNT ON

DECLARE	@HireDate	DateTime
DECLARE @tblPeriods Table (Period Varchar(10), VendorId Varchar(15))

INSERT INTO @tblPeriods
SELECT	TOP 2 *
FROM	(
		SELECT	DISTINCT Period, MAX(CAST(PayDate AS Date)) AS PayDate
		FROM	SafetyBonus
		WHERE	Company = @Company
				AND SortColumn = 1
				AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
		GROUP BY Period
		) DATA
ORDER BY 1 DESC

UPDATE	SafetyBonus
SET		SafetyBonus.OldDriverId = DATA.OldDriverId
FROM	(
		SELECT	VMA.Company,
				VMA.VendorId,
				VMA.OldDriverId
		FROM	VendorMaster VMA
				INNER JOIN (SELECT DISTINCT Company, VendorId, OldDriverId FROM SafetyBonus) SAB ON VMA.Company = SAB.Company AND VMA.VendorId = SAB.VendorId
		WHERE	VMA.OldDriverId IS NOT Null
				AND SAB.OldDriverId IS Null
		) DATA
WHERE	SafetyBonus.Company = DATA.Company
		AND SafetyBonus.VendorId = DATA.VendorId

DECLARE curDrivers CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT VendorId
FROM	SafetyBonus
WHERE	Company = @Company
		AND SortColumn = 1
		AND Paid = 0
		AND Period IN (SELECT Period FROM @tblPeriods)
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
UNION
SELECT	DISTINCT VendorId
FROM	SafetyBonus
WHERE	Company = @Company
		AND SortColumn = 1
		AND Paid = 0
		AND OldDriverId IS NOT Null
		AND Period IN (SELECT Period FROM @tblPeriods)
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
ORDER BY 1

OPEN curDrivers
FETCH FROM curDrivers INTO @VendorId

WHILE @@FETCH_STATUS = 0 
BEGIN
	SELECT	@HireDate = HireDate
	FROM	VendorMaster
	WHERE	Company = @Company
			AND VendorId = @VendorId

	UPDATE	SafetyBonus
	SET		HireDate = @HireDate
	WHERE	Company = @Company
			AND VendorId = @VendorId

	EXECUTE dbo.USP_RecalculateSafetyBonusByDriver @Company, @VendorId

	FETCH FROM curDrivers INTO @VendorId
END

CLOSE curDrivers
DEALLOCATE curDrivers