USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_Find_SWS_EIR]    Script Date: 06/16/2011 09:58:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Find_SWS_EIR 3590823
*/
ALTER PROCEDURE [dbo].[USP_Find_SWS_EIR] (@EIRCode Int)
AS
DECLARE	@Query			Varchar(MAX),
		@OrderNumber	Varchar(20)
		
CREATE TABLE #tmpDepotData
	(CompanyNumber	Int,
	EIR_Code		Varchar(10),
	EIR_Type		Varchar(8), 
	EIR_Date		Datetime, 
	BillToCode		Varchar(5),
	BillToName		Varchar(35),
	Container		Varchar(10), 
	Chassis			Varchar(10), 
	SiteId			Varchar(6),
	SiteCode		Varchar(7),
	SiteCity		Varchar(20),
	TruckerId		Varchar(10),
	Seal			Varchar(20),
	Note			Varchar(40),
	DriverId		Varchar(6),
	DriverName		Varchar(30),
	DriverDivision	Char(2),
	DriverType		Char(1),
	MyTruckDate		Datetime,
	OrderNumber		Int,
	ProNumber		Varchar(10),
	ReceivedBy		Varchar(8),
	ReceivedByName	Varchar(30))

CREATE TABLE #tmpProData
	(OrderNumber	Int,
	ProBillToCode	Varchar(6),
	ProBillToName	Varchar(30),
	Pickup_Date		Datetime,
	LOD_Equipment	Varchar(10),
	LOD_DriverId	Varchar(10))

-- DEFINE QUERY TO QUERY SWS DEPOT MANAGEMENT SYSTEM
SET @Query = N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''SELECT DEP.company_number AS CompanyNumber, EIR.code AS eir_code, EIR.eirtype AS EIR_type, (edate::varchar(10) || '''' '''' || etime::varchar(8))::TIMESTAMP AS EIR_Date, EIR.dmbillto_code AS BillToCode, BIL.name AS BillToName, dmeqmast_code_container AS container, dmeqmast_code_chassis as chassis, EIR.dmsite_code AS SiteId, DMS.shortdesc AS SiteCode, DMS.city AS SiteCity, trucker_code AS TruckerId, seal, chcomment1 AS Note, EIR.driver_code AS DriverId, DRV.name as DriverName, DRV.Div_Code AS DriverDivision, DRV.Type AS DriverType, DRV.mytruckdt AS MyTuckDate, EIR.order_number AS OrderNumber, EIR.pro as pronumber, EIR.alogin AS ReceivedBy, UID.Name AS ReceivedByName FROM public.eir EIR INNER JOIN com.userid UID ON EIR.alogin = UID.code LEFT JOIN trk.driver DRV ON EIR.driver_code = DRV.code INNER JOIN public.dmsite DMS ON EIR.dmsite_code = DMS.code LEFT JOIN public.dmbillto BIL ON EIR.dmbillto_code = BIL.code LEFT JOIN com.dep2pro DEP ON EIR.code = DEP.eir_code WHERE EIR.code = ''''' + CAST(@EIRCode AS Varchar(12)) + ''''''')'

-- INSERT THE SWS DEPOT MANAGEMENT SYSTEM DATA IN TEMPORAL TABLE
INSERT INTO #tmpDepotData
EXECUTE(@Query)

-- PULL THE ORDER NUMBER FROM THE DEPOT TEMPORAL TABLE
SELECT	@OrderNumber = OrderNumber 
FROM	#tmpDepotData

-- DEFINE QUERY TO QUERY SWS TRUCKING SYSTEM ORDER TABLE
SET @Query = N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''SELECT ORD.no AS OrderNumber, ORD.bt_code AS BillToCode, BIL.name AS ProBillToName, MOV.odate AS Pickup_Date, ORD.tlolp_code AS LOD_Equipment, MOV.dr_code AS LOD_DriverId FROM trk.order ORD INNER JOIN com.billto BIL ON ORD.bt_code = BIL.code AND ORD.cmpy_no = BIL.cmpy_no LEFT JOIN trk.move MOV ON ORD.no = MOV.or_no WHERE ORD.no = ' + @OrderNumber + ''')'

-- INSERT THE SWS TRUCKING SYSTEM ORDER TABLE DATA IN TEMPORAL TABLE
INSERT INTO #tmpProData
EXECUTE(@Query)

-- JOIN BOTH TABLES RESULTS

SELECT	COM.CompanyId,
		EIR.EIR_Code,
		EIR.EIR_Type,
		EIR.EIR_Date,
		EIR.BillToCode,
		EIR.BillToName,
		EIR.Container,
		EIR.Chassis,
		EIR.SiteId,
		EIR.SiteCode,
		EIR.SiteCity,
		EIR.TruckerId,
		EIR.Seal,
		EIR.Note,
		EIR.DriverId,
		EIR.DriverName,
		EIR.DriverDivision,
		CASE WHEN EIR.MyTruckDate IS Null THEN (CASE WHEN EIR.DriverType = 'C' THEN 'Company Driver' ELSE 'Owner Operator' END) ELSE 'My Truck' END AS DriverType,
		EIR.OrderNumber,
		EIR.ProNumber,
		EIR.ReceivedBy,
		EIR.ReceivedByName,
		PRO.ProBillToCode,
		PRO.ProBillToName,
		PRO.Pickup_Date,
		PRO.LOD_Equipment,
		PRO.LOD_DriverId
FROM	#tmpDepotData EIR
		INNER JOIN Companies COM ON EIR.CompanyNumber = COM.CompanyNumber
		LEFT JOIN #tmpProData PRO ON EIR.OrderNumber = PRO.OrderNumber

-- DELETE TEMPORAL TABLES
DROP TABLE #tmpDepotData
DROP TABLE #tmpProData

/*
SELECT * FROM OPENQUERY(PostgreSQLPROD, 'SELECT EIR.code AS eir_code, EIR.eirtype AS EIR_type, edate::varchar(10) || '' '' || etime::varchar(8) AS EIR_Date, dmeqmast_code_container AS container, dmeqmast_code_chassis as chassis, dmsite_code AS SiteId, trucker_code AS TruckerId, seal, chcomment1 AS Note, driver_code AS DriverId, DRV.name as DriverName, DRV.Div_Code AS DriverDivision, DRV.Type AS DriverType, DRV.mytruckdt AS MyTuckDate, order_number AS OrderNumber, pro as pronumber, EIR.alogin AS ReceivedBy, UID.Name AS ReceivedByName FROM public.eir EIR INNER JOIN com.userid UID ON EIR.alogin = UID.code LEFT JOIN trk.driver DRV ON EIR.driver_code = DRV.code WHERE EIR.code = ''3590823''')
*/