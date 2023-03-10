/*
EXECUTE USP_PaperlessInvoices_Log '11/28/2018', 'W', 'AIS'
EXECUTE USP_PaperlessInvoices_Log '11/07/2018', 'D', 'AIS','119G'
EXECUTE USP_PaperlessInvoices_Log '11/06/2018', 'D', 'AIS','119G'
EXECUTE USP_PaperlessInvoices_Log '11/28/2018', 'W', Null, Null, 'CO'
EXECUTE USP_PaperlessInvoices_Log '11/28/2018', 'W', 'AIS', Null, 'CU'
*/
ALTER PROCEDURE USP_PaperlessInvoices_Log
		@ReportDate		Date,
		@DateType		Char(1) = 'W',
		@Company		Varchar(5) = Null,
		@Customer		Varchar(15) = Null,
		@JustDataType	Char(2) = Null
AS
DECLARE	@DateIni	Datetime,
		@DateEnd	Datetime

IF @Company = ''
	SET @Company = Null

IF @Customer = ''
	SET @Customer = Null

DECLARE @tblCompanies Table (CompanyAlias Varchar(6), CompanyId Varchar(5), CompanyName Varchar(75))
DECLARE @tblCustomers Table (CompanyId Varchar(5), CustNmbr Varchar(20), CustName Varchar(75), SWSCustomerId Varchar(6) Null)

INSERT INTO @tblCompanies
SELECT	DAT.CompanyAlias,
		DAT.CompanyId,
		COM.CompanyName
FROM	(
		SELECT	DISTINCT VCA.CompanyId, ISNULL(VCA.CompanyAlias, VCA.CompanyId) AS CompanyAlias
		FROM	PRISQL01P.GPCustom.dbo.View_CompaniesAndAgents VCA
		) DAT
		INNER JOIN PRISQL01P.GPCustom.dbo.Companies COM ON DAT.CompanyId = COM.CompanyId

INSERT INTO @tblCustomers
SELECT	CompanyId, 
		CustNmbr, 
		CustName, 
		SWSCustomerId 
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	@Company IS Null
		OR CompanyId = @Company  

IF @DateType = 'W'
BEGIN
	IF DATENAME(Weekday, @ReportDate) = 'Monday'
		SET @DateIni = @ReportDate
	ELSE
		SET @DateIni = dbo.DayFwdBack(@ReportDate, 'P', 'Monday')

	SET @DateEnd = dbo.DayFwdBack(@ReportDate, 'N', 'Saturday')
END
ELSE
BEGIN
	SET @DateIni = @ReportDate
	SET @DateEnd = CAST(CAST(@ReportDate AS Char(10)) + ' 11:59:59 PM' AS Datetime)
END

PRINT @DateIni
PRINT @DateEnd

IF @JustDataType IS Null
	SELECT	RTRIM(GPC.CompanyAlias) AS Company
			,GPC.CompanyName
			,PIN.Customer
			,ISNULL(CUS.CustName, '') AS CustName
			,PIN.InvoiceNumber
			,CAST(FSH.WeekEndDate AS Date) AS WeekEndDate
			,ISNULL(FSH.Agent,'') AS Agent
			,FORMAT(PIN.RunDate, 'MM/dd/yyyy HH:MM:ss tt') AS RunDateFormat
	FROM	PaperlessInvoices PIN
			INNER JOIN FSI_ReceivedHeader FSH ON PIN.Company = FSH.Company
			INNER JOIN FSI_ReceivedDetails FSD ON PIN.Customer = FSD.CustomerNumber AND PIN.InvoiceNumber = FSD.InvoiceNumber AND FSH.BatchId = FSD.BatchId
			LEFT JOIN @tblCompanies GPC ON PIN.Company = GPC.CompanyId
			LEFT JOIN @tblCustomers CUS ON GPC.CompanyAlias = CUS.CompanyId AND PIN.Customer = CUS.CustNmbr
	WHERE	PIN.RunDate BETWEEN @DateIni AND @DateEnd
			AND (@Company IS Null OR PIN.Company = @Company)
			AND (@Customer IS Null OR PIN.Customer = @Customer)
	ORDER BY 
			FSH.WeekEndDate,
			PIN.Company,
			FSH.Agent,
			PIN.Customer,
			PIN.InvoiceNumber
ELSE
BEGIN
	IF @JustDataType = 'CO'
		SELECT	DISTINCT RTRIM(GPC.CompanyAlias) AS Company
				,GPC.CompanyName
		FROM	PaperlessInvoices PIN
				INNER JOIN FSI_ReceivedHeader FSH ON PIN.Company = FSH.Company
				INNER JOIN FSI_ReceivedDetails FSD ON PIN.Customer = FSD.CustomerNumber AND PIN.InvoiceNumber = FSD.InvoiceNumber AND FSH.BatchId = FSD.BatchId
				LEFT JOIN @tblCompanies GPC ON PIN.Company = GPC.CompanyId
		WHERE	PIN.RunDate BETWEEN @DateIni AND @DateEnd
		ORDER BY 1
	ELSE
		SELECT	DISTINCT PIN.Customer
				,ISNULL(RTRIM(CUS.CustName) + ' [' + RTRIM(PIN.Customer) + ']', PIN.Customer) AS CustomerName
		FROM	PaperlessInvoices PIN
				INNER JOIN FSI_ReceivedHeader FSH ON PIN.Company = FSH.Company
				INNER JOIN FSI_ReceivedDetails FSD ON PIN.Customer = FSD.CustomerNumber AND PIN.InvoiceNumber = FSD.InvoiceNumber AND FSH.BatchId = FSD.BatchId
				LEFT JOIN @tblCompanies GPC ON PIN.Company = GPC.CompanyId
				LEFT JOIN @tblCustomers CUS ON GPC.CompanyAlias = CUS.CompanyId AND PIN.Customer = CUS.CustNmbr
		WHERE	PIN.RunDate BETWEEN @DateIni AND @DateEnd
				AND (@Company IS Null OR PIN.Company = @Company)
		ORDER BY 2
END
