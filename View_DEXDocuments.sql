USE [FB]
GO

/****** Object:  View [dbo].[View_DEXDocuments]    Script Date: 9/1/2020 9:45:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
SELECT * FROM View_DEXDocuments WHERE ProjectId = 42 and field3 = '0000557235'
SELECT * FROM View_DEXDocuments WHERE DocumentID = 218000
SELECT * FROM View_DEXDocuments WHERE Field4 = '2011-741'
*/
ALTER VIEW [dbo].[View_DEXDocuments]
AS
SELECT	DAT.*
		,RST.StepNumber
		,RST.StepName
		,DRO.ByUserID AS RoutedByUserID
		,DRO.Status AS RoutedStatus
		,DRO.Completed
		,DRO.RouteStepID
		,DRO.Finished
FROM	(
		SELECT	FIL.ProjectID
				,PRO.ProjectName
				,DOC.FileID
				,DOC.DocumentID
				,DOC.CategoryID
				,DOC.DividerName
				,DOC.DateFiled
				,DOC.UserFiled
				,DOC.Description
				,DOC.Extension
				,CAST('\\PRIFBFILE01P\Filebound_Docs\' + dbo.PADR(CASE WHEN DOC.DocumentID > 999999 THEN '0' ELSE '00' END + LEFT(CAST(DOC.DocumentID AS Varchar), CASE WHEN DOC.DocumentID > 999999 THEN 4 ELSE 3 END), 8, '0') + '\' + CAST(DOC.DocumentID AS Varchar(10)) + '.' + RTRIM(DOC.Extension) AS Varchar(100)) AS FullFileName
				,DOC.Pages
				,DOC.SortOrder
				,DOC.Contents
				,DOC.FileSize
				,DOC.LastView
				,DOC.AnnoSize
				,DOC.EformID
				,DOC.EformDue
				,DOC.EformComplete
				,DOC.ProcessStepID
				,DOC.Separator
				,DOC.RevDocumentID
				,DOC.Locked
				,DOC.DocPtr
				,DOC.BatchDate
				,DOC.Cleaned
				,DOC.DocDate
				,DOC.Encrypted
				,DOC.Secured
				,DOC.DocText
				,DOC.ArchiveID
				,DOC.Archive
				,DOC.FTTimestamp
				,DOC.RelProjectID
				,DOC.DateCreated
				,DOC.UserCreated
				,FIL.Status
				,FIL.Notes
				,FIL.DateChanged
				,FIL.Destruction
				,FIL.Field1
				,FIL.Field2
				,FIL.Field3
				,FIL.Field4
				,FIL.Field5
				,FIL.Field6
				,FIL.Field7
				,FIL.Field8
				,FIL.Field9
				,FIL.Field10
				,FIL.DateStarted
				,FIL.LabelPrinted
				,FIL.UpdateFieldValueOld
				,FIL.CheckDone
				,FIL.BoxID
				,FIL.Field11
				,FIL.Field12
				,FIL.Field13
				,FIL.Field14
				,FIL.Field15
				,FIL.Field16
				,FIL.Field17
				,FIL.Field18
				,FIL.Field19
				,FIL.Field20
				,FIL.FilePtr
				,FIL.RemoteID
				,FIL.ChangedBy AS EnteredBy
				,USR.UserName AS UserId
				,USR.Contact AS UserName
				,EXT.PropertyValue
				,EXT.KeyGroup1
				,EXT.KeyGroup2
				,EXT.KeyGroup3
				,EXT.KeyGroup4
				,EXT.KeyGroup5
				,EXT.KeyGroup6
				,EXT.KeyGroup7
				,EXT.KeyGroup8
				,EXT.KeyGroup9
				,EXT.KeyGroup10
				,EXT.ExtendedPropertyID
				,DocumentRouteId = (SELECT MAX(DRO.DocumentRouteID) AS DocumentRouteID FROM DocumentRoute DRO WHERE DRO.DocumentID = DOC.DocumentID)
				,'https://apimaging.imcc.com/v7/Output/Viewer.ashx?ProjectID=' + CAST(FIL.ProjectID AS Varchar) + '&FileID=' + CAST(FIL.FileID AS Varchar) + '&DocumentID=' + CAST(DOC.DocumentID AS Varchar) + '&ShowFileViewer=true' AS FileBoundLink
		FROM	Documents DOC
				INNER JOIN Files FIL ON DOC.FileID = FIL.FileID
				INNER JOIN Projects PRO ON FIL.ProjectID = PRO.ProjectID
				LEFT JOIN ExtendedProperties EXT ON DOC.FileID = EXT.ObjectID AND EXT.PropertyKey = 'GL_Code_Entry' --AND FIL.Field17 = EXT.PropertyValue --AND CAST(FIL.Field5 AS Numeric(10,2)) = CAST(EXT.KeyGroup4 AS Numeric(10,2))
				LEFT JOIN Users USR ON FIL.ChangedBy = USR.UserID
		WHERE	DOC.Extension <> 'LNK'
		) DAT
		LEFT JOIN DocumentRoute DRO ON DAT.DocumentRouteId = DRO.DocumentRouteId
		LEFT JOIN RouteSteps RST ON DRO.RouteStepID = RST.RouteStepID


GO


