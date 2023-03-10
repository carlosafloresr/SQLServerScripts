USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_ImportSWSAgentsandDivisions]    Script Date: 2/18/2016 1:03:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ImportSWSAgentsandDivisions
*/
ALTER PROCEDURE [dbo].[USP_ImportSWSAgentsandDivisions]
AS
SET NOCOUNT OFF

IF EXISTS(SELECT Name FROM tempdb.sys.objects WHERE Name LIKE '%##tmpDataSWSAD%')
	DROP TABLE ##tmpDataSWSAD

IF EXISTS(SELECT Name FROM tempdb.sys.objects WHERE Name LIKE '%##tmpSWSDA%')
	DROP TABLE ##tmpSWSDA

EXECUTE USP_QuerySWS 'SELECT DIV.Cmpy_No AS Agent, DIV.Code AS Division, COM.Name AS AgentName FROM COM.Company COM LEFT JOIN Trk.division DIV ON DIV.Cmpy_No = COM.No WHERE COM.AgentOf_Cmpy_No > 0 AND DIV.Status = ''A'' ORDER BY DIV.Cmpy_No, DIV.Code', '##tmpDataSWSAD'

UPDATE	Agents
SET		Agents.Inactive		= CASE WHEN Agents.Inactive = 0 THEN 1 ELSE Agents.Inactive END,
		Agents.AgentName	= CASE WHEN Agents.AgentName IS Null THEN DATA.AgentName ELSE Agents.AgentName END
FROM	(
			SELECT	AG.AgentId,
					AG.Agent,
					AG.Division,
					SW.Agent AS SW_Agent,
					SW.Division AS SW_Division,
					AG.Inactive,
					SW.AgentName
			FROM	Agents AG
					LEFT JOIN ##tmpDataSWSAD SW ON AG.Agent = SW.Agent AND AG.Division = SW.Division
		) DATA
WHERE	Agents.AgentId = DATA.AgentId
		AND (DATA.SW_Agent IS Null
		OR Agents.Inactive = 0
		OR Agents.AgentName IS Null)

INSERT INTO Agents (Company, Agent, Division, AgentName)
SELECT	'NDS',
		Agent,
		Division,
		AgentName
FROM	##tmpDataSWSAD
WHERE	RTRIM(Agent) + '-' + RTRIM(Division) NOT IN (SELECT RTRIM(Agent) + '-' + RTRIM(Division) FROM Agents)

DROP TABLE ##tmpDataSWSAD

EXECUTE USP_QuerySWS N'SELECT DISTINCT DIV.Code, DIV.Name, CASE WHEN COM.AgentOf_Cmpy_No > 0 THEN COM.AgentOf_Cmpy_No ELSE DIV.Cmpy_No END AS Cmpy_No, DIV.Status, DIV.rgn_code, REG.Name AS rgn_name, COM.Name AS AgentName FROM TRK.Division DIV INNER JOIN com.company COM ON DIV.Cmpy_No = COM.No LEFT JOIN Trk.Region REG ON DIV.rgn_code = REG.Code WHERE DIV.Code <> ''99'' ORDER BY 3, 1', '##tmpSWSDA'

SELECT	Code, Name, CompanyId, rgn_code, rgn_name, MIN(Status) AS Status
INTO	#tmpData
FROM	(
			SELECT	COM.CompanyId,
					SWS.Code,
					SWS.Name,
					SWS.Status,
					SWS.rgn_code,
					SWS.rgn_name
			FROM	##tmpSWSDA SWS
					INNER JOIN Companies COM ON SWS.Cmpy_No = COM.CompanyNumber AND COM.IsTest = 0
		) DATA
GROUP BY Code, Name, CompanyId, rgn_code, rgn_name

INSERT INTO Divisions (Fk_CompanyId, DivisionNumber, Division)
SELECT	CompanyId,
		Code,
		dbo.PROPER(Name)
FROM	#tmpData
WHERE	Status = 'A'
		AND RTRIM(CompanyId) + '_' + RTRIM(Code) NOT IN (SELECT RTRIM(Fk_CompanyId) + '_' + RTRIM(DivisionNumber) FROM Divisions)

UPDATE	Divisions
SET		Divisions.Inactive	= CAST(CASE WHEN Data.Status = 'A' THEN 0 ELSE 1 END AS Bit),
		Divisions.Rgn_Code	= Data.rgn_code,
		Divisions.Region	= RTRIM(Data.rgn_name)
FROM	(
			SELECT	*
			FROM	#tmpData
		) Data
WHERE	Divisions.Fk_CompanyID = Data.CompanyId
		AND Divisions.DivisionNumber = Data.Code
		AND (Divisions.Inactive <> CAST(CASE WHEN Data.Status = 'A' THEN 0 ELSE 1 END AS Bit)
		OR Divisions.Rgn_Code IS Null)

DROP TABLE #tmpData
DROP TABLE ##tmpSWSDA