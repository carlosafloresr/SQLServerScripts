SELECT	*
FROM	PM20000
WHERE	DOCNUMBR = 'TIP0518181357'

--SELECT	*
--FROM	PM20100
--WHERE	APFRDCNM = 'TIP0518181357'
--		OR APTODCNM = 'TIP0518181357'

SELECT	APTODCNM,
		APPLDAMT
FROM	PM30300
WHERE	APFRDCNM = 'TIP0518181357'
		OR APTODCNM = 'TIP0518181357'
ORDER BY APPLDAMT

SELECT	SUM(APPLDAMT)
FROM	PM30300
WHERE	APFRDCNM = 'TIP0518181357'

SELECT	SUM(CASE WHEN APPLDAMT IS Null THEN 0 ELSE APPLDAMT END) AS APPLDAMT,
		SUM(ApplyAmount) AS ApplyAmount
FROM	(
		SELECT	APP.*,
				APA.APTODCNM,
				APA.APPLDAMT
		FROM	IntegrationsDB.Integrations.dbo.Integrations_ApplyTo APP
				LEFT JOIN PM30300 APA ON APP.CustomerVendor = APA.VendorId AND APP.ApplyTo = APA.APTODCNM AND APP.ApplyFrom = APA.APFRDCNM
		WHERE	APP.ApplyFrom = 'TIP0518181357'
				AND APP.RecordType = 'AP'
		) DATA
		
		SELECT	APP.*,
				APA.APTODCNM,
				APA.APPLDAMT
		FROM	PM30300 APA
				JOIN IntegrationsDB.Integrations.dbo.Integrations_ApplyTo APP ON APP.CustomerVendor = APA.VendorId AND APP.ApplyTo = APA.APTODCNM AND APP.ApplyFrom = APA.APFRDCNM
		WHERE	APP.ApplyFrom = 'TIP0518181357'
				AND APP.RecordType = 'AP'

--PRINT 73512.94000 - 73287.94000
--PRINT 73512.94000 - 75922.94


