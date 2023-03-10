USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindSelectedPaperlessInvoices]    Script Date: 11/3/2021 2:37:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
EXECUTE USP_FindSelectedPaperlessInvoices
EXECUTE USP_FindSelectedPaperlessInvoices @ForceRun = 1
EXECUTE USP_FindSelectedPaperlessInvoices @RunDate = '10/08/2021', @ForceRun = 1
EXECUTE USP_FindSelectedPaperlessInvoices @Company = 'PDS', @RunDate = '11/03/2021', @CompanyNumber = 9
EXECUTE USP_FindSelectedPaperlessInvoices @Company = 'GLSO', @RunDate = '10/08/2021', @Customer = '2945W', @CompanyNumber = 9
EXECUTE USP_FindSelectedPaperlessInvoices @Company = 'GIS', @RunDate = '11/03/2021', @Customer = '12330', @CompanyNumber = 2

EXECUTE USP_FindSelectedPaperlessInvoices @RunDate = '11/25/2017'
EXECUTE USP_FindSelectedPaperlessInvoices @Company = 'PTS', @RunDate = '10/21/2017'
EXECUTE USP_FindSelectedPaperlessInvoices @Company = 'PTS', @RunDate = '10/21/2017', @Customer = 'CMACGM', @CompanyNumber = 3
*/
-- =======================================================================================
-- Author:	  			Carlos A. Flores
-- Creation date:		03/18/2010
-- Description:			Invoice selection
-- =======================================================================================
-- Modification date:	12/05/2019	The Companies table is load into a table variable
--									to only read that external table 1 time.
-- Modification date:	04/07/2020	Added the Customer Master columns TextPDF and Exxon.
-- =======================================================================================
ALTER PROCEDURE [dbo].[USP_FindSelectedPaperlessInvoices]
		@Company		Varchar(5) = Null, 
		@Customer		Varchar(15) = Null, 
		@CompanyNumber	Int = Null, 
		@RunDate		Date = Null,
		@ForceRun		Bit = 0,
		@JustCustomer	Bit = 0
AS
SET NOCOUNT ON

DECLARE	@ParameterDate	Date,
		@RunBothWeeks	Bit

IF @RunDate IS Null OR @RunDate = CAST(GETDATE() AS Date)
	SET @RunDate = GETDATE()

SET @ParameterDate = @RunDate
SET @RunDate = CASE WHEN DATENAME(Weekday, @RunDate) = 'Saturday' THEN @RunDate ELSE dbo.DayFwdBack(@RunDate, CASE WHEN DATEPART(DW, @RunDate) BETWEEN 1 AND 3 THEN 'P' ELSE 'N' END, 'Saturday') END

DECLARE	@DailyRun		Bit = 0,
		@WeeklyRun		Bit = 0,
		@WeekDate		Date,
		@RunDay			Varchar(15),
		@ActiveWeekEnd	Date = CASE WHEN DATENAME(Weekday, GETDATE()) = 'Saturday' THEN GETDATE() ELSE dbo.DayFwdBack(GETDATE(), 'P', 'Saturday') END,
		@WeekEndDate	Date = CASE WHEN DATENAME(Weekday, @RunDate) = 'Saturday' THEN @RunDate ELSE dbo.DayFwdBack(@RunDate, 'P', 'Saturday') END

SET @RunBothWeeks		= CASE WHEN DATENAME(Weekday, @ParameterDate) IN ('Wednesday','Thursday') THEN 1 ELSE 0 END
DECLARE	@FromDate		Date = DATEADD(dd, -(CASE WHEN @RunBothWeeks = 1 THEN 7 ELSE 6 END), @WeekEndDate)

IF @WeekEndDate < @ActiveWeekEnd
	SET @ForceRun = 1

PRINT @FromDate
PRINT @WeekEndDate

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
	CustomerNumber					Varchar(25) Null,
	CustName						varchar(100) Null,
	InvoiceEmailOption				Smallint Null,
	JustInvoice						Bit Null,
	CompanyNumber					Smallint Null,
	InvoiceNumber					Varchar(30) Null,
	FSI_ReceivedDetailId			Int Null,
	CustomerRequiredDocumentTypes	Varchar(100) Null,
	WeekEndDate						Date Null,
	BillToRef						Varchar(20) Null,
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
		AND (@Company IS Null
		OR (@Company IS NOT Null AND CompanyID = @Company))
		AND (@Customer IS Null
		OR (@Customer IS NOT Null AND CustNmbr = @Customer))

INSERT INTO @tblDates
EXECUTE USP_PaperlessInvoicing_Schedule @RunDate

SELECT @RunDay = WeekDay FROM @tblDates WHERE Weekly = 1

IF EXISTS(SELECT WeekDay FROM @tblDates WHERE RunDate = @RunDate AND (Daily = 1 OR Weekly = 1)) OR @ForceRun = 1
BEGIN
	DECLARE	@Query			Varchar(Max),
			@CompanyId		Varchar(5)

	SELECT	@DailyRun	= Daily,
			@WeeklyRun	= CASE WHEN @ForceRun = 1 THEN 1 ELSE Weekly END
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

		OPEN curCompanies 
		FETCH FROM curCompanies INTO @CompanyId

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			EXECUTE USP_Automate_InvoicesByEmail @CompanyId, 1, @WeekEndDate

			IF @RunBothWeeks = 1
				EXECUTE USP_Automate_InvoicesByEmail @CompanyId, 1, @FromDate

			FETCH FROM curCompanies INTO @CompanyId
		END

		CLOSE curCompanies
		DEALLOCATE curCompanies
	
		INSERT INTO @tblData (Company, CompanyNumber, WeekEndDate)
		SELECT	DISTINCT FSID.Company,
				CASE FSID.Company WHEN 'NDS' THEN CAST(LEFT(FSID.BatchId, 2) AS Integer) ELSE CompanyNumber END AS CompanyNumber,
				FSID.WeekEndDate
		FROM	(
				SELECT	DISTINCT FSID.Company,
						FSID.CustomerNumber,
						FSID.BatchId,
						FSID.WeekEndDate,
						PAPC.CompanyNumber
				FROM	View_Integration_FSI FSID
						INNER JOIN @tblCompanies PAPC ON FSID.Company = PAPC.Company
						LEFT JOIN PaperlessInvoices PINV ON FSID.Company = PINV.Company AND FSID.CustomerNumber = PINV.Customer AND FSID.InvoiceNumber = PINV.InvoiceNumber
				WHERE	FSID.RecordStatus = 1
						AND FSID.WeekEndDate BETWEEN @FromDate AND @WeekEndDate
						AND FSID.InvoiceTotal > 0
						AND FSID.InvoiceType <> 'C'
						AND FSID.BatchId NOT LIKE '%_SUM'
						AND PINV.InvoiceNumber IS NULL
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
							,CASE FSID.Company WHEN 'NDS' THEN CAST(LEFT(FSID.BatchId, 2) AS Integer) ELSE COMP.CompanyNumber END AS CompanyNumber							
							,FSID.WeekEndDate
					FROM	View_Integration_FSI FSID
							INNER JOIN @tblCompanies COMP ON FSID.Company = COMP.Company
							INNER JOIN PaperlessInvoicingCompanies PAPC ON FSID.Company = PAPC.Company AND PAPC.Active = 1
							LEFT JOIN PaperlessInvoices PINV ON FSID.Company = PINV.Company AND FSID.CustomerNumber = PINV.Customer AND FSID.InvoiceNumber = PINV.InvoiceNumber
					WHERE	FSID.Company = @Company
							AND FSID.WeekEndDate BETWEEN @FromDate AND @WeekEndDate
							AND FSID.RecordStatus = 1
							AND FSID.InvoiceType <> 'C'
							AND FSID.InvoiceTotal > 0.1
							AND FSID.BatchId NOT LIKE '%_SUM'
							AND LEFT(FSID.InvoiceNumber, 1) NOT IN ('C')
							AND PINV.InvoiceNumber IS NULL
					) FSID
					LEFT JOIN @tblCustomers CUMA ON FSID.Company = CUMA.CompanyId AND FSID.CustNmbr = CUMA.CustNmbr
			WHERE	CUMA.InvoiceEmailOption > 1
			ORDER BY Company, CompanyNumber, CustNmbr
		END
		ELSE
		BEGIN
			PRINT 'Find All Paperless Invoices for a Specific Customer'
			DECLARE @MainCustomer Varchar(20) = @Customer

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
					,IIF(@JustCustomer = 1, '', FSID.InvoiceNumber) AS InvoiceNumber
					,IIF(@JustCustomer = 1, 0, FSID.FSI_ReceivedDetailId) AS FSI_ReceivedDetailId
					,CUMA.RequiredDocuments AS CustomerRequiredDocumentTypes
					,FSID.WeekEndDate
					,CASE WHEN CUMA.ReferenceOnEmail = 1 THEN FSID.BillToRef ELSE '' END AS BillToRef
					,TextPDF
					,Exxon
					,CompanyInInvoice
			FROM	(
					SELECT	DISTINCT FSID.Company
							,FSID.CustomerNumber
							,CASE FSID.Company WHEN 'NDS' THEN CAST(LEFT(FSID.BatchId, 2) AS Integer) ELSE COMP.CompanyNumber END AS CompanyNumber
							,FSID.InvoiceNumber
							,FSID.FSI_ReceivedDetailId
							,FSID.BillToRef
							,FSID.WeekEndDate
					FROM	View_Integration_FSI FSID
							INNER JOIN @tblCompanies COMP ON FSID.Company = COMP.Company
							INNER JOIN PaperlessInvoicingCompanies PAPC ON FSID.Company = PAPC.Company AND PAPC.Active = 1
							LEFT JOIN PaperlessInvoices PINV ON FSID.Company = PINV.Company AND FSID.CustomerNumber = PINV.Customer AND FSID.InvoiceNumber = PINV.InvoiceNumber
					WHERE	FSID.Company = @Company
							AND FSID.WeekEndDate BETWEEN @FromDate AND @WeekEndDate
							AND CASE FSID.Company WHEN 'NDS' THEN CAST(LEFT(FSID.BatchId, 2) AS Integer) ELSE COMP.CompanyNumber END = @CompanyNumber
							AND FSID.CustomerNumber = @Customer
							AND FSID.RecordStatus = 1
							AND FSID.InvoiceType <> 'C'
							AND FSID.InvoiceTotal > 0.1
							AND FSID.BatchId NOT LIKE '%_SUM'
							AND LEFT(FSID.InvoiceNumber, 1) NOT IN ('C')
							AND PINV.InvoiceNumber IS NULL
					) FSID
					LEFT JOIN @tblCustomers CUMA ON FSID.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr
			WHERE	CUMA.InvoiceEmailOption > 1
			ORDER BY FSID.Company, FSID.CustomerNumber, IIF(@JustCustomer = 1, '', FSID.InvoiceNumber)
		END
	END
END

SELECT	*
FROM	@tblData
ORDER BY Company, WeekEndDate, CustomerNumber, InvoiceNumber

/*
SELECT * FROM PaperlessInvoices WHERE InvoiceNumber IN ('57-197588-A','57-196305-A','57-198802-A','57-198820-A')
DELETE PaperlessInvoices WHERE InvoiceNumber = '57-197588-A'
*/