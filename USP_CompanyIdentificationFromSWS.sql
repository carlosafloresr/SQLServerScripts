/*
EXECUTE USP_CompanyIdentificationFromSWS 41
*/
CREATE PROCEDURE USP_CompanyIdentificationFromSWS
	@CompanyNumber		Int
AS
DECLARE	@Query			Varchar(2000),
		@SWSCompNmbr	Int

SET @Query = N'SELECT No AS Cmpy_No, AgentOf_Cmpy_No FROM COM.Company WHERE No = ' + CAST(@CompanyNumber AS Varchar)

EXECUTE USP_QuerySWS @Query, '##tmpSWSCompanies'

SELECT	@SWSCompNmbr = CASE WHEN AgentOf_Cmpy_No > 0 THEN AgentOf_Cmpy_No ELSE Cmpy_No END
FROM	##tmpSWSCompanies

SELECT	CompanyId 
FROM	GPCustom.dbo.Companies 
WHERE	CompanyNumber = @SWSCompNmbr

DROP TABLE ##tmpSWSCompanies
GO