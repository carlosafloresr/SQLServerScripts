USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_LoadSWSOwnerOperatorsEquipment]    Script Date: 9/7/2021 3:35:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_LoadSWSOwnerOperatorsEquipment
*/
ALTER PROCEDURE [dbo].[USP_LoadSWSOwnerOperatorsEquipment]
AS
EXECUTE USP_QuerySWS_ReportData 
'SELECT cmpy_no, t_code AS UnitNumber, div_code, tvin, tyear, tmake, '''' AS model, '''' AS daycab, ttag, ttagst, ttagdt, 0 AS unladenwt, 0 as grosswt, 0 as regwt, 
null AS fhwadt, rem, code AS vend_code, hiredt, '''' AS descother, termdt as offhiredate, status, mytruck FROM dta.trk.driver where status = ''A'' AND code NOT IN (-1,999) order by code', '##tmpSWSDrivers'

update ##tmpswsdrivers
set daycab='N'

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
		--,[fhwadt]
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
		,[UnitNumber]
		,[div_code]
		,[Tvin]
		,[Tyear]
		,[Tmake]
		,[model]
		,[daycab]
		,[Ttag]
		,[Ttagst]
		,[Ttagdt]
		,[unladenwt]
		,[grosswt]
		,[regwt]
		--,[fhwadt]
		,[rem]
		,[vend_code]
		,[hiredt]
		,[descother]
		,[offhiredate]
		,[status]
		,CASE WHEN [mytruck] = 'N' THEN 0 ELSE 1 END
		,'O'
		,'TRK'
FROM	##tmpSWSDrivers
WHERE	UnitNumber <> ''
		AND UnitNumber NOT IN (SELECT UnitNumber FROM EquipmentTags)

--select * from ##tmpswsdrivers
DROP TABLE ##tmpSWSDrivers

/*
SELECT * FROM EquipmentTags
*/
