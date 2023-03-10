/*
SELECT * FROM View_PrincipalTiers ORDER BY 1

SELECT * FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE CUSTNMBR = 'PDMESU'
*/
ALTER VIEW View_PrincipalTiers
AS
SELECT	DISTINCT PRA.PrincipalKey
		,PRI.Name
		,PRI.VendorCode
		,PRI.SCACCode
		,PRI.Address1
		,PRI.Address2
		,PRI.City
		,PRI.State
		,PRI.Zip
		,PRA.AgrementID
		,AGT.RateID
		,AGT.RateCode
		,AGT.EquipmentSizeID AS AgreementEquipmentSize
		,EQS.EquipmentSizeID
		,EQS.ShortDesc AS EquipmentSize
		,AGT.EquipmentTypeId AS AgreementEquipmentType
		,EQT.EquipmentTypeId
		,EQT.EquipmentType
		,AGT.FreeDays
		,AGT.STDays
		,AGT.CustomDays
		,AGT.EffectiveDate AS Rate_EffectiveDate
		,AGT.ExpirationDate AS Rate_ExpirationDate
		,PRA.EffectiveDate AS Agreement_EffectiveDate
		,PRA.ExpirationDate AS Agreement_ExpirationDate
		,PRA.ImportsExports
		,PRA.DoorsMoveBilled
		,PRA.PortInterchangedRule
		,PRA.HolidaysFree
		,PRA.WeekendsFree
		,PRA.DayInterchangeFree
		,PRA.CreatedBy
		,PRA.CreatedDate
		,PRA.Modifiedby
		,PRA.ModifiedDate
		,PRA.HolidayID
FROM	PrincipalAgreements PRA
		INNER JOIN Principals PRI ON PRA.PrincipalKey = PRI.PrincipalKey
		INNER JOIN AgreementsRateTiers AGT ON PRA.AgrementID = AGT.AgreementID
		INNER JOIN EquipmentSize EQS ON PATINDEX('%' + CAST(EQS.EquipmentSizeId AS Varchar(10)) + '%', (AGT.EquipmentSizeID)) > 0
		INNER JOIN EquipmentType EQT ON PATINDEX('%' + CAST(EQT.EquipmentTypeId AS Varchar(10)) + '%', (AGT.EquipmentTypeId)) > 0