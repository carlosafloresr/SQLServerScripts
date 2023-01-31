CREATE PROCEDURE USP_FixGreatPlainsGLDescriptions
AS
DECLARE	@Company	Varchar(5),
		@Query		Varchar(MAX)

DECLARE Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT CompanyId FROM Dynamics.dbo.View_Companies

OPEN Companies 
FETCH FROM Companies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = RTRIM(@Company) + '.dbo.USP_FixGLReferences'
	
	EXECUTE(@Query)

	FETCH FROM Companies INTO @Company
END

CLOSE Companies
DEALLOCATE Companies