SELECT DISTINCT db_verMajor FROM DB_UPGRADE WHERE db_name = 'DYNAMICS' 
SELECT * FROM DB_UPGRADE WHERE db_name = 'DYNAMICS' 

-- QUERY 1:
SELECT * FROM DB_UPGRADE WHERE db_verMajor <>  12 ORDER BY db_verMajor, PRODID

-- QUERY 2
SELECT * FROM DB_UPGRADE

UPDATE	DB_UPGRADE
SET		db_verMajor = 12,
		db_verBuild = 1801,
		db_verOldMajor = 12
WHERE	db_verMajor < 12