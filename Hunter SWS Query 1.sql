DECLARE @Query Varchar(MAX)

SET @Query = 'SELECT pk_id, 
				cmpy_no, 
				status, 
				eq_code, 
				tl_code, 
				ddate, 
				dtime, 
				CAST(CASE WHEN tl_code = eq_code AND dtime IS Null THEN ''ok'' 
					 WHEN eq_code IS Null AND tl_code IS NOT Null AND dtime IS Null THEN ''add'' 
					 WHEN eq_code IS Null AND tl_code IS NOT Null AND ddate IS NOT Null AND dtime IS NOT Null AND ddate < CURRENT_DATE - 2 THEN ''ok'' 
					 WHEN eq_code IS Null AND tl_code IS NOT Null AND ddate IS NOT Null AND dtime IS NOT Null AND ddate >= CURRENT_DATE - 2 THEN ''add'' 
					 WHEN eq_code IS NOT Null AND tl_code IS NOT Null AND ddate IS NOT Null AND dtime IS NOT Null AND ddate >= CURRENT_DATE - 2 THEN ''ok'' 
					 WHEN eq_code IS NOT Null AND tl_code IS NOT Null AND ddate IS NOT Null AND dtime IS NOT Null AND ddate < CURRENT_DATE - 2 THEN ''remove'' 
					 ELSE ''???'' END AS STRING) AS "cur_status" 
		FROM	( 
				SELECT	move.tl_code, 
						move.ddate, 
						move.dtime, 
						move.cmpy_no, 
						move.status, 
						rail.pk_id, 
						rail.eq_code 
				FROM	trk.move move
						INNER JOIN com.company cmpy ON move.cmpy_no = cmpy.No AND cmpy.No <= 9 AND cmpy.status = ''A''
						LEFT JOIN trk.locprof delv ON delv.cmpy_no = move.cmpy_no AND delv.code = move.dlp_code AND delv.type = ''R''
						LEFT JOIN trk.locprof puloc ON puloc.cmpy_no = move.cmpy_no AND puloc.code = move.olp_code AND puloc.type <> ''R''
						LEFT JOIN trk.eqtrace_railinc rail ON rail.eq_code = move.tl_code AND rail.fleet_code = ''INGATES'' 
				WHERE	LENGTH(move.tl_code) >= 10
						AND (move.dtime IS Null OR (move.dtime IS NOT Null AND move.ddate >= CURRENT_DATE - 7)) 
						AND rail.pk_id IS NOT Null
				)
ORDER BY tl_code, ddate DESC Nulls FIRST, dtime DESC Nulls FIRST'

EXECUTE USP_QuerySWS_ReportData @Query