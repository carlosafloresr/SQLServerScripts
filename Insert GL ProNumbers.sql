USE [GLSO]
GO

DECLARE	@JustOpen	Bit = 1

INSERT INTO GPCustom.dbo.GL_ProNumbers
SELECT	DB_NAME() AS Company
		,JRNENTRY 
		,ProNumber
		,REFRENCE
FROM	(
		SELECT	DISTINCT JRNENTRY,
				RTRIM(REFRENCE) AS REFRENCE,
				GPCustom.dbo.FindProNumber(REFRENCE) AS ProNumber
		FROM	GL20000
		WHERE	REFRENCE LIKE '%-%'
				AND JRNENTRY NOT IN (SELECT JRNENTRY FROM GPCustom.dbo.GL_ProNumbers WHERE Company = DB_NAME())
		) DATA
WHERE	ProNumber <> ''
		AND LEN(ProNumber) < 12
		AND ProNumber LIKE '%-%'
		AND ProNumber IN (SELECT InvoiceNumber FROM IntegrationsDB.Integrations.dbo.FSI_ReceivedDetails)

IF @JustOpen = 0
BEGIN
	INSERT INTO GPCustom.dbo.GL_ProNumbers
	SELECT	DB_NAME() AS Company
			,JRNENTRY 
			,ProNumber
			,REFRENCE
	FROM	(
			SELECT	DISTINCT JRNENTRY,
					RTRIM(REFRENCE) AS REFRENCE,
					GPCustom.dbo.FindProNumber(REFRENCE) AS ProNumber
			FROM	GL30000
			WHERE	REFRENCE LIKE '%-%'
					AND JRNENTRY NOT IN (SELECT JRNENTRY FROM GPCustom.dbo.GL_ProNumbers WHERE Company = DB_NAME())
			) DATA
	WHERE	ProNumber <> ''
			AND LEN(ProNumber) < 12
			AND ProNumber LIKE '%-%'
			AND ProNumber IN (SELECT InvoiceNumber FROM IntegrationsDB.Integrations.dbo.FSI_ReceivedDetails)
END

/*
--REFRENCE LIKE '%-%' AND REFRENCE LIKE '%|%' AND REFRENCE NOT LIKE 'ICB%'

SELECT	*
FROM	GPCustom.dbo.GL_ProNumbers
WHERE	JRNENTRY = 319289

DELETE	GL_ProNumbers
WHERE	ProNumber NOT IN (SELECT InvoiceNumber FROM IntegrationsDB.Integrations.dbo.FSI_ReceivedDetails)
RPC-TCNU3522350

TRUNCATE TABLE GPCustom.dbo.GL_ProNumbers
*/