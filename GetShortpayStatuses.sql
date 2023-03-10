USE [CollectIT]
GO
/****** Object:  StoredProcedure [dbo].[GetShortpayStatuses]    Script Date: 1/17/2017 9:38:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE GetShortpayStatuses @InvoiceIds = '140938,140939,140940,140941,140942,140943,140944,140945,140946,140947'
*/
ALTER PROCEDURE [dbo].[GetShortpayStatuses] @InvoiceIds Nvarchar(MAX)
AS
BEGIN
	SET NOCOUNT ON

	IF RIGHT(@InvoiceIds, 1) <> ','
	SET @InvoiceIds = RTRIM(@InvoiceIds) + ','

	DECLARE	@TotalPars		Int = GPCustom.dbo.OCCURS(',', @InvoiceIds),
			@CountItems		Int = 0,
			@PrevPosition	Int = 0,
			@LastPosition	Int,
			@Length			Int = LEN(@InvoiceIds),
			@Counter		Int = 1,
			@InvoiceId		Varchar(20),
			@Company		Varchar(5),
			@Status			Varchar(100)

	DECLARE	@tblInvoices TABLE (InvoiceId Int)

	DECLARE	@tblCollectIT TABLE (Company Varchar(5), InvoiceId Int, ShortPayStatus Varchar(100) Null)

	WHILE @CountItems < @TotalPars
	BEGIN
		SET @LastPosition = GPCustom.dbo.AT(',', @InvoiceIds, @Counter)

		IF @LastPosition > 0
		BEGIN
			SET @InvoiceId = SUBSTRING(@InvoiceIds, @PrevPosition + 1, @LastPosition - @PrevPosition - 1)
			SET @Counter = @Counter + 1
			SET @PrevPosition = @LastPosition
			SET @CountItems = @CountItems + 1

			INSERT INTO @tblInvoices (InvoiceId) VALUES (@InvoiceId)
		END
	END

	INSERT INTO @tblCollectIT
	SELECT	CSE.EnterpriseNumber AS Company,
			CSI.InvoiceId,
			''
	FROM	CS_Invoice CSI
			INNER JOIN dbo.CS_Enterprise CSE ON CSI.EnterpriseId = CSE.EnterpriseId 
			INNER JOIN @tblInvoices IDS ON IDS.InvoiceId = CSI.InvoiceId

	DECLARE Transaction_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	Company, InvoiceId
	FROM	@tblCollectIT

	OPEN Transaction_Companies 
	FETCH FROM Transaction_Companies INTO @Company, @InvoiceId

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Status = (	SELECT	TOP 1 RTRIM(wf1.[Name]) AS [QueueName] 
						FROM	LENSASQL002.Tributary.dbo.wfqueue wf1 
								INNER JOIN LENSASQL002.Tributary.dbo.WFWorkItem wf2 ON wf1.QueueID = wf2.QueueID 
								INNER JOIN LENSASQL002.Tributary.dbo.PacketIDX_ShortPay wf3 ON wf2.PacketID = wf3.PacketID  
						WHERE	wf3.[InvoiceNumber] = '28-136927'
								AND wf3.[Division] = 'DNJ' 
						ORDER BY [Division], InQueueDT DESC)

		IF @Status IS NOT Null
			UPDATE	@tblCollectIT
			SET		ShortPayStatus = LEFT(@Status, 100)
			WHERE	Company = @Company
					AND InvoiceId = @InvoiceId

		FETCH FROM Transaction_Companies INTO @Company, @InvoiceId
	END

	CLOSE Transaction_Companies
	DEALLOCATE Transaction_Companies

	SELECT	InvoiceId, ShortPayStatus
	FROM	@tblCollectIT
END