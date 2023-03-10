-- ***************************************************************
-- *** FIX DUPLICATE PAYROLL - AP INTEGRATION DOCUMENT NUMBERS ***
-- ***************************************************************

BEGIN TRANSACTION

UPDATE PM00400 SET DOCNUMBR = REPLACE(DOCNUMBR, 'PIP', 'PP') WHERE DOCNUMBR LIKE 'PIP%'
UPDATE GL20000 SET ORDOCNUM = REPLACE(ORDOCNUM, 'PIP', 'PP') WHERE ORDOCNUM LIKE 'PIP%'
UPDATE GL30000 SET ORDOCNUM = REPLACE(ORDOCNUM, 'PIP', 'PP') WHERE ORDOCNUM LIKE 'PIP%'
UPDATE PM00201 SET LSTINNUM = REPLACE(LSTINNUM, 'PIP', 'PP') WHERE LSTINNUM LIKE 'PIP%'
UPDATE PM20000 SET DOCNUMBR = REPLACE(DOCNUMBR, 'PIP', 'PP') WHERE DOCNUMBR LIKE 'PIP%'
UPDATE PM30200 SET DOCNUMBR = REPLACE(DOCNUMBR, 'PIP', 'PP') WHERE DOCNUMBR LIKE 'PIP%'	
UPDATE PM30300 SET APTODCNM = REPLACE(APTODCNM, 'PIP', 'PP') WHERE APTODCNM LIKE 'PIP%'
UPDATE PM80500 SET APTODCNM = REPLACE(APTODCNM, 'PIP', 'PP') WHERE APTODCNM LIKE 'PIP%'

IF @@ERROR = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION