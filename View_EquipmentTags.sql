USE [GPCustom]
GO

/****** Object:  View [dbo].[View_EquipmentTags]    Script Date: 08/11/2011 11:06:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
SELECT Code, 'Unit # ' + RTRIM(Code) + ' ' + RTRIM(CompanyId) + ' ' + RTRIM(Make) + ' ' + Year + '  TAG: ' + Tag AS Description FROM View_EquipmentTags ORDER BY 2
select * from View_EquipmentTags ORDER BY Code
*/
ALTER VIEW [dbo].[View_EquipmentTags]
AS
SELECT	EQT.EquipmentTagId
		,EQT.cmpy_no
		,COM.CompanyId
		,COM.CompanyName
		,EQT.UnitNumber
		,EQT.UnitType
		,CASE WHEN EQT.UnitType = 'TRA' THEN 'Trailer' WHEN  EQT.UnitType = 'CHA' THEN 'Chassis' ELSE 'Truck' END AS UnitTypeDescription
		,EQT.div_code
		,ISNULL(DIV.DivisionName, 'No Division Assigned') AS DivisionName
		,EQT.vin
		,EQT.year
		,EQT.make
		,EQT.model
		,EQT.daycab
		,EQT.tag
		,EQT.tagst
		,EQT.tagdt
		,EQT.unladenwt
		,EQT.grosswt
		,EQT.regwt
		,EQT.fhwadt
		,EQT.rem
		,EQT.vend_code
		,EQT.onhiredt
		,EQT.descother
		,EQT.offhiredt
		,EQT.status
		,CASE WHEN EQT.status = 'A' THEN 'Active' ELSE 'Inactive' END AS UnitStatus
		,EQT.MyTruck
		,EQT.ownertype
		,EQT.TagCost
		,EQT.AdminFee
		,EQT.TransferTo
		,EQT.TagReturned
		,EQT.Title
		,EQT.Comments
FROM	GPCustom.dbo.EquipmentTags EQT
		LEFT JOIN GPCustom.dbo.Companies COM ON CASE WHEN EQT.cmpy_no BETWEEN 10 AND 40 THEN 10 ELSE EQT.cmpy_no END = COM.CompanyNumber
		LEFT JOIN GPCustom.dbo.View_Divisions DIV ON EQT.div_code = DIV.Division AND COM.CompanyId = DIV.Fk_CompanyId

GO


