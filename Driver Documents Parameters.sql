SELECT	*
FROM	Parameters
WHERE	ParameterCode = 'DRIVERSIMAGINGPATH'
--VarC LIKE '%HTT%'

UPDATE	Parameters
SET		VarC = 'http://ILSFTP01/OOSDocuments/' 
WHERE	ParameterCode = 'DRIVERDOCUMENTSWEB'

UPDATE	Parameters
SET		VarC = '\\ILSFTP01\DriverDocuments\'
WHERE	ParameterCode = 'DRIVERSIMAGINGPATH'

-- http://LENSAAPP001/OOSDocuments/
-- http://PRIAPINT01P/OOSDocuments/

--\\PRIAPINT01P\DriverDocuments\

UPDATE	Parameters
SET		VarC = '\\PRIAPINT01P\DriverDocuments\DriverDocuments\'
WHERE	ParameterCode = 'DRIVERSIMAGINGPATH'

