USE [DepotSystemsViews]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_DataInquiry]    Script Date: 6/2/2020 11:11:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE DepotSystemsViews.dbo.USP_SWS_DataInquiry 0, 'TSXZ605230', 'TEMU677409', '04/27/2020 23:59:00'
EXECUTE DepotSystemsViews.dbo.USP_SWS_DataInquiry 1, 'DCSZ706117', 'EGHU925186', '04/27/2020 09:27:00'
EXECUTE DepotSystemsViews.dbo.USP_SWS_DataInquiry 1, '', 'EGHU925186', '04/27/2020 09:27:00'
*/
ALTER PROCEDURE [dbo].[USP_SWS_DataInquiry]
		@DepoType		Bit,
		@parChassis		Varchar(15),
		@parContainer	Varchar(15),
		@RepDate		Datetime
AS
DECLARE	@Query			Varchar(MAX),
		@Date			Char(10) = CONVERT(Char(10), @RepDate, 101),
		@Time			Char(8) = CAST(CAST(@RepDate AS Time) AS Char(8)),
		@DTValue		Varchar(60) = 'TO_TIMESTAMP(''' + CONVERT(Char(16), @RepDate, 20) + ':00'',''YYYY-MM-DD HH24:MI:SS'')'

IF @DepoType = 0
BEGIN -- TRUCKING
	IF @parChassis <> '' AND @parContainer <> ''
	BEGIN		
		SET @Query = N'SELECT O.Div_Code, O.Pro, M.Tl_Code AS Companion, M.Dr_Code, D.Type, 
							D.Div_Code AS DriverDiv, CONCAT(M.DDate,'' '',M.DTime)::timestamp AS MDate
					FROM	TRK.Move M 
							INNER JOIN TRK.Order O ON M.Or_No = O.No 
							LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = M.Cmpy_No
					WHERE	M.Ch_Code = ''' + @parChassis + ''' AND M.Tl_Code = ''' + @parContainer + ''' 
							AND CONCAT(M.DDate,'' '',M.DTime)::timestamp <= ' + @DTValue + ' 
					ORDER BY M.ADate DESC LIMIT 1'
	END
	ELSE
		IF @parChassis = '' OR @parContainer = ''
		BEGIN
			IF @parChassis <> ''
				SET @Query = N'SELECT O.Div_Code, O.Pro, M.Tl_Code AS Companion, M.Dr_Code, D.Type, 
								D.Div_Code AS DriverDiv, CONCAT(M.DDate,'' '',M.DTime)::timestamp AS MDate
						FROM	TRK.Move M 
								INNER JOIN TRK.Order O ON M.Or_No = O.No 
								LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = M.Cmpy_No
						WHERE	M.Ch_Code = ''' + @parChassis + ''' 
								AND CONCAT(M.DDate,'' '',M.DTime)::timestamp <= ' + @DTValue + ' 
						ORDER BY M.ADate DESC LIMIT 1'
			ELSE
				SET @Query = N'SELECT O.Div_Code, O.Pro, M.Ch_Code AS Companion, M.Dr_Code, D.Type, 
									D.Div_Code AS DriverDiv, CONCAT(M.DDate,'' '',M.DTime)::timestamp AS MDate
							FROM	TRK.Move M 
									INNER JOIN TRK.Order O ON M.Or_No = O.No 
									LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = M.Cmpy_No
							WHERE	M.Tl_Code = ''' + @parContainer + ''' 
									AND CONCAT(M.DDate,'' '',M.DTime)::timestamp <= ' + @DTValue + ' 
							ORDER BY M.ADate DESC LIMIT 1'
		END
END
ELSE
BEGIN -- DEPOT CHECK
	IF @parChassis <> '' AND @parContainer <> ''
	BEGIN		
		SET @Query = N'SELECT E.Code, E.DMEqMast_Code_Container, E.DMStatus_Code_Chassis, 
							E.Driver_Code, E.Pro, CONCAT(E.edate,'' '',E.etime)::timestamp AS IDate, D.Div_Code, D.Type
					FROM	Eir E
							LEFT JOIN TRK.Driver D ON E.Driver_Code = D.Code AND E.Cmpy_No = D.Cmpy_No
					WHERE	E.cmpy_no = 1 AND E.dmeqmast_code_chassis = ''' + @parChassis + ''' 
							AND CONCAT(E.edate,'' '',E.etime)::timestamp <= ' + @DTValue + ' AND E.eirtype = ''I'' 
							AND E.status = ''R'' ORDER BY E.edate DESC, E.etime DESC LIMIT 1'
	END
	ELSE
		IF @parChassis = '' OR @parContainer = ''
		BEGIN
			IF @parChassis <> ''
				SET @Query = N'SELECT E.Code, E.DMEqMast_Code_Container, E.DMStatus_Code_Chassis, 
							E.Driver_Code, E.Pro, CONCAT(E.edate,'' '',E.etime)::timestamp AS IDate, D.Div_Code, D.Type
					FROM	Eir E
							LEFT JOIN TRK.Driver D ON E.Driver_Code = D.Code AND E.Cmpy_No = D.Cmpy_No
					WHERE	E.cmpy_no = 1 AND E.dmeqmast_code_chassis = ''' + @parChassis + ''' 
							AND CONCAT(E.edate,'' '',E.etime)::timestamp <= ' + @DTValue + ' AND E.eirtype = ''I'' 
							AND E.status = ''R'' ORDER BY E.edate DESC, E.etime DESC LIMIT 1'
			ELSE
				SET @Query = N'SELECT E.Code, E.dmeqmast_code_chassis, E.DMStatus_Code_Chassis, 
							E.Driver_Code, E.Pro, CONCAT(E.edate,'' '',E.etime)::timestamp AS IDate, D.Div_Code, D.Type
					FROM	Eir E
							LEFT JOIN TRK.Driver D ON E.Driver_Code = D.Code AND E.Cmpy_No = D.Cmpy_No
					WHERE	E.cmpy_no = 1 AND E.dmeqmast_code_container = ''' + @parContainer + ''' 
							AND CONCAT(E.edate,'' '',E.etime)::timestamp <= ' + @DTValue + ' AND E.eirtype = ''I'' 
							AND E.status = ''R'' ORDER BY E.edate DESC, E.etime DESC LIMIT 1'
		END
END
--PRINT @Query
EXECUTE USP_QuerySWS @Query