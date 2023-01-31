/*
EXECUTE sp_RSA_FindOriginAndDestination 42033
*/
ALTER PROCEDURE sp_RSA_FindOriginAndDestination (@TicketNumber Int)
AS
DECLARE	@ProNumber	Varchar(12),
		@DriverId	Varchar(12),
		@CompanyId	Varchar(5),
		@Company	Int,
		@Division	Char(2),
		@Pro		Varchar(10),
		@Query		Varchar(Max)

SELECT	@ProNumber	= RTRIM(ProNumber),
		@CompanyId	= RTRIM(Company),
		@DriverId	= UPPER(RTRIM(DriverNumber))
FROM	DriverInfo
WHERE	IdRepairNumber = @TicketNumber

SET @Company	= (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId)
SET	@Division	= dbo.PADL(LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1), 2, '0')
SET	@Pro		= SUBSTRING(@ProNumber, dbo.AT('-', @ProNumber, 1) + 1, 7)
SET @Query		= N'SELECT	MOV.OName AS OriginName,
	LOR.Addr1 AS OriginAddress,
	MOV.OCity AS OriginCity,
	MOV.OSt_Code AS OriginState,
	MOV.OZip AS OriginZip,
	MOV.DName AS DestinationName,
	LDE.Addr1 AS DestinationAddress,
	MOV.DCity AS DestinationCity,
	MOV.DSt_Code AS DestinationState,
	MOV.DZip AS DestinationZip,
	MOV.NO AS LODPId
FROM	Trk.Order ORD
	LEFT JOIN Trk.Move MOV ON ORD.No = MOV.Or_No
	LEFT JOIN Trk.LocProf LOR ON MOV.Cmpy_No = LOR.Cmpy_No AND MOV.OLP_Code = LOR.Code
	LEFT JOIN Trk.LocProf LDE ON MOV.Cmpy_No = LDE.Cmpy_No AND MOV.DLP_Code = LDE.Code
WHERE ORD.Cmpy_No = ' + CAST(@Company AS Varchar) + ' AND ORD.Div_Code = ''' + @Division + ''' AND ORD.Pro = ''' + @Pro + ''' AND MOV.Dr_Code = ''' + @DriverId + ''''

EXECUTE USP_QuerySWS @Query, '##tmpMove'

UPDATE	DriverInfo
SET		DriverInfo.OriginTitle			= DATA.OriginTitle,
		DriverInfo.OriginAddress		= DATA.OriginAddress,
		DriverInfo.DestinationTitle		= DATA.DestinationTitle,
		DriverInfo.DestinationAddress	= DATA.DestinationAddress
FROM	(
		SELECT	'Origin: ' + RTRIM(OriginName) AS OriginTitle,
				RTRIM(OriginAddress) + ', ' + RTRIM(OriginCity) + ', ' + RTRIM(OriginState) + ' ' + RTRIM(OriginZip) AS OriginAddress,
				'Destination: ' + RTRIM(DestinationName) AS DestinationTitle,
				RTRIM(DestinationAddress) + ', ' + RTRIM(DestinationCity) + ', ' + RTRIM(DestinationState) + ' ' + RTRIM(DestinationZip) AS DestinationAddress
		FROM	##tmpMove
		) DATA
WHERE	DriverInfo.IdRepairNumber = @TicketNumber

DROP TABLE ##tmpMove