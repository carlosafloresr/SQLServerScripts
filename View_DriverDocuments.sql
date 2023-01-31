USE [GPCustom]
GO

/****** Object:  View [dbo].[View_DriverDocuments]    Script Date: 4/14/2021 12:24:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
SELECT	* 
FROM	View_DriverDocuments 
WHERE	Company = 'DNJ'
		AND BatchId IN('DSDR080614CK','DSDR080614DD')
ORDER BY VendorId
*/
ALTER VIEW [dbo].[View_DriverDocuments]
AS
SELECT	DISTINCT *
FROM	(
SELECT	DD.DriverDocumentId
		,DD.Company
		,DD.VendorId
		,DD.BatchId
		,DD.WeekEndingDate
		,DD.Fk_DocumentTypeId
		,RTRIM(PA.VarC) + CASE WHEN DD.VendorId = 'ALL' THEN DD.Company ELSE RTRIM(DD.VendorId) END + '/' + DD.FileName AS DocumentName
		,RTRIM(P2.VarC) + CASE WHEN DD.VendorId = 'ALL' THEN DD.Company ELSE RTRIM(DD.VendorId) END + '\' + DD.FileName AS SharedDocumentName
		,DT.DocumentType
		,DT.Sort
		,CASE WHEN DT.Category = 1 THEN 'Owner Operator Payroll' ELSE 'Driver File Related' END AS Category
		,VM.PaidByPayCard
		,VM.Agent
		,VM.Division
		,DD.FileFixed
		,VM.NewOOSDate
FROM	DriverDocuments DD
		INNER JOIN VendorMaster VM ON DD.Company = VM.Company AND (DD.VendorId = VM.VendorId OR DD.VendorId = 'ALL')
		INNER JOIN DocumentTypes DT ON DD.Fk_DocumentTypeId = DT.DocumentTypeId
		INNER JOIN Parameters PA ON PA.Company = 'ALL' AND PA.ParameterCode = 'DRIVERDOCUMENTSWEB'
		INNER JOIN Parameters P2 ON P2.Company = 'ALL' AND P2.ParameterCode = 'DRIVERSIMAGINGPATH'
WHERE	CASE WHEN DD.BatchId LIKE '%DD%' AND FileName LIKE '%CK%' THEN 0
			 WHEN DD.BatchId LIKE '%CK%' AND FileName LIKE '%DD%' THEN 0
		ELSE 1 END = 1
		AND DD.VendorId <> 'ALL'
UNION
SELECT	DD.DriverDocumentId
		,DD.Company
		,IIF(DD.VendorId = 'ALL' , VM.VendorId, DD.VendorId) AS VendorId
		,DD.BatchId
		,DD.WeekEndingDate
		,TM.Fk_DocumentTypeId
		,RTRIM(PA.VarC) + CASE WHEN TM.VendorId = 'ALL' THEN DD.Company ELSE RTRIM(DD.VendorId) END + '/' + TM.FileName AS DocumentName
		,RTRIM(P2.VarC) + CASE WHEN TM.VendorId = 'ALL' THEN DD.Company ELSE RTRIM(DD.VendorId) END + '\' + TM.FileName AS SharedDocumentName
		,DT.DocumentType
		,DT.Sort
		,CASE WHEN DT.Category = 1 THEN 'Owner Operator Payroll' ELSE 'Driver File Related' END AS Category
		,VM.PaidByPayCard
		,VM.Agent
		,VM.Division
		,TM.FileFixed
		,VM.NewOOSDate
FROM	DriverDocuments DD
		INNER JOIN DriverDocuments TM ON DD.Company = TM.Company AND DD.WeekEndingDate = TM.WeekEndingDate AND TM.VendorId = 'ALL' AND TM.Fk_DocumentTypeId = 5
		INNER JOIN VendorMaster VM ON DD.Company = VM.Company AND DD.VendorId = VM.VendorId
		INNER JOIN DocumentTypes DT ON TM.Fk_DocumentTypeId = DT.DocumentTypeId
		INNER JOIN Parameters PA ON PA.Company = 'ALL' AND PA.ParameterCode = 'DRIVERDOCUMENTSWEB'
		INNER JOIN Parameters P2 ON P2.Company = 'ALL' AND P2.ParameterCode = 'DRIVERSIMAGINGPATH'
WHERE	CASE WHEN DD.BatchId LIKE '%DD%' AND DD.FileName LIKE '%CK%' THEN 0
			 WHEN DD.BatchId LIKE '%CK%' AND DD.FileName LIKE '%DD%' THEN 0
		ELSE 1 END = 1
		AND DD.VendorId <> 'ALL'
		AND DD.Fk_DocumentTypeId = 1
		AND VM.TerminationDate IS Null
		) DATA
GO


