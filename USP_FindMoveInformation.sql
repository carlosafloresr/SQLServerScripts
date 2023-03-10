USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindMoveInformation]    Script Date: 06/27/2011 13:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindMoveInformation '07-181590', Null, Null, 0, 1
EXECUTE USP_FindMoveInformation '38-146277', 'TAXZ432310', 'FSCU4223819'
EXECUTE USP_FindMoveInformation '36-110593','APMZ234016','MRKU6534943'
EXECUTE USP_FindMoveInformation '36-110593',Null,'MRKU6534943',0
                                                  MRKU653494
EXECUTE USP_FindMoveInformation Null, 'TAXZ432310', 'FSCU4223819'
*/
ALTER PROCEDURE [dbo].[USP_FindMoveInformation]
		@ProNumber		Varchar(15) = Null,
		@Chassis		Varchar(20) = Null,
		@Container		Varchar(20) = Null,
		@OnlyMain		Bit = 1,
		@WithCharges	Bit = 0
AS
DECLARE	@Query			Varchar(MAX),
		@Pro			Varchar(12),
		@Div			Varchar(2),
		@MulFilter		Bit,
		@Equipment		Varchar(20)
		
IF @Container IS NOT Null
	SET @Equipment = LEFT(@Container, LEN(RTRIM(@Container)) - 1)
		
IF @OnlyMain IS Null
	SET @OnlyMain = 0

SET	@MulFilter = 0

SET	@Query = 'SELECT DISTINCT Q.* FROM (SELECT A.cmpy_no AS CompanyNumber, A.tl_code AS equipmentnumber, A.odate, A.ddate, B.div_code, B.pro, B.bt_code, C.code AS customernumber, C.name AS customername,' +
	' C.contact, B.accchg, B.chtype, A.status, A.dr_code, A.drtype, A.paymiles, A.payamt, A.acrudamt,' +
	' B.shlp_code AS ship_code, B.shaddr1 AS ship_address, B.shcity AS ship_city, B.shst_code AS ship_state, B.shzip AS ship_zipcode,' +
	' B.shdate AS ship_date, B.shtime1 AS ship_time, A.ch_code, A.tl_code, A.or_no, B.shname, ' +
	' B.cnname, B.cnaddr1, B.cncity, B.cnst_code, B.cnzip, B.fscamt, B.fscpercent::numeric(9,2), B.cref, ' + 
	CASE WHEN @WithCharges = 1 THEN 'D.t300_code, D.description, D.total,' ELSE '0 AS t300_code, 0 AS description, 0 AS total,' END +
	' A.seq FROM trk.move A' +
	' INNER JOIN trk.order B ON (A.or_no = B.no)' +
	CASE WHEN @WithCharges = 1 THEN ' LEFT JOIN trk.orchrg D ON (A.or_no = D.or_no)' ELSE '' END +
	' LEFT OUTER JOIN com.Billto C ON (A.cmpy_no = C.cmpy_no and B.bt_code = C.code) WHERE '

IF @ProNumber IS NOT Null
BEGIN
	SET	@Div		= LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1)
	SET	@Pro		= REPLACE(@ProNumber, @Div + '-', '')
	SET	@Div		= dbo.PADL(@Div, 2, '0')
	SET	@Query		= @Query + ' (B.pro = ''' + @Pro + ''' AND B.div_code = ''' + @Div + ''')'
	SET	@MulFilter	= 1
END

IF @Chassis IS NOT Null AND @Container IS NOT Null
BEGIN
	SET	@Query		= @Query + CASE WHEN @MulFilter = 1 THEN ' AND' ELSE '' END
	SET	@Query		= @Query + ' (A.ch_code = ''' + @Chassis + ''' OR (A.tl_code = ''' + @Container + ''' OR A.tl_code = ''' + @Equipment + '''))'
	SET	@MulFilter	= 1
END
ELSE
BEGIN
	IF @Chassis IS NOT Null AND @Container IS Null
	BEGIN
		SET	@Query		= @Query + CASE WHEN @MulFilter = 1 THEN ' AND' ELSE '' END
		SET	@Query		= @Query + ' A.ch_code = ''' + @Chassis + ''''
		SET	@MulFilter	= 1
	END	

	IF @Chassis IS Null AND @Container IS NOT Null
	BEGIN
		SET	@Query		= @Query + CASE WHEN @MulFilter = 1 THEN ' AND' ELSE '' END
		SET	@Query		= @Query + ' (A.tl_code = ''' + @Container + ''' OR A.tl_code = ''' + @Equipment + ''')'
		SET	@MulFilter	= 1
	END
END
	
SET	@Query = @Query + ') Q ORDER BY odate DESC'
SET	@Query = N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''' + REPLACE(@Query, '''', '''''') + ''')'

SELECT	*
INTO	#Temp_SWS_MoveData
FROM	SWS_MoveData

PRINT @Query

INSERT INTO #Temp_SWS_MoveData 
EXECUTE(@Query)

IF @OnlyMain = 0
BEGIN
	SELECT	COM.CompanyId
			,COM.CompanyName
			,SWS.companynumber AS CompanyNumber
			,SWS.equipmentnumber AS EquipmentNumber
			,SWS.odate AS OrderDate
			,SWS.ddate AS DestinationDate
			,SWS.div_code AS Division
			,SWS.pro AS Pro
			,SWS.div_code + '-' + SWS.pro AS ProNumber
			,SWS.ch_code AS Chassis
			,SWS.tl_code AS Trailer
			,SWS.customernumber AS CustomerNumber
			,SWS.customername AS CustomerName
			,SWS.contact AS Contact
			,SWS.accchg
			,SWS.chtype
			,SWS.status
			,SWS.dr_code AS DriverId
			,dbo.GetDriverName(COM.CompanyId, SWS.dr_code, SWS.drtype) AS DriverName
			,SWS.drtype AS DriverType
			,SWS.paymiles AS PayMiles
			,SWS.payamt AS PayAmount
			,SWS.acrudamt
			,SWS.ship_code
			,SWS.shname AS Ship_Name
			,SWS.ship_address
			,SWS.ship_city
			,SWS.ship_state
			,SWS.ship_zipcode
			,SWS.ship_date
			,SWS.ship_time
			,SWS.cnname AS Cons_name
			,SWS.cnaddr1 AS Cons_Address
			,SWS.cncity AS Cons_City
			,SWS.cnst_code AS Cons_State
			,SWS.cnzip AS Cons_ZipCode
			,SWS.or_no AS OrderNumber
			,SWS.seq AS ItemNumber
			,SWS.fscamt AS FSCAmount
			,SWS.fscpercent AS FSCPercetage
			,SWS.cref AS ReferenceNumber
			,SWS.t300_code AS ChargeCode
			,SWS.Description AS ChargeDescription
			,SWS.Total AS ChargeAmount
	FROM	#Temp_SWS_MoveData SWS
			INNER JOIN GPCustom.dbo.Companies COM ON SWS.companynumber = COM.CompanyNumber
END
ELSE
BEGIN
	SELECT	COM.CompanyId
			,COM.CompanyName
			,SWS.companynumber AS CompanyNumber
			,SWS.equipmentnumber AS EquipmentNumber
			,SWS.odate AS OrderDate
			,SWS.ddate AS DestinationDate
			,SWS.div_code AS Division
			,SWS.pro AS Pro
			,SWS.div_code + '-' + SWS.pro AS ProNumber
			,SWS.ch_code AS Chassis
			,SWS.tl_code AS Trailer
			,SWS.customernumber AS CustomerNumber
			,SWS.customername AS CustomerName
			,SWS.contact AS Contact
			,SWS.accchg
			,SWS.chtype
			,SWS.status
			,SWS.dr_code AS DriverId
			,dbo.GetDriverName(COM.CompanyId, SWS.dr_code, SWS.drtype) AS DriverName
			,SWS.drtype AS DriverType
			,SWS.paymiles AS PayMiles
			,SWS.payamt AS PayAmount
			,SWS.acrudamt
			,SWS.ship_code
			,SWS.shname AS Ship_Name
			,SWS.ship_address
			,SWS.ship_city
			,SWS.ship_state
			,SWS.ship_zipcode
			,SWS.ship_date
			,SWS.ship_time
			,SWS.cnname AS Cons_name
			,SWS.cnaddr1 AS Cons_Address
			,SWS.cncity AS Cons_City
			,SWS.cnst_code AS Cons_State
			,SWS.cnzip AS Cons_ZipCode
			,SWS.or_no AS OrderNumber
			,SWS.seq AS ItemNumber
			,SWS.fscamt AS FSCAmount
			,SWS.fscpercent AS FSCPercetage
			,SWS.cref AS ReferenceNumber
			,SWS.t300_code AS ChargeCode
			,SWS.Description AS ChargeDescription
			,SWS.Total AS ChargeAmount
	FROM	#Temp_SWS_MoveData SWS
			INNER JOIN GPCustom.dbo.Companies COM ON SWS.companynumber = COM.CompanyNumber
	WHERE	SWS.seq = 1000
END

DROP TABLE #Temp_SWS_MoveData