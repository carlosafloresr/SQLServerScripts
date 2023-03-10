USE [DepotSystemsViews]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_DataInquiry]    Script Date: 7/20/2020 1:39:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE DepotSystemsViews.dbo.USP_SWS_DataInquiry 0, 'IMCZ100017', '', '06/01/2020 12:00:00', 104468671
EXECUTE DepotSystemsViews.dbo.USP_SWS_DataInquiry 1, 'IMCZ100017', '', '06/01/2020 12:11:00'
EXECUTE DepotSystemsViews.dbo.USP_SWS_DataInquiry 1, '', 'EGHU925186', '04/27/2020 09:27:00'
*/
ALTER PROCEDURE [dbo].[USP_SWS_DataInquiry]
		@SearchType		Smallint,
		@parChassis		Varchar(15),
		@parContainer	Varchar(15),
		@RepDate		Datetime,
		@OrderNumber	Int =  Null
AS
DECLARE	@Query			Varchar(MAX),
		@Date			Char(10) = CONVERT(Char(10), @RepDate, 101),
		@Time			Char(8) = CAST(CAST(@RepDate AS Time) AS Char(8)),
		@DTValue		Varchar(60) = 'TO_TIMESTAMP(''' + CONVERT(Char(16), @RepDate, 20) + ':00'',''YYYY-MM-DD HH24:MI:SS'')'

IF @SearchType = 0
BEGIN -- TRUCKING
	IF @parChassis <> '' AND @parContainer <> '' AND @parChassis = @parContainer
		SET @parChassis = ''

	IF @OrderNumber IS NOT Null
	BEGIN
		SET @Query = N'SELECT O.Div_Code, O.Pro, M.Tl_Code AS Companion, M.Dr_Code, D.Type, 
								D.Div_Code AS DriverDiv, CONCAT(M.DDate, '' '', M.DTime)::timestamp AS MDate, M.Or_No
						FROM	TRK.Move M 
								INNER JOIN TRK.Order O ON M.Or_No = O.No 
								LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = D.Cmpy_No
						WHERE	M.Or_No = ' + CAST(@OrderNumber AS Varchar) + '
								AND ((M.DDate  = ''' + @Date + ''' AND M.DTime <= ''' + @Time + ''' ) 
								OR M.DDate  < ''' + @Date + ''') 
						ORDER BY M.ADate DESC LIMIT 1'
	END
	ELSE
	BEGIN
		IF @parChassis <> '' AND @parContainer <> ''
		BEGIN
			SET @Query = N'SELECT O.Div_Code, O.Pro, M.Tl_Code AS Companion, M.Dr_Code, D.Type, 
								D.Div_Code AS DriverDiv, CONCAT(M.DDate,'' '',M.DTime)::timestamp AS MDate, M.Or_No
						FROM	TRK.Move M 
								INNER JOIN TRK.Order O ON M.Or_No = O.No 
								LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = D.Cmpy_No
						WHERE	M.Ch_Code = ''' + @parChassis + ''' AND M.Tl_Code = ''' + @parContainer + ''' 
								AND NOT (M.DLP_Code = ''NRP'' AND M.Dr_Code = ''999'')
								AND ((M.DDate  = ''' + @Date + ''' AND M.DTime <= ''' + @Time + ''' ) 
								OR M.DDate  < ''' + @Date + ''') 
						ORDER BY M.ADate DESC LIMIT 1'
		END
		ELSE
			IF @parChassis = '' OR @parContainer = ''
			BEGIN
				IF @parChassis <> ''
					SET @Query = N'SELECT O.Div_Code, O.Pro, M.Tl_Code AS Companion, M.Dr_Code, D.Type, 
									D.Div_Code AS DriverDiv, CONCAT(M.DDate,'' '',M.DTime)::timestamp AS MDate, M.Or_No
							FROM	TRK.Move M 
									INNER JOIN TRK.Order O ON M.Or_No = O.No 
									LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = D.Cmpy_No
							WHERE	M.Ch_Code = ''' + @parChassis + ''' 
									AND NOT (M.DLP_Code = ''NRP'' AND M.Dr_Code = ''999'')
									AND ((M.DDate  = ''' + @Date + ''' AND M.DTime <= ''' + @Time + ''' ) 
									OR M.DDate  < ''' + @Date + ''')
							ORDER BY M.ADate DESC LIMIT 1'
				ELSE
					SET @Query = N'SELECT O.Div_Code, O.Pro, M.Ch_Code AS Companion, M.Dr_Code, D.Type, 
										D.Div_Code AS DriverDiv, CONCAT(M.DDate,'' '',M.DTime)::timestamp AS MDate, M.Or_No
								FROM	TRK.Move M 
										INNER JOIN TRK.Order O ON M.Or_No = O.No 
										LEFT JOIN TRK.Driver D ON M.DR_Code = D.Code AND M.Cmpy_No = D.Cmpy_No
								WHERE	M.Tl_Code = ''' + @parContainer + ''' 
										AND NOT (M.DLP_Code = ''NRP'' AND M.Dr_Code = ''999'')
										AND ((M.DDate  = ''' + @Date + ''' AND M.DTime <= ''' + @Time + ''' ) 
										OR M.DDate  < ''' + @Date + ''') 
								ORDER BY M.ADate DESC LIMIT 1'
			END
	END
END

IF @SearchType = 1
BEGIN -- DEPOT CHECK
	IF @parChassis <> '' AND @parContainer <> ''
	BEGIN		
		SET @Query = N'SELECT E.Code, E.DMEqMast_Code_Container, E.DMStatus_Code_Chassis, 
							E.Driver_Code, E.Pro, CONCAT(E.edate,'' '',E.etime)::timestamp AS IDate, D.Div_Code, D.Type, E.Order_Number
					FROM	Eir E
							LEFT JOIN TRK.Driver D ON E.Driver_Code = D.Code AND E.Cmpy_No = D.Cmpy_No
					WHERE	E.cmpy_no = 1 AND E.dmeqmast_code_chassis = ''' + @parChassis + ''' 
							AND ((E.EDate  = ''' + @Date + ''' AND E.ETime <= ''' + @Time + ''' ) 
							OR E.EDate  < ''' + @Date + ''') 
							AND E.eirtype = ''I'' AND E.status = ''R'' 
							ORDER BY E.edate DESC, E.etime DESC LIMIT 1'
	END
	ELSE
		IF @parChassis = '' OR @parContainer = ''
		BEGIN
			IF @parChassis <> ''
				SET @Query = N'SELECT E.Code, E.DMEqMast_Code_Container, E.DMStatus_Code_Chassis, 
							E.Driver_Code, E.Pro, CONCAT(E.edate,'' '',E.etime)::timestamp AS IDate, D.Div_Code, D.Type, E.Order_Number
					FROM	Eir E
							LEFT JOIN TRK.Driver D ON E.Driver_Code = D.Code AND E.Cmpy_No = D.Cmpy_No
					WHERE	E.cmpy_no = 1 AND E.dmeqmast_code_chassis = ''' + @parChassis + ''' 
							AND ((E.EDate  = ''' + @Date + ''' AND E.ETime <= ''' + @Time + ''' ) 
							OR E.EDate  < ''' + @Date + ''') 
							AND E.eirtype = ''I'' AND E.status = ''R'' 
					ORDER BY E.edate DESC, E.etime DESC LIMIT 1'
			ELSE
				IF @parContainer = ''
				BEGIN				
					SET @Query = N'SELECT E.Code, E.dmeqmast_code_chassis, E.DMStatus_Code_Chassis, 
								E.Driver_Code, E.Pro, CONCAT(E.edate,'' '',E.etime)::timestamp AS IDate, D.Div_Code, D.Type, E.Order_Number
						FROM	Eir E
								LEFT JOIN TRK.Driver D ON E.Driver_Code = D.Code AND E.Cmpy_No = D.Cmpy_No
						WHERE	E.cmpy_no = 1 AND E.dmeqmast_code_container = ''***NOTHING***'' 
								AND ((E.EDate  = ''' + @Date + ''' AND E.ETime <= ''' + @Time + ''' ) 
								OR E.EDate  < ''' + @Date + ''') 
								AND E.eirtype = ''I'' AND E.status = ''R'' 
						ORDER BY E.edate DESC, E.etime DESC LIMIT 1'
				END
				ELSE
				BEGIN
					SET @Query = N'SELECT E.Code, E.dmeqmast_code_chassis, E.DMStatus_Code_Chassis, 
								E.Driver_Code, E.Pro, CONCAT(E.edate,'' '',E.etime)::timestamp AS IDate, D.Div_Code, D.Type, E.Order_Number
						FROM	Eir E
								LEFT JOIN TRK.Driver D ON E.Driver_Code = D.Code AND E.Cmpy_No = D.Cmpy_No
						WHERE	E.cmpy_no = 1 AND E.dmeqmast_code_container = ''' + @parContainer + ''' 
								AND ((E.EDate  = ''' + @Date + ''' AND E.ETime <= ''' + @Time + ''' ) 
								OR E.EDate  < ''' + @Date + ''') 
								AND E.eirtype = ''I'' AND E.status = ''R'' 
						ORDER BY E.edate DESC, E.etime DESC LIMIT 1'
				END
		END
END

PRINT @Query
EXECUTE USP_QuerySWS @Query