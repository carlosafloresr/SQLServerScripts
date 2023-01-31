USE GPCustom
GO
/****** Object:  StoredProcedure [dbo].[USP_SalesStatement_w_SWSData]    Script Date: 10/19/2022 9:40:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
====================================================================================================================
Author:			Carlos A. Flores
Create Date:	10/19/2022
Change:			The equipment check digit has been pulled from SWS and added under the final billtl_code field
====================================================================================================================
EXECUTE USP_Customer_Statemets 'GIS','10837'
EXECUTE USP_Customer_Statemets 'AIS', '552A'
EXECUTE USP_Customer_Statemets 'DNJ', 'PD8789'
====================================================================================================================
*/
ALTER PROCEDURE [dbo].[USP_Customer_Statemets]
		@CompanyID		Varchar(5),
		@CustomerNumber	Varchar(10)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @CompanyName	Nvarchar(5),
			@i				Integer = 1,
			@numDataRows	Integer,
			@ProNumber		Nvarchar(15),
			@Divison		Nvarchar(2),
			@CmpyNumber		Int,
			@GPQuery		Nvarchar(MAX)

	DECLARE @tblGPData		Table (
			Company			Varchar(5),
			DataRow			Int,
			CUSTNMBR		Varchar(20),
			CUSTNAME		Varchar(75),
			DOCDATE			Date,
			DUEDATE			Date,
			DOCNUMBR		Varchar(30),
			TRXDSCRN		Varchar(30),
			ORTRXAMT		Numeric(10,2),
			CURTRXAM		Numeric(10,2),
			SWSInvoice		Varchar(15),
			Division		Varchar(3),
			Pro				Varchar(15))

	SET @CmpyNumber = (SELECT CompanyNumber FROM GPCustom.DBO.View_CompanyAgents WHERE CompanyId = @CompanyID)
    SET @CustomerNumber = LTRIM(RTRIM(@CustomerNumber))

    SET @GPQuery = 'SELECT  ''' + @CompanyID + ''' AS Company, ROW_NUMBER() OVER (ORDER BY DET.[DOCDATE], DET.[DOCNUMBR] DESC) AS DataRow
    ,RTRIM(DET.[CUSTNMBR])
	,RTRIM(CST.[CUSTNAME])
    ,DET.[DOCDATE]
	,DET.[DUEDATE]
    ,RTRIM(DET.[DOCNUMBR])
    ,RTRIM(DET.[TRXDSCRN])
    ,DET.[ORTRXAMT]
    ,DET.[CURTRXAM]
    ,CASE WHEN CHARINDEX(''-'',DET. [DOCNUMBR]) = 2 AND LEFT(DET.[DOCNUMBR], 1) <> ''S'' THEN ''0'' + DET.[DOCNUMBR]
            WHEN CHARINDEX(''-'', DET.[DOCNUMBR]) = 4
            THEN CASE WHEN LEN(RIGHT(RTRIM(LTRIM(DET.[DOCNUMBR])), LEN(DET.[DOCNUMBR]) - 1)) > 8
                    THEN LEFT(RIGHT(RTRIM(LTRIM(DET.[DOCNUMBR])), LEN(DET.[DOCNUMBR]) - 1), 9)
                    ELSE RIGHT(RTRIM(LTRIM(DET.[DOCNUMBR])), LEN(DET.[DOCNUMBR]) - 1) END ELSE DET.[DOCNUMBR] END SWSInvoice
    ,RIGHT(REPLACE(CASE WHEN LEN(SUBSTRING(DET.[DOCNUMBR], 1, CHARINDEX(''-'', DET.[DOCNUMBR]) - 1)) = 1 AND LEFT(DET.[DOCNUMBR], 1) <> ''S'' 
                    THEN ''0'' + SUBSTRING(DET.[DOCNUMBR], 1, CHARINDEX(''-'', DET.[DOCNUMBR]) - 1)
                    ELSE SUBSTRING(DET.[DOCNUMBR], 1, CHARINDEX(''-'', DET.[DOCNUMBR]) - 1) END, ''D'', ''0''), 2) AS Division
    ,SUBSTRING(DET.[DOCNUMBR], CHARINDEX(''-'', DET.[DOCNUMBR]) + 1, LEN(DET.[DOCNUMBR]) - CHARINDEX(''-'', DET.[DOCNUMBR])) AS Pro
FROM [' + @CompanyID + '].[dbo].[RM20101] DET
	INNER JOIN [' + @CompanyID + '].[dbo].[RM00101] CST ON DET.[CUSTNMBR] = CST.[CUSTNMBR]
WHERE DET.[CUSTNMBR] = ''' + @CustomerNumber + ''' AND DET.[CURTRXAM] > 0 AND DET.[RMDTYPAL] < 7'

	INSERT INTO @tblGPData
    EXECUTE(@GPQuery)

	DECLARE @tblSWSData Table (
		pro				Varchar(10), 
		div_code		Varchar(3), 
		deldt			Date, 
		billtl_code		Varchar(15), 
		billtl_chkdig	Int, 
		origby			Varchar(30))

    SET @numDataRows = (SELECT COUNT(*) FROM @tblGPData)
		
    IF @numDataRows > 0
        WHILE @i <= @numDataRows
        BEGIN			
            SET @ProNumber = (SELECT CASE WHEN @CompanyName = 'NDS' THEN SUBSTRING([Pro], 0, CHARINDEX('_' , [Pro])) ELSE [Pro] END AS [Pro] FROM @tblGPData WHERE [DataRow] = @i)
			SET @ProNumber = LEFT(@ProNumber, patindex('%[^0-9]%', @ProNumber + '.') - 1) -- this removes the '-A' or any other non-numeric values from the pronumber
            SET @Divison = (SELECT [Division] FROM @tblGPData WHERE [DataRow] = @i)
				
			IF @CompanyName = 'NDS' 
				SET @CompanyID = (SELECT SUBSTRING([Pro], CHARINDEX('_', [Pro]) + 1, LEN([Pro]) - CHARINDEX('_', [Pro]) + 1) AS [Pro] FROM @tblGPData WHERE [DataRow] = @i)

			UPDATE @tblGPData SET [Pro] = @ProNumber WHERE [DataRow] = @i

			-- bt_code condition unneccessary?
			DECLARE @POSTGRES NVarchar(MAX) = 'SELECT * FROM OPENQUERY(PostgreSQLProd, ''SELECT pro, div_code, deldt, billtl_code, billtl_chkdig, origby FROM trk.order WHERE cmpy_no = '''''
				+ CAST(@CmpyNumber AS Varchar) + ''''' AND div_code = ''''' + RTRIM(@Divison) + ''''' AND pro = ''''' + RTRIM(@ProNumber) + ''''''')'
                
			INSERT INTO @tblSWSData
            EXECUTE sp_executesql @POSTGRES
                
			SET @i = @i + 1	
        END

	UPDATE	@tblGPData
	SET		TRXDSCRN = REPLACE(REPLACE(TRXDSCRN, 'Ref # ', ''), 'Ref #', '')

    SELECT  TSS.Company,
			TSS.DataRow,
			TSS.CUSTNMBR,
			TSS.CUSTNAME,
			CAST(TSS.DOCDATE AS Date) AS DOCDATE,
			TSS.DUEDATE,
			DATEDIFF(DD, TSS.DUEDATE, GETDATE()) AS Days_Past,
			TSS.DOCNUMBR,
			TSS.TRXDSCRN,
			TSS.ORTRXAMT,
			TSS.CURTRXAM,
			TSS.SWSInvoice,
			TSS.Division,
			TSS.Pro,
            TSD.deldt,
            ISNULL(RTRIM(TSD.billtl_code) + CAST(TSD.billtl_chkdig AS Varchar), '') AS billtl_code,
			TSD.billtl_chkdig,
            ISNULL(TSD.origby,'') AS origby,
			DYN.CmpnyNam,
			RTRIM(DYN.Address1) + IIF(DYN.Address2 = '', '', + CHAR(13) + RTRIM(DYN.Address2)) + CHAR(13) + RTRIM(DYN.City) + ', ' + RTRIM(DYN.State) + ' ' + RTRIM(DYN.ZipCode) AS Address,
			dbo.FormatPhoneNumber(DYN.Phone1) AS Phone
    FROM    @tblGPData AS TSS
			INNER JOIN DYNAMICS.dbo.View_AllCompanies DYN ON DYN.InterId = @CompanyID
            LEFT JOIN @tblSWSData AS TSD ON TSD.pro = TSS.Pro AND TSD.div_code = TSS.Division
	ORDER BY DOCDATE, DOCNUMBR
END
