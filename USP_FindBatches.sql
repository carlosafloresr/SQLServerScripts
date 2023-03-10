USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindBatches]    Script Date: 6/8/2017 1:58:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindBatches 'IMC', '06/08/2017'
*/
ALTER PROCEDURE [dbo].[USP_FindBatches]
	@Company	Varchar(5),
	@BatchDate	Datetime
AS
SELECT	DISTINCT BachNumb 
FROM	PM10300 
WHERE	Company = @Company 
		AND DocDate BETWEEN dbo.DayFwdBack(@BatchDate,'P','Monday') AND dbo.DayFwdBack(@BatchDate,'N','Sunday')
		AND (BachNumb LIKE '%DD' OR BachNumb LIKE '%CK')
		--AND (BachNumb LIKE '%CK%' OR BachNumb LIKE '%DD%')