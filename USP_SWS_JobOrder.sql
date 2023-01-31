ALTER PROCEDURE USP_SWS_JobOrder (@JobOrd Varchar(25))
AS
DECLARE @Query	Varchar(Max)

SET		@Query = 'SELECT * FROM OPENQUERY(PostgreSQLProd, '
SET		@Query	= @Query  + '''SELECT invno AS RecId, invno AS Inv_No, invdate AS Inv_Date, mrbillto_code AS Acct_No, invtotal AS Inv_Total, mrmechanic_code AS Inv_Mech, Container, Chassis, Genset AS Genset_No FROM mrinv WHERE jo = ''''' + @JobOrd + ''''' ORDER BY invno'') RECS'

EXECUTE(@Query)

-- EXECUTE USP_SWS_JobOrder '200920110DEN'
-- SELECT * FROM OPENQUERY(PostgreSQLProd, 'SELECT * FROM mrinv')
