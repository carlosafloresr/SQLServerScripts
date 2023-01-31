UPDATE	Integrations_GL
SET		Processed = 0,
		InvoiceNumber = 'SBA_20170303'
WHERE	Integration = 'SBA'

UPDATE	ReceivedIntegrations
SET		Status = 0
WHERE	Integration = 'SBA'

SELECT	*
FROM	Integrations_GL
WHERE	Integration = 'SBA'

SELECT	*
FROM	ReceivedIntegrations
WHERE	Integration = 'SBA'

SELECT *, JrnlRows = (SELECT COUNT(TM.InvoiceNumber) FROM Integrations_GL TM WHERE TM.InvoiceNumber = Integrations_GL.InvoiceNumber AND TM.BatchId = Integrations_GL.BatchId) FROM Integrations_GL WHERE Integration = 'SBA' AND BatchId = 'SBA_20170303' AND Processed = 0 ORDER BY InvoiceNumber, SqncLine

at _6WheelListener.FrmListener.SendNotification(String BatchID, String TransactionType, String Others, String GPServer, Int32 BatchStatus) 
in E:\Development\VBNET\IntegrationsManager_GP2015\6WheelListener\FrmListener.vb:line 7824" 
at _6WheelListener.FrmListener.Find_Integrations() in E:\Development\VBNET\IntegrationsManager_GP2015\6WheelListener\FrmListener.vb:line 5765"

_6WheelListener.FrmListener.Send_XML_Files(String Integration, String Batch) 
in E:\Development\VBNET\IntegrationsManager_GP2015\6WheelListener\FrmListener.vb:line 3239
at _6WheelListener.FrmListener.SendNotification(String BatchID, String TransactionType, String Others, String GPServer, Int32 BatchStatus) 
in E:\Development\VBNET\IntegrationsManager_GP2015\6WheelListener\FrmListener.vb:line 7800"

"data source=LENSASQL001;initial catalog=DNJ;integrated security=SSPI;persist security info=False; packet size=4096;"