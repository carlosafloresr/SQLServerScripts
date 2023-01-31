INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_DEBITACCOUNT',
		'ALL' AS Company,
		'FSI AP Per Diem Debit Account' AS Description,
		'C' AS VarType,
		'0-00-2117' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_CREDITACCOUNT',
		'ALL' AS Company,
		'FSI AP Per Diem Credit Account' AS Description,
		'C' AS VarType,
		'0-DD-6594' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_ACCESSORAILCODE',
		'ALL' AS Company,
		'FSI AP Per Diem Accessorial Code' AS Description,
		'C' AS VarType,
		'PRD' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_VENDORCODE',
		'GIS' AS Company,
		'FSI AP Per Diem Vendor' AS Description,
		'C' AS VarType,
		'GISPDA' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_VENDORCODE',
		'OIS' AS Company,
		'FSI AP Per Diem Vendor' AS Description,
		'C' AS VarType,
		'OISPDA' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_VENDORCODE',
		'AIS' AS Company,
		'FSI AP Per Diem Vendor' AS Description,
		'C' AS VarType,
		'AISPDA' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_VENDORCODE',
		'PDS' AS Company,
		'FSI AP Per Diem Vendor' AS Description,
		'C' AS VarType,
		'PDSPDA' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_VENDORCODE',
		'DNJ' AS Company,
		'FSI AP Per Diem Vendor' AS Description,
		'C' AS VarType,
		'DNJPDA' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_VENDORCODE',
		'GLSO' AS Company,
		'FSI AP Per Diem Vendor' AS Description,
		'C' AS VarType,
		'INAPDA' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_VENDORCODE',
		'IMC' AS Company,
		'FSI AP Per Diem Vendor' AS Description,
		'C' AS VarType,
		'IMGPDA' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PRD_VENDORCODE',
		'HMIS' AS Company,
		'FSI AP Per Diem Vendor' AS Description,
		'C' AS VarType,
		'HMIPDA' AS VarC