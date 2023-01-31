UPDATE	GL40000
SET		NJRNLENT = (DATA.JRNENTRY + 1)
FROM	(
		SELECT	MAX(JRNENTRY) AS JRNENTRY
		FROM	(
				SELECT	MAX(JRNENTRY) AS JRNENTRY
				FROM	GL10000
				UNION
				SELECT	MAX(JRNENTRY) AS JRNENTRY
				FROM	GL20000
				UNION
				SELECT	MAX(JRNENTRY) AS JRNENTRY
				FROM	GL30000
				) DATA
		) DATA

SELECT	NJRNLENT
FROM	GL40000