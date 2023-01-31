/*
SELECT	*
FROM	View_CustomerTiers
WHERE	CustomerNo = 'PD1198'
*/
--SELECT * FROM View_PrincipalTiers WHERE loa

SELECT	CM.CompanyId
		,CT.CustNmbr
		,CM.CustName
		,CT.PrincipalID
		,CT.CustomerNo
		,CT.CustomerName
		,CT.WorldRegionsDesc
		,CT.EquipmentSize
		,CT.EquipmentShortDesc
		,CT.FreeDays
		,CT.PrincipalFreeDays
		,CT.EffectiveDate
		,CT.ExpirationDate
		,CT.MoveTypeDesc
		,CT.EntryPortDesc
		,CT.GracePeriod
		,CT.Invoicing
		,CT.InvoicingTimeFrame
		,CT.SCACCode
		,CT.BusinessDays
		,CT.OnlyExtendedFreeDays
		,CT.TierNo
		,CT.TierStartDay
		,CT.TierEndDay
		,CT.Rate
FROM	View_CustomerTiers CT
		INNER JOIN ILSGP01.GPCustom.dbo.Companies CO ON CT.Company = CO.CompanyNumber
		INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CM ON CT.CustNmbr = CM.CustNmbr AND CO.CompanyId = CM.CompanyId
WHERE	CT.CustomerNo = 'PD1198'
ORDER BY
		CT.CustNmbr
		,CT.CustomerNo
		,CT.PrincipalID
		,CT.EquipmentSize
		,CT.EquipmentShortDesc
		,CT.MoveTypeCode
		,CT.Tierno
		--CustNmbr = '2154'