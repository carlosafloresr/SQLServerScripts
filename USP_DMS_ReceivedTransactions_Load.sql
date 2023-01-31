-- =======================================================================
-- Author:		Jeff Crumbley
-- Create date: 2008-04-28
-- Description:	Used to load information from Postgres View into  
--				dminvoice_test table on SQL Server
--------------------------------------------------------------------------
-- EXECUTE DMS_ReceivedTransactions_Load '1000740'
-- =======================================================================
CREATE PROCEDURE [dbo].[USP_DMS_ReceivedTransactions_Load]
	@Company	Int,
	@BatchId	Varchar(15),
	@PostDate	Date
AS
BEGIN
--------------------------------------------------------------------------
-- Required Code prior to passing request to PostgreSQL - Start
--------------------------------------------------------------------------
DECLARE @MyString	Varchar(max),
		@ToExecute1 Int,
		@ToExecute2 Int,
		@CompanyId	Varchar(5)

IF @Company BETWEEN 10 AND 49
	SET @CompanyId = 'NDS'
ELSE
	SET @CompanyId = (SELECT CompanyId FROM LENSASQL001.GPCustom.dbo.Companies WHERE CompanyNumber = @Company)

SET @ToExecute1 = (SELECT COUNT(invoice_no) FROM dbo.DMS_ReceivedTransactions WHERE batch_no = @BatchId AND status BETWEEN 0 AND 1)

IF @ToExecute1 >= 0 OR @ToExecute1 = Null
	BEGIN
		IF @ToExecute1 > 0
		BEGIN
			DELETE FROM DMS_ReceivedTransactions WHERE batch_no = @BatchId
		END

		SET	@MyString = 'SELECT	a.cmpy_no,
								a.oid, 
								a.code, 
								a.postdate, 
								a.batch, 
								a.dmbillto_code, 
								a.dmsite_code, 
								d.glpre as glpre, 
								NULL::CHARACTER VARYING(9) AS applyto, 
								''I'' AS type , 
								SUM(CASE WHEN b.chargetype~''I|O'' THEN b.charge::real ELSE null END) as eir, 
								SUM(CASE WHEN b.chargetype=''L'' THEN b.charge::real ELSE null END) as lifts, 
								SUM(CASE WHEN b.chargetype=''S'' THEN b.charge::real ELSE null END) as storage, 
								NULL::numeric as misc, 
								NULL::numeric as dem, 
								SUM(b.charge::real) as total
						FROM	dminvoice a
								LEFT JOIN dminvoicerec b ON a.oid = b.dminvoice_oid AND b.chargetype~''I|O|L|S''
								LEFT JOIN dmsite d on d.code = a.dmsite_code 
						WHERE	a.cmpy_no = ' + CAST(@Company AS Varchar) + '
								AND a.batch = ' + RTRIM(@BatchId) + '
								AND a.postdate IS NOT NULL
								AND a.postflag = ''Y'' 	
						GROUP BY 1,2,3,4,5,6,7,8
						UNION
						SELECT	e.cmpy_no,
								e.oid, 
								e.code, 
								e.postdate, 
								e.batch, 
								e.dmbillto_code, 
								e.dmsite_code, 
								g.glpre AS glpre, 
								e.applyto AS applyto, 
								e.type AS type, 
								SUM(CASE WHEN f.glcode=''4010'' THEN f.charge::real ELSE null END) AS eir, 
								SUM(CASE WHEN f.glcode=''4011'' THEN f.charge::real ELSE null END) AS lifts, 
								SUM(CASE WHEN f.glcode=''4012'' THEN f.charge::real ELSE null END) AS storage, 
								SUM(CASE WHEN f.glcode=''4014'' THEN f.charge::real ELSE null END) AS misc, 
								SUM(CASE WHEN f.glcode=''4015'' THEN f.charge::real ELSE null END) as dem, 
								SUM(f.charge::real) AS total  
						FROM	dmmiscinvoice e
								LEFT JOIN dmmiscinvoicerec f ON e.code = f.dmmiscinvoice_code AND f.glcode IN (''4010'', ''4011'', ''4012'', ''4014'', ''4015'')
								LEFT JOIN dmsite g on g.code = e.dmsite_code  
						WHERE	e.cmpy_no = ' + CAST(@Company AS Varchar) + '
								AND e.batch = ' + RTRIM(@BatchId) + '
								AND e.postdate IS NOT NULL 
								AND e.postflag = ''Y''
						GROUP BY 1,2,3,4,5,6,7,8,9,10'

		EXECUTE USP_QuerySWS @MyString, '##tmpDMSData'
		--------------------------------------------------------------------------
		-- Required Code prior to passing request to PostgreSQL - End
		--------------------------------------------------------------------------
		--SET	@MyString = N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''' + REPLACE(@MyString, '''', '''''') + ''')'
				
		INSERT INTO Integrations.dbo.DMS_ReceivedTransactions 
				(glpre
				,invoice_no
				,customer_no
				,batch_no
				,apply_to
				,c_type
				,liftcharge
				,eircharge
				,storagecharge
				,misccharge
				,dem
				,totalcharge
				,location_code
				,status
				,batch_date
				,curr_date
				,WeekEndDate
				,cmpy_no)
		SELECT	glpre
				, code AS invoice_no
				, 'IC' + RTRIM(dmbillto_code) AS customer_no
				, batch AS batch_no
				, applyto AS apply_to
				, type AS c_type
				, CAST(lifts AS decimal(18,2)) AS liftcharge
				, CAST(eir AS decimal(18,2)) AS eircharge
				, CAST(storage AS decimal(18,2)) AS storagecharge
				, CAST(misc AS decimal(18,2)) AS misccharge
				, CAST(dem AS decimal(18,2)) AS dem
				, CAST(total AS decimal(18,2)) AS totalcharge
				, dmsite_code AS location_code
				, 0 AS status
				, postdate AS batch_date
				, GETDATE() AS curr_date
				, dbo.DayFwdBack(@PostDate, 'P', 'Friday') AS WeekEndDate
				, cmpy_no
		FROM	##tmpDMSData
		WHERE	total <> 0

		DROP TABLE ##tmpDMSData

		IF @@ERROR = 0
		BEGIN
			EXECUTE USP_ReceivedIntegrations 'DMS', @CompanyId, @BatchId, 0
		END

		--UPDATE Integrations.dbo.DMS_ReceivedTransactions SET WeekEndDate = dbo.DayFwdBack(GETDATE(),'P','Friday') WHERE batch_no = @batch AND Status = -1
		--UPDATE Integrations.dbo.DMS_ReceivedTransactions SET Status = 0 WHERE batch_no = @BatchId AND Status = -1
	END
END
