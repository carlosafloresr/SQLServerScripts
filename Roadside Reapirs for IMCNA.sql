/*
EXECUTE SP_RSA_FindMoveInformation '96-244812', '1069', Null, 1
EXECUTE SP_RSA_FindMoveInformation '09-442356', '13311', Null, 0
*/
ALTER PROCEDURE SP_RSA_FindMoveInformation
		@ProNumber		Varchar(15),
		@DriverId		Varchar(15),
		@Tractor		Varchar(15) = Null,
		@Broker			Bit = 1
AS
SET NOCOUNT ON

DECLARE @Query			Varchar(MAX),
		@Pro			Varchar(15),
		@Div			Varchar(3)

DECLARE	@tblSWS			Table (
		CompanyNumber	Smallint,
		div_code		Varchar(3),
		pro				Varchar(12),
		Container		Varchar(15),
		Chassis			Varchar(15),
		IdStatus		Char(1),
		DriverId		Varchar(15),
		DriverName		Varchar(40),
		Phone			Varchar(20),
		Mobile			Varchar(20),
		TractorNumber	Varchar(20),
		TractorTag		Varchar(20),
		TractorMake		Varchar(40),
		TractorColor	Varchar(20),
		OrderNumber		Numeric(12,0),
		ADate			Date,
		ATime			Varchar(20))

SET	@Div	= LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1)
SET	@Pro	= REPLACE(@ProNumber, @Div + '-', '')
SET	@Div	= dbo.PADL(@Div, 2, '0')

IF @Broker = 0
	SET @Query	= N'SELECT ORD.cmpy_no AS CompanyNumber,
			ORD.div_code,
			ORD.pro,
			ORD.billtl_code AS Container,
			ORD.billch_code AS Chassis,
			MOV.Status AS IdStatus,
			MOV.dr_code AS DriverId,
			DRV.name AS DriverName,
			DRV.phone AS Phone,
			DRV.mobile AS Mobile,
			DRV.t_code AS TractorNumber,
			DRV.ttag AS TractorTag,
			DRV.tmake AS TractorMake,
			DRV.tcolor AS TractorColor,
			MOV.or_no AS OrderNumber,
			MOV.ADate,
			MOV.ATime 
	FROM	trk.order ORD
			INNER JOIN trk.move MOV ON MOV.cmpy_no = ORD.cmpy_no AND MOV.or_no = ORD.no
			INNER JOIN trk.driver DRV ON MOV.dr_code = DRV.code '
ELSE
		SET @Query	= N'SELECT ORD.cmpy_no AS CompanyNumber,
			ORD.div_code,
			ORD.pro,
			ORD.billtl_code AS Container,
			ORD.billch_code AS Chassis,
			MOV.Status AS IdStatus,
			MOV.t_code AS DriverId,
			DRV.name AS DriverName,
			DRV.phone AS Phone,
			'''' AS Mobile,
			'''' AS TractorNumber,
			'''' AS TractorTag,
			'''' AS TractorMake,
			'''' AS TractorColor,
			MOV.or_no AS OrderNumber,
			MOV.ADate,
			MOV.ATime 
	FROM	trk.order ORD
			INNER JOIN trk.move MOV ON MOV.cmpy_no = ORD.cmpy_no AND MOV.or_no = ORD.no
			INNER JOIN trk.vendor DRV ON MOV.t_code = DRV.code '

SET	@Query	= @Query + ' WHERE ORD.pro = ''' + @Pro + ''' AND ORD.div_code = ''' + @Div + ''''

IF @Broker = 1
	SET	@Query	= @Query + ' AND MOV.t_code = ''' + RTRIM(@DriverId) + ''' '
ELSE
BEGIN
	SET	@Query	= @Query + ' AND MOV.dr_code = ''' + RTRIM(@DriverId) + ''' '

	IF @Tractor IS NOT Null
		SET	@Query	= @Query + ' AND DRV.t_code = ''' + RTRIM(@Tractor) + ''' '
END

SET	@Query	= @Query + ' ORDER BY MOV.ADate DESC, MOV.ATime DESC LIMIT 1'

INSERT INTO @tblSWS
EXECUTE USP_QuerySWS_ReportData @Query

SELECT	CompanyNumber,
		div_code AS Division,
		pro,
		div_code + '-' + pro AS ProNumber,
		Container,
		Chassis,
		IdStatus,
		DriverId,
		DriverName,
		Phone,
		Mobile,
		TractorNumber,
		TractorTag,
		TractorMake,
		TractorColor,
		OrderNumber,
		ADate,
		ATime
FROM	@tblSWS


/*

EXECUTE USP_QuerySWS_ReportData 'SELECT * FROM TRK.Order WHERE cmpy_no = 9 and Div_code = 96 and pro = 244812' --96-244812 --current_carrier

EXECUTE USP_QuerySWS_ReportData 'SELECT * FROM TRK.Move WHERE t_code = ''1069''' 

EXECUTE USP_QuerySWS_ReportData 'SELECT * FROM TRK.Vendor WHERE code = ''1069'''

*/