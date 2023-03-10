USE [ADG]
GO
/****** Object:  StoredProcedure [revAcct].[Invoice_SSRS_SummarizedInvoicing_v3]    Script Date: 10/24/2022 2:41:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE revAcct.Invoice_SSRS_SummarizedInvoicing_v4 1, '1FSI20221019_1515_SUM', 1
*/
ALTER PROCEDURE [revAcct].[Invoice_SSRS_SummarizedInvoicing_v4]
		@CompanyID		Int,
  		@BatchOrInvoice Varchar(25),
		@ShowDebugData	Bit = 0
AS 
BEGIN
    SET NOCOUNT ON
    
	DECLARE @Duration AS DATETIME = GETDATE()

    PRINT 'Step 1: Setting Variables @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))
            
    DECLARE @AvailRows			FLOAT = 32,
			@TotalRows			FLOAT,
			@RoundedNumber		FLOAT,
			@BlankRows			INT,
			@NumInvoices		INT,
			@AdditionalInfo		INT,     
			@EqCount			INT,
			@S_InvoiceTotal		MONEY,
			@OriginialBatchID	VARCHAR(25),
			@BatchID			VARCHAR(25),
			@PostgresQuery		NVARCHAR(MAX),
			@PostgresQuery2		NVARCHAR(MAX),
			@invoicingDate		DATE
           
    PRINT 'Step 1: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
    PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
    PRINT '***********************************************************' + CHAR(10)   

    SET @Duration = GETDATE()
    PRINT 'Step 2:Getting BatchID and Post Date and Time @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))
            
    IF PATINDEX('%SUM%' , @BatchOrInvoice) = 0 
    BEGIN
		SELECT	@OriginialBatchID = [BatchId]
        FROM	[IntegrationsDB].Integrations.dbo.View_Integration_FSI_Full
        WHERE	[InvoiceNumber] = @BatchOrInvoice
    END
    ELSE 
    BEGIN
        SELECT	@OriginialBatchID = [BatchId]
        FROM	[IntegrationsDB].Integrations.dbo.View_Integration_FSI_Full
        WHERE	[BatchId] = @BatchOrInvoice			 
    END

    SET @BatchID = LEFT(@OriginialBatchID , LEN(@OriginialBatchID) - 4)

    DECLARE @PostDate AS DATE
    DECLARE @PostTime AS TIME

    IF RIGHT(@BatchID , 4) = '_SUM' 
    BEGIN
        SET @PostDate = CAST(LEFT(RIGHT(@BatchID , 17) , 8) AS DATE)
        SET @PostTime = CAST(LEFT(RIGHT(RIGHT(@BatchID , 17) , 8), 2) + ':' + RIGHT(LEFT(RIGHT(@BatchID , 17) , 13) , 2) AS TIME)
    END
    ELSE
    BEGIN
        SET @PostDate = CAST(LEFT(RIGHT(@BatchID , 13) , 8) AS DATE)
        SET @PostTime = CAST(LEFT(RIGHT(RIGHT(@BatchID , 13) , 4), 2) + ':' + RIGHT(RIGHT(RIGHT(@BatchID , 13) , 4) , 2) AS TIME)
    END      
          
    PRINT CHAR(9) + '@BatchOrInvoice: ' + @BatchOrInvoice
    PRINT CHAR(9) + 'BatchID: ' + @BatchID
    PRINT CHAR(9) + 'Originial BatchID: ' + @OriginialBatchID
    PRINT CHAR(9) + 'PostDate: ' + CAST(@PostDate AS VARCHAR(15))
    PRINT CHAR(9) + 'PostTime: ' + CAST(@PostTime AS VARCHAR(25))
    PRINT 'Step 2: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
    PRINT CAST('Section Time Taken: '+ RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
    PRINT '***********************************************************' + CHAR(10) 
  
    BEGIN 
        SET @Duration = GETDATE()
        PRINT 'Step 3: Pulling SWS Data @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))

        SET @PostgresQuery = 'SELECT * INTO ##GetData2 FROM OPENQUERY(PostgreSQLProd,''SELECT Invoice.code as inv_code, Invoice.applyto, Invoice.div_code, Invoice.pro, Invoice.sinv_code, Invoice.invdate, Invoice.bt_code, Invoice.btname, Invoice.btaddr1, Invoice.btaddr2, Invoice.btcity, Invoice.btst_code, Invoice.btzip, Invoice.bol, Invoice.paydate, Invoice.ok2prt, Invoice.prtdate, Invoice.ok2inv, Invoice.cmpy_no, Invoice.or_no, Invoice.pdate, Invoice.ptime, Invoice.brokerage_order_id, trk.order.no, trk.order.shzip, trk.order.cnzip, trk.order.billtl_code, trk.order.billtl_chkdig, com.billto.code, com.billto.doccodes, com.billto.sumrefer, com.billto.sumdocs, com.billto.prtinv, com.billto.use210 FROM trk.invoice as Invoice Left Outer Join trk.order on trk.order.no = Invoice.or_no and trk.order.cmpy_no = Invoice.cmpy_no Left Outer Join com.billto on com.billto.code = Invoice.bt_code and com.billto.cmpy_no = Invoice.cmpy_no WHERE Invoice.pdate = '''''
            + CAST(@PostDate AS VARCHAR(15)) + ''''' AND Invoice.cmpy_no = '''''
            + CAST(@CompanyID AS VARCHAR(2)) + ''''' AND Invoice.ptime = ''''' + CAST(@PostTime AS VARCHAR(25)) + ''''''')'
			 
        PRINT 'Step 3: PG Query @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CHAR(9) + @PostgresQuery 
        PRINT 'Step 3: Executing Query @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
            
        EXECUTE(@PostgresQuery)
		  
        PRINT 'Step 3: Saving Data To Temp Table @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
            
        SELECT * INTO #TempDataFromPostgres FROM ##GetData2
		
        PRINT 'Step 3: Dropping Temp Table @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
            
        DROP TABLE ##GetData2
           
        BEGIN 
            IF @ShowDebugData = 1 
				SELECT 'Step 3:', * FROM #TempDataFromPostgres

            PRINT 'Step 3: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
            PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
            PRINT '***********************************************************' + CHAR(10)
        END
    END		

    BEGIN 
        SET @Duration = GETDATE()
		PRINT 'Step 4: Combining SWS and Integrations For Complete Invoice Data @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))
	
        SELECT	TOP 1 @invoicingDate = [invdate]
        FROM	#TempDataFromPostgres
	          		
        SELECT	RemitData.Agent AS CompanyID
				, PGData.no AS OrderID
				, Details.BatchId
				, Details.DetailId
				, Details.ReceivedOn
				, CAST(Details.ReceivedOn AS DATE) AS ReceivedDate
				, Details.Status
				, [ADG].[sws].[DivPro_To_ProNumber](PGData.div_code, PGData.pro, 1) AS ProNumber
				, PGData.div_code AS Division
				, PGData.pro AS Pro
				, Details.InvoiceNumber
				, Details.InvoiceDate
				, Details.InvoiceType
				, PGData.sinv_code AS S_InvoiceNumber
				, PGData.doccodes
				, Details.ShipperName AS Shipper_Name
				, Details.ShipperCity AS Shipper_City
				, PGData.shzip AS Shipper_Zip
				, Details.ConsigneeName AS Consignee_Name
				, Details.ConsigneeCity AS Consignee_City
				, PGData.cnzip AS Consignee_Zip
				, PGData.btname AS BillTo
				, Details.CustomerNumber AS BillTo_Code
				, PGData.btaddr1 AS BillTo_Addr1
				, PGData.btaddr2 AS BillTo_Addr2
				, PGData.btcity + ', ' + PGData.btst_code + ' ' + PGData.btzip AS BillTo_Addr3
				, PGData.btcity AS BillTo_City
				, PGData.btst_code AS BillTo_State
				, PGData.btzip AS BillTo_Zip
				, PGData.billtl_code AS TrailerNo
				, Details.BillToRef AS BillTo_Ref
				, PGData.bol	
				, Details.DeliveryDate
				, PGData.paydate AS PaymentDue 
				, Details.InvoiceTotal
				, PGData.ok2prt
				, PGData.prtdate AS PrintDate
				, PGData.ok2inv
				, PGData.prtinv AS _PrintInvoice
				, RemitData.Remit_Name
				, RemitData.Remit_Addr1
				, RemitData.Remit_Addr2
				, RemitData.Remit_City
				, RemitData.Remit_State
				, RemitData.Remit_Postal
				, RemitData.Inquiry_Name
				, RemitData.Inquiry_Addr1
				, RemitData.Inquiry_Addr2
				, RemitData.Inquiry_City
				, RemitData.Inquiry_State
				, RemitData.Inquiry_Postal
				, RemitData.Inquiry_Phone
				, RemitData.Inquiry_Fax
				, RemitData.Img_Name
				, RemitData.einvoicing_email
				, Details.ApplyTo
				, Details.RecordStatus
				, Details.Imaged
				, Details.Printed
				, Details.Emailed
				, Details.FSI_ReceivedHeaderId
				, Details.FSI_ReceivedDetailId
				, PGData.use210 AS _Use210
				, Details.RecordType
				, Details.RecordCode
				, Details.Reference
				, Details.ChargeAmount1
				, Details.ChargeAmount2
				, Details.ReferenceCode
				, Details.Verification
				, Details.Processed
				, Details.VndIntercompany
				, Details.VendorDocument
				, PGData.sumrefer AS Sum_PrintInvoice
				, PGData.sumdocs AS Sum_Docs
				, PGData.brokerage_order_id
				, CASE WHEN [Details].[InvoiceType] <> 'C'
							AND [PGData].[ok2prt] = 'Y'
							AND [PGData].[prtinv] = 'Y'
							AND [PGData].[use210] = 'N' THEN 'Y'
						ELSE 'N' END AS PrintStatus
        INTO	#InvoiceData
		FROM	[IntegrationsDB].Integrations.dbo.View_Integration_FSI_Full AS Details
				INNER JOIN [#TempDataFromPostgres] AS PGData ON Details.InvoiceNumber = PGData.inv_code AND LEFT([Details].[BatchId], CHARINDEX('F' , [Details].[BatchId]) - 1) = [PGData].[cmpy_no]
				INNER JOIN [ADG].[sws].[cmpys] AS RemitData ON PGData.cmpy_no = RemitData.Agent
        WHERE	Details.RecordType NOT IN ('EQP','TRK','VND')
				AND [Details].[InvoiceDate] = @invoicingDate
				AND [Details].[BatchId] = @OriginialBatchID

        IF @ShowDebugData = 1 
            SELECT 'Step 4:', * FROM [#InvoiceData]
        
        PRINT 'Step 4: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
        PRINT '***********************************************************' + CHAR(10)
    END        

    BEGIN 
        SET @Duration = GETDATE()
        PRINT 'Step 5: Getting Invoice Equipment Data From SWS @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))

        DECLARE @sinv_code AS NVARCHAR(MAX)

        IF CHARINDEX('-' , @BatchOrInvoice) > 0 
            SET @sinv_code = '''''' + @BatchOrInvoice + ''''''
        ELSE 
            SELECT	@sinv_code = COALESCE(@sinv_code + ', ' , '') + '''''' + [inv_code] + ''''''
			FROM	#TempDataFromPostgres

        PRINT 'Step 5: Executing Query @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        
        SET @PostgresQuery2 = 'SELECT * INTO ##GetData FROM OPENQUERY(PostgreSQLProd,''SELECT
						"Invoices".cmpy_no AS cmpy_no,
						"Orders". NO AS OrderID,
						"Invoices".code As Code,
						"Invoices".div_code AS Division,
						"Invoices".pro, CAST(CASE WHEN LEFT ("Invoices".div_code, 1) = ''''' + '0' + ''''' THEN RIGHT ("Invoices".div_code, 1)
						 ELSE "Invoices".div_code END || ''''' + '-' + ''''' || "Invoices".pro as varchar(100)) AS pronumber,
						"Invoices".sinv_code,
						"Invoices".invdate,
						"Bill_To".doccodes,
						"Orders".shzip,
						"Orders".cnzip,
						"Invoices".btname,
						"Invoices".bt_code,
						cast ("Invoices".btaddr1 as varchar(100)),
						"Invoices".btaddr2,
						cast (( "Invoices".btcity || ''''' + ', ' + ''''' || "Invoices".btst_code || ''''' + ' ' + ''''' || "Invoices".btzip ) as varchar(100)) AS btaddr3,
						"Invoices".btcity,
						"Invoices".btst_code,
						"Invoices".btzip,
						cast ( "Orders".billtl_code || "Orders".billtl_chkdig as varchar(100) ) AS TrailerNo,
						"Invoices".bol,
						"Invoices".paydate AS PaymentDue,
						"Invoices".ok2prt,
						"Invoices".prtdate AS PrintDate,
						"Invoices".ok2inv,
						"Bill_To".prtinv AS _PrintInvoice,
						"Bill_To".use210 AS _Use210,
						"Bill_To".sumrefer AS Sum_PrintInvoice,
						"Bill_To".sumdocs AS Sum_Docs,
						"Invoices".brokerage_order_id,
						"Equipment".eq_code AS Equipment,
						"Equipment".total AS EqTotal,
						"Equipment".fscamt AS EqFscamt
						FROM com.billto AS "Bill_To"
							 LEFT OUTER JOIN trk.invoice AS "Invoices" ON "Bill_To".code = "Invoices".bt_code AND "Bill_To".cmpy_no = "Invoices".cmpy_no
							 LEFT OUTER JOIN trk."order" AS "Orders" ON "Invoices".or_no = "Orders"."no" AND "Invoices".cmpy_no = "Orders".cmpy_no
							 LEFT OUTER JOIN trk.invequip AS "Equipment" ON "Equipment".inv_code = CASE
						WHEN LEFT ("Invoices".div_code, 1) = ''''' + '0' + ''''' THEN RIGHT ("Invoices".div_code, 1) ELSE "Invoices".div_code END || ''''' + '-' + ''''' || "Invoices".pro 
						WHERE "Invoices".cmpy_no = ''''' + CAST(@CompanyID AS VARCHAR) + '''''
						AND "Invoices".sinv_code IN (' + CAST(@sinv_code AS VARCHAR) + ') '')'

        PRINT 'Step 5: PG Query @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CHAR(9) + @PostgresQuery2        
        PRINT 'Step 5: Executing Query @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
            
        EXECUTE(@PostgresQuery2)

        PRINT 'Step 5: Saving Data To Temp Table @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))

        SELECT * INTO #SummaryData FROM ##GetData

        IF @ShowDebugData = 1
            SELECT 'Step 5:', * FROM [#SummaryData]
        
		PRINT 'Step 5: Dropping Temp Table @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
            
        DROP TABLE ##GetData
           
        PRINT 'Step 5: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
        PRINT '***********************************************************' + CHAR(10)
    END

    BEGIN 
        SET @Duration = GETDATE()

        PRINT 'Step 6: Getting BillTo Code and Min & Max Invoice Datess @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))
        
        DECLARE @invoice_btcode AS VARCHAR(15)
        DECLARE @invoice_mindate AS DATETIME
        DECLARE @invoice_maxdate AS DATETIME

        SELECT	DISTINCT @invoice_btcode = [bt_code]
        FROM	[#SummaryData]

        SELECT	@invoice_mindate = MIN([invdate])
        FROM	[#SummaryData]

        SELECT	@invoice_maxdate = MAX([invdate])
        FROM	[#SummaryData]
				
		PRINT '@invoice_mindate set to:' + RTRIM(CAST(@invoice_mindate AS CHAR(10)))
		PRINT '@invoice_maxdate set to:' + RTRIM(CAST(@invoice_maxdate AS CHAR(10)))
           
        IF @ShowDebugData = 1 
            SELECT	'Step 6:' AS [Step]
                    , @invoice_btcode AS [BillTo Code]
                    , @invoice_mindate AS [Min Date]
                    , @invoice_maxdate AS [MAX Date]
                         
        PRINT 'Step 6: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
        PRINT 'The retrieving of the MIN and MAX Dates is to only limit the records coming from Integrations TO speed up process'
        PRINT '***********************************************************' + CHAR(10)
    END

    BEGIN 
        SET @Duration = GETDATE()
        PRINT 'Step 7: @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))

        SELECT	Companies.Agent AS CompanyID
				, [Data].orderid AS OrderID
				, Details.BatchId
				, Details.DetailId
				, Details.ReceivedOn
				, CAST(Details.ReceivedOn AS DATE) AS ReceivedDate
				, Details.Status
				, [ADG].[sws].[DivPro_To_ProNumber]([Data].division, [Data].pro, 1) AS ProNumber
				, [Data].division AS Division
				, [Data].pro
				, Details.InvoiceNumber
				, Details.InvoiceDate
				, Details.InvoiceType
				, [Data].sinv_code AS S_InvoiceNumber
				, [Data].doccodes
				, [ADG].dbo.PROPER(Details.ShipperName) AS Shipper_Name
				, [ADG].dbo.PROPER(Details.ShipperCity) AS Shipper_City
				, [Data].shzip AS Shipper_Zip
				, [ADG].dbo.PROPER(Details.ConsigneeName) AS Consignee_Name
				, [ADG].dbo.PROPER(Details.ConsigneeCity) AS Consignee_City
				, [Data].cnzip AS Consignee_Zip
				, [Data].btname AS BillTo
				, Details.CustomerNumber AS BillTo_Code
				, [Data].btaddr1 AS BillTo_Addr1
				, [Data].btaddr2 AS BillTo_Addr2
				, [Data].btcity + ', ' + [Data].btst_code + ' ' + [Data].btzip AS BillTo_Addr3
				, [Data].btcity AS BillTo_City
				, [Data].btst_code AS BillTo_State
				, [Data].btzip AS BillTo_Zip
				, [Data].TrailerNo
				, Details.BillToRef AS BillTo_Ref
				--, CASE WHEN [Details].[CustomerNumber] <> 'E1042' THEN [Data].bol ELSE Details.BillToRef END AS [BOL]
				, CASE WHEN [Details].[CustomerNumber] not in ( 'E1042' ,'5496')  THEN [Data].bol ELSE Details.BillToRef END AS [BOL]
				, Details.DeliveryDate
				, [Data].PaymentDue AS PaymentDue
				, Details.InvoiceTotal
				, [Data].ok2prt
				, [Data].PrintDate AS PrintDate
				, [Data].ok2inv
				, [Data]._PrintInvoice AS _PrintInvoice
				, Companies.Remit_Name
				, Companies.Remit_Addr1
				, Companies.Remit_Addr2
				, Companies.Remit_City
				, Companies.Remit_State
				, Companies.Remit_Postal
				, Companies.Inquiry_Name
				, Companies.Inquiry_Addr1
				, Companies.Inquiry_Addr2
				, Companies.Inquiry_City
				, Companies.Inquiry_State
				, Companies.Inquiry_Postal
				, Companies.Inquiry_Phone
				, Companies.Inquiry_Fax
				, Companies.Img_Name
				, Companies.einvoicing_email
				, Details.ApplyTo
				, Details.RecordStatus
				, Details.Imaged
				, Details.Printed
				, Details.Emailed
				, [Data]._Use210 AS _Use210
				, Details.RecordType
				, Details.RecordCode
				, Details.Reference
				, Details.ChargeAmount1
				, Details.ChargeAmount2
				, Details.ReferenceCode
				, Details.Verification
				, Details.Processed
				, Details.VndIntercompany
				, Details.VendorDocument
				, [Data].Sum_PrintInvoice AS Sum_PrintInvoice
				, [Data].Sum_Docs AS Sum_Docs
				, [Data].brokerage_order_id
				, CASE WHEN Details.InvoiceType <> 'C'
							AND [Data].ok2prt = 'Y'
							AND [Data]._PrintInvoice = 'Y'
							AND [Data]._Use210 = 'N' THEN 'Y'
						ELSE 'N' END AS PrintStatus
				, [Data].Equipment AS Equipment
				, [Data].EqTotal AS EqTotal
				, [Data].EqFscamt AS EqFscamt
        INTO	#PulledData
        FROM	[#SummaryData] AS Data
				LEFT OUTER JOIN [ADG].[sws].[cmpys] AS Companies WITH (NOLOCK) ON Data.cmpy_no = Companies.Agent
				LEFT OUTER JOIN [IntegrationsDB].[Integrations].dbo.View_Integration_FSI_Full AS Details WITH (NOLOCK) ON Details.InvoiceNumber = CAST(Data.code AS Varchar) AND REPLACE(Details.Company, ' ', '') = Companies.Company AND Details.RecordType NOT IN ('EQP','TRK','VND')
        WHERE	[Details].[InvoiceDate] BETWEEN @invoice_mindate AND @invoice_maxdate
				AND [Details].[CustomerNumber] = @invoice_btcode

        IF @ShowDebugData = 1 
			SELECT 'Step 7:', * FROM #PulledData

        PRINT 'Step 7: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
        PRINT '***********************************************************' + CHAR(10)
    END

    BEGIN 
        SET @Duration = GETDATE()
        PRINT 'Step 8: Creating Temp Staging Table @ '+ CAST(CAST(@Duration AS TIME) AS VARCHAR(100))

        CREATE TABLE #SummaryTable_New (
              CompanyID INT
            , OrderID INT
            , BatchId VARCHAR(25)
            , DetailId CHAR(10)
            , ReceivedOn SMALLDATETIME
            , ReceivedDate DATE
            , Status INT
            , ProNumber VARCHAR(15)
            , Division VARCHAR(2)
            , pro VARCHAR(9)
            , InvoiceNumber VARCHAR(20)
            , InvoiceDate DATETIME
            , InvoiceType CHAR(1)
            , S_InvoiceNumber VARCHAR(20)
            , doccodes NVARCHAR(36)
            , Shipper_Name NVARCHAR(4000)
            , Shipper_City NVARCHAR(4000)
            , Shipper_Zip VARCHAR(10)
            , Consignee_Name NVARCHAR(4000)
            , Consignee_City NVARCHAR(4000)
            , Consignee_Zip VARCHAR(10)
            , BillTo VARCHAR(30)
            , BillTo_Code VARCHAR(10)
            , BillTo_Addr1 VARCHAR(30)
            , BillTo_Addr2 VARCHAR(30)
            , BillTo_Addr3 VARCHAR(35)
            , BillTo_City VARCHAR(20)
            , BillTo_State VARCHAR(2)
            , BillTo_Zip VARCHAR(10)
            , TrailerNo VARCHAR(11)
            , BillTo_Ref VARCHAR(50)
            , BOL VARCHAR(50)
            , DeliveryDate DATETIME
            , PaymentDue DATE
            , InvoiceTotal MONEY
            , ok2prt VARCHAR(1)
            , PrintDate DATE
            , ok2inv VARCHAR(1)
            , _PrintInvoice NVARCHAR(1)
            , Remit_Name VARCHAR(50)
            , Remit_Addr1 VARCHAR(50)
            , Remit_Addr2 VARCHAR(50)
            , Remit_City VARCHAR(50)
            , Remit_State VARCHAR(3)
            , Remit_Postal VARCHAR(50)
            , Inquiry_Name VARCHAR(50)
            , Inquiry_Addr1 VARCHAR(50)
            , Inquiry_Addr2 VARCHAR(50)
            , Inquiry_City VARCHAR(50)
            , Inquiry_State VARCHAR(3)
            , Inquiry_Postal VARCHAR(50)
            , Inquiry_Phone VARCHAR(50)
            , Inquiry_Fax VARCHAR(20)
            , Img_Name VARCHAR(20)
            , einvoicing_email VARCHAR(100)
            , ApplyTo VARCHAR(25)
            , RecordStatus SMALLINT
            , Imaged BIT
            , Printed BIT
            , Emailed BIT
            , _Use210 VARCHAR(1)
            , RecordType CHAR(3)
            , RecordCode VARCHAR(10)
            , Reference VARCHAR(60)
            , ChargeAmount1 MONEY
            , ChargeAmount2 MONEY
            , ReferenceCode CHAR(10)
            , Verification VARCHAR(50)
            , Equipment VARCHAR(10)
            , EqTotal NUMERIC(16 , 2)
            , EqFscamt NUMERIC(16 , 2) )
           
        PRINT 'Step 8: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
        PRINT '***********************************************************' + CHAR(10)
    END  
  
    BEGIN
		SET @Duration = GETDATE()

		PRINT 'Step 9: Inserting Report Header Data Into Staging Table @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))
		PRINT 'Step 9: Checking If We Have A BatchID or Invoice Number @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
            
        IF CHARINDEX('-' , @BatchOrInvoice) > 0 
        BEGIN
            PRINT 'Step 9: Value Was A BatchID @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
            PRINT 'Step 9: Inserting @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))

            INSERT INTO #SummaryTable_New
            SELECT	DISTINCT [Details].[CompanyID]
					, [Details].[OrderID]
					, [Details].[BatchId]
					, [Details].[DetailId]
					, [Details].[ReceivedOn]
					, [Details].[ReceivedDate]
					, [Details].[Status]
					, [Details].[ProNumber]
					, [Details].[Division]
					, [Details].[pro]
					, [Details].[InvoiceNumber]
					, [Details].[InvoiceDate]
					, [Details].[InvoiceType]
					, [Details].[S_InvoiceNumber]
					, [Details].[doccodes]
					, [Details].[Shipper_Name]
					, [Details].[Shipper_City]
					, [Details].[Shipper_Zip]
					, [Details].[Consignee_Name]
					, [Details].[Consignee_City]
					, [Details].[Consignee_Zip]
					, [Details].[BillTo]
					, [Details].[BillTo_Code]
					, [Details].[BillTo_Addr1]
					, [Details].[BillTo_Addr2]
					, [Details].[BillTo_Addr3]
					, [Details].[BillTo_City]
					, [Details].[BillTo_State]
					, [Details].[BillTo_Zip]
					, [Details].[TrailerNo]
					, [Details].[BillTo_Ref]
					, [Details].[BOL]
					, [Details].[DeliveryDate]
					, [Details].[PaymentDue]
					, [Details].[InvoiceTotal]
					, [Details].[ok2prt]
					, [Details].[PrintDate]
					, [Details].[ok2inv]
					, [Details].[_PrintInvoice]
					, [Details].[Remit_Name]
					, [Details].[Remit_Addr1]
					, [Details].[Remit_Addr2]
					, [Details].[Remit_City]
					, [Details].[Remit_State]
					, [Details].[Remit_Postal]
					, [Details].[Inquiry_Name]
					, [Details].[Inquiry_Addr1]
					, [Details].[Inquiry_Addr2]
					, [Details].[Inquiry_City]
					, [Details].[Inquiry_State]
					, [Details].[Inquiry_Postal]
					, [Details].[Inquiry_Phone]
					, [Details].[Inquiry_Fax]
					, [Details].[Img_Name]
					, [Details].[einvoicing_email]
					, [Details].[ApplyTo]
					, [Details].[RecordStatus]
					, [Details].[Imaged]
					, [Details].[Printed]
					, [Details].[Emailed]
					, [Details].[_Use210]
					, [Details].[RecordType]
					, [Details].[RecordCode]
					, [Details].[Reference]
					, [Details].[ChargeAmount1]
					, [Details].[ChargeAmount2]
					, [Details].[ReferenceCode]
					, [Details].[Verification]
					, ''
					, 0
					, 0
            FROM	[#InvoiceData] AS Details
            WHERE	[InvoiceNumber] = @BatchOrInvoice
                
            PRINT 'Step 9: Insert Complete @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        END
        ELSE 
        BEGIN
            PRINT 'Step 9: Value Was A Invoice Number @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
            PRINT 'Step 9: Inserting @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
                
            INSERT INTO #SummaryTable_New
            SELECT	DISTINCT [Details].[CompanyID]
					, [Details].[OrderID]
					, [Details].[BatchId]
					, [Details].[DetailId]
					, [Details].[ReceivedOn]
					, [Details].[ReceivedDate]
					, [Details].[Status]
					, [Details].[ProNumber]
					, [Details].[Division]
					, [Details].[pro]
					, [Details].[InvoiceNumber]
					, [Details].[InvoiceDate]
					, [Details].[InvoiceType]
					, [Details].[S_InvoiceNumber]
					, [Details].[doccodes]
					, [Details].[Shipper_Name]
					, [Details].[Shipper_City]
					, [Details].[Shipper_Zip]
					, [Details].[Consignee_Name]
					, [Details].[Consignee_City]
					, [Details].[Consignee_Zip]
					, [Details].[BillTo]
					, [Details].[BillTo_Code]
					, [Details].[BillTo_Addr1]
					, [Details].[BillTo_Addr2]
					, [Details].[BillTo_Addr3]
					, [Details].[BillTo_City]
					, [Details].[BillTo_State]
					, [Details].[BillTo_Zip]
					, [Details].[TrailerNo]
					, [Details].[BillTo_Ref]
					, [Details].[BOL]
					, [Details].[DeliveryDate]
					, [Details].[PaymentDue]
					, [Details].[InvoiceTotal]
					, [Details].[ok2prt]
					, [Details].[PrintDate]
					, [Details].[ok2inv]
					, [Details].[_PrintInvoice]
					, [Details].[Remit_Name]
					, [Details].[Remit_Addr1]
					, [Details].[Remit_Addr2]
					, [Details].[Remit_City]
					, [Details].[Remit_State]
					, [Details].[Remit_Postal]
					, [Details].[Inquiry_Name]
					, [Details].[Inquiry_Addr1]
					, [Details].[Inquiry_Addr2]
					, [Details].[Inquiry_City]
					, [Details].[Inquiry_State]
					, [Details].[Inquiry_Postal]
					, [Details].[Inquiry_Phone]
					, [Details].[Inquiry_Fax]
					, [Details].[Img_Name]
					, [Details].[einvoicing_email]
					, [Details].[ApplyTo]
					, [Details].[RecordStatus]
					, [Details].[Imaged]
					, [Details].[Printed]
					, [Details].[Emailed]
					, [Details].[_Use210]
					, [Details].[RecordType]
					, [Details].[RecordCode]
					, [Details].[Reference]
					, [Details].[ChargeAmount1]
					, [Details].[ChargeAmount2]
					, [Details].[ReferenceCode]
					, [Details].[Verification]
					, ''
					, 0
					, 0
            FROM	[#InvoiceData] AS Details
            WHERE	[BatchId] = @BatchID
        END
           
        IF @ShowDebugData = 1 
            SELECT 'Step 9:', * FROM #SummaryTable_New
                
        PRINT 'Step 9: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
        PRINT '***********************************************************' + CHAR(10)
    END
  
    SET @Duration = GETDATE()

    PRINT 'Step 10: Update Statement: Updating Invoice Number @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))
		         
    UPDATE #SummaryTable_New SET [S_InvoiceNumber] = [InvoiceNumber]
           
    IF @ShowDebugData = 1 
        SELECT 'Step 10:' , * FROM #SummaryTable_New
                
    PRINT 'Step 10: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
    PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
    PRINT '***********************************************************' + CHAR(10)
    	
    BEGIN 
        SET @Duration = GETDATE()        
		PRINT 'Step 11: Inserting Report Header Data Into Staging Table @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))
        
        INSERT INTO #SummaryTable_New
        SELECT	DISTINCT [Details].[CompanyID]
                , [Details].[OrderID]
                , @OriginialBatchID AS BatchID
                , [Details].[DetailId]
                , [Details].[ReceivedOn]
                , [Details].[ReceivedDate]
                , [Details].[Status]
                , [Details].[ProNumber]
                , [Details].[Division]
                , [Details].[pro]
                , [Details].[InvoiceNumber]
                , [Details].[InvoiceDate]
                , [Details].[InvoiceType]
                , [Details].[S_InvoiceNumber]
                , [Details].[doccodes]
                , [Details].[Shipper_Name]
                , [Details].[Shipper_City]
                , [Details].[Shipper_Zip]
                , [Details].[Consignee_Name]
                , [Details].[Consignee_City]
                , [Details].[Consignee_Zip]
                , [Details].[BillTo]
                , [Details].[BillTo_Code]
                , [Details].[BillTo_Addr1]
                , [Details].[BillTo_Addr2]
                , [Details].[BillTo_Addr3]
                , [Details].[BillTo_City]
                , [Details].[BillTo_State]
                , [Details].[BillTo_Zip]
                , CAST([Details].[TrailerNo] AS VARCHAR(MAX)) AS [TrailerNo]
                , [Details].[BillTo_Ref]
                , [Details].[BOL]
                , [Details].[DeliveryDate]
                , [Details].[PaymentDue]
                , [Details].[InvoiceTotal]
                , [Details].[ok2prt]
                , [Details].[PrintDate]
                , [Details].[ok2inv]
                , [Details].[_PrintInvoice]
                , [Details].[Remit_Name]
                , [Details].[Remit_Addr1]
                , [Details].[Remit_Addr2]
                , [Details].[Remit_City]
                , [Details].[Remit_State]
                , [Details].[Remit_Postal]
                , [Details].[Inquiry_Name]
                , [Details].[Inquiry_Addr1]
                , [Details].[Inquiry_Addr2]
                , [Details].[Inquiry_City]
                , [Details].[Inquiry_State]
                , [Details].[Inquiry_Postal]
                , [Details].[Inquiry_Phone]
                , [Details].[Inquiry_Fax]
                , [Details].[Img_Name]
                , [Details].[einvoicing_email]
                , [Details].[ApplyTo]
                , [Details].[RecordStatus]
                , [Details].[Imaged]
                , [Details].[Printed]
                , [Details].[Emailed]
                , [Details].[_Use210]
                , [Details].[RecordType]
                , [Details].[RecordCode]
                , [Details].[Reference]
                , SUM([Details].[ChargeAmount1]) AS [ChargeAmount1]
                , SUM([Details].[ChargeAmount2]) AS [ChargeAmount2]
                , [Details].[ReferenceCode]
                , [Details].[Verification]
                , [Details].Equipment
                , SUM([Details].EqTotal) AS EqTotal
                , SUM([Details].EqFscamt) AS EqFscamt
        FROM	#PulledData AS Details
        WHERE	Details.RecordType NOT IN ('EQP','TRK','VND')
		GROUP BY [Details].[CompanyID]
                , [Details].[OrderID]
                , BatchID
                , [Details].[DetailId]
                , [Details].[ReceivedOn]
                , [Details].[ReceivedDate]
                , [Details].[Status]
                , [Details].[ProNumber]
                , [Details].[Division]
                , [Details].[pro]
                , [Details].[InvoiceNumber]
                , [Details].[InvoiceDate]
                , [Details].[InvoiceType]
                , [Details].[S_InvoiceNumber]
                , [Details].[doccodes]
                , [Details].[Shipper_Name]
                , [Details].[Shipper_City]
                , [Details].[Shipper_Zip]
                , [Details].[Consignee_Name]
                , [Details].[Consignee_City]
                , [Details].[Consignee_Zip]
                , [Details].[BillTo]
                , [Details].[BillTo_Code]
                , [Details].[BillTo_Addr1]
                , [Details].[BillTo_Addr2]
                , [Details].[BillTo_Addr3]
                , [Details].[BillTo_City]
                , [Details].[BillTo_State]
                , [Details].[BillTo_Zip]
                , CAST([Details].[TrailerNo] AS VARCHAR(MAX))
                , [Details].[BillTo_Ref]
                , [Details].[BOL]
                , [Details].[DeliveryDate]
                , [Details].[PaymentDue]
                , [Details].[InvoiceTotal]
                , [Details].[ok2prt]
                , [Details].[PrintDate]
                , [Details].[ok2inv]
                , [Details].[_PrintInvoice]
                , [Details].[Remit_Name]
                , [Details].[Remit_Addr1]
                , [Details].[Remit_Addr2]
                , [Details].[Remit_City]
                , [Details].[Remit_State]
                , [Details].[Remit_Postal]
                , [Details].[Inquiry_Name]
                , [Details].[Inquiry_Addr1]
                , [Details].[Inquiry_Addr2]
                , [Details].[Inquiry_City]
                , [Details].[Inquiry_State]
                , [Details].[Inquiry_Postal]
                , [Details].[Inquiry_Phone]
                , [Details].[Inquiry_Fax]
                , [Details].[Img_Name]
                , [Details].[einvoicing_email]
                , [Details].[ApplyTo]
                , [Details].[RecordStatus]
                , [Details].[Imaged]
                , [Details].[Printed]
                , [Details].[Emailed]
                , [Details].[_Use210]
                , [Details].[RecordType]
                , [Details].[RecordCode]
                , [Details].[Reference]
                , [Details].[ReferenceCode]
                , [Details].[Verification]
                , [Details].Equipment
  
        SELECT * INTO #SummarizedInvoicing FROM #SummaryTable_New

        DROP TABLE #SummaryTable_New
        DROP TABLE [#SummaryData]
        DROP TABLE #PulledData
			
		IF @ShowDebugData = 1 
			SELECT 'Step 11:' , * FROM #SummarizedInvoicing

        PRINT 'Step 11: Terminated @ '+ CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CAST('Section Time Taken: '+ RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10)))+ 'sec(s)' AS VARCHAR(50))
        PRINT '***********************************************************' + CHAR(10)
    END

    BEGIN 
        SET @Duration = GETDATE()
        
		PRINT 'Step 12: Formatting Data for Reporting @ ' + CAST(CAST(@Duration AS TIME) AS VARCHAR(100))
		
        SELECT @S_InvoiceTotal = [InvoiceTotal] FROM #SummarizedInvoicing WHERE [CompanyID] = @CompanyID AND [InvoiceType] = 'S'
			
		IF ISNULL(@S_InvoiceTotal, '') = ''  
			IF PATINDEX('%SUM%' , @BatchOrInvoice) = 0 
			BEGIN
				SELECT	TOP 1 @S_InvoiceTotal = [InvoiceTotal]				
				FROM	[IntegrationsDB].Integrations.dbo.View_Integration_FSI_Full 
				WHERE	invoicenumber = @BatchOrInvoice
						AND company = (SELECT TOP 1 company FROM [sws].[cmpys] WHERE companyid = @CompanyID)
			END
			ELSE
			BEGIN
				SELECT	TOP 1 @S_InvoiceTotal = [InvoiceTotal]
				FROM	[IntegrationsDB].Integrations.dbo.View_Integration_FSI_Full 
				WHERE	batchid = @BatchOrInvoice
						AND company = (SELECT TOP 1 company FROM [sws].[cmpys] WHERE companyid = @CompanyID)
			END
			 
        IF @ShowDebugData = 1 
            SELECT 'Step 12: Get Summary Total' , @S_InvoiceTotal AS [@S_InvoiceTotal]

        DECLARE @Data_inv_code AS VARCHAR(20)

        SELECT TOP 1 @Data_inv_code = [S_InvoiceNumber] FROM #SummarizedInvoicing
			 
        IF @ShowDebugData = 1 
            SELECT 'Step 12: Getting InvCode' , @Data_inv_code AS [@Data_inv_code]

        SELECT @NumInvoices = COUNT(DISTINCT [InvoiceNumber]) * 2 FROM #SummarizedInvoicing WHERE [InvoiceType] <> 'S'

        PRINT 'Step 12: Calculations @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CHAR(9) + 'Number of Invoices: ' + CAST(@NumInvoices AS VARCHAR)
        
        SELECT	@AdditionalInfo = COUNT(*)
        FROM	(
                SELECT	DISTINCT [InvoiceNumber], [Reference]
                FROM	#SummarizedInvoicing
                WHERE	[InvoiceType] <> 'S'
                GROUP BY  [InvoiceNumber], [Reference]
				) AS [CountTbl]

        PRINT 'Step 12: Calculations @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))                
        PRINT CHAR(9) + 'Number of References: ' + CAST(@AdditionalInfo AS VARCHAR)

        SELECT @EqCount = COUNT(DISTINCT [Equipment]) FROM [#SummarizedInvoicing] WHERE [InvoiceType] <> 'S' AND [Equipment] IS NOT NULL
	
        PRINT 'Step 12: Calculations @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
		PRINT CHAR(9) + 'Number of Equipment: ' + CAST(@EqCount AS VARCHAR)

        SELECT @TotalRows = @NumInvoices + @AdditionalInfo + @EqCount FROM [#SummarizedInvoicing] WHERE [InvoiceType] <> 'S'
			 
        PRINT 'Step 12: Calculations @ '+ CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))                
        PRINT CHAR(9) + 'Total Rows: ' + CAST(@TotalRows AS VARCHAR)

        SET @RoundedNumber = CEILING(@TotalRows / @AvailRows)
            
        PRINT 'Step 12: Calculations @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))                
        PRINT CHAR(9) + 'Multiple By: '+ CAST(@RoundedNumber AS VARCHAR)
        
        SET @BlankRows = ( @AvailRows * @RoundedNumber ) - @TotalRows
            
        PRINT 'Step 12: Calculations @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CHAR(9) + 'Needed Blank Rows: ' + CAST(@BlankRows AS VARCHAR)

        SELECT TOP 1 * INTO #BlankRows FROM [#SummarizedInvoicing]

        TRUNCATE TABLE [#BlankRows]

        DECLARE @Counter AS INT = 1

		PRINT 'Step 12: Blank Rows ' + CAST(@BlankRows AS Varchar)

        WHILE @Counter < @BlankRows - 1 
        BEGIN
            INSERT INTO [#BlankRows]
                    ([InvoiceNumber]
                    , [InvoiceType]
                    , [S_InvoiceNumber]
                    , [Equipment]
                    , [EqFscamt]
                    , [EqTotal])
            VALUES
                    ('99-999999'
                    , 'T'
                    , @Data_inv_code
                    , @Counter
                    , 0
                    , 0)

            SET @Counter = @Counter + 1
        END	

        SELECT	* 
		INTO	#FinalData
        FROM	[#SummarizedInvoicing]
        WHERE	[Equipment] IS NOT NULL
				OR [ChargeAmount1] <> 0

        INSERT INTO #FinalData
        SELECT	*
        FROM	[#BlankRows]

        SELECT	*
				, ROW_NUMBER() OVER ( ORDER BY [CompanyID] DESC ) AS Memo
				, @TotalRows AS [Rows]
				, @S_InvoiceTotal AS [S_Invoice_Total]
				, LEN(Reference) AS [DetailsLength]
        FROM	[#FinalData]
        ORDER BY CASE InvoiceType
                WHEN 'S' THEN 1
                WHEN 'A' THEN 2
				WHEN 'D' THEN 3
                WHEN 'T' THEN 4 END
           
        PRINT 'Step 12: Terminated @ ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(100))
        PRINT CAST('Section Time Taken: ' + RTRIM(CAST(DATEDIFF(s , @Duration , GETDATE()) AS CHAR(10))) + 'sec(s)' AS VARCHAR(50))
        PRINT '***********************************************************' + CHAR(10)
    END

    DROP TABLE [#SummarizedInvoicing]
    DROP TABLE [#BlankRows]
    DROP TABLE [#FinalData]
END
