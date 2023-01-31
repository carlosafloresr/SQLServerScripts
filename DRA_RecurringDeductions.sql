-- EXECUTE USP_DRA_Report 'AIS', '05/05/2008', 'A0011'

ALTER PROCEDURE USP_DRA_Report -- DRA = Driver Remittance Advice
		@Company	Char(6),
		@WeekEnd	Datetime,
		@DriverId	Varchar(10) = Null
AS
DECLARE	@Year		Int,
		@Week		Int,
		@CpnyName	Varchar(40),
		@Query		Varchar(5000),
		@Driver		Varchar(10)

SET		@WeekEnd	= CASE	WHEN DATENAME(Weekday, @WeekEnd) = 'Sunday' THEN @WeekEnd - 1
							ELSE DATEADD(Day, 7 - dbo.WeekDay(@WeekEnd), @WeekEnd) END
SET		@Year		= YEAR(@WeekEnd)
SET		@Week		= DATENAME(Week, @WeekEnd)
SET		@CpnyName	= (SELECT CmpnyNam FROM Dynamics.dbo.View_AllCompanies WHERE Interid = @Company)
SET		@Driver		= CASE WHEN @DriverId IS Null THEN 'Q~Q~W~' ELSE RTRIM(@DriverId) END
SET		@Query		= 'SELECT ''' + @CpnyName + ''' AS Company,
		CAST(''' + CONVERT(Char(10), @WeekEnd, 101) + ''' AS Datetime) AS WeekEndDate,
		DeductionDate AS TransDate,
		DATENAME(Week, WeekEndDate) AS Week,
		TR.VendorId,
		VE.VendName AS Vendor,
		''10_'' + DeductionCode AS DeductionCode,
		LEFT(DeductionType, 50) AS DeductionType,
		SUM(DeductionAmount * -1) AS DeductionAmount
FROM	View_OOS_Transactions TR 
		LEFT JOIN ' + RTRIM(@Company) + '.dbo.PM00200 VE ON TR.VendorId = VE.VendorId
WHERE	Company = ''' + @Company + ''' AND
		VE.VndClsId = ''DRV'' AND
		DATENAME(Week, WeekEndDate) = ' + CAST(@Week AS Char(2)) + ''

IF @DriverId IS NOT Null
	SET @Query = @Query + ' AND TR.VendorId = ''' + @Driver + ''''

SET @Query = @Query + ' GROUP BY
		WeekEndDate,
		DeductionDate,
		TR.VendorId,
		VE.VendName,
		DeductionCode,
		DeductionType
UNION
SELECT	''' + @CpnyName + ''' AS Company,
		CAST(''' + CONVERT(Char(10), @WeekEnd, 101) + ''' AS Datetime) AS WeekEndDate,
		TransDate,
		DATENAME(Week, WeekEndDate) AS Week,
		TR.VendorId,
		VE.VendName AS Vendor,
		''02_FPT'' AS DeductionCode,
		''Fuel Purchases'' AS DeductionType,
		SUM(TotalFuel * -1)
FROM	View_Integration_FPT TR
		LEFT JOIN ' + RTRIM(@Company) + '.dbo.PM00200 VE ON TR.VendorId = VE.VendorId
WHERE	Company = ''' + @Company + ''' AND
		DATENAME(Week, WeekEndDate) = ' + CAST(@Week AS Char(2)) + ''
		
IF @DriverId IS NOT Null
	SET @Query = @Query + ' AND TR.VendorId = ''' + @Driver + ''''

SET @Query = @Query + ' GROUP BY
		WeekEndDate,
		TransDate,
		TR.VendorId,
		VE.VendName
UNION
SELECT	''' + @CpnyName + ''' AS Company,
		CAST(''' + CONVERT(Char(10), @WeekEnd, 101) + ''' AS Datetime) AS WeekEndDate,
		WeekEndDate AS TransDate,
		DATENAME(Week, WeekEndDate) AS Week,
		TR.VendorId,
		VE.VendName AS Vendor,
		''01_DPY'' AS DeductionCode,
		''Drayage'' AS DeductionType,
		SUM(Drayage)
FROM	View_Integration_AP TR
		LEFT JOIN ' + RTRIM(@Company) + '.dbo.PM00200 VE ON TR.VendorId = VE.VendorId
WHERE	Company = ''' + @Company + ''' AND
		DATENAME(Week, WeekEndDate) = ' + CAST(@Week AS Char(2)) + ''
		
IF @DriverId IS NOT Null
	SET @Query = @Query + ' AND TR.VendorId = ''' + @Driver + ''''

SET @Query = @Query + ' GROUP BY
		WeekEndDate,
		TR.VendorId,
		VE.VendName '

SET @Query = @Query + 'UNION 
SELECT	''' + @CpnyName + ''' AS Company,
		CAST(''' + CONVERT(Char(10), @WeekEnd, 101) + ''' AS Datetime) AS WeekEndDate,
		PH.DocDate AS TransDate,
		DATENAME(Week, PH.PstgDate) AS Week,
		PH.VendorId,
		VE.VendName AS Vendor,
		''30_OTHREIM_H'' AS DeductionCode,
		PH.TrxDscrn,
		PH.DocAmnt
FROM	' + RTRIM(@Company) + '.dbo.PM30200 PH
		LEFT JOIN ' + RTRIM(@Company) + '.dbo.PM30600 PD ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce AND PD.DistType = 2
		LEFT JOIN ' + RTRIM(@Company) + '.dbo.PM00200 VE ON PH.VendorId = VE.VendorId
WHERE	PH.BchSourc = ''PM_Trxent'' AND
		VE.VndClsId = ''DRV'' AND
		PD.DstIndx NOT IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = ''' + @Company + ''') AND
		DATENAME(Week, PH.PstgDate) = ' + CAST(@Week AS Char(2)) + ''

IF @DriverId IS NOT Null
	SET @Query = @Query + ' AND PH.VendorId = ''' + @Driver + ''''

SET @Query = @Query + 'UNION 
SELECT	''' + @CpnyName + ''' AS Company,
		CAST(''' + CONVERT(Char(10), @WeekEnd, 101) + ''' AS Datetime) AS WeekEndDate,
		PH.DocDate AS TransDate,
		DATENAME(Week, PH.PstgDate) AS Week,
		PH.VendorId,
		VE.VendName AS Vendor,
		''30_OTHREIM_O'' AS DeductionCode,
		PH.TrxDscrn,
		PH.DocAmnt
FROM	' + RTRIM(@Company) + '.dbo.PM20000 PH
		LEFT JOIN ' + RTRIM(@Company) + '.dbo.PM10100 PD ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce AND PD.DistType = 2
		LEFT JOIN ' + RTRIM(@Company) + '.dbo.PM00200 VE ON PH.VendorId = VE.VendorId
WHERE	PH.BchSourc = ''PM_Trxent'' AND
		VE.VndClsId = ''DRV'' AND
		PD.DstIndx NOT IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = ''' + @Company + ''') AND
		DATENAME(Week, PH.PstgDate) = ' + CAST(@Week AS Char(2)) + ''

IF @DriverId IS NOT Null
	SET @Query = @Query + ' AND PH.VendorId = ''' + @Driver + ''''

SET @Query = @Query + ' ORDER BY
		TR.VendorId,
		DeductionCode,
		DeductionType'

PRINT(@Query)
EXECUTE(@Query)