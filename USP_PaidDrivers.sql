USE [ILS_Datawarehouse]
GO
/****** Object:  StoredProcedure [dbo].[USP_PaidDrivers]    Script Date: 10/5/2020 9:51:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_PaidDrivers 'AIS', '10/31/2019', 'DSDR103119DD,', Null, 0, NULL, 'CFLORES'
EXECUTE USP_PaidDrivers 'IMC', '08/06/2020', 'DSDR080620DD', Null, 0, NULL, 'CFLORES'
EXECUTE USP_PaidDrivers 'NDS', '02/18/2016', NULL, NULL, 0, NULL, 'CFLORES'
EXECUTE USP_PaidDrivers 'PTS', '10/22/2018', NULL, NULL, 1, NULL, 'CFLORES', 1
*/
ALTER PROCEDURE [dbo].[USP_PaidDrivers]
		@Company	Varchar(6),
		@WeekDate	Datetime = Null,
		@BatchId	Varchar(500) = Null,
		@VendorId	Varchar(12) = Null,
		@ShowBatch	Bit = 0,
		@Divisions	Varchar(200) = Null,
		@UserId		Varchar(25) = Null,
		@SortById	Bit = 0
AS
IF @WeekDate IS NOT Null
BEGIN
	IF GPCustom.dbo.WeekDay(@WeekDate) < 5
		SET	@WeekDate = GPCustom.dbo.DayFwdBack(@WeekDate,'N','Thursday')
END

DECLARE @TblAgents TABLE (Agent Char(2))
DECLARE @TblDivisions TABLE (Division Char(2))

IF @Company = 'NDS'
BEGIN
	IF @UserId IS Null OR NOT EXISTS(SELECT TOP 1 Fk_AgentId FROM Intranet.dbo.UserAgents WHERE Fk_UserId = @UserId)
	BEGIN
		INSERT INTO @TblAgents
		SELECT	DISTINCT Agent 
		FROM	GPCustom.dbo.Agents

		PRINT 'No Agents restrictions'
	END
	ELSE
	BEGIN
		INSERT INTO @TblAgents
		SELECT	DISTINCT Agent 
		FROM	GPCustom.dbo.Agents
		WHERE	Agent IN (SELECT Fk_AgentId FROM Intranet.dbo.UserAgents WHERE Fk_UserId = @UserId)

		PRINT 'With Agents restrictions'
	END
END

IF @UserId IS Null OR NOT EXISTS(SELECT TOP 1 Fk_DivisionId FROM Intranet.dbo.UserDivisions WHERE Fk_UserId = @UserId)
BEGIN
	INSERT INTO @TblDivisions
	SELECT	DISTINCT Division 
	FROM	GPCustom.dbo.View_Divisions 
	WHERE	Fk_CompanyId = @Company
			AND IsTrucking = 1

	PRINT 'No Divisions restrictions'
END
ELSE
BEGIN
	IF @Company = 'NDS'
	BEGIN
		INSERT INTO @TblDivisions
		SELECT	DISTINCT DIV.Division
		FROM	GPCustom.dbo.Agents AGN
				INNER JOIN Intranet.dbo.UserAgents UAG ON AGN.Agent = UAG.Fk_AgentId
				INNER JOIN Intranet.dbo.UserDivisions UDV ON AGN.Division = UDV.Fk_DivisionId
				INNER JOIN GPCustom.dbo.View_Divisions DIV ON UDV.Fk_DivisionId = DIV.DivisionId
		WHERE	UAG.Fk_UserId = @UserId
	END
	ELSE
	BEGIN
		INSERT INTO @TblDivisions
		SELECT	DISTINCT Division 
		FROM	GPCustom.dbo.View_Divisions 
		WHERE	Fk_CompanyId = @Company
				AND DivisionId IN (SELECT Fk_DivisionId FROM Intranet.dbo.UserDivisions WHERE Fk_UserId = @UserId)
				AND IsTrucking = 1
	END

	PRINT 'With Divisions restrictions'
END

IF @ShowBatch = 1
BEGIN
	SELECT	DISTINCT REM.VendorId
			,VMA.DriverName AS VendName
			,REM.BatchId
			,VMA.Division
			,VMA.Agent
			,VMA.PaidByPayCard
			,CASE WHEN @SortById = 0 THEN VMA.DriverName ELSE REM.VendorId END AS SortColumn
	FROM	DrvReps_RemittanceAdvise REM
			INNER JOIN GPCustom.dbo.VendorMaster VMA ON REM.CompanyId = VMA.Company AND REM.VendorId = VMA.Vendorid AND (VMA.NewOOSDate IS Null OR VMA.NewOOSDate > @WeekDate)
	WHERE	REM.CompanyId = @Company
			AND REM.BatchId <> ''
			AND (REM.BatchId LIKE '%CK%' OR REM.BatchId LIKE '%DD%')
			AND (@WeekDate IS Null OR (@WeekDate IS NOT Null AND REM.WeekEndDate = @WeekDate))
			AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(REM.BatchId) + '%', @BatchId) > 0))
			AND (@VendorId IS Null OR (@VendorId IS NOT Null AND REM.VendorId = @VendorId))
			AND VMA.Division IN (SELECT Division FROM @TblDivisions)
			AND ((@Company = 'NDS' AND VMA.Agent IN (SELECT Agent FROM @TblAgents)) OR VMA.Agent IS Null)
			AND (@Divisions IS Null OR (@Divisions IS NOT Null AND GPCustom.dbo.AT(VMA.Division, @Divisions, 1) > 0))
	ORDER BY REM.BatchId, 7
END
ELSE
BEGIN
	SELECT	DISTINCT REM.VendorId
			,VMA.DriverName AS VendName
			,VMA.Division
			,VMA.Agent
			,VMA.PaidByPayCard
	FROM	DrvReps_RemittanceAdvise REM
			INNER JOIN GPCustom.dbo.VendorMaster VMA ON REM.CompanyId = VMA.Company AND REM.VendorId = VMA.Vendorid AND (VMA.NewOOSDate IS Null OR VMA.NewOOSDate > @WeekDate)
	WHERE	REM.CompanyId = @Company
			AND REM.BatchId <> ''
			AND (REM.BatchId LIKE '%CK' OR REM.BatchId LIKE '%DD')--AND REM.BatchId LIKE '%DSD%'
			AND (@WeekDate IS Null OR (@WeekDate IS NOT Null AND REM.WeekEndDate = @WeekDate))
			AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(REM.BatchId) + '%', @BatchId) > 0))
			AND (@VendorId IS Null OR (@VendorId IS NOT Null AND REM.VendorId = @VendorId))
			AND VMA.Division IN (SELECT Division FROM @TblDivisions)
			AND ((@Company = 'NDS' AND VMA.Agent IN (SELECT Agent FROM @TblAgents)) OR VMA.Agent IS Null)
			AND (@Divisions IS Null OR (@Divisions IS NOT Null AND PATINDEX('%' + RTRIM(VMA.Division) + '%', @Divisions) > 0))
	ORDER BY VMA.DriverName
END

RETURN @@ROWCOUNT
/*
DSDR022014CK 
DSDR022014DD 

EXECUTE USP_PaidDrivers 'AIS', '02/20/2014', 'DSDR022014DD,', Null, 0, NULL, 'GWoitesek'
EXECUTE USP_PaidDrivers 'NDS', '12/09/2010', 'DSDRV120910DD,', Null, 0, NULL, 'CFLORES'
EXECUTE USP_PaidDrivers 'NDS', '02/20/2014', 'DSDRV022014CK,', Null, 0, NULL, 'BBRENNAN'
SELECT Fk_AgentId FROM Intranet.dbo.UserAgents WHERE Fk_UserId = 'EHURLEY'
SELECT Fk_AgentId FROM Intranet.dbo.UserAgents WHERE Fk_UserId = 'CFLORES'
SELECT * FROM GPCustom.dbo.View_Divisions WHERE DivisionId IN (SELECT Fk_DivisionId FROM Intranet.dbo.UserDivisions WHERE Fk_UserId = 'EHURLEY')
update GPCustom.dbo.VendorMaster SET AGENT = NULL WHERE Company <> 'NDS'
*/