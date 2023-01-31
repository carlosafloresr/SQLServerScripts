UPDATE	ExtendedProperties
SET		ExtendedProperties.KeyGroup1 = DATA.ACTDESCR
FROM	(
		SELECT	DEX.Field4, 
				EX.ObjectId,
				EX.PropertyValue,
				EX.KeyGroup3,
				EX.KeyGroup4,
				EX.KeyGroup7
				,RIGHT(EX.PropertyValue, 4) AS Account_PV
				,REPLACE(LEFT(EX.PropertyValue, 4), '-', '') AS Department_KG3
				,FIL.Field2 AS DEPTODESC
				,ACTDESCR = EX.PropertyValue + ' ' + ISNULL((SELECT ACTDESCR FROM PRISQL01P.IMC.dbo.GL00100 WHERE ACTINDX IN (SELECT ACTINDX FROM PRISQL01P.IMC.dbo.GL00105 WHERE ACTNUMST = LEFT(EX.KeyGroup3, 1) + '-' + RIGHT(EX.KeyGroup3, 2) + '-' + EX.PropertyValue)),'')
		FROM	ExtendedProperties EX
				LEFT JOIN View_DEXDocuments DEX ON DEX.ProjectID = 65 AND EX.ObjectID = DEX.FileID
				LEFT JOIN FB.dbo.Files FIL ON FIL.ProjectID = 74 AND EX.KeyGroup3 = FIL.Field1
		WHERE	EX.PropertyKey = 'GL_Code_Entry'
				AND DEX.Field8 = '1000331'
				AND DEX.Field4 IN ('1785842',
'1785843',
'1785844',
'1785850',
'1785852',
'1785856',
'1785859',
'1785880',
'1785905',
'1785907',
'1785914',
'1785917',
'1785924',
'1785928',
'1785930',
'1785934',
'1785935',
'1785956',
'1785971',
'1785973',
'1785990',
'1786002',
'1786005',
'1786010',
'1786012',
'1786017',
'1786052',
'1786116',
'1786120',
'1786123',
'1786126',
'1786152',
'1786156',
'1786158',
'1786200')
		) DATA
WHERE	ExtendedProperties.ObjectID = DATA.ObjectID
		AND ExtendedProperties.PropertyValue = DATA.PropertyValue
		AND ExtendedProperties.KeyGroup4 = DATA.KeyGroup4
		AND ExtendedProperties.PropertyKey = 'GL_Code_Entry'