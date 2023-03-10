/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 2000 [RouteStepTaskID]
      ,[RouteStepID]
      ,[ChildRouteID]
      ,[Description]
      ,[IconNumber]
      ,[TaskOrder]
      ,[ActionType]
      ,[ActionNum]
      ,[AutoStep]
      ,[Caption]
      ,[AutoNum]
  FROM [fb].[dbo].[RouteStepTasks]
  where RouteStepID in (SELECT [RouteStepID]
  FROM [fb].[dbo].[RouteSteps]
  where RouteID= 37)
	--AND Description = 'Approved'
  order by TaskOrder

  update [fb].[dbo].[RouteStepTasks]
  set	AutoNum = 8
  where	AutoNum = 26
		AND Description = 'Approved'