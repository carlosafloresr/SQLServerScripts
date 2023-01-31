SELECT	*
FROM	[LENSASQL001].[GPCustom].[dbo].[Integration_APHeader]
WHERE	WeekEndDate = '07/21/2018'
order by company, batchid

SELECT	*
FROM	ReceivedIntegrations
WHERE	Integration = 'DPY'

DELETE	ReceivedIntegrations
WHERE	Integration = 'DPY'
