-- EXECUTE USP_CDP_Batch 'CDP208_20080705'
ALTER PROCEDURE [dbo].[USP_CDP_Batch] (@BatchId Char(16))
AS
IF @BatchId = 'WITHNULLS'
BEGIN
	SELECT	DISTINCT EmployId,
			DriverCode,
			DriverName
	FROM	View_SWS_DPY_CompanyDrivers
	WHERE	Processed = 0
			AND EmployId IS Null
	ORDER BY DriverName
END
ELSE
BEGIN
	SELECT	*,
			CASE WHEN EmpInactive = 1 AND TotalAmount < 0 AND TerminationDate IS NOT Null THEN 0 
				 WHEN TotalAmount < 0 AND BatchId = @BatchId AND TerminationDate IS Null THEN 1 
				 WHEN EmpInactive = 1 AND TotalAmount > 0 THEN 3
			ELSE 2 END AS SortKey
	FROM (SELECT	Sws_DpyId,
					Company,
					Division,
					Department,
					EmployId,
					DriverCode,
					DriverName,
					PayCode,
					EndDate - 6 AS StartDate,
					EndDate,
					Processed,
					EmpInactive,
					BatchId,
					HireDate,
					TerminationDate,
					Applied,
					PayCodeInactive,
					Amount
			FROM	View_SWS_DPY_CompanyDrivers
			WHERE	BatchId = @BatchId
			UNION
			SELECT	NEG.Sws_DpyId,
					NEG.Company,
					NEG.Division,
					NEG.Department,
					NEG.EmployId,
					NEG.DriverCode,
					NEG.DriverName,
					NEG.PayCode,
					NEG.EndDate - 6 AS StartDate,
					NEG.EndDate,
					NEG.Processed,
					NEG.EmpInactive,
					NEG.BatchId,
					NEG.HireDate,
					NEG.TerminationDate,
					NEG.Applied,
					NEG.PayCodeInactive,
					NEG.Amount
			FROM	View_SWS_DPY_CompanyDrivers NEG
					INNER JOIN (SELECT	EmployId,
										MAX(TotalAmount) AS TotalAmount
								FROM	View_SWS_DPY_CompanyDrivers
								WHERE	BatchId = @BatchId
										AND Amount <> 0
										--AND Processed < 2
								GROUP BY
										EmployId) TOT ON NEG.EmployId = TOT.EmployId AND NEG.Amount <= TOT.TotalAmount
			WHERE	NEG.Amount < 0 
					AND NEG.Processed = 5
					AND BatchId <> @BatchId) SWS
				INNER JOIN (SELECT  DriverCode, SUM(Amount) AS TotalAmount FROM (SELECT	NEG.DriverCode,
									NEG.Amount
							FROM	View_SWS_DPY_CompanyDrivers NEG
									LEFT JOIN (SELECT	EmployId,
														MAX(TotalAmount) AS TotalAmount
												FROM	View_SWS_DPY_CompanyDrivers
												WHERE	BatchId = @BatchId
														AND Amount > 0
														AND Processed < 2
												GROUP BY
														EmployId) TOT ON NEG.EmployId = TOT.EmployId AND NEG.Amount <= TOT.TotalAmount
							WHERE	BatchId = @BatchId
									OR (NEG.Amount < 0 
									AND NEG.Processed = 5
									AND BatchId <> @BatchId)) RES
							GROUP BY DriverCode) SMQ ON SWS.DriverCode = SMQ.DriverCode
			ORDER BY 21, SWS.DriverName, SWS.PayCode, SWS.EndDate DESC
	/*
	SELECT	SWS.*,
			CNT.Counter,
			SWS.EndDate - 6 AS StartDate
	FROM	View_SWS_DPY_CompanyDrivers SWS
			INNER JOIN (SELECT	DriverCode,
								COUNT(PayCode) AS Counter
						FROM	View_SWS_DPY_CompanyDrivers
						WHERE	BatchId = @BatchId
						GROUP BY DriverCode) CNT ON SWS.DriverCode = CNT.DriverCode
	WHERE	SWS.Processed = 0
			AND SWS.BatchId = @BatchId
	ORDER BY SWS.SortKey, SWS.DriverName, SWS.PayCode
	*/
END