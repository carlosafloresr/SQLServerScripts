SELECT	DOCTYPE, 
		VCHRNMBR, 
		COUNT(*) AS [COUNT] 
FROM	(
		SELECT DOCTYPE, VCHNUMWK AS VCHRNMBR FROM PM10000 W
		UNION ALL
		SELECT DOCTYPE, VCHRNMBR FROM PM10300 P
		UNION ALL
		SELECT DOCTYPE, VCHRNMBR FROM PM10400 M
		UNION ALL
		SELECT DOCTYPE, VCHRNMBR FROM PM20000 O
		UNION ALL
		SELECT DOCTYPE, VCHRNMBR FROM PM30200 H
		) C
GROUP BY DOCTYPE, VCHRNMBR
HAVING	COUNT(*) > 1

