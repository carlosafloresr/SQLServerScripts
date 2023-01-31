SELECT	[Module]
		,[UserId]
		,[ActivityDate]
  FROM [Intranet].[dbo].[IntranetLog]
  WHERE ActivityDate > '10/01/2022'
  ORDER BY Module, USERID

SELECT	[Module]
		,COUNT(*) AS Counter
  FROM [Intranet].[dbo].[IntranetLog]
  WHERE ActivityDate > '01/01/2022'
  GROUP BY [Module]
  ORDER BY Module