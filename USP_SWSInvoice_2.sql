/****** Object:  StoredProcedure [dbo].[USP_SWSInvoice]    Script Date: 4/9/2020 2:01:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWSInvoice 'GIS', '2-260562'
*/
ALTER PROCEDURE [dbo].[USP_SWSInvoice]
    @Company	Varchar(5),
	@ProNumber	Varchar(25)
AS
SET NOCOUNT ON

DECLARE @Query		Varchar(MAX),
		@CompanyNum	Int,
		@Customer	Varchar(15),
		@Message1	Varchar(50),
		@Message2	Varchar(50),
		@Message3	Varchar(50),
		@Message4	Varchar(50),
		@Message5	Varchar(50),
		@Address1	Varchar(50),
		@Address2	Varchar(50),
		@Address3	Varchar(50),
		@IsExxon	Bit = 0

SET @CompanyNum = (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WHERE CompanyId = @Company)
SET @Customer	= (SELECT TOP 1 CustomerNumber FROM IntegrationsDB.Integrations.dbo.View_Integration_FSI_Full WHERE Company = @Company AND InvoiceNumber = @ProNumber)

DECLARE	@tblExxon Table
		( CustomerId VARCHAR(15))

DECLARE @tblDataFromPostgres Table
        ( inv_code VARCHAR(20)
        , applyto VARCHAR(20)
        , div_code VARCHAR(2)
        , pro VARCHAR(9)
        , sinv_code VARCHAR(20)
        , bt_code VARCHAR(6)
        , btname VARCHAR(30)
        , btaddr1 VARCHAR(30)
        , btaddr2 VARCHAR(30)
        , btcity VARCHAR(20)
        , btst_code VARCHAR(2)
        , btzip VARCHAR(10)
        , bol VARCHAR(20)
        , paydate DATE
        , ok2prt CHAR(1)
        , prtdate DATE
        , ok2inv CHAR(1)
        , cmpy_no INT
        , or_no INT
        , pdate DATE
        , ptime TIME
        , brokerage_order_id BIGINT
        , [no] INT
        , shzip VARCHAR(10)
        , cnzip VARCHAR(10)
        , eq_code VARCHAR(10)
        , eqchkdig CHAR(1)
        , code VARCHAR(6)
        , doccodes VARCHAR(36)
        , sumrefer CHAR(1)
        , sumdocs VARCHAR(25)
        , prtinv CHAR(1)
        , use210 CHAR(1)
        , ordertype CHAR(2))

INSERT INTO @tblExxon
SELECT	CustNmbr
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	Exxon = 1
		AND CustNmbr = @Customer

IF (SELECT COUNT(*) FROM @tblExxon) > 0
BEGIN
	SET @IsExxon = 1

	SELECT	@Message1 = VarC
	FROM	PRISQL01P.GPCustom.dbo.Parameters
	WHERE	ParameterCode = 'EXXON_INVOICE_01'

	SELECT	@Message2 = VarC
	FROM	PRISQL01P.GPCustom.dbo.Parameters
	WHERE	ParameterCode = 'EXXON_INVOICE_02'

	SELECT	@Message3 = VarC
	FROM	PRISQL01P.GPCustom.dbo.Parameters
	WHERE	ParameterCode = 'EXXON_INVOICE_03'

	SELECT	@Message4 = VarC
	FROM	PRISQL01P.GPCustom.dbo.Parameters
	WHERE	ParameterCode = 'EXXON_INVOICE_04'

	SELECT	@Message5 = VarC
	FROM	PRISQL01P.GPCustom.dbo.Parameters
	WHERE	ParameterCode = 'EXXON_INVOICE_05'

	SELECT	@Address1 = VarC
	FROM	PRISQL01P.GPCustom.dbo.Parameters
	WHERE	ParameterCode = 'EXXON_ADDRESS_1'

	SELECT	@Address2 = VarC
	FROM	PRISQL01P.GPCustom.dbo.Parameters
	WHERE	ParameterCode = 'EXXON_ADDRESS_2'

	SELECT	@Address3 = VarC
	FROM	PRISQL01P.GPCustom.dbo.Parameters
	WHERE	ParameterCode = 'EXXON_ADDRESS_3'
END

SET @Query = N'SELECT Invoice.code as inv_code, Invoice.applyto, Invoice.div_code, Invoice.pro, Invoice.sinv_code, Invoice.bt_code, Invoice.btname, Invoice.btaddr1, Invoice.btaddr2, Invoice.btcity, Invoice.btst_code, Invoice.btzip, Invoice.bol, Invoice.paydate, Invoice.ok2prt, Invoice.prtdate, Invoice.ok2inv, Invoice.cmpy_no, Invoice.or_no, Invoice.pdate, Invoice.ptime, Invoice.brokerage_order_id, trk.order.no, trk.order.shzip, trk.order.cnzip, Invoice.eq_code, Invoice.eqchkdig, com.billto.code, com.billto.doccodes, com.billto.sumrefer, com.billto.sumdocs, com.billto.prtinv, com.billto.use210, trk.order.type as ordertype FROM trk.invoice as Invoice Left Outer Join trk.order on trk.order.no = Invoice.or_no and trk.order.cmpy_no = Invoice.cmpy_no LEFT OUTER JOIN com.billto on com.billto.code = Invoice.bt_code and com.billto.cmpy_no = Invoice.cmpy_no WHERE Invoice.cmpy_no = ' + CAST(@CompanyNum AS Varchar) + ' AND Invoice.code = ''' + @ProNumber + ''''
            
INSERT INTO @tblDataFromPostgres
EXECUTE [dbo].[USP_QuerySWS] @Query

SELECT	RemitData.Agent AS CompanyID
		, PGData.no AS OrderID
		, Details.BatchId
		, Details.DetailId
		, Details.ReceivedOn
		, CAST(Details.ReceivedOn AS DATE) AS ReceivedDate
		, Details.Status
		, @ProNumber AS ProNumber
		, PGData.div_code AS Division
		, PGData.pro AS Pro
		, Details.[Original_InvoiceNumber] AS [InvoiceNumber]
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
		, IIF(@IsExxon = 1, @Address1, PGData.btaddr1) AS BillTo_Addr1
		, IIF(@IsExxon = 1, @Address2, PGData.btaddr2) AS BillTo_Addr2
		, IIF(@IsExxon = 1, @Address3, REPLACE(PGData.btcity + ', ' + PGData.btst_code + ' ' + PGData.btzip, '  ', ' ')) AS BillTo_Addr3
		, PGData.btcity AS BillTo_City
		, PGData.btst_code AS BillTo_State
		, PGData.btzip AS BillTo_Zip
		, PGData.eq_code AS EquipmentNo
		, [PGData].[eqchkdig] AS Equipment_chkdig
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
		, CASE WHEN [RecordType] = 'EQP' THEN [RecordCode]
				ELSE Details.Reference
		END AS Reference
		, Details.ChargeAmount1
		, Details.ChargeAmount2
		, CASE WHEN [RecordType] = 'EQP' THEN 'SPQ'
				ELSE Details.ReferenceCode
		END AS ReferenceCode
		, Details.Verification
		, Details.Processed
		, Details.VndIntercompany
		, Details.VendorDocument
		, PGData.sumrefer AS Sum_PrintInvoice
		, PGData.sumdocs AS Sum_Docs
		, PGData.brokerage_order_id
		, [PGData].[ordertype] AS [OrderType]
		, CASE WHEN [Details].[InvoiceType] <> 'C'
					AND [PGData].[ok2prt] = 'Y'
					AND [PGData].[prtinv] = 'Y'
					AND [PGData].[use210] = 'N' THEN 'Y'
				ELSE 'N'
		END AS PrintStatus
		, @Message1 AS Message1
		, @Message2 AS Message2
		, @Message3 AS Message3
		, @Message4 AS Message4
		, @Message5 AS Message5
INTO	#InvoiceData
FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI_Full AS Details
		INNER JOIN @tblDataFromPostgres AS PGData ON Details.[Original_InvoiceNumber] = PGData.inv_code AND LEFT([Details].[BatchId], CHARINDEX('F' , [Details].[BatchId]) - 1) = [PGData].[cmpy_no]
		INNER JOIN [ADG].[sws].[cmpys] AS RemitData ON PGData.cmpy_no = RemitData.Agent AND RemitData.Company = @Company
WHERE	(([ordertype] = 'R' AND Details.RecordType NOT IN ('TRK','VND'))
		OR ([ordertype] <> 'R'AND Details.RecordType NOT IN ('EQP','TRK','VND'))
		OR ([ordertype] IS NULL AND Details.RecordType NOT IN ('EQP','TRK','VND')))
		AND [Details].[Original_InvoiceNumber] = @ProNumber
		AND [Details].Company = @Company

/* Actual Results */  
DECLARE @EQCheck AS INTEGER

SELECT	@EQCheck = COUNT(*)
FROM	[#InvoiceData]
WHERE	[RecordType] = 'EQP'

PRINT '@EQCheck: ' + CAST(@EQCheck AS VARCHAR(100))
IF @EQCheck = 0 
    BEGIN
        SELECT	*
        FROM	[#InvoiceData]
    END 
ELSE 
    BEGIN
        SELECT	*
        INTO	#Test_Part_1
        FROM	[#InvoiceData]

        SELECT	*
        INTO	#Test_Part_2
        FROM	[#Test_Part_1]
  
        DELETE	[#Test_Part_1]
        WHERE	[RecordType] = 'EQP';

        WITH    EQP AS (
                        SELECT	RANK() OVER (ORDER BY [RecordCode]) [ID]
								, [EQ].*
						FROM	[#Test_Part_2] AS EQ
                        WHERE	[RecordType] = 'EQP'
                        )
        SELECT	*
        INTO	#Test_Part_3
        FROM	[EQP]

        DECLARE @rowct				INTEGER,
				@Reference			NVARCHAR(MAX),
				@ReferenceStorage	NVARCHAR(MAX),
				@MoneyHolder		MONEY,
				@Charge1			MONEY = 0,
				@Charge2			MONEY = 0,
				@curRow				INTEGER = 0,
				@addCt				INTEGER = 0
  
        SELECT	@rowct = COUNT(ID)
        FROM	#Test_Part_3

        PRINT @rowct

        WHILE @curRow <= @rowct - 1 
            BEGIN 
                SELECT	@Reference = LTRIM(RTRIM([Reference]))
                FROM	[#Test_Part_3]
                WHERE	[ID] = (@rowct - @curRow)

                SET @ReferenceStorage = CASE WHEN LEN(@Reference) = 10 THEN CASE WHEN @ReferenceStorage IS NULL THEN @Reference
                                                        ELSE CONCAT(@ReferenceStorage, REPLICATE(' ', 4), @Reference) END
                                                ELSE CASE WHEN @ReferenceStorage IS NULL THEN CONCAT(@Reference,REPLICATE(' ', 1))
                                                        ELSE CONCAT(@ReferenceStorage, REPLICATE(' ', 5) , @Reference) END 
										END
                SELECT	@MoneyHolder = [ChargeAmount1]
                FROM	[#Test_Part_3]
                WHERE	[ID] = (@rowct - @curRow)

                SET		@Charge1 = SUM(@Charge1 + @MoneyHolder)
                SET		@MoneyHolder = 0

                SELECT	@MoneyHolder = [ChargeAmount2]
                FROM	[#Test_Part_3]
                WHERE	[ID] = @rowct - @curRow

                SET @Charge2 = SUM(@Charge2 + @MoneyHolder)
                SET @MoneyHolder = 0
                SET @addCt = @addCt + 1

                IF @addCt = 4 
                    BEGIN
                        INSERT INTO [#Test_Part_1]
                        SELECT	DISTINCT [CompanyID]
								, [OrderID]
								, [BatchId]
								, [DetailId]
								, [ReceivedOn]
								, [ReceivedDate]
								, [Status]
								, [ProNumber]
								, [Division]
								, [Pro]
								, [InvoiceNumber]
								, [InvoiceDate]
								, [InvoiceType]
								, [S_InvoiceNumber]
								, [doccodes]
								, [Shipper_Name]
								, [Shipper_City]
								, [Shipper_Zip]
								, [Consignee_Name]
								, [Consignee_City]
								, [Consignee_Zip]
								, [BillTo]
								, [BillTo_Code]
								, [BillTo_Addr1]
								, [BillTo_Addr2]
								, [BillTo_Addr3]
								, [BillTo_City]
								, [BillTo_State]
								, [BillTo_Zip]
								, [EquipmentNo]
								, [Equipment_chkdig]
								, [BillTo_Ref]
								, [bol]
								, [DeliveryDate]
								, [PaymentDue]
								, [InvoiceTotal]
								, [ok2prt]
								, [PrintDate]
								, [ok2inv]
								, [_PrintInvoice]
								, [Remit_Name]
								, [Remit_Addr1]
								, [Remit_Addr2]
								, [Remit_City]
								, [Remit_State]
								, [Remit_Postal]
								, [Inquiry_Name]
								, [Inquiry_Addr1]
								, [Inquiry_Addr2]
								, [Inquiry_City]
								, [Inquiry_State]
								, [Inquiry_Postal]
								, [Inquiry_Phone]
								, [Inquiry_Fax]
								, [Img_Name]
								, [einvoicing_email]
								, [ApplyTo]
								, [RecordStatus]
								, [Imaged]
								, [Printed]
								, [Emailed]
								, [FSI_ReceivedHeaderId]
								, [FSI_ReceivedDetailId]
								, [_Use210]
								, 'EQP'
								, 'EQP'
								, @ReferenceStorage
								, @Charge1
								, @Charge2
								, 'SPQ'
								, [Verification]
								, [Processed]
								, [VndIntercompany]
								, [VendorDocument]
								, [Sum_PrintInvoice]
								, [Sum_Docs]
								, [brokerage_order_id]
								, [OrderType]
								, [PrintStatus]
                        FROM	[#Test_Part_1]

                        SET @ReferenceStorage = NULL
                        SET @Charge1 = 0
                        SET @Charge2 = 0
                        SET @addCt = 0  
                    END

                SET @curRow = @curRow + 1
            END

        SELECT	*
        FROM	[#Test_Part_1]
  
        DROP TABLE [#Test_Part_1]
        DROP TABLE [#Test_Part_2]
        DROP TABLE [#Test_Part_3]        
    END  


DROP TABLE [#InvoiceData]