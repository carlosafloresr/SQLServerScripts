SELECT	inv_no,
		inv_est,
		acct_no,
		container,
		chassis,
		genset_no,
		inv_total,
		inv_date,
		est_date,
		rep_date,
		labor_hour,
		labor,
		mech_hours,
		parts,
		cdex_remk,
		cost,
		vendor_id,
		post_date
FROM	View_FI_Estimates
WHERE	historical = 0
		AND status <> 'CANC'
		AND ((inv_est = 'I' 
            AND inv_date between DATEADD(dd, -7, '2014-08-10') AND DATEADD(dd,-1,  '2014-08-10')
            AND acct_no <> 'ADMFRS'
			)
		OR (inv_est = 'E' 
			AND rep_date BETWEEN DATEADD(dd, -45, CAST(GETDATE() AS Date)) AND DATEADD(dd, -1, CAST(GETDATE() AS Date))
			AND acct_no <> 'ADMFRS'))