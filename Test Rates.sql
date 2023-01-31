DECLARE	@Customer	Varchar(12),
		@Query		Varchar(MAX),
		@ProNumber	Varchar(20)

TRUNCATE TABLE PerDiemProNumbers
TRUNCATE TABLE PerDiemTestRecords

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT RTRIM(CustNmbr) AS CustNmbr
FROM	View_CustomerTiers 
WHERE	(CustNmbr IN (SELECT FreightBillTo FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE BillType > 0 AND FreightBillTo <> '' AND CompanyId = 'GIS')
		OR CustNmbr IN (SELECT CustNmbr FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE BillType > 0 AND CompanyId = 'GIS')
		OR CustNmbr IN (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'GIS')
		OR CustomerNo IN (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'GIS'))

OPEN curData
FETCH FROM curData INTO @Customer

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET	@Query = N'SELECT div_code as division, pro FROM TRK.Order WHERE shdate > ''2011/01/01'' AND bt_code = ''' + @Customer + ''' AND cmpy_no = 2 ORDER BY 1 LIMIT 25'
	
	EXECUTE dbo.USP_QuerySWS @Query, '##tmpData'

	IF @@ROWCOUNT > 0
	BEGIN
		INSERT INTO PerDiemProNumbers
		SELECT	RTRIM(division) + '-' + rtrim(pro), @Customer
		FROM	##tmpData
		WHERE	RTRIM(division) + '-' + rtrim(pro) NOT IN (SELECT ProNumber FROM PerDiemProNumbers)
	END

	DROP TABLE ##tmpData
	
	FETCH FROM curData INTO @Customer
END

CLOSE curData
DEALLOCATE curData

DECLARE PerDiem CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT ProNumber FROM PerDiemProNumbers

OPEN PerDiem 
FETCH FROM PerDiem INTO @ProNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @ProNumber
	EXECUTE USP_PullMoveInformationByProNumber @ProNumber

	FETCH FROM PerDiem INTO @ProNumber
END

CLOSE PerDiem
DEALLOCATE PerDiem

DECLARE	@RecordId			int,
		@Company			int,
		@BillTo				varchar(20),
		@MoveType			char(1),
		@Division			varchar(3),
		@DateOfInterchange	datetime,
		@StartMoveDate		datetime,
		@EndMoveDate		datetime,
		@MoveDays			int,
		@LPCode				varchar(20),
		@PrincipalCode		varchar(15),
		@EquipmentSizeType	varchar(15),
		@IsReefer			bit,
		@UsedDays			smallint,
		@BilledDays			smallint,
		@WeekendDays		smallint,
		@Holidays			smallint,
		@LastFreeDay		date,
		@Tariff				numeric(18,2),
		@Notification		varchar(100)

DECLARE PerDiem CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RecordId
		,Company
		,BillTo
		,MoveType
		,Division
		,DateOfInterchange
		,StartMoveDate
		,EndMoveDate
		,MoveDays
		,LPCode
		,ProNumber
		,PrincipalCode
		,EquipmentSizeType
		,IsReefer 
FROM	PerDiemTestRecords
WHERE	MoveDays > 0
		AND EquipmentId <> ''
		--AND RecordId = 44

OPEN PerDiem 
FETCH FROM PerDiem INTO @RecordId, @Company, @BillTo, @MoveType, @Division, @DateOfInterchange, @StartMoveDate, @EndMoveDate, @MoveDays, @LPCode,
						@ProNumber, @PrincipalCode, @EquipmentSizeType, @IsReefer

WHILE @@FETCH_STATUS = 0
BEGIN
	EXECUTE SPU_CalculateRate_Test @RecordId, @Company, @StartMoveDate, @EndMoveDate, @PrincipalCode, @EquipmentSizeType, Null, @LPCode, 0, @BillTo, @MoveType, @Division, Null
	
	FETCH FROM PerDiem INTO @RecordId, @Company, @BillTo, @MoveType, @Division, @DateOfInterchange, @StartMoveDate, @EndMoveDate, @MoveDays, @LPCode,
							@ProNumber, @PrincipalCode, @EquipmentSizeType, @IsReefer
END

CLOSE PerDiem
DEALLOCATE PerDiem

SELECT	RecordId
		,Company
		,BillTo
		,RTRIM(MoveType) AS MoveType
		,Division
		,DateOfInterchange
		,StartMoveDate
		,EndMoveDate
		,MoveDays
		,LPCode
		,ProNumber
		,PrincipalCode
		,EquipmentSizeType
		,IsReefer
		,EquipmentId
		,FreeDays
		,UsedDays
		,BilledDays
		,[Weekend Days]
		,Holidays
		,LastFreeDay
		,Tariff
		,Notification
		,RateUsed 
FROM	PerDiemTestRecords 
WHERE	MoveDays > 0 
		AND EquipmentId <> ''
		--AND RecordId = 44

/*
EXECUTE SPU_CalculateRate 7, '01/21/2011', '01/27/2011', 'ZIMLI', '40H', Null, 'UPH', 0, '1283', 'I'

SELECT	BillType,
		DoesBillPerDiem,
		FreightBillTo,
		BillToAllLocations
FROM	ILSGP01.GPCustom.dbo.CustomerMaster 
WHERE	CustNmbr				= '1283'
		AND CompanyId			= 'GIS'

SELECT	* 
FROM	View_CustomerTiers 
WHERE	PrincipalID = 'CMA'
		AND EquipmentSize = '40'
		AND EquipmentShortDesc = 'H'
		AND CustNmbr = '1283'


SELECT	*
FROM	View_PrincipalTiers
WHERE	PrincipalID = 'CMA'
		AND EquipmentSize = '40'
		AND EquipmentShortDesc = 'H'

EXECUTE SPU_CalculateRate 7, '01/12/2011', '01/13/2011', 'CMA', '40H', Null, 'PHROPE', 0, '1283', 'I'
*/