/*
SELECT * FROM PM00201 WHERE VendorId = '4465'
SELECT * FROM PM00202 WHERE VendorId = '4465' AND Year1 = 2009
SELECT SUM(TEN99ALIF) FROM PM00202 WHERE VendorId = '4465' AND Year1 = 2009 AND HistType = 0 AND PeriodId = 1

UPDATE	PM00202
SET		PM00202.TEN99ALIF = RECS.TEN99AMNT
FROM	(
		SELECT	VendorId,
				YEAR(DocDate) AS Year1,
				MONTH(DocDate) AS Month1,
				SUM(Un1099AM) AS TEN99AMNT
		FROM	(
		SELECT	VendorId,
				DocDate,
				Un1099AM,
				VchrNmbr,
				ROW_NUMBER() OVER (PARTITION BY VchrNmbr ORDER BY VendorId, VchrNmbr, PayType DESC) AS Row
		FROM	View_VendorRecords
		WHERE	VendorType = 'DRV'
				AND DocDate BETWEEN '1/1/2009' AND '12/31/2009'
				AND (LastPayDate <= '12/31/2009' OR LastPayDate IS NULL)
				AND DocAmnt <> 0
		UNION
		SELECT	VendorId,
				DocDate,
				Un1099AM,
				VchrNmbr,
				ROW_NUMBER() OVER (PARTITION BY VchrNmbr ORDER BY VendorId, VchrNmbr, PayType DESC) AS Row
		FROM	View_VendorRecords
		WHERE	VendorType = 'DRV'
				AND DocDate BETWEEN '1/1/2009' AND '12/31/2009'
				AND (LastPayDate <= '12/31/2009' OR LastPayDate IS NULL)
				AND DocAmnt <> 0) RECS
		WHERE	Row = 1
		GROUP BY VendorId, YEAR(DocDate), MONTH(DocDate)) RECS
WHERE	PM00202.VendorId = RECS.VendorId
		AND PM00202.Year1 = RECS.Year1 
		AND PM00202.PeriodId = RECS.Month1
		--AND PM00202.HistType = 1

UPDATE	PM00201
SET		PM00201.TEN99ALIF = TEN99SUM,
		PM00201.TEN99AYTD = TEN99SUM
FROM	(SELECT VendorId
				,SUM(TEN99ALIF) AS TEN99SUM
		FROM	PM00202 
		WHERE	Year1 = 2009
				--AND	HistType = 1
		GROUP BY VendorId) RECS
WHERE	PM00201.VendorId = RECS.VendorId
*/

SELECT	VendorId,
		--YEAR(DocDate) AS Year1,
		--MONTH(DocDate) AS Month1,
		SUM(Un1099AM) AS TEN99AMNT
FROM	(
SELECT	VendorId,
		DocDate,
		Un1099AM,
		VchrNmbr,
		ROW_NUMBER() OVER (PARTITION BY VchrNmbr ORDER BY VendorId, VchrNmbr, PayType DESC) AS Row,
		LastPayDate
FROM	View_VendorRecords
WHERE	VendorType = 'DRV'
		AND DocDate BETWEEN '1/1/2012' AND '12/31/2012'
		AND (LastPayDate <= '12/31/2012' OR LastPayDate IS NULL)
		--AND DocAmnt <> 0
		AND VendorId = 'D0008'
UNION
SELECT	VendorId,
		DocDate,
		Un1099AM,
		VchrNmbr,
		ROW_NUMBER() OVER (PARTITION BY VchrNmbr ORDER BY VendorId, VchrNmbr, PayType DESC) AS Row,
		LastPayDate
FROM	View_VendorRecords
WHERE	VendorType = 'DRV'
		AND DocDate BETWEEN '1/1/2012' AND '12/31/2012'
		AND (LastPayDate <= '12/31/2012' OR LastPayDate IS NULL)
		--AND DocAmnt <> 0
		AND VendorId = 'D0008') RECS
WHERE	Row = 1
GROUP BY VendorId, YEAR(DocDate), MONTH(DocDate)

-- SELECT * FROM View_VendorRecords WHERE VendorId = '9761' AND CheckDate BETWEEN '1/1/2009' AND '12/31/2009'