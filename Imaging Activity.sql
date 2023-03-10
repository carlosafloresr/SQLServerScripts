SELECT	CONVERT(Varchar, ProcessedOn, 101) as date,
		count(*) as counter
FROM	[GPCustom].[dbo].[DocPowerImages]
WHERE	ProcessedOn BETWEEN '11/19/2017' AND '11/25/2017 11:59 PM'
group by CONVERT(Varchar, ProcessedOn, 101)
order by 1

SELECT	DATEPART(wk, ProcessedOn) AS Week,
		count(*) as counter
FROM	[GPCustom].[dbo].[DocPowerImages]
WHERE	ProcessedOn BETWEEN '01/01/2017' AND '11/20/2017 11:59 PM'
group by DATEPART(wk, ProcessedOn)
order by 1

SELECT	CONVERT(Varchar, ProcessedOn, 101) as date,
		dbo.padl(DATEPART(HOUR, ProcessedOn), 2, '0') as hour,
		count(*) as counter
FROM	[GPCustom].[dbo].[DocPowerImages]
WHERE	ProcessedOn BETWEEN '11/19/2017' AND '11/25/2017 11:59 PM'
group by CONVERT(Varchar, ProcessedOn, 101), DATEPART(HOUR, ProcessedOn)
order by 1,2