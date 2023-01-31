/*
EXECUTE USP_DriversByUser 'AIS', 'CFLORES', 1, 1
EXECUTE USP_DriversByUser 'NDS', 'CFLORES'
EXECUTE USP_DriversByUser 'NDS', 'EHURLEY', 1
*/
ALTER PROCEDURE USP_DriversByUser
	@Company	Varchar(50),
	@UserId		Varchar(25),
	@Status		Int = 0, -- 0 = All, 1 = Active, 2 = Inactive,
	@OrderBy	Int = 0 -- 0 = Name, 1 = Vendor Id
AS
DECLARE @TblAgents		TABLE (Agent Char(2))
DECLARE @TblDivisions	TABLE (Division Char(2))

IF @Company = 'NDS'
BEGIN
	IF @UserId IS Null OR NOT EXISTS(SELECT TOP 1 Fk_AgentId FROM Intranet.dbo.UserAgents WHERE Fk_UserId = @UserId)
	BEGIN
		INSERT INTO @TblAgents
		SELECT	DISTINCT Agent 
		FROM	GPCustom.dbo.Agents
	END
	ELSE
	BEGIN
		INSERT INTO @TblAgents
		SELECT	DISTINCT Agent 
		FROM	GPCustom.dbo.Agents
		WHERE	Agent IN (SELECT Fk_AgentId FROM Intranet.dbo.UserAgents WHERE Fk_UserId = @UserId)
	END
END

IF @UserId IS Null OR NOT EXISTS(SELECT TOP 1 Fk_DivisionId FROM Intranet.dbo.UserDivisions WHERE Fk_UserId = @UserId)
BEGIN
	INSERT INTO @TblDivisions
	SELECT	DISTINCT Division 
	FROM	GPCustom.dbo.View_Divisions 
	WHERE	IsTrucking = 1
END
ELSE
BEGIN
	INSERT INTO @TblDivisions
	SELECT	DISTINCT Division 
	FROM	GPCustom.dbo.View_Divisions 
	WHERE	DivisionId IN (SELECT Fk_DivisionId FROM Intranet.dbo.UserDivisions WHERE Fk_UserId = @UserId)
			AND IsTrucking = 1
END

IF @OrderBy = 0
	SELECT	VMA.VendorId,
			ISNULL(VMA.DriverName, UPPER(GPCustom.dbo.GetDriverName(@Company, VMA.VendorId, 'O'))) AS DriverName,
			CAST(VMA.HireDate AS Date) AS HireDate,
			CAST(VMA.TerminationDate AS Date) AS TerminationDate,
			VMA.Division,
			CASE WHEN @Company = 'NDS' THEN VMA.Agent ELSE Null END AS Agent
	FROM	GPCustom.dbo.VendorMaster VMA
	WHERE	VMA.Company = @Company
			AND VMA.Division IN (SELECT Division FROM @TblDivisions)
			AND ((@Company = 'NDS' AND VMA.Agent IN (SELECT Agent FROM @TblAgents)) OR VMA.VendorId <> '-99-')
			AND (@Status = 0 OR (@Status = 1 AND VMA.TerminationDate IS Null) OR (@Status = 2 AND VMA.TerminationDate IS NOT Null))
	ORDER BY 2
ELSE
	SELECT	VMA.VendorId,
			ISNULL(VMA.DriverName, UPPER(GPCustom.dbo.GetDriverName(@Company, VMA.VendorId, 'O'))) AS DriverName,
			CAST(VMA.HireDate AS Date) AS HireDate,
			CAST(VMA.TerminationDate AS Date) AS TerminationDate,
			VMA.Division,
			CASE WHEN @Company = 'NDS' THEN VMA.Agent ELSE Null END AS Agent
	FROM	GPCustom.dbo.VendorMaster VMA
	WHERE	VMA.Company = @Company
			AND VMA.Division IN (SELECT Division FROM @TblDivisions)
			AND ((@Company = 'NDS' AND VMA.Agent IN (SELECT Agent FROM @TblAgents)) OR VMA.VendorId <> '-99-')
			AND (@Status = 0 OR (@Status = 1 AND VMA.TerminationDate IS Null) OR (@Status = 2 AND VMA.TerminationDate IS NOT Null))
	ORDER BY 1