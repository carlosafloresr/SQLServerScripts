/*
EXECUTE USP_SWS_Inquiry_Moves 104166733
*/
ALTER PROCEDURE USP_SWS_Inquiry_Moves
		@OrderNumber	Int
AS
DECLARE	@Query			Varchar(MAX)

DECLARE	@tblMoves		Table (
		CompanyNumber	Smallint,
		Sequence		Int,
		Status			Char(1),
		DriverId		Varchar(15),
		DriverName		Varchar(75),
		Chassis			Varchar(15),
		Orig_LPCode		Varchar(10),
		Orig_Name		Varchar(40),
		Orig_City		Varchar(30),
		Orig_State		Char(20),
		Orig_Zip		Varchar(15),
		Orig_Date		Date,
		Orig_Time		Char(8),
		Dest_LPCode		Varchar(10),
		Dest_Name		Varchar(40),
		Dest_City		Varchar(30),
		Dest_State		Char(20),
		Dest_Zip		Varchar(15),
		Dest_Date		Date,
		Dest_Time		Char(8),
		PayMile			Smallint,
		PayAmount		Numeric(10,2),
		PayType			Char(1),
		T_Code			Char(5))

IF @OrderNumber = 0
BEGIN
	SELECT	MOV.Sequence,
			MOV.Status,
			MOV.DriverId,
			MOV.DriverName,
			MOV.Chassis,
			MOV.Orig_LPCode,
			Null AS Origin,
			Null AS DepartureDate,
			MOV.Dest_LPCode,
			Null AS Destination,
			Null AS ArrivalDate,
			MOV.PayMile,
			MOV.PayAmount,
			MOV.PayType,
			MOV.T_Code
	FROM	@tblMoves MOV
END
ELSE
BEGIN
	SET @Query = N'SELECT M.Cmpy_No, M.Seq, M.Status, M.Dr_Code, D.Name, M.Ch_Code, M.OLP_Code, M.OName, M.Ocity, Ost_Code, OZip, ODate, OTime, Dlp_Code, DName, DCity, Dst_Code, DZip, DDate, DTime, PayMiles, PayAmt, PayType, M.T_Code FROM TRK.Move M LEFT JOIN TRK.Driver D ON M.Dr_Code = D.Code AND M.Cmpy_No = D.Cmpy_No WHERE M.Or_No = ' + CAST(@OrderNumber AS Varchar)

	INSERT INTO @tblMoves
	EXECUTE USP_QuerySWS_ReportData @Query

	SELECT	DISTINCT MOV.Sequence,
			MOV.Status,
			MOV.DriverId,
			MOV.DriverName,
			MOV.Chassis,
			MOV.Orig_LPCode,
			MOV.Orig_Name + ', ' + RTRIM(MOV.Orig_City) + ', ' + RTRIM(MOV.Orig_State) + ' ' + MOV.Orig_Zip AS Origin,
			CAST(CAST(MOV.Orig_Date AS Varchar) + ' ' + MOV.Orig_Time AS DateTime) AS DepartureDate,
			MOV.Dest_LPCode,
			MOV.Dest_Name + ', ' + RTRIM(MOV.Dest_City) + ', ' + RTRIM(MOV.Dest_State) + ' ' + MOV.Dest_Zip AS Destination,
			CAST(CAST(MOV.Dest_Date AS Varchar) + ' ' + MOV.Dest_Time AS DateTime) AS ArrivalDate,
			MOV.PayMile,
			MOV.PayAmount,
			MOV.PayType,
			MOV.T_Code
	FROM	@tblMoves MOV
			INNER JOIN View_CompanyAgents CPY ON MOV.CompanyNumber = CPY.CompanyNumber
			--LEFT JOIN VendorMaster VMA ON CPY.CompanyId = VMA.Company AND MOV.DriverId = VMA.VendorId
	ORDER BY MOV.Sequence
END