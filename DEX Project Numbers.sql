/****** Script for SelectTopNRows command from SSMS  ******/
SELECT Files.ProjectId,
		ProjectName,
      COUNT(Files.ProjectID) AS Counter
  FROM [fb].[dbo].[Files]
		inner join projects on files.ProjectID = projects.ProjectID
  where Files.ProjectID in (66, 61, 62, 63, 65, 67, 69,  64, 68, 66)
	and DateChanged between '01/01/2012' and '06/30/2012'
group by Files.ProjectId, ProjectName