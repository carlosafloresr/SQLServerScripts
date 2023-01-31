-- UPDATE Parameters SET Company = 'ALL'

INSERT INTO Parameters (Company
		,ParameterCode
		,Description
		,VarType
		,VarN
		,VarI
		,VarD
		,VarB
		,VarM
		,VarC)
SELECT	'OIS' AS Company
		,ParameterCode
		,Description
		,VarType
		,VarN
		,VarI
		,VarD
		,VarB
		,VarM
		,VarC
FROM	Parameters
WHERE	Company = 'AIS'
		And ParameterCode = 'CHECKID_BOA'

INSERT INTO Parameters
SELECT	'ALL' AS Company
		,'ADPCODE_437' AS ParameterCode
		,'ADP Company Code' AS Description
		,'C' AS VarType
		,VarN
		,VarI
		,VarD
		,VarB
		,VarM
		,'IMCMR' AS VarC
		,VarT
		,ApplicationName
FROM	Parameters
WHERE	ParameterCode = 'ADPCODE_8XR'