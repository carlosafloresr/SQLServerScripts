USE [FI_Data]
GO
/****** Object:  StoredProcedure [dbo].[USP_FISpecialReport]    Script Date: 04/26/2013 9:34:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FISpecialReport 'MEMMCP', '03/01/2013', '04/30/2013'
*/
ALTER PROCEDURE [dbo].[USP_FISpecialReport]
		@Customer	Varchar(10) = Null,
		@RepDate1	Date,
		@RepDate2	Date
AS
DECLARE	@Chassis	Varchar(15),
		@Inv_No		Int,
		@Est_Date	Date,
		@Est_Date1	Char(10),
		@Est_Date2	Char(10),
		@Query		Varchar(MAX)

SELECT	INV.Inv_No, INV.Estatus AS [Status], INV.Acct_No, INV.Inv_Date, INV.Est_Date, INV.Inv_Total, INV.Inv_Mech, INV.Chassis, INV.Container, INV.Depot_Loc, 
		SPACE(10) AS EIR_Code, SPACE(8) AS SCAC, SPACE(10) AS EIR_Date, SPACE(5) AS EIR_Time, SPACE(2) AS EIR_Status, SPACE(10) AS Driver_Code, SPACE(12) AS EIR_ProNumber,
		SAL.Part_No, SAL.Descript, SAL.CDex_Damag AS DamageCode, SAL.CDex_Locat AS Position, 
		SAL.Qty_Shiped AS Quantity, SAL.Part_Total AS Parts, 
		SAL.TLabor AS Labor, SAL.ItemTot AS ItemTotal, SPACE(255) AS EIR_Comments
INTO	#tmpReport
FROM	Sale SAL, Invoices INV 
WHERE	SAL.Inv_No = INV.Inv_No
		AND INV.Est_Date BETWEEN @RepDate1 AND @RepDate2
		AND SAL.CDex_Damag IN ('FS', 'RF', 'CU') 
		AND INV.Estatus NOT IN ('CANC') 
		AND ((@Customer IS NOT Null AND INV.Acct_No = @Customer) OR (@Customer IS Null AND INV.Acct_No IN ('DALCGI','FTWCGI','MEMMCP','NASMCP')))
		AND SAL.Bin = 'TIRE' 
ORDER BY INV.Depot_Loc, INV.Inv_No

DECLARE Equipment CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Inv_No, Chassis, Est_Date, REPLACE(CONVERT(Char(10), DATEADD(dd, -30, Est_Date), 102), '.', '/'), REPLACE(CONVERT(Char(10), Est_Date, 102), '.', '/')
FROM	#tmpReport

OPEN Equipment 
FETCH FROM Equipment INTO @Inv_No, @Chassis, @Est_Date, @Est_Date1, @Est_Date2

WHILE @@FETCH_STATUS = 0 
BEGIN
	--SET @Query = 'SELECT EQM.EIR_Code, EIR.Trucker_Code AS SCAC, EIR.UDate AS EIR_Date, EIR.Driver_Code FROM Public.DMEqMast EQM INNER JOIN Public.EIR EIR ON EQM.EIR_Code = EIR.Code AND EIR.EIRType = ''I'' WHERE EQM.Code = ''' + RTRIM(@Chassis) + ''''
	SET @Query = 'SELECT	EIR.code as EIR_Code, 
							EIR.DMSite_Code,
							EIR.trucker_code as SCAC, 
							EIR.edate as EIR_Date, 
							EIR.etime as EIR_Time, 
							EIR.driver_code,
							EIR.DMStatus_Code_Chassis AS EIR_Status,
							EIR.Pro,
							EIR.ChComment1,
							EIR.ChComment2,
							EIR.ChComment3,
							EIR.ChComment4
					FROM 	Public.EIR EIR 
					WHERE 	DMEqMast_Code_Chassis = ''' + RTRIM(@Chassis) + '''
							AND EIRType = ''I''
							AND edate BETWEEN ''' + @Est_Date1 + ''' AND ''' + @Est_Date2 + '''
					ORDER BY EDate DESC, ETime DESC'
					
	EXECUTE FI_Data.dbo.USP_QuerySWS @Query, '##tmpSWS'
	
	UPDATE	#tmpReport
	SET		EIR_Code			= DAT.EIR_Code, 
			SCAC				= DAT.SCAC, 
			EIR_Date			= DAT.EIR_Date,
			EIR_Time			= DAT.EIR_Time,
			Driver_Code			= DAT.Driver_Code,
			EIR_ProNumber		= DAT.Pro,
			EIR_Status			= DAT.EIR_Status,
			EIR_Comments		= CASE WHEN RTRIM(DAT.ChComment1) = '' THEN '' ELSE RTRIM(DAT.ChComment1) + '/' END +
								  CASE WHEN RTRIM(DAT.ChComment2) = '' THEN '' ELSE RTRIM(DAT.ChComment2) + '/' END +
								  CASE WHEN RTRIM(DAT.ChComment3) = '' THEN '' ELSE RTRIM(DAT.ChComment3) + '/' END +
								  CASE WHEN RTRIM(DAT.ChComment3) = '' THEN '' ELSE RTRIM(DAT.ChComment4) END
	FROM	(
			SELECT	TOP 1 *
			FROM	##tmpSWS
			WHERE	EIR_Date <= @Est_Date
			) DAT
	WHERE	#tmpReport.Inv_No	= @Inv_No

	DROP TABLE ##tmpSWS

	FETCH FROM Equipment INTO @Inv_No, @Chassis, @Est_Date, @Est_Date1, @Est_Date2
END

CLOSE Equipment
DEALLOCATE Equipment

SELECT	*
FROM	#tmpReport

DROP TABLE #tmpReport