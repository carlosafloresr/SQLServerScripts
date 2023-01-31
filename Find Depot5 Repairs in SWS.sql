DECLARE	@RecordId		Int,
		@Chassis		Varchar(15),
		@EstimateDate	Date

DECLARE	@tblTIP			Table (
		LinkedCompany	Varchar(5),
		CustomerId		Varchar(15))

DECLARE @tblDepot5		Table (
		RecordId		Int,
		CustomerId		Varchar(15),
		DepotLoc		Varchar(15),
		EstimateNo		Varchar(15),
		EstimateDate	Date,
		RepaiDate		Date,
		InvTotal		Numeric(10,2),
		Container		Varchar(12),
		Chassis			Varchar(12),
		GenSet			Varchar(12),
		Entry_Date		Date,
		Out_date		Date)

DECLARE	@tblSWSData	Table (
		Chassis		Varchar(15) Null,
		EstDate		Date Null,
		CompanyNum	Smallint,
		ProNumber	Varchar(12),
		DropDate	Date,
		DriverId	Varchar(15) Null,
		Division	Varchar(3) Null)

INSERT INTO @tblTIP
SELECT	DISTINCT LinkedCompany,
		Account AS CustomerId
FROM	IntegrationsDB.Integrations.dbo.FSI_Intercompany_ARAP
WHERE	Company = 'FI' 
		AND RecordType = 'C'

INSERT INTO @tblDepot5
SELECT	unique_key,
		ACCT_NO,
		DEPOT_LOC,
		Estimate_no,
		estimate_date,
		repair_date,
		INV_TOTAL,
		CONTAINER,
		CHASSIS,
		GENSET_NO,
		ENTRY_DATE,
		inventory_out_date
FROM	DepotSystemsIMCMNR.dbo.Invoices
WHERE	acct_no IN (SELECT CustomerId FROM @tblTIP)
		AND estimate_date >= '03/01/2020'
		AND row_status = 'N'

DECLARE curDepot5Data CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RecordId,
		Chassis,
		EstimateDate
FROM	@tblDepot5

OPEN curDepot5Data 
FETCH FROM curDepot5Data INTO @RecordId, @Chassis, @EstimateDate

WHILE @@FETCH_STATUS = 0 
BEGIN
	INSERT INTO @tblSWSData
	EXECUTE USP_Find_Repair_SWSData @Chassis, @EstimateDate

	FETCH FROM curDepot5Data INTO @RecordId, @Chassis, @EstimateDate
END

select * from @tblDepot5

SELECT	CompanyNum,
		CompanyAlias,
		Chassis,
		EstDate,
		ProNumber,
		DropDate,
		DriverId,
		Division
FROM	@tblSWSData SWS
		INNER JOIN PRISQL01P.GPCustom.dbo.View_CompanyAgents COM ON SWS.CompanyNum = COM.CompanyNumber