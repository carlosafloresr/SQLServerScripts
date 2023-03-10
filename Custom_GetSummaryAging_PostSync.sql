USE [CollectIT]
GO
/****** Object:  StoredProcedure [dbo].[Custom_GetSummaryAging_PostSync]    Script Date: 6/16/2022 9:56:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE Custom_GetSummaryAging_PostSync
*/
ALTER PROCEDURE [dbo].[Custom_GetSummaryAging_PostSync]
AS
SET NOCOUNT ON

DECLARE	@InvoiceId		Int,
		@Company		Varchar(5),
		@Invoice		Varchar(25)

DECLARE @tblInvoiceData TABLE (
		Container		Varchar(25) Null,
		ConsigneeName	Varchar(30) Null)

DECLARE curInvoices CURSOR FOR
	SELECT	CS_Invoice.InvoiceId
			,CS_Enterprise.EnterpriseNumber
			,RTRIM(CS_Invoice.InvoiceNum) AS InvoiceNum
	FROM	CS_Invoice
			INNER JOIN CS_Enterprise ON CS_Invoice.EnterpriseId = CS_Enterprise.EnterpriseId
			INNER JOIN UF_Invoice ON UF_Invoice.InvoiceId = CS_Invoice.InvoiceId
	WHERE	CS_Invoice.InvoiceNum LIKE '%-%'
			AND UF_Invoice.EquipmentNo IS Null
			--AND (CS_Invoice.InvoiceNum NOT LIKE 'DM-%' AND UF_Invoice.Consignee IS NULL)
			AND CS_Invoice.InvoiceNum NOT LIKE 'D %'
			AND CS_Invoice.DocDate > DATEADD(dd, -120, GETDATE())

OPEN curInvoices

FETCH NEXT FROM curInvoices INTO @InvoiceId, @Company, @Invoice

WHILE @@fetch_status <> - 1
BEGIN
	PRINT @Company + ' / ' + @Invoice

	IF EXISTS(SELECT TOP 1 CompanyId FROM GPCustom.dbo.SalesInvoices WHERE CompanyId = @Company AND InvoiceNumber = @Invoice)
	BEGIN
		INSERT INTO @tblInvoiceData
		SELECT	ISNULL(SI.TrailerNumber, SI.ChassisNumber),
				RTRIM(LEFT(CM.CustName, 30))
		FROM	GPCustom.dbo.SalesInvoices SI
				LEFT JOIN GPCustom.dbo.CustomerMaster CM ON SI.CustomerId = CM.CustNmbr
		WHERE	SI.CompanyId = @Company 
				AND SI.InvoiceNumber = @Invoice
	END
	ELSE
	BEGIN
		INSERT INTO @tblInvoiceData
		SELECT	RTRIM(DET.Equipment) + ISNULL(DET.CheckDigit,'') AS Container
				,DET.ConsigneeName
		FROM	[findata-intg-ms.imcc.com].Integrations.dbo.FSI_ReceivedDetails DET
				INNER JOIN [findata-intg-ms.imcc.com].Integrations.dbo.FSI_ReceivedHeader HED ON DET.BatchId = HED.BatchId AND HED.Company = @Company
		WHERE	DET.VoucherNumber = @Invoice
		
		--IF @@ROWCOUNT = 0 --AND dbo.AT('-', @Invoice, 1) > 0
		--BEGIN
		--	DECLARE	@Query			Varchar(MAX),
		--			@CompanyNumber	Varchar(2)

		--	SELECT	@CompanyNumber = CAST(CompanyNumber AS Varchar)
		--	FROM	GPCustom.dbo.Companies
		--	WHERE	CompanyId = @Company
		
		--	SET @Query	= N'SELECT cnname, Eq_Code AS Container FROM TRK.Invoice WHERE Cmpy_No = ' + @CompanyNumber + ' AND Code = ''' + @Invoice + ''''
		--	SET	@Query	= N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''' + REPLACE(@Query, '''', '''''') + ''')'
		
		--	INSERT INTO @tblInvoiceData 
		--	EXECUTE(@Query)
		--END
	END
	
	IF (SELECT COUNT(*) FROM @tblInvoiceData) = 0
	BEGIN
		UPDATE	UF_Invoice
		SET		UF_Invoice.EquipmentNo = '',
				UF_Invoice.Consignee = ''
		WHERE	UF_Invoice.InvoiceId = @InvoiceId
	END
	ELSE
	BEGIN
		UPDATE	UF_Invoice
		SET		UF_Invoice.EquipmentNo = ISNULL(DATA.Container, ''),
				UF_Invoice.Consignee = ISNULL(DATA.ConsigneeName, '')
		FROM	@tblInvoiceData DATA
		WHERE	UF_Invoice.InvoiceId = @InvoiceId
	END

	DELETE @tblInvoiceData

	FETCH NEXT FROM curInvoices INTO @InvoiceId, @Company, @Invoice
END

CLOSE curInvoices
DEALLOCATE curInvoices

-- Dynavistics 10/20/2017: clear paid invoices from letters stuck in the queue
delete CS_Letter
where LetterId in (
Select l.LetterId
from CS_Letter l
join CS_LetterInvoice li on li.LetterId = l.LetterId
join CS_Invoice i on i.InvoiceId = li.InvoiceId
where WasSent = 0
group by l.LetterId
having MAX(i.PaymentStatus) = 1 -- all invoices paid
)

delete li from CS_LetterInvoice li
join (
Select li.InvoiceId, li.LetterId
from CS_Letter l
join CS_LetterInvoice li on li.LetterId = l.LetterId
join CS_Invoice i on i.InvoiceId = li.InvoiceId
where WasSent = 0
group by li.InvoiceId, li.LetterId
having MIN(i.PaymentStatus) = 1 -- some invoices paid
) todel on todel.InvoiceId = li.InvoiceId and todel.LetterId = li.LetterId