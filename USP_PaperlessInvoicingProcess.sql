USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_PaperlessInvoicingProcess]    Script Date: 12/28/2017 11:27:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_PaperlessInvoicingProcess '12/28/2017'
*/
ALTER PROCEDURE [dbo].[USP_PaperlessInvoicingProcess]
			@RunDate			Date = Null
AS
BEGIN
	DECLARE	@Counter1			Int,
			@Counter2			Int,
			@WeekEndDate		Date = ISNULL(@RunDate, CASE WHEN DATENAME(Weekday, GETDATE()) = 'Saturday' THEN GETDATE() ELSE dbo.DayFwdBack(GETDATE(), 'P', 'Saturday') END)

	DECLARE	@tblCustomer		Table (
			CompanyId			Varchar(5),
			CustNmbr			Varchar(25),
			SWSCustomerId		Varchar(10) Null,
			InvoiceEmailOption	Int)

	INSERT INTO @tblCustomer
	SELECT	CompanyId,
			CustNmbr,
			CASE WHEN SWSCustomerId = '' THEN Null ELSE SWSCustomerId END AS SWSCustomerId,
			InvoiceEmailOption
	FROM	ILSGP01.GPCustom.dbo.CustomerMaster
	WHERE	InvoiceEmailOption > 1
			AND CustNmbr IN (SELECT DISTINCT CustomerNumber FROM View_Integration_FSI WHERE WeekEndDate BETWEEN DATEADD(dd, -6, @WeekEndDate) AND @WeekEndDate AND InvoiceTotal > 0.1)

	PRINT @WeekEndDate

	SELECT	FSID.FSI_ReceivedDetailId
	INTO	#tmpInvoices
	FROM	Integrations.dbo.FSI_ReceivedDetails FSID
			INNER JOIN Integrations.dbo.FSI_ReceivedHeader FSIH ON FSID.BatchId = FSIH.BatchId AND FSIH.WeekEndDate >= DATEADD(dd, -6, @WeekEndDate)
			INNER JOIN @tblCustomer CUMA ON FSIH.Company = CUMA.CompanyId AND FSID.CustomerNumber = ISNULL(CUMA.SWSCustomerId, CUMA.CustNmbr) AND CUMA.InvoiceEmailOption > 1
			INNER JOIN ILSGP01.GPCustom.dbo.Companies COMP ON FSIH.Company = COMP.CompanyId
			INNER JOIN PaperlessInvoicingCompanies PAPC ON FSIH.Company = PAPC.Company AND PAPC.Active = 1
			LEFT JOIN Integrations.dbo.PaperlessInvoices PINV ON FSIH.Company = PINV.Company AND FSID.CustomerNumber = PINV.Customer AND FSID.InvoiceNumber = PINV.InvoiceNumber
	WHERE	FSID.RecordStatus = 0
			AND FSID.InvoiceType <> 'C'
			AND FSID.InvoiceTotal > 0.1
			AND PINV.InvoiceNumber IS NULL
			AND LEFT(FSID.InvoiceNumber, 1) NOT IN ('C')

	SELECT	@Counter2 = COUNT(FSID.FSI_ReceivedDetailId)
	FROM	Integrations.dbo.FSI_ReceivedDetails FSID
			INNER JOIN Integrations.dbo.FSI_ReceivedHeader FSIH ON FSID.BatchId = FSIH.BatchId AND FSIH.WeekEndDate >= DATEADD(dd, -6, @WeekEndDate)
			INNER JOIN @tblCustomer CUMA ON FSIH.Company = CUMA.CompanyId AND FSID.CustomerNumber = ISNULL(CUMA.SWSCustomerId, CUMA.CustNmbr) AND CUMA.InvoiceEmailOption > 1
			INNER JOIN ILSGP01.GPCustom.dbo.Companies COMP ON FSIH.Company = COMP.CompanyId
			INNER JOIN PaperlessInvoicingCompanies PAPC ON FSIH.Company = PAPC.Company AND PAPC.Active = 1
			LEFT JOIN Integrations.dbo.PaperlessInvoices PINV ON FSIH.Company = PINV.Company AND FSID.CustomerNumber = PINV.Customer AND FSID.InvoiceNumber = PINV.InvoiceNumber
	WHERE	FSID.RecordStatus = 1
			AND FSID.InvoiceType <> 'C'
			AND FSID.InvoiceTotal > 0.1
			AND PINV.InvoiceNumber IS NULL
			AND LEFT(FSID.InvoiceNumber, 1) NOT IN ('C')

	SELECT @Counter1 = COUNT(*) FROM #tmpInvoices

	IF @Counter1 > 0
	BEGIN
		UPDATE	FSI_ReceivedDetails
		SET		RecordStatus = 1
		WHERE	FSI_ReceivedDetailId IN (SELECT FSI_ReceivedDetailId FROM #tmpInvoices)
	END

	SELECT ISNULL(@Counter1, 0) + ISNULL(@Counter2, 0) AS [Counter]

	DROP TABLE #tmpInvoices
END