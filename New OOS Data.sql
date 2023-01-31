DECLARE @Query	Varchar(2500)

SET @Query = N'SELECT CAST(''gis'' AS STRING) company,h.company_id,
		h.week_ending_date + INTERVAL ''5 day'' AS week_ending_date,
		h.driver_id,
		CAST(SUM(CASE WHEN (li.line_item_code = ''CESC'' AND d.applied_this_period = true) THEN d.charge_amount ELSE 0.00 END) AS DOUBLE PRECISION) AS StandardEscrow,
		CAST(SUM(CASE WHEN (li.line_item_code = ''TINS'' AND d.applied_this_period = true) THEN d.charge_amount ELSE 0.00 END) AS DOUBLE PRECISION) AS OOInsurance,
		CAST(SUM(CASE WHEN (li.line_item_code = ''GARN'' AND d.applied_this_period = true) THEN d.charge_amount ELSE 0.00 END) AS DOUBLE PRECISION) AS Garnishments,
		0 AS PeopleNet,
		CAST(SUM(CASE WHEN (li.line_item_code IN (''TRKB'',''TRK3'') AND d.applied_this_period = true) THEN d.charge_amount ELSE 0.00 END) AS DOUBLE PRECISION) AS LeasePayment,
		CAST(SUM(CASE WHEN (li.line_item_code = ''STD'' AND d.applied_this_period = true) THEN d.charge_amount ELSE 0.00 END) AS DOUBLE PRECISION) AS Savings,
		CAST(SUM(CASE WHEN (li.line_item_code = ''CESCADVANCE'' AND d.applied_this_period = true) THEN d.charge_amount ELSE 0.00 END) AS DOUBLE PRECISION) AS EscrowRepayment,
		CAST(SUM(CASE WHEN (li.line_item_code = ''OOTA'' AND d.applied_this_period = true) THEN d.charge_amount ELSE 0.00 END) AS DOUBLE PRECISION) AS TagsandTaxes,
		CAST(SUM(CASE WHEN (li.line_item_code = ''OAC'' AND d.applied_this_period = true) THEN d.charge_amount ELSE 0.00 END) AS DOUBLE PRECISION) AS OtherInsurance
FROM	oos.driver_settlement_header h
		INNER JOIN oos.driver_settlement_details d on d.driver_settlement_header_id = h.pk_id
        INNER JOIN oos.charge_back cb on cb.pk_id = d.charge_back_id
        INNER JOIN oos.line_item li on li.pk_id = cb.line_item_id
WHERE	h.company_id = 2
		AND h.week_ending_date BETWEEN ''01/01/2021'' AND ''02/01/2022'' 
		AND h.driver_id = ''G50276'' 
GROUP BY h.company_id, h.driver_id, h.week_ending_date
ORDER BY h.company_id, h.driver_id, h.week_ending_date'

EXECUTE GPCustom.dbo.USP_QuerySWS_ReportData @Query, Null, 'POSTGRESQL_IMC_ENTERPRISE'

PRINT DATEADD(dd, 5, '2021-06-05')