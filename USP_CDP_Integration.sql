/*
EXECUTE USP_CDP_Integration 'IMC', 'CDP_IMC13-20130316'
*/
ALTER PROCEDURE USP_CDP_Integration
		@Company	Varchar(5),
		@BatchId	Varchar(25)
AS
-- CREATES A TEMPORAL DRIVERS-EMPLOYEES TABLE
SELECT	PAY.EmployId
		,PAY.UserDef1 AS DriverId
		,RTRIM(PAY.LASTNAME) + ', ' + RTRIM(PAY.FRSTNAME) + ' ' + RTRIM(PAY.MIDLNAME) AS EmployeeName
		,PAY.Deprtmnt
		,PAY.Inactive
INTO	#tmpEmployees
FROM	GPCustom.dbo.View_CDP_Integration CDP
		LEFT JOIN AIS.dbo.UPR00100 PAY ON CDP.DriverId = PAY.UserDef1 AND PAY.EMPLCLAS LIKE 'NONE'
WHERE	CDP.Company = 'NONE'

-- CREATES A TEMPORAL PAY CODES TABLE
SELECT	EmployId
		,PayRcord
		,Inactive
INTO	#tmpPayCodes
FROM	AIS.dbo.UPR00400
WHERE	EmployId = '-9-9-'

IF @Company = 'AIS'
BEGIN
	INSERT INTO #tmpEmployees
	SELECT	PAY.EmployId
			,PAY.UserDef1 AS DriverId
			,RTRIM(PAY.LASTNAME) + ', ' + RTRIM(PAY.FRSTNAME) + ' ' + RTRIM(PAY.MIDLNAME) AS EmployeeName
			,PAY.Deprtmnt
			,PAY.Inactive
	FROM	GPCustom.dbo.View_CDP_Integration CDP
			LEFT JOIN AIS.dbo.UPR00100 PAY ON CDP.DriverId = PAY.UserDef1 AND PAY.EMPLCLAS LIKE '%DRV%'
	WHERE	CDP.Company = @Company
			AND CDP.Batchid = @BatchId

	INSERT INTO #tmpPayCodes
	SELECT	EmployId
			,PayRcord
			,Inactive
	FROM	AIS.dbo.UPR00400
	WHERE	EmployId IN (SELECT EmployId FROM #tmpEmployees)
END

IF @Company = 'DNJ'
BEGIN
	INSERT INTO #tmpEmployees
	SELECT	PAY.EmployId
			,PAY.UserDef1 AS DriverId
			,RTRIM(PAY.LASTNAME) + ', ' + RTRIM(PAY.FRSTNAME) + ' ' + RTRIM(PAY.MIDLNAME) AS EmployeeName
			,PAY.Deprtmnt
			,PAY.Inactive
	FROM	GPCustom.dbo.View_CDP_Integration CDP
			LEFT JOIN DNJ.dbo.UPR00100 PAY ON CDP.DriverId = PAY.UserDef1 AND PAY.EMPLCLAS LIKE '%DRV%'
	WHERE	CDP.Company = @Company
			AND CDP.Batchid = @BatchId

	INSERT INTO #tmpPayCodes
	SELECT	EmployId
			,PayRcord
			,Inactive
	FROM	DNJ.dbo.UPR00400
	WHERE	EmployId IN (SELECT EmployId FROM #tmpEmployees)
END

IF @Company = 'GIS'
BEGIN
	INSERT INTO #tmpEmployees
	SELECT	PAY.EmployId
			,PAY.UserDef1 AS DriverId
			,RTRIM(PAY.LASTNAME) + ', ' + RTRIM(PAY.FRSTNAME) + ' ' + RTRIM(PAY.MIDLNAME) AS EmployeeName
			,PAY.Deprtmnt
			,PAY.Inactive
	FROM	GPCustom.dbo.View_CDP_Integration CDP
			LEFT JOIN GIS.dbo.UPR00100 PAY ON CDP.DriverId = PAY.UserDef1 AND PAY.EMPLCLAS LIKE '%DRV%'
	WHERE	CDP.Company = @Company
			AND CDP.Batchid = @BatchId

	INSERT INTO #tmpPayCodes
	SELECT	EmployId
			,PayRcord
			,Inactive
	FROM	GIS.dbo.UPR00400
	WHERE	EmployId IN (SELECT EmployId FROM #tmpEmployees)
END

IF @Company = 'IMC'
BEGIN
	INSERT INTO #tmpEmployees
	SELECT	PAY.EmployId
			,PAY.UserDef1 AS DriverId
			,RTRIM(PAY.LASTNAME) + ', ' + RTRIM(PAY.FRSTNAME) + ' ' + RTRIM(PAY.MIDLNAME) AS EmployeeName
			,PAY.Deprtmnt
			,PAY.Inactive
	FROM	GPCustom.dbo.View_CDP_Integration CDP
			LEFT JOIN IMC.dbo.UPR00100 PAY ON CDP.DriverId = PAY.UserDef1 AND PAY.EMPLCLAS LIKE '%DRV%'
	WHERE	CDP.Company = @Company
			AND CDP.Batchid = @BatchId

	INSERT INTO #tmpPayCodes
	SELECT	EmployId
			,PayRcord
			,Inactive
	FROM	IMC.dbo.UPR00400
	WHERE	EmployId IN (SELECT EmployId FROM #tmpEmployees)
END

IF @Company = 'NDS'
BEGIN
	INSERT INTO #tmpEmployees
	SELECT	PAY.EmployId
			,PAY.UserDef1 AS DriverId
			,RTRIM(PAY.LASTNAME) + ', ' + RTRIM(PAY.FRSTNAME) + ' ' + RTRIM(PAY.MIDLNAME) AS EmployeeName
			,PAY.Deprtmnt
			,PAY.Inactive
	FROM	GPCustom.dbo.View_CDP_Integration CDP
			LEFT JOIN NDS.dbo.UPR00100 PAY ON CDP.DriverId = PAY.UserDef1 AND PAY.EMPLCLAS LIKE '%DRV%'
	WHERE	CDP.Company = @Company
			AND CDP.Batchid = @BatchId

	INSERT INTO #tmpPayCodes
	SELECT	EmployId
			,PayRcord
			,Inactive
	FROM	NDS.dbo.UPR00400
	WHERE	EmployId IN (SELECT EmployId FROM #tmpEmployees)
END

SELECT	SWS.*,
		PAC.Inactive AS PayCodeInactive,
		CASE WHEN EmpInactive = 1 AND TotalAmount < 0 AND TerminationDate IS NOT Null THEN 0 
		     WHEN TotalAmount < 0 AND TerminationDate IS Null THEN 1 
			 WHEN EmpInactive = 1 AND TotalAmount > 0 THEN 3
		ELSE 2 END AS SortKey
FROM	(
		SELECT	SWS.CDP_DetailId AS Sws_DpyId,
				SWS.Company,
				SWS.Division,
				EMP.Deprtmnt AS Department,
				EMP.EmployId,
				SWS.DriverId AS DriverCode,
				EMP.EmployeeName AS DriverName,
				PHR.GP_PayCode AS PayCode,
				SWS.WeekEndingDate AS EndDate,
				SWS.Processed,
				CAST(EMP.Inactive AS Bit) AS EmpInactive,
				SWS.BatchId,
				SUM(SWS.Total - SWS.Applied) AS Amount,
				TOT.TotalAmount,
				SWS.HireDate,
				SWS.TerminationDate,
				SWS.Applied
		FROM	dbo.View_CDP_Integration SWS
				INNER JOIN (SELECT	DriverId,
									SUM(Total) AS TotalAmount
							FROM	View_CDP_Integration
							WHERE	Batchid = @BatchId
							GROUP BY DriverId
							) TOT ON SWS.DriverId = TOT.DriverId
				LEFT JOIN #tmpEmployees EMP ON SWS.DriverId = EMP.DriverId
				LEFT JOIN PHR_PayCodes PHR ON SWS.TransactionType = PHR.SWS_PayCode
		WHERE	SWS.Batchid = @BatchId
				AND SWS.Total <> 0
		GROUP BY
				SWS.CDP_DetailId,
				SWS.Company,
				SWS.Division,
				EMP.Deprtmnt,
				EMP.EmployId,
				SWS.DriverId,
				EMP.EmployeeName,
				EMP.EMPLOYID,
				PHR.GP_PayCode,
				SWS.WeekEndingDate,
				SWS.Processed,
				CAST(EMP.Inactive AS Bit),
				SWS.BatchId,
				TOT.TotalAmount,
				SWS.HireDate,
				SWS.TerminationDate,
				SWS.Applied
		HAVING	SUM(SWS.Total) <> 0
		) SWS
	LEFT JOIN #tmpPayCodes PAC ON SWS.EmployId = PAC.EmployId AND SWS.PayCode = PAC.PayRcord

DROP TABLE #tmpEmployees
DROP TABLE #tmpPayCodes