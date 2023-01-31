DECLARE @Query	Varchar(MAX)

SELECT	*
FROM	GP_XCB_Prepaid
WHERE	ProNumber = '95-297607'

SET @Query = N'SELECT DISTINCT CAST(a.div_code||''-''||a.pro AS STRING) AS pronumber, b.vn_code, c.name, 
			b.vnref, b.amount, b.prepay, a.status, a.invdt, a.deldt
	FROM	TRK.Order a
			INNER JOIN TRK.OrvnPay b ON a.cmpy_no = b.cmpy_no AND a.no = b.or_no AND b.amount <> 0
			INNER JOIN TRK.Vendor c ON a.cmpy_no = c.cmpy_no AND b.vn_code = c.code
	WHERE	a.cmpy_no = 9
			AND CAST(a.div_code||''-''||a.pro AS STRING) IN (''95-297607'')'

EXECUTE USP_QuerySWS_ReportData @Query