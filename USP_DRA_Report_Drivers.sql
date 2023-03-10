ALTER PROCEDURE USP_DRA_Report_PayDrivers
		@Company	Varchar(6),
		@WeekDate	Datetime,
		@BatchId	Varchar(17) = Null,
		@VendorId	Varchar(12) = Null
AS
IF GPCustom.dbo.WeekDay(@WeekDate) < 5
	SET	@WeekDate = GPCustom.dbo.DayFwdBack(@WeekDate,'N','Thursday')

SELECT	PH.VendorId,
		PH.VendName,
		PH.BachNumb
FROM	GPCustom.dbo.PM10300 PH
		INNER JOIN (SELECT VendorId, COUNT(BachNumb) AS Counter 
					FROM GPCustom.dbo.PM10300 
					WHERE Company = @Company AND DocDate = @WeekDate
					GROUP BY VendorId) VN ON PH.VendorId = VN.VendorId
		LEFT JOIN ME27606 EF ON PH.VendorId = EF.VendorId
WHERE	PH.Company = @Company
		AND PH.DocDate = @WeekDate
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND BachNumb = @BatchId))
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND PH.VendorId = @VendorId))
		AND VN.Counter = 1
		AND PATINDEX('%' + CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 'DD' ELSE 'CK' END + '%', PH.BachNumb) > 0
UNION
SELECT	PH.VendorId,
		PH.VendName,
		PH.BachNumb
FROM	GPCustom.dbo.PM10300 PH
		INNER JOIN (SELECT VendorId, COUNT(BachNumb) AS Counter 
					FROM GPCustom.dbo.PM10300 
					WHERE Company = @Company AND DocDate = @WeekDate
					GROUP BY VendorId) VN ON PH.VendorId = VN.VendorId
		LEFT JOIN ME27606 EF ON PH.VendorId = EF.VendorId
WHERE	PH.Company = @Company
		AND PH.DocDate = @WeekDate
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND BachNumb = @BatchId))
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND PH.VendorId = @VendorId))
		AND VN.Counter > 1
		AND PATINDEX('%' + CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 'DD' ELSE 'CK' END + '%', PH.BachNumb) > 0
ORDER BY PH.BachNumb, PH.VendorId

/*
EXECUTE USP_DRA_Report_PayDrivers 'IMC', '04/16/2009', nULL, '4465'
*/