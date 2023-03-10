USE [FRS]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetQueueItems]    Script Date: 3/5/2014 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
	Author:		Sean O'Leary
	Create date: 2/28/2014
	Description:	Get the contents for the FRS work item queue.

	EXECUTE usp_GetQueueItems

=============================================
*/
ALTER PROCEDURE [dbo].[usp_GetQueueItems] 
	-- Add the parameters for the stored procedure here
	@status INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT TICK.ID
			,'' AS Requestor
			,'' AS BillTo
			,TICK.RepairID
			,EQUI.DamageEQ AS EqType
			,CASE EQUI.DepotCode
				WHEN 'C' THEN UPPER(TICK.Chassis)
				WHEN 'R' THEN UPPER(TICK.Container)
				WHEN 'A' THEN UPPER(TICK.Genset)
				WHEN 'F' THEN UPPER(TICK.Genset)
				WHEN 'K' THEN UPPER(TICK.Trailer)
				ELSE UPPER(TICK.TrkNumber)
			END AS Equipment
			,VEND.Name AS Vendor
			,REPS.[Status]
			,TICK.CreatedBy AS Creator
			,CONVERT(VARCHAR, CAST(DISP.ETA AS TIME), 100) AS ETA
			,ISNULL(CONT.CustomerName, CONT.CustomerName + '<br />' + ISNULL(CONT.CustomerPhone, 'NOT PROVIDED')) AS ContactInfo
			,CONT.TrkCmpyName + '<br />' + CONT.TrkCmpyPhone AS TruckCmpy
			,ISNULL(CONT.[DriverName], CONT.[DriverName] + '<br />' + ISNULL(CONT.[DriverPhone], 'NOT PROVIDED')) AS DriverInfo
			,LEFT(CONVERT(VARCHAR, TICK.CreatedTime, 120), 10) + '<br />' + CONVERT(VARCHAR,CAST(TICK.CreatedTime AS TIME), 100) AS Start
	FROM	Tickets AS TICK
			LEFT OUTER JOIN [lookup].[DamagedEquip] AS EQUI ON TICK.DamageEQ = EQUI.ID 
			LEFT OUTER JOIN vwContacts AS CONT ON TICK.RepairID = CONT.RepairID 
			LEFT OUTER JOIN Dispatches AS DISP ON TICK.ID = DISP.RepairID-- AND VEND.ID = DISP.VendorID 
			LEFT OUTER JOIN Vendors AS VEND ON DISP.VendorID = VEND.ID 
			INNER JOIN [lookup].[RepairStatuses] AS REPS ON TICK.Status = REPS.ID
	WHERE	TICK.[Status] < 3
	UNION
	SELECT TICK.ID
			,'' AS Requestor
			,'' AS BillTo
			,TICK.RepairID
			,EQUI.DamageEQ AS EqType
			,CASE EQUI.DepotCode
				WHEN 'C' THEN UPPER(TICK.Chassis)
				WHEN 'R' THEN UPPER(TICK.Container)
				WHEN 'A' THEN UPPER(TICK.Genset)
				WHEN 'F' THEN UPPER(TICK.Genset)
				WHEN 'K' THEN UPPER(TICK.Trailer)
				ELSE UPPER(TICK.TrkNumber)
			END AS Equipment
			,VEND.Name AS Vendor
			,REPS.[Status]
			,TICK.CreatedBy AS Creator
			,CONVERT(VARCHAR, CAST(DISP.ETA AS TIME), 100) AS ETA
			,ISNULL(CONT.CustomerName, CONT.CustomerName + '<br />' + ISNULL(CONT.CustomerPhone, 'NOT PROVIDED')) AS ContactInfo
			,CONT.TrkCmpyName + '<br />' + CONT.TrkCmpyPhone AS TruckCmpy
			,ISNULL(CONT.[DriverName], CONT.[DriverName] + '<br />' + ISNULL(CONT.[DriverPhone], 'NOT PROVIDED')) AS DriverInfo
			,LEFT(CONVERT(VARCHAR, TICK.CreatedTime, 120), 10) + '<br />' + CONVERT(VARCHAR,CAST(TICK.CreatedTime AS TIME), 100) AS Start
	FROM	Tickets AS TICK
			LEFT OUTER JOIN [lookup].[DamagedEquip] AS EQUI ON TICK.DamageEQ = EQUI.ID 
			LEFT OUTER JOIN vwContacts AS CONT ON TICK.RepairID = CONT.RepairID 
			LEFT OUTER JOIN Dispatches AS DISP ON TICK.ID = DISP.RepairID-- AND VEND.ID = DISP.VendorID 
			LEFT OUTER JOIN Vendors AS VEND ON DISP.VendorID = VEND.ID 
			INNER JOIN [lookup].[RepairStatuses] AS REPS ON TICK.Status = REPS.ID
	WHERE	TICK.[Status] = 4
			AND TICK.CompleteDateTime >= GETDATE() - 2
	ORDER BY 13 DESC
END


