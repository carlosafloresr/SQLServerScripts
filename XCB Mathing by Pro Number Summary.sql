DECLARE @Company		Varchar(5) = 'GLSO',
		@GLAccount		Varchar(15) = '0-88-1866',
		@ProNumber		Varchar(15) = '95-262269'

DECLARE @tblSource1 Table (
ProNumber		Varchar(15),
Reference		Varchar(50),
Vendor			Varchar(15),
FP_StartDate	Date,
Amount			Numeric(10,2),
Summary			Numeric(10,2),
RecordId		Int)

DECLARE @tblSource2 Table (
ProNumber		Varchar(15),
Reference		Varchar(50),
Vendor			Varchar(15),
FP_StartDate	Date,
Amount			Numeric(10,2),
Summary			Numeric(10,2),
RecordId		Int)

INSERT INTO @tblSource1
SELECT	XCB1.ProNumber,
		XCB1.Reference,
		IIF(XCB1.Vendor = '', ISNULL(XCB1.SWSVendor, ''), XCB1.Vendor) AS Vendor,
		XCB1.FP_StartDate,
		XCB1.Amount,
		Summary = (SELECT SUM(Amount) FROM GP_XCB_Prepaid XCB WHERE XCB.Company = XCB1.Company AND XCB.GLAccount = XCB1.GLAccount AND XCB.ProNumber = XCB1.ProNumber AND XCB.Vendor = XCB1.Vendor AND XCB.Amount > 0),
		XCB1.RecordId
FROM	GP_XCB_Prepaid XCB1
WHERE	XCB1.Company = @Company
			AND XCB1.GLAccount = @GLAccount
		AND ((XCB1.Matched = 0 AND @ProNumber IS Null) OR (@ProNumber IS NOT Null AND XCB1.ProNumber = @ProNumber))
		AND XCB1.Amount > 0
		AND IIF(XCB1.Vendor = '', ISNULL(XCB1.SWSVendor, ''), XCB1.Vendor) <> ''
		AND XCB1.ProNumber <> ''

INSERT INTO @tblSource2
SELECT	XCB1.ProNumber,
		XCB1.Reference,
		IIF(XCB1.Vendor = '', ISNULL(XCB1.SWSVendor, ''), XCB1.Vendor) AS Vendor,
		XCB1.FP_StartDate,
		XCB1.Amount,
		Summary = (SELECT SUM(ABS(Amount)) FROM GP_XCB_Prepaid XCB WHERE XCB.Company = XCB1.Company AND XCB.GLAccount = XCB1.GLAccount AND XCB.ProNumber = XCB1.ProNumber AND XCB.Vendor = XCB1.Vendor AND XCB.Amount < 0),
		XCB1.RecordId
FROM	GP_XCB_Prepaid XCB1
WHERE	XCB1.Company = @Company
		AND XCB1.GLAccount = @GLAccount
		AND ((XCB1.Matched = 0 AND @ProNumber IS Null) OR (@ProNumber IS NOT Null AND XCB1.ProNumber = @ProNumber))
		AND XCB1.Amount < 0
		AND IIF(XCB1.Vendor = '', ISNULL(XCB1.SWSVendor, ''), XCB1.Vendor) <> ''
		AND XCB1.ProNumber <> ''
		

SELECT	DISTINCT S1.ProNumber,
		S1.Reference,
		S1.Vendor,
		S1.Amount AS Amount1,
		S1.Summary AS Summary1,
		S2.Amount AS Amount2,
		S2.Summary AS Summary2,
		S1.FP_StartDate AS StartDate1,
		S1.FP_StartDate AS StartDate2,
		S2.Reference,
		S1.RecordId AS RecordId1,
		S2.RecordId AS RecordId2
FROM	@tblSource1 S1
		INNER JOIN @tblSource2 S2 ON S1.ProNumber = S2.ProNumber AND S1.Vendor = S2.Vendor AND S1.Summary = S2.Summary
ORDER BY S1.ProNumber, S1.Vendor

/*
SELECT	DISTINCT S1.RecordId AS RecordId1,
			S2.RecordId AS RecordId2,		
			S1.FP_StartDate AS StartDate1,
			S2.FP_StartDate AS StartDate2
	FROM	@tblSource1 S1
			INNER JOIN @tblSource2 S2 ON S1.ProNumber = S2.ProNumber AND S1.Vendor = S2.Vendor AND S1.Summary = S2.Summary

SELECT	*
FROM	GP_XCB_Prepaid
WHERE	RecordId IN (SELECT RecordId FROM @tblSource1 UNION SELECT RecordId FROM @tblSource2)
ORDER BY ProNumber, Matched, Amount

UPDATE GP_XCB_Prepaid SET Matched = 0, MatchFrom = Null WHERE ProNumber = '95-262269'

DELETE GP_XCB_Prepaid_Matched WHERE RecordId IN (SELECT RecordId FROM GP_XCB_Prepaid WHERE ProNumber = '95-262269')
*/