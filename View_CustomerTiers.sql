/*
SELECT * FROM View_CustomerTiers
*/
ALTER VIEW View_CustomerTiers
AS
SELECT	RTI.CustomerNo
		,RTI.PrincipalKey
		,RTI.LocationProfileID
		,RTI.RateID
		,RTI.Company
		,RTI.GrupoCode
		,RTI.DirectBill
		,RTI.CargoID
		,RTI.LocationID
		,WRE.WorldRegionsCode
		,WRE.WorldRegionsDesc
		,RTI.EquipmentSizeID
		,RTI.EquipmentTypeID
		,RTI.FreeDays
		,RTI.ExpirationDate
		,RTI.EffectiveDate
		,RTI.HolidayID
		,RTI.MoveTypeId
		,TYP.MoveTypeCode
		,TYP.MoveTypeDesc
		,RTI.DestinationId
		,POR.EntryPortCode
		,POR.EntryPortDesc
		,CPR.Shipper
		,CPR.Consignee
		,CPR.ContactId
		,CPR.Agreement
		,CPR.GracePeriod
		,CPR.BillAprovalRequired
		,CPR.ApprovalEmail
		,CPR.AdvancedNotification
		,CPR.NotifiationEmail
		,CPR.DocRequired
		,CPR.OtherDocRequired
		,CPR.MarkupType
		,CPR.MarkupValue
		,CPR.Invoicing
		,CPR.InvoicingTimeFrame
		,CPR.CompanyTariffs
		,CPR.ImportsExports
		,CPR.DoorMoves
		,CPR.InterchangeRules
		,CPR.Holidays
		,CPR.Weekends
		,CPR.InterchangeFree
FROM	dbo.LPRateTiers RTI
		INNER JOIN CustomerLocationProfiles CPR ON RTI.CustomerNo = CPR.CustomerNo AND RTI.LocationProfileID = CPR.LocationProfileID
		INNER JOIN RateMoveType TYP ON RTI.MoveTypeId = TYP.MoveTypeId
		LEFT JOIN RateEntryPort POR ON RTI.DestinationId = POR.EntryPortId
		LEFT JOIN RateWorldRegions WRE ON RTI.LocationID = WRE.WorldRegionsId