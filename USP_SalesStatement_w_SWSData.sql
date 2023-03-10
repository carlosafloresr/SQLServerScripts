USE [GIS]
GO
/****** Object:  StoredProcedure [dbo].[USP_SalesStatement_w_SWSData]    Script Date: 12/22/2022 10:15:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
====================================================================================================================
Author:			Jonathan M Hare
Create date:	4/16/2014
Description:	Combines GP Sales Statement to SWS Data for CSR Name, Equipment, and Delivery Date
====================================================================================================================
Modified by:	Carlos A. Flores
Modify Date:	10/19/2022
Change:			The equipment check digit has been pulled from SWS and added under the final billtl_code field
				and the "Ref #" has been removed from the description.
====================================================================================================================
EXECUTE USP_SalesStatement_w_SWSData '4386C', 2
EXECUTE USP_SalesStatement_w_SWSData '552A', 4
====================================================================================================================
Modified by: Tina Gerlich
Modify Date: 12/15/2022
Change: Add DueDate and PastDue from GP RM20101 per request #471321 RE: RM Statement Report
====================================================================================================================
*/
ALTER PROCEDURE [dbo].[USP_SalesStatement_w_SWSData]
		@CustomerNumber	Varchar(10),
		@CompanyID		Int
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @CompanyName	Nvarchar(5),
			@i				Integer = 1,
			@numrows		Integer,
			@ProNumber		Nvarchar(15),
			@Divison		Nvarchar(2),
			@GPQuery		Nvarchar(MAX)
			--@CompanyID INT = 1,
			--@CustomerNumber Varchar(10) = '3100'

	SET @CompanyName = (SELECT CompanyId FROM GPCustom.DBO.View_CompanyAgents WHERE CompanyNumber = @CompanyID)
    SET @CustomerNumber = LTRIM(RTRIM(@CustomerNumber))
--select top 10 * from rm20101
	IF OBJECT_ID('tempdb..##tempSalesStatement') IS NOT NULL 
		DROP TABLE ##tempSalesStatement

    SET @GPQuery = 'SELECT  ROW_NUMBER() OVER ( ORDER BY [DOCDATE], [DOCNUMBR] DESC ) AS ROW
    ,[CUSTNMBR]
    ,[DOCDATE]
    ,[DOCNUMBR]
    ,[TRXDSCRN]
    ,[ORTRXAMT]
    ,[CURTRXAM]
	,[DUEDATE]
    ,CASE WHEN CHARINDEX(''-'' , [DOCNUMBR]) = 2 AND LEFT([DOCNUMBR], 1) <> ''S'' THEN ''0'' + [DOCNUMBR]
            WHEN CHARINDEX(''-'' , [DOCNUMBR]) = 4
            THEN CASE WHEN LEN(RIGHT(RTRIM(LTRIM([DOCNUMBR])) ,
                                    LEN([DOCNUMBR]) - 1)) > 8
                    THEN LEFT(RIGHT(RTRIM(LTRIM([DOCNUMBR])) ,
                                    LEN([DOCNUMBR]) - 1) , 9)
                    ELSE RIGHT(RTRIM(LTRIM([DOCNUMBR])) ,
                                LEN([DOCNUMBR]) - 1)
                END
            ELSE [DOCNUMBR] END SWSInvoice
    ,RIGHT(REPLACE(CASE WHEN LEN(SUBSTRING([DOCNUMBR] , 1 ,
                                    CHARINDEX(''-'' , [DOCNUMBR]) - 1)) = 1 AND LEFT([DOCNUMBR], 1) <> ''S'' 
                    THEN ''0'' + SUBSTRING([DOCNUMBR] , 1 ,
                                        CHARINDEX(''-'' , [DOCNUMBR]) - 1)
                    ELSE SUBSTRING([DOCNUMBR] , 1 ,
                                CHARINDEX(''-'' , [DOCNUMBR]) - 1)
            END, ''D'' , ''0''), 2) AS Division
    ,SUBSTRING([DOCNUMBR], CHARINDEX(''-'', [DOCNUMBR]) + 1, LEN([DOCNUMBR]) - CHARINDEX(''-'' , [DOCNUMBR])) AS Pro
	INTO ##tempSalesStatement
FROM [' + @CompanyName + '].[dbo].[RM20101]
WHERE [CUSTNMBR] = ''' + @CustomerNumber + ''' AND [CURTRXAM] > 0 AND LEFT([DOCNUMBR], 1) <> ''C'' AND CHARINDEX(''-'', [DOCNUMBR]) > 0'

    EXECUTE(@GPQuery)

	DECLARE @tblSWSData Table (
		pro				Varchar(10), 
		div_code		Varchar(3), 
		deldt			Date, 
		billtl_code		Varchar(15), 
		billtl_chkdig	Int, 
		origby			Varchar(30))

    SET @numrows = (SELECT COUNT(*) FROM [##tempSalesStatement])
		
    IF @numrows > 0
	BEGIN
        WHILE @i <= @numrows
        BEGIN			
            SET @ProNumber = (SELECT CASE WHEN @CompanyName = 'NDS' THEN SUBSTRING([Pro], 0, CHARINDEX('_' , [Pro])) ELSE [Pro] END AS [Pro] FROM [##tempSalesStatement] WHERE [ROW] = @i)
			SET @ProNumber = LEFT(@ProNumber, patindex('%[^0-9]%', @ProNumber + '.') - 1) -- this removes the '-A' or any other non-numeric values from the pronumber
            SET @Divison = (SELECT [Division] FROM [##tempSalesStatement] WHERE [ROW] = @i)
				
			--IF @CompanyName = 'NDS' 
			--	SET @CompanyID = (SELECT SUBSTRING([Pro], CHARINDEX('_', [Pro]) + 1, LEN([Pro]) - CHARINDEX('_', [Pro]) + 1) AS [Pro] FROM [##tempSalesStatement] WHERE [ROW] = @i)
			PRINT @ProNumber
			UPDATE	[##tempSalesStatement] 
			SET		[Pro] = @ProNumber,
					[TRXDSCRN] = REPLACE(REPLACE(TRXDSCRN, 'Ref # ', ''), 'Ref #', '')
			WHERE	[ROW] = @i

			-- bt_code condition unneccessary?
			DECLARE @POSTGRES NVarchar(MAX) = 'SELECT * FROM OPENQUERY(PostgreSQLProd, ''SELECT pro, div_code, deldt, billtl_code, billtl_chkdig, origby FROM trk.order WHERE cmpy_no = '''''
				+ CAST(@CompanyID AS Varchar) + ''''' AND div_code = ''''' + RTRIM(@Divison) + ''''' AND pro = ''''' + RTRIM(@ProNumber) + ''''''')'
               PRINT @POSTGRES
			INSERT INTO @tblSWSData
            EXECUTE sp_executesql @POSTGRES
                
			SET @i = @i + 1	
            --PRINT CAST(@i AS NVARCHAR(5)) + ') ' + @Divison + '-' + @ProNumber
        END
	END

    SELECT  TSS.*
            ,TSD.deldt
            ,RTRIM(TSD.billtl_code) + CAST(TSD.billtl_chkdig AS Varchar) AS billtl_code
			,TSD.billtl_chkdig
            ,TSD.origby
    FROM    ##tempSalesStatement AS TSS
            LEFT JOIN @tblSWSData AS TSD ON TSD.pro = TSS.Pro AND TSD.div_code = TSS.Division
  
    DROP TABLE [##tempSalesStatement]
END
