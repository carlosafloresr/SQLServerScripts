USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[DMS_ReceivedTransactions_Load]    Script Date: 6/16/2022 10:03:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================
-- Author:		Jeff Crumbley
-- Create date: 2008-04-28
-- Description:	Used to load information from Postgres View into  
--				dminvoice_test table on SQL Server
-- =======================================================================
ALTER PROCEDURE [dbo].[DMS_ReceivedTransactions_Load]
	@batch VARCHAR(254)
AS
BEGIN
--------------------------------------------------------------------------
-- Required Code prior to passing request to PostgreSQL - Start
--------------------------------------------------------------------------
Declare @MyString varchar(max),
		@ToExecute1 int,
		@ToExecute2 int

SET @ToExecute1 = (Select count(invoice_no) from [findata-intg-ms.imcc.com].Integrations.dbo.DMS_ReceivedTransactions where batch_no=@batch and status between 0 and 1)

IF @ToExecute1 >= 0 or @ToExecute1 = null
	BEGIN
	
		IF @ToExecute1 > 0
		BEGIN
			DELETE FROM [findata-intg-ms.imcc.com].Integrations.dbo.DMS_ReceivedTransactions WHERE batch_no=@batch
		END

		SET	@MyString =
		--------------------------------------------------------------------------
		-- Code to be Modified
		-- Note: Single Quotes (') are to be coded as (''')
		--		For Example: string'+'''value'''+'string
		--		Sample Calls:
		--			EXEC postgre_depot @batch = '1000351'
		--			Select count(*) from DMS_ReceivedTransactions
		--			DELETE FROM DMS_ReceivedTransactions
		--------------------------------------------------------------------------
		--'select * from dminv_dmmiscinv2('+@batch+')'
		'Select glpre '+
		', code as invoice_no '+
		', CAST('+'''IC'''+'|| dmbillto_code::character varying(10) AS varchar(15)) AS customer_no '+
		', batch as batch_no '+ 
		', applyto as apply_to '+
		', type as c_type '+
		', CAST(lifts AS decimal(18,2)) as liftcharge '+
		', CAST(eir AS decimal(18,2)) as eircharge '+
		', CAST(storage AS decimal(18,2)) as storagecharge '+
		', CAST(misc AS decimal(18,2)) as misccharge '+
		', CAST(dem AS decimal(18,2)) as dem '+
		', CAST(total AS decimal(18,2)) as totalcharge '+
		', dmsite_code as location_code '+
		', -1 AS status '+
		', postdate as batch_date '+
		', CURRENT_TIMESTAMP as curr_date '+
		', null as WeekEndDate '+
		' from ( ' +
			'Select a.oid, a.code, a.postdate, a.batch, a.dmbillto_code, a.dmsite_code ' +
			' , d.glpre as glpre ' +
			' , NULL::CHARACTER VARYING(9) AS applyto ' +
			' , ' + '''' + 'I' + '''' + ' AS type' +
			' , SUM(CASE WHEN b.chargetype~' + '''' + 'I|O' + '''' + ' THEN charge ELSE null END) as eir ' +
			' , SUM(CASE WHEN b.chargetype=' + '''' + 'L' + '''' + ' THEN charge ELSE null END) as lifts ' +
			' , SUM(CASE WHEN b.chargetype=' + '''' + 'S' + '''' + ' THEN charge ELSE null END) as storage ' +
			' , NULL::numeric as misc, NULL::numeric as dem ' +
			' , MAX(c.total) as total ' +
			' FROM dminvoice a ' +
			' LEFT OUTER JOIN ( ' +
			'	Select dminvoice_oid, chargetype, Sum(charge) as charge ' +
			'	from dminvoicerec ' +
			'	where dminvoice_oid in ( ' + 
			'		Select oid FROM dminvoice ' +
			'		WHERE postflag=' + '''' + 'Y' + '''' + 
			'		AND postdate IS NOT NULL AND batch = ' + @batch +
			'	) ' +
			'	and chargetype~' + '''' + 'I|O|L|S' + '''' +
			'	group by dminvoice_oid, chargetype ' +
			' ) b ON (a.oid=b.dminvoice_oid) ' + 
			' LEFT OUTER JOIN ( ' +
			'	Select dminvoice_oid, Sum(charge) as total ' +
			'	from dminvoicerec ' +
			'	where dminvoice_oid in ( ' + 
			'		Select oid FROM dminvoice ' +
			'		WHERE postflag=' + '''' + 'Y' + '''' + 
			'		AND postdate IS NOT NULL AND batch = ' + @batch +
			'	) ' +
			'	group by dminvoice_oid ' +
			' ) c ON (a.oid=c.dminvoice_oid) ' + 
			' LEFT OUTER JOIN dmsite d on d.code = a.dmsite_code ' +
			' WHERE a.postflag=' + '''' + 'Y' + '''' + 
			' AND a.postdate IS NOT NULL' +
			' AND a.batch = ' + @batch +
			' group by 1,2,3,4,5,6,7 ' +
			' union ' +
			'Select e.oid, e.code, e.postdate, e.batch, e.dmbillto_code, e.dmsite_code ' +
			' , g.glpre as glpre ' +
			' , e.applyto AS applyto, e.type as type ' +
			' , SUM(CASE WHEN f.glcode=' + '''' + '4010' + '''' + ' THEN charge ELSE null END) as eir ' +
			' , SUM(CASE WHEN f.glcode=' + '''' + '4011' + '''' + ' THEN charge ELSE null END) as lifts ' +
			' , SUM(CASE WHEN f.glcode=' + '''' + '4012' + '''' + ' THEN charge ELSE null END) as storage ' +
			' , SUM(CASE WHEN f.glcode=' + '''' + '4014' + '''' + ' THEN charge ELSE null END) as misc ' +
			' , SUM(CASE WHEN f.glcode=' + '''' + '4015' + '''' + ' THEN charge ELSE null END) as dem ' +
			' , MAX(h.total) as total ' +
			' FROM dmmiscinvoice e ' +
			' LEFT OUTER JOIN ( ' +
			'	Select dmmiscinvoice_code, glcode, Sum(charge) as charge ' +
			'	from dmmiscinvoicerec ' +
			'	where dmmiscinvoice_code in ( ' + 
			'		Select code FROM dmmiscinvoice ' +
			'		WHERE postflag=' + '''' + 'Y' + '''' + 
			'		AND postdate IS NOT NULL AND batch = ' + @batch +
			'	) ' +
			'	and glcode in(' + '''' + '4010' + '''' + ',' +
			'				  ' + '''' + '4011' + '''' + ',' +
			'				  ' + '''' + '4012' + '''' + ',' +
			'				  ' + '''' + '4014' + '''' + ',' +
			'				  ' + '''' + '4015' + '''' + ')' +
			'	group by dmmiscinvoice_code, glcode ' +
			' ) f ON (e.code=f.dmmiscinvoice_code) ' + 
			' LEFT OUTER JOIN ( ' +
			'	Select dmmiscinvoice_code, Sum(charge) as total ' +
			'	from dmmiscinvoicerec ' +
			'	where dmmiscinvoice_code in ( ' + 
			'		Select code FROM dmmiscinvoice ' +
			'		WHERE postflag=' + '''' + 'Y' + '''' + 
			'		AND postdate IS NOT NULL AND batch = ' + @batch +
			'	) ' +
			'	group by dmmiscinvoice_code ' +
			' ) h ON (e.code=h.dmmiscinvoice_code) ' + 
			' LEFT OUTER JOIN dmsite g on g.code = e.dmsite_code ' +
			' WHERE e.postflag=' + '''' + 'Y' + '''' + 
			' AND e.postdate IS NOT NULL' +
			' AND e.batch = ' + @batch +
			' group by 1,2,3,4,5,6,7,8,9 ' +
	    ' ) z order by 6 desc'		
		--------------------------------------------------------------------------
		-- Required Code prior to passing request to PostgreSQL - End
		--------------------------------------------------------------------------
		SET	@MyString = N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''' + REPLACE(@MyString, '''', '''''') + ''')'
		--PRINT @MyString
		INSERT into [findata-intg-ms.imcc.com].Integrations.dbo.DMS_ReceivedTransactions
		EXEC (@MyString)

		UPDATE [findata-intg-ms.imcc.com].Integrations.dbo.DMS_ReceivedTransactions SET WeekEndDate = dbo.DayFwdBack(GETDATE(),'P','Friday') WHERE batch_no = @batch AND Status = -1

		UPDATE [findata-intg-ms.imcc.com].Integrations.dbo.DMS_ReceivedTransactions SET Status = 0 WHERE batch_no = @batch AND Status = -1
	END
END
