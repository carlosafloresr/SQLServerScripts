/*
EXECUTE USP_ExpenseReciveryOps 'IMC', 'TVRAN', '0', 'A'
*/
CREATE PROCEDURE USP_ExpenseReciveryOps
		@Company	Varchar(5),
		@UserId		Varchar(25),
		@Status		Char(1),
		@Product	Char(1)
AS
DECLARE	@Divisions	Table (Division Varchar(3))
DECLARE	@Restricted	Int = (SELECT COUNT(*) FROM Intranet.dbo.UserDivisions WHERE Fk_UserId = @UserId)

IF @Company = 'NDS' AND EXISTS(SELECT TOP 1 Fk_AgentId FROM Intranet.dbo.UserAgents WHERE Fk_UserId = @UserId)
BEGIN
	INSERT INTO @Divisions
	SELECT	DIV.Division
	FROM	GPCustom.dbo.View_Divisions DIV
			INNER JOIN GPCustom.dbo.Agents SWS ON DIV.Division = SWS.Division AND SWS.Agent IN (SELECT Fk_AgentId FROM Intranet.dbo.UserAgents WHERE Fk_UserId = @UserId)
			LEFT JOIN Intranet.dbo.UserDivisions ON DIV.DivisionId = UserDivisions.Fk_DivisionId AND UserDivisions.Fk_UserId = @UserId
	WHERE	Fk_CompanyId = @Company
			AND (UserDivisions.Fk_DivisionId IS NOT Null
			OR @Restricted = 0)
	ORDER BY 
			DIV.Division
END
ELSE
BEGIN
	INSERT INTO @Divisions
	SELECT	DISTINCT DIV.Division
	FROM	GPCustom.dbo.View_Divisions DIV
			LEFT JOIN Intranet.dbo.UserDivisions ON DIV.DivisionId = UserDivisions.Fk_DivisionId AND UserDivisions.Fk_UserId = @UserId
	WHERE	Fk_CompanyId = @Company
			AND (UserDivisions.Fk_DivisionId IS NOT Null
			OR @Restricted = 0)
	ORDER BY 
			DIV.Division
END

SELECT	* 
FROM	View_ExpenseRecovery 
WHERE	Company = @Company
		AND EffDate IS NOT Null
		AND Division IN (SELECT Division FROM @Divisions)
		AND (@Status = 'A' 
			OR (@Status = 'O' AND [Status] = 'Open') 
			OR (@Status = 'C' AND [Status] = 'Closed') 
			OR (@Status = 'P' AND [Status] = 'Pending'))
		--AND DOCNUMBER = '224019' 
ORDER BY Division, EffDate DESC, RepairTypeSort