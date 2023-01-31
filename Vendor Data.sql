SELECT	* 
FROM	SY01200 
WHERE	Master_Type = 'VEN' 
		AND Master_ID = '102'

SELECT	* 
FROM	SY04906 
WHERE	EmailCardID = '102' 
ORDER BY EmailRecipientTypeTo DESC, EmailRecipientTypeCc DESC, EmailRecipientTypeBcc DESC