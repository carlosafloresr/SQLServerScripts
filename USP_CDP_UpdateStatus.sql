ALTER PROCEDURE USP_CDP_UpdateStatus
		@BatchId	Char(25),
		@Status		Int
AS
IF @Status = 1
BEGIN
	UPDATE	SWS_DPY 
	SET		Processed = @Status 
	FROM	View_SWS_DPY_CompanyDrivers SWV 
	WHERE	SWS_DPY.Sws_DpyId = SWV.Sws_DpyId 
			AND SWV.BatchId = @BatchId 
			AND SWV.SortKey <> 1
END
ELSE
BEGIN
	UPDATE	SWS_DPY 
	SET		Processed = CASE WHEN SWV.SortKey = 1 THEN 5 ELSE @Status END
	FROM	(
		SELECT Sws_DpyId,
						BatchId,
						Processed, DriverName, AMOUNT,
						CASE WHEN EmpInactive = 1 AND TotalAmount < 0 AND TerminationDate IS NOT Null THEN 0 
							 WHEN TotalAmount < 0 AND BatchId = @BatchId AND TerminationDate IS Null THEN 1 
							 WHEN EmpInactive = 1 AND TotalAmount > 0 THEN 3
						ELSE 2 END AS SortKey
	FROM	(SELECT	Sws_DpyId,
					Company,
					Division,
					Department,
					EmployId,
					DriverCode,
					DriverName,
					PayCode,
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
							GROUP BY DriverCode) SMQ ON SWS.DriverCode = SMQ.DriverCode) SWV 
		WHERE	SWS_DPY.Sws_DpyId = SWV.Sws_DpyId 
				AND (SWV.BatchId = @BatchId OR SWV.Processed = 5)
END

/*
DECLARE	@BatchId	Char(20)
SET		@BatchId = 'CDP223_20080705'

EXECUTE USP_CDP_UpdateStatus 'CDP208_20080705', 1
SELECT * FROM View_SWS_DPY_CompanyDrivers WHERE SortKey = 1

EXECUTE USP_CDP_Batch 'CDP208_20080705'

SELECT * FROM SWS_DPY WHERE Driver_Code = '9584'
update SWS_DPY set processed = 0
*/