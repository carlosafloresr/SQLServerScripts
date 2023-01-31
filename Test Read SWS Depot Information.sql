/*
EXECUTE USP_Find_SWS_EIR 3590823
*/
CREATE PROCEDURE dbo.USP_Find_SWS_EIR (@EIRCode Int)
AS
DECLARE	@Query			Varchar(MAX),
		@OrderNumber	Varchar(20)
		
CREATE TABLE #tmpDepotData
	(eir_code		Varchar(10), 
	eir_type		Varchar(8), 
	eir_date		Datetime, 
	order_number	Int,
	depot_code		Varchar(6), 
	pronumber		Varchar(10), 
	company_number	Int, 
	division		Char(2), 
	driver_code		Varchar(6), 
	scan_date		Datetime, 
	container		Varchar(10), 
	chassis			Varchar(10), 
	audit_date		Datetime)

CREATE TABLE #tmpProData
	(OrderNumber	Int,
	Reference		Varchar(25),
	BillToCode		Varchar(6),
	BillToName		Varchar(30))

-- DEFINE QUERY TO QUERY SWS DEPOT MANAGEMENT SYSTEM
SET @Query = N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''SELECT eir_code, eir_type, eir_date, order_number, depot_site_code as depot_code, pro as pronumber, company_number, division_code as division, driver_code, scan_date, container, chassis, audit_date FROM com.dep2pro WHERE eir_code = ''''' + CAST(@EIRCode AS Varchar(12)) + ''''''')'

-- INSERT THE SWS DEPOT MANAGEMENT SYSTEM DATA IN TEMPORAL TABLE
INSERT INTO #tmpDepotData
EXECUTE(@Query)

-- PULL THE ORDER NUMBER FROM THE DEPOT TEMPORAL TABLE
SELECT	@OrderNumber = order_number 
FROM	#tmpDepotData

-- DEFINE QUERY TO QUERY SWS TRUCKING SYSTEM ORDER TABLE
SET @Query = N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''SELECT no as order_number, cref AS Reference, shlp_code AS BillToCode, shname AS BillToName FROM trk.order WHERE no = ' + @OrderNumber + ''')'

-- INSERT THE SWS TRUCKING SYSTEM ORDER TABLE DATA IN TEMPORAL TABLE
INSERT INTO #tmpProData
EXECUTE(@Query)

-- JOIN BOTH TABLES RESULTS
SELECT	DEP.*
		,PRO.Reference
		,PRO.BillToCode
		,PRO.BillToName
FROM	#tmpDepotData DEP
		LEFT JOIN #tmpProData PRO ON DEP.order_number = PRO.OrderNumber

-- DELETE TEMPORAL TABLES
DROP TABLE #tmpDepotData
DROP TABLE #tmpProData