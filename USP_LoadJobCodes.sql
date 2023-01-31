USE [MobileEstimates]
GO

/****** Object:  StoredProcedure [dbo].[USP_LoadJobCodes]    Script Date: 10/05/2012 8:20:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
EXECUTE USP_LoadJobCodes 'TIRES', 'REPLACE', 'SP'
*/
ALTER PROCEDURE [dbo].[USP_LoadJobCodes]
		@Category		Varchar(20),
		@SubCategory	Varchar(25),
		@Languaje		Char(2) = 'EN'
AS
SELECT	DISTINCT ChildCode, 
		RTRIM(ChildCode) + ' - ' + CASE WHEN @Languaje = 'EN' THEN RTRIM(EnglishText) ELSE RTRIM(SpanishText) END AS ChildDescription 
FROM	View_CodeRelations_Full 
WHERE	RelationType = 'JC' 
		AND Category = @Category
		AND SubCategory = @SubCategory
		AND ChildCode IN (
						SELECT	ParentCode 
						FROM	View_CodeRelations
						WHERE	RelationType = 'RC' 
								AND Category = @Category
								AND SubCategory = @SubCategory
						)
ORDER BY 2
GO


