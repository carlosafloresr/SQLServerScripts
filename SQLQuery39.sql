/*
SELECT	DISTINCT DD.WeekEndingDate
				,DD.DocumentName
				,ISNULL(PM.ChekTotl, 0.0) AS Amount
		FROM	View_DriverDocuments DD
				LEFT JOIN PM10300 PM ON DD.VendorId = PM.VendorId AND PM.DocDate BETWEEN dbo.DayFwdBack(DD.WeekEndingDate, 'P', 'Monday') AND DD.WeekEndingDate
		WHERE	DD.Fk_DocumentTypeId = 1 
				AND DD.Company = RTRIM('PTS')
				AND DD.VendorId = RTRIM('5468')
				AND DD.WeekEndingDate > DATEADD(dd, -40, GETDATE())

SELECT * FROM View_DriverDocuments WHERE VendorId = '5468'
*/
SELECT	PM.*,
		DD.WeekEndingDate
FROM	PM10300 PM
		LEFT JOIN View_DriverDocuments DD ON PM.Company = DD.Company AND PM.VendorId = DD.VendorId AND PM.DocDate = DD.WeekEndingDate
WHERE	PM.VendorId = '5468'
		AND PM.Voided = 0
ORDER BY PM.DocDate DESC