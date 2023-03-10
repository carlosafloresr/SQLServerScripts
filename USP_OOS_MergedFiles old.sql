USE [ILS_Datawarehouse]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_MergedFiles]    Script Date: 9/24/2021 8:58:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_OOS_MergedFiles
*/
ALTER PROCEDURE [dbo].[USP_OOS_MergedFiles]
AS
SELECT	DISTINCT STL.Company, 
		STL.Weekending AS PayDate, 
		STL.Company + ',' + CONVERT(Char(10), STL.Weekending, 101) + ',' AS RunCommand
FROM	Settlements STL
		INNER JOIN DocumentBatches DOB ON STL.Company = DOB.Company AND STL.Weekending = DOB.WeekEndingDate
WHERE	DOB.MergedFiles = 0