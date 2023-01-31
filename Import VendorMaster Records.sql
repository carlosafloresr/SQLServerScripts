INSERT INTO VendorMaster
SELECT	DISTINCT [VendorId]
      ,'GIS'
      ,[HireDate]
      ,[TerminationDate]
      ,[SubType]
      ,[ApplyRate]
      ,[Rate]
      ,[ApplyAmount]
      ,[Amount]
      ,[ScheduledReleaseDate]
      ,'CFLORES'
      ,GETDATE() 
FROM	VendorMaster 
WHERE	Company = 'IMC'
		AND VendorId IN (SELECT VendorId FROM IMC.dbo.PM00200 WHERE VndClsId = 'DRV')