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

SELECT	*
FROM	@tblAgents