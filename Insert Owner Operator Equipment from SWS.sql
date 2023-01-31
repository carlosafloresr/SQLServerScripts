/*
SELECT * FROM EquipmentTags

EXECUTE USP_QuerySWS 'SELECT cmpy_no, t_code AS UnitNumber, div_code, tvin, tyear, tmake, '''' AS Model, ''N'' AS DayCab, TTAG, ttagst, ttagdt, 0 AS unladenwt, 0 as grosswt, 0 as regwt, null AS fhwadt, rem, code AS vend_code, hiredt, '''' AS descother, termdt as offhiredate, status, mytruck FROM trk.driver where status = ''A'' order by code', '##test1'
*/
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
		,[ownertype])
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
		,[fhwadt]
		,[rem]
		,[vend_code]
		,[hiredt]
		,[descother]
		,[offhiredate]
		,[status]
		,CASE WHEN [mytruck] = 'N' THEN 0 ELSE 1 END
		,'O'
FROM	##test1

-- drop table ##test1