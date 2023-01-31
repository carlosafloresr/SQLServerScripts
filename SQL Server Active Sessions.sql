DECLARE	@tblSessions Table (
	Spid		Smallint,
	Ecid		Smallint,
	Status		Nvarchar(30),
	LoginName	Nvarchar(128),
	HostName	Nvarchar(128),
	Blk			Char(5),
	DBName		Nvarchar(128),
	Cmd			Nvarchar(16),
	RequestId	Int)

INSERT INTO @tblSessions
EXEC sp_who 'rnunn'

SELECT	*
FROM	@tblSessions
--WHERE	DBName = 'DNJ'
ORDER BY DBName, HostName

/*
SELECT	name, database_id, create_date  
FROM	sys.databases
*/