USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_QuerySWS]    Script Date: 2/5/2020 10:45:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_QuerySWS_ReportData 'SELECT code, description FROM public.dmsite WHERE code <> '''' ORDER BY description'
EXECUTE USP_QuerySWS_ReportData 'SELECT Eq_Code, EqChkDig FROM TRK.Invoice WHERE Cmpy_No = 4 AND Code = ''39-147223'''
EXECUTE USP_QuerySWS_ReportData 'SELECT Code, Description FROM trk.doccode WHERE CatId <> 0 AND Code NOT IN (''WO'', ''EIRO'', ''EIRI'', ''ST'', ''MEMO'', ''BOL'', ''DE'') ORDER BY Code'
*/
CREATE PROCEDURE [dbo].[USP_QuerySWS_ReportData] (@Request Varchar(MAX), @CursorName Varchar(30) = Null, @LinkServer Varchar(30) = Null)
AS
DECLARE	@Query	Varchar(MAX),
		@Query2	Varchar(MAX)

print(@query)
IF @LinkServer IS Null
	SET @LinkServer = 'PostgreSQLPROD'

IF @CursorName IS Null
BEGIN
	SET	@Query = N'SELECT * FROM OPENQUERY(' + @LinkServer + ',''' + REPLACE(@Request, '''', '''''') + ''')'
	EXECUTE(@Query)
END
ELSE
BEGIN
	SET	@Query2 = N'SELECT * INTO ' + @CursorName + ' FROM OPENQUERY(' + @LinkServer + ', ''' + REPLACE(@Request, '''', '''''') + ''')'
	EXECUTE(@Query2)
END
