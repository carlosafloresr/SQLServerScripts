USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_LoadSWSCompanyEquipment]    Script Date: 11/1/2018 8:26:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_LoadSWSCompanyEquipment

SELECT * FROM EquipmentTags WHERE UnitNumber = 'N4418'
*/
ALTER PROCEDURE [dbo].[USP_LoadSWSCompanyEquipment]
AS
SET NOCOUNT OFF
PRINT ' ************** LOAD SWS COMPANY TRUCKS ***********************'
EXECUTE USP_QuerySWS 'SELECT cmpy_no, Code, div_code, vin, year, make, model, daycab, tag, tagst, tagdt, unladenwt, grosswt, regwt, fhwadt, rem, 0 as mytruck, vend_code, onhiredt, descother, offhiredt, status FROM trk.tractor ORDER BY cmpy_no, Code', '##tmpCompanyTrucks'

INSERT INTO [GPCustom].[dbo].[EquipmentTags]
		([cmpy_no]
		,[UnitNumber]
		,[div_code]
		,[vin]
		,[year]
		,[make]
		,[model]
		,[daycab]
		,[tag]
		,[tagst]
		,[tagdt]
		,[unladenwt]
		,[grosswt]
		,[regwt]
		,[fhwadt]
		,[rem]
		,[vend_code]
		,[onhiredt]
		,[descother]
		,[offhiredt]
		,[status]
		,[mytruck]
		,[ownertype]
		,[UnitType])
SELECT	CASE WHEN [cmpy_no] BETWEEN '10' AND '49' THEN '10' ELSE [cmpy_no] END AS cmpy_no
		,[code]
		,[div_code]
		,[vin]
		,[year]
		,[make]
		,[model]
		,[daycab]
		,[tag]
		,[tagst]
		,[tagdt]
		,[unladenwt]
		,[grosswt]
		,[regwt]
		,[fhwadt]
		,[rem]
		,[vend_code]
		,[onhiredt]
		,[descother]
		,[offhiredt]
		,[status]
		,[mytruck]
		,'C'
		,'TRK'
FROM	##tmpCompanyTrucks
WHERE	Code <> ''
		AND Code NOT IN (SELECT UnitNumber FROM EquipmentTags)

DROP TABLE ##tmpCompanyTrucks

PRINT ' ************** LOAD SWS NDS COMPANY TRUCKS ***********************'
EXECUTE USP_QuerySWS 'SELECT 10 AS cmpy_no, dr_t_code, dr_div_code, dr_tvin, dr_tyear, dr_tmake, '''' AS model, '''' AS daycab, dr_ttag, dr_ttagst, dr_ttagdt, 0 AS unladenwt, 0 AS grosswt, 0 AS regwt, dr_fhwadt, dr_rem, 0 AS mytruck, dr_code, dr_hiredt, '''' AS descother, dr_safnotdt, dr_status FROM gps.drv WHERE dr_cmpy_no BETWEEN ''10'' AND ''49'' AND dr_t_code <> '''' ORDER BY dr_t_code', '##tmpCompanyTrucks'

INSERT INTO [GPCustom].[dbo].[EquipmentTags]
		([cmpy_no]
		,[UnitNumber]
		,[div_code]
		,[vin]
		,[year]
		,[make]
		,[model]
		,[daycab]
		,[tag]
		,[tagst]
		,[tagdt]
		,[unladenwt]
		,[grosswt]
		,[regwt]
		,[fhwadt]
		,[rem]
		,[vend_code]
		,[onhiredt]
		,[descother]
		,[offhiredt]
		,[status]
		,[mytruck]
		,[ownertype]
		,[UnitType])
SELECT	[cmpy_no]
		,[dr_t_code]
		,[dr_div_code]
		,[dr_tvin]
		,[dr_tyear]
		,[dr_tmake]
		,[model]
		,[daycab]
		,[dr_ttag]
		,[dr_ttagst]
		,[dr_ttagdt]
		,[unladenwt]
		,[grosswt]
		,[regwt]
		,[dr_fhwadt]
		,[dr_rem]
		,[dr_code]
		,[dr_hiredt]
		,[descother]
		,[dr_safnotdt]
		,[dr_status]
		,[mytruck]
		,'C'
		,'TRK'
FROM	##tmpCompanyTrucks
WHERE	dr_t_code <> ''
		AND dr_t_code NOT IN (SELECT UnitNumber FROM EquipmentTags)

DROP TABLE ##tmpCompanyTrucks

PRINT ' ************** LOAD SWS COMPANY CONTAINERS, CHASISES AND VANS ***********************'
EXECUTE USP_QuerySWS 'SELECT CMPY_NO, CODE, DIV_CODE, VIN, year, make, null AS Model, null as daycab, tag, tagst, tagdt, null as unladenwt, null as grosswt, null as regwt, fhwadt, remarks as rem, 0 as mytruck, null as vend_code, onhiredt, descother, offhiredt, status, ascii(''C'') AS ownertype, length, width, type FROM trk.trailer', '##tempTrailers'

INSERT INTO [GPCustom].[dbo].[EquipmentTags]
           ([cmpy_no]
           ,[UnitNumber]
           ,[div_code]
           ,[vin]
           ,[year]
           ,[make]
           ,[model]
           ,[daycab]
           ,[tag]
           ,[tagst]
           ,[tagdt]
           ,[unladenwt]
           ,[grosswt]
           ,[regwt]
           ,[fhwadt]
           ,[rem]
           ,[mytruck]
           ,[vend_code]
           ,[onhiredt]
           ,[descother]
           ,[offhiredt]
           ,[status]
           ,[ownertype]
           ,[Length]
           ,[Width]
           ,[UnitType])
SELECT	[cmpy_no]
		,[code]
		,[div_code]
		,[vin]
		,[year]
		,[make]
		,[model]
		,[daycab]
		,[tag]
		,[tagst]
		,[tagdt]
		,[unladenwt]
		,[grosswt]
		,[regwt]
		,[fhwadt]
		,[rem]
		,[mytruck]
		,[vend_code]
		,[onhiredt]
		,[descother]
		,[offhiredt]
		,[status]
		,'C' AS [ownertype]
		,[Length]
		,[Width]
		,CASE WHEN [Type] = 'U' THEN 'CON' WHEN [Type] = 'V' THEN 'VAN' ELSE 'CHA' END AS [Type]
FROM	##tempTrailers
WHERE	Code NOT IN (SELECT UnitNumber FROM EquipmentTags WHERE UnitType <> 'TRK')

DROP TABLE ##tempTrailers

PRINT ' ************** LOAD SWS DIVISIONS ***********************'
EXECUTE USP_QuerySWS 'SELECT CASE WHEN COM.AgentOf_Cmpy_No > 0 THEN COM.AgentOf_Cmpy_No ELSE DIV.Cmpy_No END AS cmpy_no, DIV.code AS Division, DIV.name, DIV.city, DIV.st_code AS state, DIV.status FROM trk.division DIV INNER JOIN com.company COM ON DIV.Cmpy_No = COM.No WHERE DIV.Code <> ''99'' ORDER BY 1, 2', '##tmpDivisions'

INSERT INTO Divisions (Fk_CompanyID, Division, DivisionNumber, Location, Inactive)
SELECT	COM.CompanyId AS Fk_CompanyId
		,CASE WHEN DIV.City = '' THEN dbo.PROPER(DIV.Name) ELSE dbo.PROPER(DIV.City) + ', ' + DIV.State END AS Division
		,DIV.Division AS DivisionNumber
		,Null AS Location
		,0 AS Inactive
FROM	##tmpDivisions DIV
		INNER JOIN Companies COM ON DIV.cmpy_no = COM.CompanyNumber
WHERE	DIV.Division NOT IN (SELECT DivisionNumber FROM Divisions)
		AND DIV.Status = 'A'

DROP TABLE ##tmpDivisions

PRINT ' ************** LOAD SWS OWNER OPERATOR DRIVERS'' TRUCKS ***********************'
EXECUTE USP_QuerySWS 'SELECT cmpy_no, t_code, code, div_code, tvin, tyear, tmake, ttag, ttagst, ttagdt, mytruck, hiredt, status, termdt, termrem1 FROM TRK.Driver WHERE T_Code <> ''''', '##tmpDriversEquipment'

INSERT INTO [GPCustom].[dbo].[EquipmentTags]
           ([cmpy_no]
           ,[UnitNumber]
           ,[div_code]
           ,[vin]
           ,[year]
           ,[make]
           ,[tag]
           ,[tagst]
           ,[tagdt]
           ,[mytruck]
           ,[vend_code]
           ,[onhiredt]
           ,[descother]
           ,[offhiredt]
           ,[status]
           ,[ownertype]
           ,[UnitType])
SELECT	[cmpy_no]
		,[t_code]
		,[div_code]
		,[tvin]
		,[tyear]
		,[tmake]
		,[ttag]
		,[ttagst]
		,[ttagdt]
		,CASE WHEN mytruck = 'N' THEN 0 ELSE 1 END AS [mytruck]
		,[code]
		,[hiredt]
		,RTRIM(LEFT(termrem1, 30))
		,termdt
		,[status]
		,'O' AS [ownertype]
		,'TRK' AS [Type]
FROM	##tmpDriversEquipment
WHERE	t_code NOT IN (SELECT UnitNumber FROM EquipmentTags WHERE UnitType = 'TRK')

DROP TABLE ##tmpDriversEquipment

/*
EXECUTE USP_QuerySWS 'SELECT * FROM TRK.Driver  LIMIT 100'
*/