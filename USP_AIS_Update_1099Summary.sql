ALTER PROCEDURE USP_AIS_Update_1099Summary
	@VendorId	Char(12),
	@Year		Int,
	@Period		Int
AS
UPDATE	AIS.dbo.PM00202
SET	Ten99Alif = SU.Ten99Amnt
FROM	(SELECT	VendorId,
		Year1,
		PeriodId,
		SUM(Ten99Amnt) AS Ten99Amnt
	FROM	(SELECT	VendorId,
			Year1,
			PeriodId,
			SUM(Ten99Amnt * CASE WHEN DocType = 5 THEN -1 ELSE 1 END) AS Ten99Amnt
		FROM 	AIS.dbo.PM30200 HH
			LEFT JOIN AIS.dbo.SY40100 FI ON HH.DocDate BETWEEN FI.PeriodDT AND FI.PerDenDT AND FI.Series = 0 AND YEAR(HH.DocDate) = FI.Year1
		WHERE	Voided = 0 AND
			Ten99Amnt <> 0 AND
			FI.PSeries_3 = 0 AND
			VendorId = @VendorId AND
			Year1 = @Year AND
			PeriodId = @Period
		GROUP BY
			VendorId,
			Year1,
			PeriodId
		UNION
		SELECT	VendorId,
			Year1,
			PeriodId,
			SUM(Ten99Amnt * CASE WHEN DocType = 5 THEN -1 ELSE 1 END) AS Ten99Amnt
		FROM 	AIS.dbo.PM20000 HH
			LEFT JOIN AIS.dbo.SY40100 FI ON HH.DocDate BETWEEN FI.PeriodDT AND FI.PerDenDT AND FI.Series = 0 AND YEAR(HH.DocDate) = FI.Year1
		WHERE	Voided = 0 AND
			Ten99Amnt <> 0 AND
			FI.PSeries_3 = 0 AND
			VendorId = @VendorId AND
			Year1 = @Year AND
			PeriodId = @Period
		GROUP BY
			VendorId,
			Year1,
			PeriodId) HH
	GROUP BY
		VendorId,
		Year1,
		PeriodId) SU
WHERE	AIS.dbo.PM00202.VendorId = SU.VendorId AND
	AIS.dbo.PM00202.Year1 = SU.Year1 AND
	AIS.dbo.PM00202.PeriodId = SU.PeriodId

GO

EXECUTE USP_AIS_Update_1099Summary 'A0133', 2008, 1