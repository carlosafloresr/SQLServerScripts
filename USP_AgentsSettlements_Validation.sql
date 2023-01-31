/*
EXECUTE USP_AgentsSettlements_Validation 'NDS20181117'
EXECUTE USP_AgentsSettlements_Validation
*/
ALTER PROCEDURE USP_AgentsSettlements_Validation
		@BatchId	Varchar(20) = Null
AS
DECLARE	@tblAgents	Table (
		Agent					Varchar(3), 
		VendorId				Varchar(15), 
		ChassisBillingDeferral	Bit,
		ChassisBillingAccount	Varchar(20) Null,
		AgentRecoveryAccount	Varchar(20) Null,
		AgentFeesAccount		Varchar(20) Null)

INSERT INTO @tblAgents (Agent, VendorId, ChassisBillingDeferral)
SELECT	DISTINCT Agent, 
		VendorId, 
		ChassisBillingDeferral
FROM	Agents
WHERE	Inactive = 0
		AND (@BatchId IS Null
		OR (@BatchId IS NOT Null 
		AND Agent IN (SELECT Agent FROM AgentsSettlementsCommisions WHERE BatchId = @BatchId AND BatchApproved = 1 AND Integrated = 0)))

UPDATE	@tblAgents
SET		ChassisBillingAccount = DATA.ACTNUMST
FROM	(
		SELECT	RTRIM(ACTNUMBR_1) AS Agent1, RTRIM(ACTNUMBR_1) + '-' + RTRIM(ACTNUMBR_2) + '-' + RTRIM(ACTNUMBR_3) AS ACTNUMST
		FROM	NDS.dbo.GL00100 
		WHERE	ACTIVE = 1 
				AND ACTNUMBR_3 = '2100'
				AND ACTNUMBR_1 IN (SELECT	DISTINCT Agent
									FROM	Agents
									WHERE	Inactive = 0)
		) DATA
WHERE	Agent = DATA.Agent1

UPDATE	@tblAgents
SET		AgentRecoveryAccount = DATA.ACTNUMST
FROM	(
		SELECT	RTRIM(ACTNUMBR_1) AS Agent1, RTRIM(ACTNUMBR_1) + '-' + RTRIM(ACTNUMBR_2) + '-' + RTRIM(ACTNUMBR_3) AS ACTNUMST
		FROM	NDS.dbo.GL00100 
		WHERE	ACTIVE = 1 
				AND ACTNUMBR_3 = '1107'
				AND ACTNUMBR_1 IN (SELECT	DISTINCT Agent
											FROM	Agents
											WHERE	Inactive = 0)
		) DATA
WHERE	Agent = DATA.Agent1

UPDATE	@tblAgents
SET		AgentFeesAccount = DATA.ACTNUMST
FROM	(
		SELECT	RTRIM(ACTNUMBR_1) AS Agent1, RTRIM(ACTNUMBR_1) + '-' + RTRIM(ACTNUMBR_2) + '-' + RTRIM(ACTNUMBR_3) AS ACTNUMST, *
		FROM	NDS.dbo.GL00100 
		WHERE	ACTIVE = 1 
				AND ACTNUMBR_3 = '6220'
				AND ACTNUMBR_1 IN (SELECT	DISTINCT Agent
											FROM	Agents
											WHERE	Inactive = 0)
		) DATA
WHERE	Agent = DATA.Agent1

IF @BatchId IS Null
	SELECT	*,
			CASE WHEN VendorId IS Null THEN 'Vendor Id not defined'
			WHEN ChassisBillingDeferral = 1 AND ChassisBillingAccount IS Null THEN 'Chassis Billing GL account not found. Add it in GP.'
			WHEN AgentRecoveryAccount IS Null THEN 'Agent Recovery GL account not found. Add it in GP.'
			WHEN AgentFeesAccount IS Null THEN 'Agent Recovery GL account not found. Add it in GP.'
			ELSE '' END AS Exception
	FROM	@tblAgents
	ORDER BY Agent
ELSE
	SELECT	Agent,
			CASE WHEN VendorId IS Null THEN 'Vendor Id not defined'
			WHEN ChassisBillingDeferral = 1 AND ChassisBillingAccount IS Null THEN 'Chassis Billing GL account not found'
			WHEN AgentRecoveryAccount IS Null THEN 'Agent Recovery GL account not found'
			ELSE 'Agent Fees GL account not found' END AS Exception
	FROM	@tblAgents
	WHERE	VendorId IS Null
			OR (ChassisBillingDeferral = 1 AND ChassisBillingAccount IS Null)
			OR AgentRecoveryAccount IS Null
			OR AgentFeesAccount IS Null
	ORDER BY Agent