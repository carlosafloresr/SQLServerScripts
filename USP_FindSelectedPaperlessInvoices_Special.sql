USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindSelectedPaperlessInvoices_Special]    Script Date: 12/5/2022 1:58:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
EXECUTE USP_FindSelectedPaperlessInvoices_Special
EXECUTE USP_FindSelectedPaperlessInvoices_Special @Company = 'IMC'
EXECUTE USP_FindSelectedPaperlessInvoices_Special @Company = 'IMC', @Customer = '4112'

*/
-- =======================================================================================
-- Author:	  			Carlos A. Flores
-- Creation date:		02/18/2022
-- Description:			Invoice selection
-- =======================================================================================
-- Modification date:	12/05/2019	The Companies table is load into a table variable
--									to only read that external table 1 time.
-- Modification date:	04/07/2020	Added the Customer Master columns TextPDF and Exxon.
-- =======================================================================================
ALTER PROCEDURE [dbo].[USP_FindSelectedPaperlessInvoices_Special]
		@Company		Varchar(5) = Null, 
		@Customer		Varchar(25) = Null
AS
SET NOCOUNT ON

DECLARE	@ParameterDate	Date,
		@RunBothWeeks	Bit,
		@DailyRun		Bit = 0,
		@WeeklyRun		Bit = 0,
		@WeekDate		Date,
		@CompanyNumber	Int,
		@Rundate		Date = GETDATE()

DECLARE	@tblDates Table
	(RecordId						Int,
	RunDate							Date,
	WeekDay							Varchar(15),
	Daily							Bit,
	Weekly							Bit)

DECLARE	@tblCompanies Table
	(Company						Varchar(5),
	CompanyNumber					Int)

DECLARE @tblCustomers Table (
	CompanyId						Varchar(5),
	SWSCustomerId					Varchar(10),
	CustNmbr						Varchar(15),
	CustName						Varchar(100),
	RequiredDocuments				Varchar(100),
	InvoiceEmailOption				Smallint,
	JustInvoice						Bit,
	ReferenceOnEmail				Bit,
	TextPDF							Bit,
	Exxon							Bit,
	CompanyInInvoice				Bit)

DECLARE	@tblData Table
	(Company						Varchar(5),
	CustomerNumber					Varchar(30) Null,
	CustName						varchar(150) Null,
	InvoiceEmailOption				Smallint Null,
	JustInvoice						Bit Null,
	CompanyNumber					Smallint Null,
	InvoiceNumber					Varchar(50) Null,
	FSI_ReceivedDetailId			Int Null,
	CustomerRequiredDocumentTypes	Varchar(200) Null,
	WeekEndDate						Date Null,
	BillToRef						Varchar(30) Null,
	TextPDF							Bit Null,
	Exxon							Bit Null,
	CompanyInInvoice				Bit Null)

INSERT INTO @tblCompanies
SELECT	CompanyId,
		CompanyNumber
FROM	PRISQL01P.GPCustom.dbo.Companies
WHERE	CompanyId IN (SELECT Company FROM PaperlessInvoicingCompanies WHERE Active = 1)
		AND (@Company IS Null
		OR (@Company IS NOT Null AND CompanyID = @Company))

INSERT INTO @tblCustomers
SELECT	CompanyId,
		SWSCustomerId,
		IIF(SWSCustomerId = '' OR SWSCustomerId IS Null, CustNmbr, SWSCustomerId) AS CustNmbr,
		CustName,
		RequiredDocuments,
		InvoiceEmailOption,
		EmailJustInvoice,
		ReferenceOnEmail,
		TextPDF,
		Exxon,
		CompanyInInvoice
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	InvoiceEmailOption > 1
		AND Inactive = 0
		AND (@Company IS Null OR (@Company IS NOT Null AND CompanyID = @Company))
		AND (@Customer IS Null OR (@Customer IS NOT Null AND CustNmbr = @Customer))

INSERT INTO @tblDates
EXECUTE USP_PaperlessInvoicing_Schedule @Rundate

DECLARE	@Query			Varchar(Max),
		@CompanyId		Varchar(5)

SELECT	@DailyRun	= Daily,
		@WeeklyRun	= Weekly
FROM	@tblDates
WHERE	WeekDay = DATENAME(Weekday, GETDATE())
	
PRINT 'Weekly Run: ' + CAST(@WeeklyRun AS Varchar)

IF @Company IS Null
BEGIN
	PRINT 'Find All Paperless Invoicing Companies'

	DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	Company
	FROM	PaperlessInvoicingCompanies
	WHERE	Active = 1
	
	INSERT INTO @tblData (Company, CompanyNumber, WeekEndDate)
	SELECT	DISTINCT FSID.Company,
			CASE FSID.Company WHEN 'NDS' THEN CAST(LEFT(FSID.BatchId, 2) AS Integer) ELSE CompanyNumber END AS CompanyNumber,
			FSID.WeekEndDate
	FROM	(
			SELECT	DISTINCT FSID.Company,
					FSID.CustomerNumber,
					'NONE' AS BatchId,
					GETDATE() AS WeekEndDate,
					PAPC.CompanyNumber
			FROM	PaperlessInvoices_Special FSID
					INNER JOIN @tblCompanies PAPC ON FSID.Company = PAPC.Company
			WHERE	FSID.Sent = 0
			) FSID
			INNER JOIN @tblCustomers CUMA ON FSID.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr
	WHERE	CUMA.InvoiceEmailOption > 1
	ORDER BY FSID.Company
END
ELSE
BEGIN
	IF @Customer IS NULL AND @Company IS NOT Null
	BEGIN
		PRINT 'Find All Paperless Invoicing Customers for a Specific Company'
	
		INSERT INTO @tblData (Company, CustomerNumber, InvoiceEmailOption, JustInvoice, CompanyNumber, CustomerRequiredDocumentTypes, WeekEndDate)
		SELECT	DISTINCT FSID.Company
				,FSID.CustNmbr
				,CUMA.InvoiceEmailOption
				,CUMA.JustInvoice
				,FSID.CompanyNumber
				,CUMA.RequiredDocuments AS CustomerRequiredDocumentTypes
				,FSID.WeekEndDate
		FROM	(
				SELECT	DISTINCT FSID.Company
						,FSID.CustomerNumber AS CustNmbr
						,COMP.CompanyNumber
						,GETDATE() AS WeekEndDate
				FROM	PaperlessInvoices_Special FSID
						INNER JOIN @tblCompanies COMP ON FSID.Company = COMP.Company
						INNER JOIN PaperlessInvoicingCompanies PAPC ON FSID.Company = PAPC.Company AND PAPC.Active = 1
				WHERE	FSID.Company = @Company
						AND FSID.Sent = 0
				) FSID
				LEFT JOIN @tblCustomers CUMA ON FSID.Company = CUMA.CompanyId AND FSID.CustNmbr = CUMA.CustNmbr
		WHERE	CUMA.InvoiceEmailOption > 1
		ORDER BY Company, CompanyNumber, CustNmbr
	END
	ELSE
	BEGIN
		PRINT 'Find All Paperless Invoices for a Specific Customer'
		DECLARE @MainCustomer Varchar(30) = @Customer

		SET @MainCustomer = (SELECT TOP 1 CustNmbr FROM @tblCustomers WHERE CompanyId = @Company AND ISNULL(CASE WHEN SWSCustomerId = '' THEN Null ELSE SWSCustomerId END, CustNmbr) = @Customer)

		IF @CompanyNumber IS Null
			SET @CompanyNumber = (SELECT CompanyNumber FROM @tblCompanies WHERE Company = @Company)

		INSERT INTO @tblData
		SELECT	DISTINCT FSID.Company
				,FSID.CustomerNumber
				,CUMA.CustName
				,CUMA.InvoiceEmailOption
				,CUMA.JustInvoice
				,FSID.CompanyNumber
				,FSID.InvoiceNumber
				,FSID.FSI_ReceivedDetailId
				,CUMA.RequiredDocuments AS CustomerRequiredDocumentTypes
				,FSID.WeekEndDate
				,CASE WHEN CUMA.ReferenceOnEmail = 1 THEN FSID.BillToRef ELSE '' END AS BillToRef
				,TextPDF
				,Exxon
				,CompanyInInvoice
		FROM	(
				SELECT	DISTINCT FSID.Company
						,FSID.CustomerNumber
						,COMP.CompanyNumber
						,FSID.InvoiceNumber
						,FSID.RecordId AS FSI_ReceivedDetailId
						,VSA.BillToRef
						,GETDATE() AS WeekEndDate
				FROM	PaperlessInvoices_Special FSID
						INNER JOIN @tblCompanies COMP ON FSID.Company = COMP.Company
						INNER JOIN PaperlessInvoicingCompanies PAPC ON FSID.Company = PAPC.Company AND PAPC.Active = 1
						INNER JOIN View_Integration_FSI_Sales VSA ON FSID.Company = VSA.Company AND FSID.CustomerNumber = VSA.CustomerNumber AND FSID.InvoiceNumber = VSA.InvoiceNumber
				WHERE	FSID.Company = @Company
						AND FSID.CustomerNumber = @Customer
						AND FSID.Sent = 0
				) FSID
				LEFT JOIN @tblCustomers CUMA ON FSID.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr
		WHERE	CUMA.InvoiceEmailOption > 1
		ORDER BY FSID.Company, FSID.CustomerNumber, FSID.InvoiceNumber
	END
END

SELECT	*
FROM	@tblData
ORDER BY Company, WeekEndDate, CustomerNumber, InvoiceNumber

/*
SELECT * FROM PaperlessInvoices WHERE InvoiceNumber IN ('57-197588-A','57-196305-A','57-198802-A','57-198820-A')
DELETE PaperlessInvoices WHERE InvoiceNumber = '57-197588-A'
*/