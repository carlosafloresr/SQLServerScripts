USE [ADG]
GO
/****** Object:  StoredProcedure [revAcct].[Closing_Summary_v2]    Script Date: 4/18/2022 10:32:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
Author:		Mitch Coolican
Create date: 10/7/2014
Description:	This is an altered version of revAcct.Closing_Summary
EXECUTE [revAcct].[Closing_Summary_v2] '04/16/2022', '04/10/2022', '04/16/2022'
=============================================
*/
ALTER PROCEDURE [revAcct].[Closing_Summary_v2] 
	@EndDate			DATE,
	@InvoiceStartDate	DATE,
	@InvoiceEndDate		DATE
AS
SET NOCOUNT ON

BEGIN
	CREATE TABLE #Manifest (
		[cmpy_no] INT
		, [div_code] CHAR(2)
		, [total] NUMERIC(16, 2)
		);

	CREATE TABLE #MDR (
		[no] INT
		, [cmpy_no] INT
		, [div_code] CHAR(2)
		, [pro] CHAR(9)
		, [totchg] NUMERIC(16, 2)
		, [frtchg] NUMERIC(16, 2)
		, [accchg] NUMERIC(16, 2)
		, [fscpercent] NUMERIC
		, [fscamt] NUMERIC(16, 2)
		, [deldt] DATE
		, [invdt] DATE
		, [donedt] DATE
		, [audit] VARCHAR(30)
		, [pronumber] VARCHAR(15)
		);

	CREATE TABLE #CNI (
		[cmpy_no] INT
		, [div_code] VARCHAR(2)
		, [pro] VARCHAR(9)
		, [totchg] NUMERIC(16, 2)
		, [profit] NUMERIC(16, 2)
		, [gp] NUMERIC
		, [noa] CHAR(1)
		, [done] CHAR(1)
		, [donedt] DATETIME
		, [status] CHAR(1)
		);

	CREATE TABLE #DNC (
		cmpy_no INT
		, div_code VARCHAR(2)
		, pro VARCHAR(9)
		, totchg NUMERIC(16, 2)
		);

	DECLARE @PostgresQuery			NVARCHAR(MAX),
			@PostgresQueryCNI		NVARCHAR(MAX),
			@PostgresQueryManifest	NVARCHAR(MAX),
			@PostgresQueryDNC		NVARCHAR(MAX),
			@StartDate				Date

	SET @StartDate = DATEADD(dd, -180, @EndDate)

	SET @PostgresQuery = 'SELECT * FROM (
			SELECT DISTINCT trk.order.no
				, trk.order.cmpy_no
				, trk.order.div_code
				, trk.order.pro
				, trk.order.totchg
				, trk.order.frtchg
				, trk.order.accchg
				, cast(trk.order.fscpercent AS NUMERIC(16, 2))
				, trk.order.fscamt
				, trk.order.deldt
				, trk.order.invdt
				, trk.order.donedt
				, CAST(''EDI'' AS STRING) AS Audit
				, CAST(trk.order.div_code || ''-'' || trk.order.pro AS STRING) AS pronumber
			FROM edi.edi204
			INNER JOIN trk.order ON trk.order.no = edi.edi204.or_no
			WHERE trk.order.deldt BETWEEN ''' + CAST(@StartDate AS VARCHAR(15)) + ''' AND ''' + CAST(@EndDate AS VARCHAR(15)) + '''
				AND trk.order.STATUS = ''C''
				AND edi.edi204.totchg <> trk.order.totchg
				AND trk.order.donedt IS NOT NULL
				AND trk.order.pdate IS NULL
				AND edi.edi204.booking <> ''''
		UNION
			SELECT DISTINCT trk.order.no
				, trk.order.cmpy_no
				, trk.order.div_code
				, trk.order.pro
				, trk.order.totchg
				, trk.order.frtchg
				, trk.order.accchg
				, cast(trk.order.fscpercent AS NUMERIC(16, 2))
				, trk.order.fscamt
				, trk.order.deldt
				, trk.order.invdt
				, trk.order.donedt
				, CAST(''MISSING'' AS STRING) AS Audit
				, CAST(trk.order.div_code || ''-'' || trk.order.pro AS STRING) AS pronumber
			FROM trk.order
			INNER JOIN trk.ordoc ON trk.order.no = trk.ordoc.or_no
			WHERE trk.order.deldt BETWEEN ''' + CAST(@StartDate AS VARCHAR(15)) + ''' AND ''' + CAST(@EndDate AS VARCHAR(15)) + '''
				AND trk.order.STATUS = ''C''
				AND trk.order.pdate IS NULL
				AND trk.order.donedt IS NOT NULL
				AND trk.ordoc.qtyrcvd < trk.ordoc.qtyneed
		UNION
			SELECT DISTINCT trk.order.no
				, trk.order.cmpy_no
				, trk.order.div_code
				, trk.order.pro
				, trk.order.totchg
				, trk.order.frtchg
				, trk.order.accchg
				, cast(trk.order.fscpercent AS NUMERIC(16, 2))
				, trk.order.fscamt
				, trk.order.deldt
				, trk.order.invdt
				, trk.order.donedt
				, CAST(''NOA'' AS STRING) AS Audit
				, CAST(trk.order.div_code || ''-'' || trk.order.pro AS STRING) AS pronumber
			FROM trk.order
			WHERE trk.order.deldt BETWEEN ''' + CAST(@StartDate AS VARCHAR(15)) + ''' AND ''' + CAST(@EndDate AS VARCHAR(15)) + '''
				AND STATUS = ''C''
				AND pdate IS NULL
				AND trk.order.donedt IS NOT NULL
				AND noa = ''Y''
		UNION
			SELECT DISTINCT trk.order.no
				, trk.order.cmpy_no
				, trk.order.div_code
				, trk.order.pro
				, trk.order.totchg
				, trk.order.frtchg
				, trk.order.accchg
				, cast(trk.order.fscpercent AS NUMERIC(16, 2))
				, trk.order.fscamt
				, trk.order.deldt
				, trk.order.invdt
				, trk.order.donedt
				, CAST(''RATE'' AS STRING) AS Audit
				, CAST(trk.order.div_code || ''-'' || trk.order.pro AS STRING) AS pronumber
			FROM trk.order
			INNER JOIN trk.woaudit ON trk.woaudit.inv_code = CASE WHEN LEFT(trk.order.div_code, 1) = ''0'' THEN RIGHT(trk.order.div_code, 1)
					ELSE trk.order.div_code END || ''-'' || trk.order.pro AND trk.woaudit.bt_code <> '''' 
			WHERE trk.order.deldt BETWEEN ''' + CAST(@StartDate AS VARCHAR(15)) + ''' AND ''' + CAST(@EndDate AS VARCHAR(15)) + '''
				AND trk.order.STATUS = ''C''
				AND trk.order.donedt IS NOT NULL
				AND trk.order.pdate IS NULL
				AND trk.order.totchg <> trk.woaudit.worate + trk.woaudit.fscamt + trk.woaudit.accchg
		UNION
			SELECT DISTINCT trk.order.no
				, trk.order.cmpy_no
				, trk.order.div_code
				, trk.order.pro
				, trk.order.totchg
				, trk.order.frtchg
				, trk.order.accchg
				, cast(trk.order.fscpercent AS NUMERIC(16, 2))
				, trk.order.fscamt
				, trk.order.deldt
				, trk.order.invdt
				, trk.order.donedt
				, CAST('' BILL TO '' AS STRING) AS Audit
				, CAST(trk.order.div_code || ''-'' || trk.order.pro AS STRING) AS pronumber
			FROM trk.order
			INNER JOIN trk.woaudit ON trk.woaudit.inv_code = CASE WHEN LEFT(trk.order.div_code, 1) = ''0'' THEN RIGHT(trk.order.div_code, 1)
					ELSE trk.order.div_code END || ''-'' || trk.order.pro AND trk.woaudit.bt_code <> '''' 
			WHERE trk.order.deldt BETWEEN ''' + CAST(@StartDate AS VARCHAR(15)) + ''' AND ''' + CAST(@EndDate AS VARCHAR(15)) + '''
				AND trk.order.STATUS = ''C''
				AND trk.order.donedt IS NOT NULL
				AND trk.order.pdate IS NULL
				AND trk.order.bt_code <> trk.woaudit.bt_code
		) AS PGData'

	INSERT INTO #MDR
	EXECUTE dbo.USP_QuerySWS @PostgresQuery

	SET @PostgresQueryCNI = 'SELECT * FROM OPENQUERY(PostgreSQLProd,''
				SELECT cmpy_no, div_code, pro, totchg, profit, cast(margin AS NUMERIC(16, 2)) AS gp, noa, done, donedt, STATUS
				FROM trk.order
				WHERE status != ''''V''''
				AND (done = ''''Y'''' or donedt IS NOT NULL)
				AND invdt IS NULL
				AND abs(margin) <= 500
				AND deldt BETWEEN ''''' + CAST(@StartDate AS VARCHAR(15)) + ''''' AND ''''' + CAST(@EndDate AS VARCHAR(15)) + '''''
				AND (type NOT IN (''''I'''', ''''N'''')
					OR
					(
						((SELECT MAX(M.ddate) 
						  FROM trk.move M 
						  WHERE M.or_no = trk.order.no 
						  AND M.tl_code != '''''''') <= (SELECT C.invdate 
									                     FROM com.company C 
									                     WHERE C.no = trk.order.cmpy_no))
						AND status = ''''C''''
					)
				)
				'')'
				/*AND (type NOT IN (''''I'''', ''''N'''') OR ((SELECT MAX(M.ddate) FROM trk.MOVE M WHERE M.or_no = trk.ORDER.no AND M.tl_code != '''''''') <= (SELECT C.invdate FROM com.company C WHERE C.no = trk.ORDER.cmpy_no)))*/

	SET @PostgresQueryManifest = 'SELECT * FROM OPENQUERY(PostgreSQLProd,''SELECT cmpy_no, div_code, cast(SUM(total) AS NUMERIC(16, 2)) AS total
				FROM trk.invoice
				WHERE invdate BETWEEN ''''' + CAST(@InvoiceStartDate AS VARCHAR(15)) + ''''' AND ''''' + CAST(@InvoiceEndDate AS VARCHAR(15)) + '''''
				AND type <> ''''S''''
				GROUP BY cmpy_no, div_code '')'

	SET @PostgresQueryDNC = 'SELECT * FROM OPENQUERY(PostgreSQLProd,''SELECT cmpy_no, div_code, pro, totchg
				FROM trk."order"
				WHERE STATUS <> ''''C''''
				AND STATUS <> ''''V''''
				AND deldt IS NOT NULL
				AND deldt >= (''''' + CAST(@EndDate AS VARCHAR(15)) + ''''')::DATE - Interval ''''1 YEAR''''
				AND deldt <= ''''' + CAST(@EndDate AS VARCHAR(15)) + ''''' '')'

	PRINT '@PostgresQuery: ' + @PostgresQuery
	--PRINT '@PostgresQueryManifest: ' + @PostgresQueryManifest
	--PRINT '@PostgresQueryDNC: ' + @PostgresQueryDNC
	--PRINT '@PostgresQueryCNI: ' + @PostgresQueryCNI

	PRINT 'MDR Ran Successfully'

	INSERT INTO #CNI
	EXEC (@PostgresQueryCNI);

	PRINT 'CNI Ran Successfully'

	INSERT INTO #Manifest
	EXEC (@PostgresQueryManifest);

	PRINT 'Manifest Ran Successfully'

	INSERT INTO #DNC
	EXEC (@PostgresQueryDNC);

	PRINT 'DNC Ran Successfully'

/* DEBUGGING 
Select * From #CNI 
order by cmpy_no, div_code;
Select * From #MDR 
order by cmpy_no, div_code;
Select * From #Manifest 
order by cmpy_no, div_code;
Select * From #DNC 
order by cmpy_no, div_code;
*/
		;

	

	WITH 
		CNI AS (
				SELECT cmpy_no AS CompanyID
					, div_code AS Division
					, COUNT(pro) AS [Pros]
					, SUM(totchg) AS [Total]
				FROM #CNI
				GROUP BY cmpy_no, div_code
				),

		MDR AS (
				SELECT DISTINCT [cmpy_no] AS CompanyID
					, [div_code] AS Division
					, COUNT(DISTINCT [pro]) AS [Pros]
					, SUM(DISTINCT [totchg]) AS [Total]
				FROM #MDR
				GROUP BY [cmpy_no], [div_code]
				),

		DNC AS (
				SELECT DISTINCT [cmpy_no] AS CompanyID
					, [div_code] AS Division
					, COUNT(DISTINCT [pro]) AS [Pros]
					, SUM([totchg]) AS [Total]
				FROM #DNC
				GROUP BY [cmpy_no], [div_code]
				)

	SELECT CASE WHEN [c].[CompanyID] IS NULL
                         THEN CASE WHEN [m].[CompanyID] IS NULL
                                   THEN [d].[CompanyID]
                                   ELSE [m].[companyid]
                              END
                         ELSE [c].[CompanyID]
                    END AS [CNI CompanyID]
                  , CASE WHEN [c].[Division] IS NULL
                         THEN CASE WHEN [m].[Division] IS NULL
                                   THEN [d].[Division]
                                   ELSE [m].[Division]
                              END
                         ELSE [c].[Division]
                    END AS [CNI Division]
                  , CASE WHEN [c].[pros] IS NULL THEN 0
                         ELSE [c].[pros]
                    END AS [CNI Pros]
                  , CASE WHEN [c].[total] IS NULL THEN 0
                         ELSE [c].[total]
                    END AS [CNI Total]
                  , CASE WHEN [m].[CompanyID] IS NULL
                         THEN CASE WHEN [c].[CompanyID] IS NULL
                                   THEN [d].[CompanyID]
                                   ELSE [c].[companyid]
                              END
                         ELSE [m].[CompanyID]
                    END AS [MDR CompanyID]
                  , CASE WHEN [m].[Division] IS NULL
                         THEN CASE WHEN [c].[Division] IS NULL
                                   THEN [d].[Division]
                                   ELSE [c].[Division]
                              END
                         ELSE [m].[Division]
                    END AS [MDR Division]
                  , CASE WHEN [m].[pros] IS NULL 
					   THEN 0
                         ELSE [m].[pros]
                    END AS [MDR Pros]
                  , CASE WHEN [m].[total] IS NULL THEN 0
                         ELSE [m].[total]
                    END AS [MDR Total]
                  , CASE WHEN [d].[CompanyID] IS NULL
                         THEN CASE WHEN [c].[CompanyID] IS NULL
                                   THEN [m].[CompanyID]
                                   ELSE [c].[companyid]
                              END
                         ELSE [d].[CompanyID]
                    END AS [DNC CompanyID]
                  , CASE WHEN [d].[Division] IS NULL
                         THEN CASE WHEN [c].[Division] IS NULL
                                   THEN [m].[Division]
                                   ELSE [c].[Division]
                              END
                         ELSE [d].[Division]
                    END AS [DNC Division]
                  , CASE WHEN [d].[pros] IS NULL THEN 0
                         ELSE [d].[pros]
                    END AS [DNC Pros]
                  , CASE WHEN [d].[total] IS NULL THEN 0
                         ELSE [d].[total]
                    END AS [DNC Total]
	INTO #ClosingStage1
	FROM CNI AS c
	FULL JOIN MDR AS m ON [m].[CompanyID] = [c].[CompanyID]
		AND [m].[Division] = [c].[Division]
	FULL JOIN DNC AS d ON [d].[CompanyID] = [c].[CompanyID]
		AND [d].[Division] = [c].[Division]

	SELECT ISNULL(#Manifest.cmpy_no, Closing.[CNI CompanyID]) AS CompanyID
		, ISNULL(#Manifest.div_Code, closing.[CNI Division]) AS Division
		, ISNULL(closing.[MDR Pros], 0) AS [MDR Pros]
		, ISNULL(closing.[CNI Pros], 0) AS [CNI Pros]
		, ISNULL(closing.[DNC Pros], 0) AS [DNC Pros]
		, ISNULL(closing.[CNI Total], 0) AS [CNI Total]
		, ISNULL(closing.[DNC Total], 0) AS [DNC Total]
		, ISNULL(#Manifest.total, 0) AS Invoiced
	INTO #ClosingReport
	FROM (
		SELECT [CNI CompanyID]
			, [CNI Division]
			, SUM([CNI Pros]) AS [CNI Pros]
			, SUM([CNI Total]) AS [CNI Total]
			, [MDR CompanyID]
			, [MDR Division]
			, SUM([MDR Pros]) AS [MDR Pros]
			, SUM([MDR Total]) AS [MDR Total]
			, [DNC CompanyID]
			, [DNC Division]
			, SUM([DNC Pros]) AS [DNC Pros]
			, SUM([DNC Total]) AS [DNC Total]
		FROM #ClosingStage1
		GROUP BY [CNI CompanyID]
			, [CNI Division]
			, [DNC CompanyID]
			, [DNC Division]
			, [MDR CompanyID]
			, [MDR Division]
		) AS Closing
	FULL JOIN #Manifest ON Closing.[CNI CompanyID] = #Manifest.cmpy_no
		AND closing.[CNI Division] = #Manifest.div_Code
	FULL JOIN #DNC ON Closing.[CNI CompanyID] = #DNC.cmpy_no
		AND closing.[CNI Division] = #DNC.div_Code

		

/*
SELECT [CNI CompanyID],[CNI Division], SUM([CNI Pros]) AS [CNI Pros], SUM([CNI Total]) AS [CNI Total], [MDR CompanyID], [MDR Division], SUM([MDR Pros]) AS [MDR Pros], SUM([MDR Total]) AS [MDR Total], [DNC CompanyID], [DNC Division], SUM([DNC Pros]) AS [DNC Pros], SUM([DNC Total]) AS [DNC Total] FROM #ClosingStage1
GROUP BY [CNI CompanyID],[CNI Division],[DNC CompanyID],[DNC Division],[MDR CompanyID],[MDR Division]

SELECT *
FROM #ClosingReport
ORDER BY CompanyID, Division
*/


	SELECT info.CompanyShort
		, info.President
		, Closing.*
	FROM #ClosingReport AS Closing
	FULL JOIN [ADG].[revAcct].[Closing_map_cmpy] AS info ON Closing.CompanyID = info.CompanyID
		AND Closing.Division = info.Division
	WHERE Closing.CompanyID IS NOT NULL
	GROUP BY [info].[CompanyShort]
		, [info].[President]
		, [Closing].[CompanyID]
		, [Closing].[Division]
		, [Closing].[MDR Pros]
		, [Closing].[CNI Pros]
		, [Closing].[DNC Pros]
		, [Closing].[CNI Total]
		, [Closing].[DNC Total]
		, [Closing].[Invoiced]
	ORDER BY Closing.CompanyID
		, Closing.Division

	DROP TABLE #CNI
	DROP TABLE #MDR
	DROP TABLE #DNC
	DROP TABLE #Manifest
	DROP TABLE #ClosingStage1
	DROP TABLE #ClosingReport
END