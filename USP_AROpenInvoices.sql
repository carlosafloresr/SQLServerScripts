ALTER PROCEDURE dbo.USP_AROpenInvoices
		@OnlySummary	Bit = 1,
		@DueDays		Int = Null, 
		@Customer		Varchar(20) = Null,
		@InvoiceNum		Varchar(30) = Null,
		@UserId			Varchar(25)
AS
IF @DueDays IS Null
	SET @DueDays = 90
	
IF @Customer = ''
	SET @Customer = Null

IF @InvoiceNum = ''
	SET @InvoiceNum = Null
	
SELECT	CN1.CustNmbr
		,CN1.Cprcstnm
		,GRP.CustName AS GroupName
		,CUS.CustName
		,CUS.Address1
		,CUS.Address2
		,CUS.City
		,CUS.State
		,CUS.Zip 
		,CUS.Phone1
		,CN1.DocNumbr
		,CN1.DocDate
		,CN1.OrTrxAmt
		,CN1.CurTrxAm
		,CN1.TrxDscrn
		,CN3.Amount_Promised
		,CN3.Action_Promised
		,CN3.Note_Display_String
		,CN3.CntCPrsn
		,CN3.UserId
		,CN1.BachNumb
		,DATEDIFF(DD, DocDate, GETDATE()) AS InvAge
		,NTE.NoteDate
		,NTE.Note
		,@DueDays AS RunDays
INTO	#tmpInvoices
FROM	RM20101 CN1
		LEFT JOIN CN20100 CN2 ON CN1.CustNmbr = CN2.CustNmbr AND CN1.Cprcstnm = CN2.Cprcstnm AND CN1.DocNumbr = CN2.DocNumbr
		LEFT JOIN CN00100 CN3 ON CN1.CustNmbr = CN3.CustNmbr AND CN1.Cprcstnm = CN3.Cprcstnm AND CN2.NoteIndx = CN3.NoteIndx
		LEFT JOIN RM00101 CUS ON CN1.CustNmbr = CUS.CustNmbr
		LEFT JOIN RM00101 GRP ON CN1.Cprcstnm = GRP.CustNmbr
		LEFT JOIN View_CustomerNotes NTE ON CN1.CustNmbr = NTE.CustNmbr
WHERE	CN1.DocDate < GETDATE() - @DueDays
		AND CN1.CurTrxAm > 0
		AND CN1.RmdTypal = 1
		AND (@InvoiceNum IS Null OR (@InvoiceNum IS NOT Null AND CN1.DocNumbr = @InvoiceNum))
		AND (@Customer IS Null OR (@Customer IS NOT Null AND CN1.CustNmbr = @Customer))
	
SELECT	*
INTO	#tmpInvoicesData
FROM	(
		SELECT	CN1.CustNmbr
				,CN1.Cprcstnm
				,CN1.GroupName
				,CN1.CustName
				,CN1.Address1
				,CN1.Address2
				,CN1.City
				,CN1.State
				,CN1.Zip 
				,CN1.Phone1
				,CN1.DocNumbr
				,CN1.DocDate
				,CN1.OrTrxAmt
				,CN1.CurTrxAm
				,CN1.TrxDscrn
				,CN1.Amount_Promised
				,CN1.Action_Promised
				,CN1.Note_Display_String
				,CN1.CntCPrsn
				,CN1.UserId
				,CN1.BachNumb
				,FSI.InvoiceNumber
				,FSI.BilltoRef
				,FSI.InvoiceDate
				,FSI.InvoiceTotal
				,FSI.ShipperName
				,FSI.ShipperCity
				,FSI.ConsigneeName
				,FSI.ConsigneeCity
				,FSI.RecordType
				,FSI.RecordCode
				,FSI.Reference
				,ISNULL(FSI.ChargeAmount1, 0.00) AS ChargeAmount1
				,EquipmentId = CASE WHEN FSI.InvoiceNumber IS Null THEN (SELECT TOP 1 FS2.RecordCode FROM ILSINT01.Integrations.dbo.View_Integration_FSI_Full FS2 WHERE FS2.RecordType = 'EQP' AND FS2.InvoiceNumber = FSI.InvoiceNumber) ELSE Null END
				,BaseRate = CASE WHEN FSI.InvoiceNumber IS Null THEN (SELECT TOP 1 FS2.ChargeAmount1 FROM ILSINT01.Integrations.dbo.View_Integration_FSI_Full FS2 WHERE FS2.RecordType = 'EQP' AND FS2.InvoiceNumber = FSI.InvoiceNumber) ELSE Null END
				,FSCAmount = CASE WHEN FSI.InvoiceNumber IS Null THEN (SELECT TOP 1 FS2.ChargeAmount1 FROM ILSINT01.Integrations.dbo.View_Integration_FSI_Full FS2 WHERE FS2.RecordCode = 'FSC' AND FS2.InvoiceNumber = FSI.InvoiceNumber) ELSE Null END
				,FSCPercentage = CASE WHEN FSI.InvoiceNumber IS Null THEN (SELECT TOP 1 FS2.ReferenceCode FROM ILSINT01.Integrations.dbo.View_Integration_FSI_Full FS2 WHERE FS2.RecordCode = 'FSC' AND FS2.InvoiceNumber = FSI.InvoiceNumber) ELSE Null END
				,ROW_NUMBER() OVER (PARTITION BY CN1.DocNumbr ORDER BY FSI.DetailId) AS RowId
				,CN1.InvAge
				,CN1.NoteDate
				,CN1.Note
				,CN1.RunDays
		FROM	#tmpInvoices CN1
				LEFT JOIN ILSINT01.Integrations.dbo.View_Integration_FSI_Full FSI ON FSI.Company = DB_NAME() AND CN1.DocNumbr = FSI.InvoiceNumber AND FSI.RecordType = 'ACC' AND FSI.RecordCode BETWEEN '300' AND '900' AND FSI.RecordCode NOT IN ('FSC','FRT')
		) RECS
WHERE	RowId = 1
		OR (RowId > 1 AND ChargeAmount1 <> 0)
ORDER BY
		Cprcstnm
		,DocNumbr
		,RowId
		,RecordType

DECLARE	@CustNmbr	Varchar(20),
		@DocNumbr	Varchar(20),
		@ProNumber	Varchar(15),
		@Equipment	Varchar(20),
		@WithData	Bit

DECLARE NullInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	CustNmbr, DocNumbr
	FROM	#tmpInvoicesData
	WHERE	InvoiceNumber IS NULL
			AND PATINDEX('%SUM%', BachNumb) = 0
			AND LEFT(CustNmbr, 2) = 'PD'

OPEN NullInvoices 
FETCH FROM NullInvoices INTO @CustNmbr, @DocNumbr

WHILE @@FETCH_STATUS = 0 
BEGIN
	-- *** QUERY PER DIEM TABLES ***
	SELECT	@Equipment = EquipmentId,
			@ProNumber = ProNum
	FROM	ILSSQL01.Accounting.dbo.InvoiceDetail
	WHERE	CustInvNum = @DocNumbr
			AND BillToCustomer = @CustNmbr
	
	IF @ProNumber IS NOT Null
	BEGIN
		-- *** SEARCH SWS POSTGRESQL MOVE INFRMATION ***
		EXECUTE GPCustom.dbo.USP_SaveMoveInformation @UserId, @ProNumber, Null, @Equipment, 1, 1, @WithData OUTPUT

		IF @WithData = 1
		BEGIN
			SELECT	CN1.CustNmbr
					,CN1.Cprcstnm
					,CN1.GroupName
					,CN1.CustName
					,CN1.Address1
					,CN1.Address2
					,CN1.City
					,CN1.State
					,CN1.Zip 
					,CN1.Phone1
					,CN1.DocNumbr
					,CN1.DocDate
					,CN1.OrTrxAmt
					,CN1.CurTrxAm
					,CN1.TrxDscrn
					,CN1.Amount_Promised
					,CN1.Action_Promised
					,CN1.Note_Display_String
					,CN1.CntCPrsn
					,CN1.UserId
					,CN1.BachNumb
					,CN1.DocNumbr AS InvoiceNumber
					,SWS.ReferenceNumber AS BilltoRef
					,CN1.DocDate AS InvoiceDate
					,CN1.OrTrxAmt AS InvoiceTotal
					,SWS.Ship_Name AS ShipperName
					,SWS.ship_city AS ShipperCity
					,SWS.Cons_name AS ConsigneeName
					,SWS.Cons_City AS ConsigneeCity
					,'ACC' AS RecordType
					,SWS.ChargeCode AS RecordCode
					,SWS.ChargeDescription AS Reference
					,SWS.ChargeAmount AS ChargeAmount1
					,@Equipment AS EquipmentId
					,0 AS BaseRate
					,SWS.FSCAmount
					,SWS.FSCPercentage
					,ROW_NUMBER() OVER (PARTITION BY CN1.DocNumbr ORDER BY SWS.ChargeCode) AS RowId
					,CN1.InvAge
					,CN1.NoteDate
					,CN1.Note
					,CN1.RunDays
			INTO	#tmpSWSData
			FROM	#tmpInvoicesData CN1
					INNER JOIN GPCustom.dbo.SWS_MoveData_Results SWS ON CN1.CUSTNMBR = @CustNmbr AND CN1.DocNumbr = @DocNumbr AND SWS.UserId = @UserId AND SWS.ChargeCode BETWEEN '300' AND '900'
					
			IF @@ROWCOUNT > 0
			BEGIN
				DELETE #tmpInvoicesData WHERE CUSTNMBR = @CustNmbr AND DocNumbr = @DocNumbr
				
				INSERT INTO #tmpInvoicesData SELECT * FROM #tmpSWSData
			END 
					
			DROP TABLE #tmpSWSData
		END
	END
	
	FETCH FROM NullInvoices INTO @CustNmbr, @DocNumbr
END

CLOSE NullInvoices
DEALLOCATE NullInvoices

SELECT	*
FROM	#tmpInvoicesData
ORDER BY CustNmbr, DocNumbr

DROP TABLE #tmpInvoices		
DROP TABLE #tmpInvoicesData

/*
EXECUTE USP_AROpenInvoices 0, 90, Null, Null, 'CFLORES'
EXECUTE USP_AROpenInvoices 0, 90, '2363A', Null, 'CFLORES'
*/