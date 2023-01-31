DECLARE	@UserId Varchar(25) = 'CFLORES',
		@Approval Varchar(20) = null,
		@dAge Decimal = null,
		@sDepotCity Varchar(15) = 'MEMPHIS',
		@sType Varchar(25) = 'U,',
		@sSWSStatus varchar(2) = null,
		@vEquipment Varchar(10) = null,
		@vCompanion Varchar(10) = null,
		@vCustomerNotCombo Varchar(10) = null,
		@vSize Varchar(5) = null,
		@nEstimateNum Int = null

DECLARE @Depots_Managers TABLE
		(
		Depot_Loc	varchar(15)
		)

IF EXISTS(SELECT Depot_Loc FROM ILSINT02.FI_Data.dbo.Depots_Managers WHERE UserId = @UserId AND	Process = 'OOS')
BEGIN
	INSERT INTO @Depots_Managers
	SELECT	Depot_Loc
	FROM	ILSINT02.FI_Data.dbo.Depots_Managers
	WHERE	UserId = @UserId
			AND	Process = 'OOS'
END
ELSE
BEGIN
	
	EXECUTE dbo.USP_QuerySWS 'SELECT DISTINCT City AS Depot_Loc FROM Public.DMSite WHERE City <> '''' ORDER BY City', '##tmpData'

	INSERT INTO @Depots_Managers
	SELECT Depot_Loc FROM ##tmpData

	DROP TABLE ##tmpData
END

SELECT	*
FROM	View_OOS_EquipmentRecords OER
WHERE	UserId = @UserId
		AND Site IN (SELECT Depot_Loc FROM @Depots_Managers)
		AND	(
				(@sDepotCity IS NULL) 
						OR
				(OER.Site = @sDepotCity)
			)
		AND (
				(@dAge IS NULL)
						OR
				(OER.InGate_Age = @dAge)
			)
		AND (
				(@sSWSStatus IS NULL)
						OR
				(OER.[Status] = @sSWSStatus)
			)
		AND (
				dbo.AT(Type, @sType, 1) > 0
			)
		AND (
				(@vEquipment IS NULL)
						OR
				(OER.UnitNumber = @vEquipment)
			)
		AND (
				(@vCompanion IS NULL)
						OR
				(@vCompanion IS NOT NULL AND OER.Companion = @vCompanion)
			)
		AND (
				(@vCustomerNotCombo IS NULL)
						OR
				(@vCustomerNotCombo IS NOT NULL AND OER.Customer = @vCustomerNotCombo)
			)
		AND (
				(@vSize IS NULL)
						OR
				(@vSize IS NOT NULL AND OER.EqType = @vSize)
			)
		AND (
				(@nEstimateNum IS NULL)
						OR
				(@nEstimateNum IS NOT NULL AND OER.Estimate = @nEstimateNum)
			)
ORDER BY
		FI_Status_Sort
		,InGate_Age DESC

/*
EXECUTE USP_OOS_Equipment_Result2 'CFLORES', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0
EXECUTE USP_OOS_Equipment_Result2 'CFLORES', NULL, NULL, 'MEMPHIS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0
*/
