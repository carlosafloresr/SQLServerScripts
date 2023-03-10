USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_SWS_NonInvoicedPayouts]    Script Date: 5/23/2022 12:19:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SWS_ChassisReport 'AIS', '01/25/2021'
EXECUTE USP_SWS_ChassisReport 'GLSO','11/20/2021'
*/
ALTER PROCEDURE [dbo].[USP_SWS_ChassisReport]
		@CompanyId	Varchar(5),
		@RunDate	Date
AS
SET NOCOUNT ON

DECLARE @CmpyNumb	Varchar(3) = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId),
		@Company	Varchar(5) = (SELECT CompanyAlias FROM View_CompanyAgents WHERE  CompanyId = @CompanyId),
		@Query		Varchar(Max)

SET @Query = 'SELECT CAST(a.div_code || ''-'' || a.pro AS STRING) as "DivPro",
         a.no as "Order Number",
         b.code as "Chassis",
         a.chzamt as "Chassis Sales",
         a.chztotvn as "Chassis Cost",
         a.billch_eqocode as "Chassis Owner",
         a.pudt as "Pickup Date",
         a.deldt as "Delivery Date",
         a.chzstartdt as "Chassis Outgate",
         a.chzstopdt as "Chassis Termination Date",
         a.chzusagedays as "Chassis Usage Days",
         a.donedt as "Order Complete Date",
         a.status AS "Order Status"
FROM trk.order a, trk.eqmast b
WHERE a.cmpy_no = ' + @CmpyNumb + ' 
AND a.invdt is null
AND a.status != ''V''
AND a.adate <= ''' + CAST(@RunDate AS Varchar) + ''' 
AND b.or_no = a.no
ORDER BY 1'

PRINT @Query

EXECUTE USP_QuerySWS_ReportData @Query, '##tmpSWS_Data'

SELECT	@Company AS Company,
		DivPro,
		[Order Number],
		Chassis,
		[Chassis Sales],
		[Chassis Cost],
		[Chassis Owner],
		CAST([Pickup Date] AS Date) AS [Pickup Date],
		CAST([Delivery date] AS Date) AS [Delivery Date],
		CAST([Chassis Outgate] AS Date) AS [Chassis Outgate],
		CAST([Chassis Termination Date] AS Date) AS [Chassis Termination Date],
		[Chassis Usage Days],
		CAST([Order Complete Date] AS Date) AS [Order Complete Date],
		[Order Status]
FROM	##tmpSWS_Data

DROP TABLE ##tmpSWS_Data