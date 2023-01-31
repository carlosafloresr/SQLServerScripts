SELECT	Depot,
		EmailAddress
FROM	EmailNotification
WHERE	Process = 'MECHLABORREPORT'
		AND Inactive = 0
ORDER BY 1, 2