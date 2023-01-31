IF NOT EXISTS(SELECT PymTrmId FROM SY03300 WHERE PymTrmId = 'Net 28 Days')
BEGIN
	INSERT INTO SY03300
		   (PymTrmId,
			Duedtds,
			DueType,
			DiscType,
			DsclcTyp, 
			LstUsrEd)
	SELECT	'Net 28 Days',
			28,
			1,
			1,
			1,
			'cflores'
END

SELECT	*
FROM	SY03300