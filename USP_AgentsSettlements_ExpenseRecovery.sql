/*
EXECUTE USP_AgentsSettlements_ExpenseRecovery 'NDS', '12-04-1107', '1/1/2005', '02/03/2018', 1
EXECUTE USP_AgentsSettlements_ExpenseRecovery 'NDS', '12-04-1107', '1/28/2018', '02/03/2018', 1
EXECUTE USP_AgentsSettlements_ExpenseRecovery 'NDS', '12-04-1107', '2/04/2018', '02/10/2018', 1
*/
ALTER PROCEDURE USP_AgentsSettlements_ExpenseRecovery
		@Company		Varchar(5), 
		@Account		Varchar(15),
		@DateIni		Date,
		@DateEnd		Date,
		@HideZeros		Bit = 1
AS
SET NOCOUNT ON

DECLARE @Query			Varchar(Max)
DECLARE @tblData		Table (
	EscrowTransactionId		int NOT NULL,
	Source					char(2) NULL,
	VoucherNumber			varchar(22) NULL,
	ItemNumber				int NULL,
	CompanyId				varchar(6) NULL,
	Fk_EscrowModuleId		int NOT NULL,
	AccountNumber			char(15) NOT NULL,
	AccountType				int NULL,
	VendorId				varchar(10) NOT NULL,
	DriverId				varchar(10) NULL,
	Division				varchar(4) NULL,
	Amount					numeric(10,2) NULL,
	ClaimNumber				varchar(15) NULL,
	DriverClass				int NULL,
	AccidentType			int NULL,
	Status					int NULL,
	DMSubmitted				int NULL,
	DeductionPlan			char(5) NULL,
	Comments				varchar(1000) NULL,
	ProNumber				varchar(50) NULL,
	TransactionDate			datetime NULL,
	PostingDate				datetime NULL,
	EnteredBy				varchar(25) NULL,
	EnteredOn				datetime NULL,
	ChangedBy				varchar(25) NULL,
	ChangedOn				datetime NULL,
	Void					bit NULL,
	InvoiceNumber			varchar(30) NULL,
	OtherStatus				varchar(20) NULL,
	DeletedBy				varchar(25) NULL,
	DeletedOn				datetime NULL,
	BatchId					varchar(25) NULL,
	SOPDocumentNumber		varchar(25) NULL,
	UnitNumber				varchar(90) NULL,
	RepairDate				date NULL,
	ETA						date NULL,
	RecordType				varchar(1) NULL,
	ChassisNumber			varchar(15) NULL,
	TrailerNumber			varchar(15) NULL,
	AccountIndex			int NULL,
	AccountAlias			varchar(50) NULL,
	Balance					numeric(10,2) NULL,
	EndBalance				numeric(10,2) NULL,
	FinalBalance			numeric(10,2) NULL,
	PeriodSummary			int NULL,
	TransDescription		varchar(500) NULL,
	CompanyName				varchar(50) NULL,
	VendName				varchar(50) NULL,
	ActDescr				varchar(51) NULL,
	ProNumberMain			varchar(50) NULL,
	DocNumber				varchar(20) NULL,
	PostDate				datetime NULL,
	Module					varchar(50) NULL,
	HireDate				datetime NULL,
	TerminationDate			datetime NULL,
	DriverType				varchar(3) NOT NULL,
	RowNumber				bigint NULL,
	AccountStartBalance		numeric(10,2) NULL,
	AccountEndingBalance	numeric(10,2) NULL,
	ReportEndingBalance		numeric(10,2) NULL,
	RecordStatus			varchar(25) NULL)

SET @Query = N'EXECUTE ' + RTRIM(@Company) + '.dbo.USP_Report_ExpenseRecovery ''' + RTRIM(@Company) + ''',''' + RTRIM(@Account) + ''',''' + CAST(@DateIni AS Varchar) + ''',''' + CAST(@DateEnd AS Varchar) + ''',' + CAST(@HideZeros AS Varchar)

INSERT INTO @tblData
EXECUTE(@Query)

--SELECT	*
--FROM	@tblData
--ORDER BY
--		AccountNumber,
--		ProNumber, 
--		PostingDate

SELECT	ProNumberMain,
		Balance,
		ISNULL(Amount,0) AS Amount,
		FinalBalance
FROM	@tblData
ORDER BY FinalBalance