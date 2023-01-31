UPDATE	KarmakIntegration
SET		Processed = 2
WHERE	KarmakIntegrationID IN (
								SELECT	KarmakIntegrationID
								FROM	View_KarmakIntegration
								WHERE	CustomerNumber NOT IN ('AIS','GIS','RCMR')
										AND InvoiceTotal > 0
										AND CustomerNumber <> CustomerToExclude
										AND WeekEndDate = '8/04/2018'
								)