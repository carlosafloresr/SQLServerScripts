USE [FI_Data]
GO
/****** Object:  StoredProcedure [dbo].[USP_LocationDocumentsList]    Script Date: 10/14/2009 15:29:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_LocationDocumentsList]
AS
SELECT	*
FROM	(
		SELECT	DISTINCT 0 AS LocationDocumentId
				,LocationId AS NodeId
				,LocationId AS DocumentName
				,Null AS DocType
				,Null AS DocName
				,Null AS BatchId
				,1 AS Category
				,'root' AS Parent
		FROM	LocationDocuments 
		WHERE	Fk_FI_DocumentId IS NULL
		UNION		
		SELECT	DISTINCT 0
				,RTRIM(LocationId) + RTRIM(Mechanic)
				,Mechanic
				,Null
				,Null
				,Null
				,2 AS Category
				,LocationId
		FROM	LocationDocuments 
		WHERE	Fk_FI_DocumentId IS NULL
		UNION
		SELECT	DISTINCT 0
				,RTRIM(LocationId) + RTRIM(Mechanic) + CONVERT(Char(10), ScanDate, 101)
				,CONVERT(Char(10), ScanDate, 101)
				,Null
				,Null
				,Null
				,3 AS Category
				,RTRIM(LocationId) + RTRIM(Mechanic)
		FROM	LocationDocuments 
		WHERE	Fk_FI_DocumentId IS NULL
		UNION
		SELECT	LocationDocumentId
				,'NOD_' + RTRIM(CAST(LocationDocumentId AS Varchar(10))) AS NodeId
				,'File ' + CAST(ROW_NUMBER() OVER (PARTITION BY LocationId, Mechanic, CONVERT(Char(10), ScanDate, 101) ORDER BY LocationId, Mechanic, ScanDate) AS Varchar(20))
				,DocType
				,DocName
				,BatchId
				,4 AS Category
				,RTRIM(LocationId) + RTRIM(Mechanic) + CONVERT(Char(10), ScanDate, 101) AS Parent
		FROM	LocationDocuments 
		WHERE	Fk_FI_DocumentId IS NULL) RECS
ORDER BY 
		Category
		,DocumentName
		
/*
EXECUTE USP_LocationDocumentsList
*/