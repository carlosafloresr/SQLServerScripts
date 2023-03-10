USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[DMS_ReceivedTransactions_Listener]    Script Date: 6/16/2022 10:02:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- EXEC DMS_ReceivedTransactions_Listener
-- SET XACT_ABORT ON
-- =============================================
ALTER PROCEDURE [dbo].[DMS_ReceivedTransactions_Listener]
AS
BEGIN
--*********************************************************************************
-- Variables
--*********************************************************************************
Declare @MyString	varchar(max),
		@MyResult1	varchar(max),
		@MyResult2	varchar(max),
		@MyString2	varchar(max)

--*********************************************************************************
-- Set the Maximum Remote Batch Number 
--*********************************************************************************
create table #temp (batch int)

SET	@MyString =	'select max(batch) AS batch from dminvoice WHERE postflag='+'''Y'''+' AND postdate IS NOT NULL'
SET	@MyString = N'INSERT INTO #temp (batch) SELECT batch FROM OPENQUERY(PostgreSQLPROD, ''' + REPLACE(@MyString, '''', '''''') + ''')'
--PRINT @MyString
EXEC ( @MyString )
SET @MyResult1 = (SELECT batch FROM #temp)
--PRINT @MyResult1

DROP TABLE #temp

--*********************************************************************************
-- Set the Maximum Local Batch Number 
--*********************************************************************************
SET @MyResult2 = (SELECT MAX(batch_no) FROM [findata-intg-ms.imcc.com].Integrations.dbo.DMS_ReceivedTransactions)
--PRINT @MyResult2

--*********************************************************************************
-- Compare the Batch Numbers
--*********************************************************************************
IF @MyResult1 > @MyResult2
BEGIN
  --PRINT 'Load a new batch'
  SET @MyString2 = 'DMS_ReceivedTransactions_Load @batch = ' + @MyResult1
  EXECUTE(@MyString2)
END
END
