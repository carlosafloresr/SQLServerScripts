/*
EXECUTE USP_AP_ReceivedIntegration 66
*/
ALTER PROCEDURE USP_AP_ReceivedIntegration
		@ProjectID		Int
AS
DECLARE	@Integration	Varchar(6) = 'DXP',
		@Company		Varchar(5),
		@BatchId		Varchar(15) = 'DEX' + dbo.FormatDateYMD(GETDATE(), 1, 1, 1),
		@GPServer		Varchar(15) = 'PRISQL01P',
		@ReceivedOn		Datetime = GETDATE()

SELECT	@Company = RTRIM(Company)
FROM	PRISQL01P.GPCustom.dbo.DexCompanyProjects
WHERE	ProjectId = @ProjectID
		AND ProjectType = 'AP'

EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId, 0, Null, Null, Null, @ReceivedOn, @GPServer

GO