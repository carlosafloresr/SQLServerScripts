	SELECT FileID
	  FROM [FB].[dbo].[View_DEXDocuments]
	  where ProjectID = 65
		AND Field8 = '1000331'
		AND Field4 between '1785372' and '1785871'
		AND KeyGroup1 IS Null
		--AND FileID IN (2139236,2139227)
		--and StepNumber = 2
		--AND RoutedStatus = 0
/*
select * from DocumentRoute where DocumentRouteId in (select DocumentRouteId FROM [FB].[dbo].[View_DEXDocuments]
  where ProjectID = 65
		AND Field8 = '1000331'
		AND Field4 between '1785372' and '1785871'
		AND StepNumber = 2
		AND RoutedStatus = 0)

update DocumentRoute 
set		Status = 1
where DocumentRouteId in (select DocumentRouteId FROM [FB].[dbo].[View_DEXDocuments]
  where ProjectID = 65
		AND Field8 = '1000331'
		AND Field4 between '1785372' and '1785871'
		AND StepNumber = 2
		AND RoutedStatus = 0)
*/