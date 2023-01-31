-- SELECT * FROM PM10201 -- PM_Payment_Apply_WORK
-- SELECT * FROM PM10300 -- PM_Payment_WORK

DECLARE	@Year		Int,
		@Week		Int,
		@CpnyName	Varchar(40),
		@Query		Varchar(5000),
		@Driver		Varchar(10),
		@Company	Char(6),
		@WeekEnd	Datetime,
		@DriverId	Varchar(10),
		@WEndDate	Datetime

SET		@Company	= 'AIS'
SET		@WeekEnd	= '05/22/2008'
SET		@DriverId	= 'A0164'
SET		@CpnyName	= (SELECT CmpnyNam FROM Dynamics.dbo.View_AllCompanies WHERE Interid = @Company)
SET		@WEndDate	= CASE	WHEN DATENAME(Weekday, @WeekEnd) = 'Sunday' THEN @WeekEnd - 1
							ELSE DATEADD(Day, 7 - GPCustom.dbo.WeekDay(@WeekEnd), @WeekEnd) END
SET		@Year		= YEAR(@WEndDate)
SET		@Week		= DATENAME(Week, @WEndDate)

SELECT	@CpnyName AS Company,
		@WEndDate AS WeekEndDate,
		PH.DocDate AS TransDate,
		@Week AS Week,
		PH.VendorId,
		PH.VendName,
		CASE	WHEN LEFT(PD.ApFvchNm, 3) = 'DPY' THEN 1
				WHEN LEFT(PD.ApFvchNm, 3) = 'FPT' THEN 2
				WHEN LEFT(PD.ApFvchNm, 3) = 'OOS' THEN 3
		ELSE 4 END AS DeductionCode,
		CASE	WHEN LEFT(PD.ApFvchNm, 3) = 'DPY' THEN 'Drayage'
				WHEN LEFT(PD.ApFvchNm, 3) = 'FPT' THEN 'Fuel Purchases'
				WHEN LEFT(PD.ApFvchNm, 3) = 'OOS' THEN (SELECT Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = @Company AND DeductionCode = LEFT(PD.DocNumbr, GPCustom.dbo.AT(RTRIM(PH.VendorId), PD.DocNumbr, 1) - 1))
		ELSE 'Other Deduction' END AS DeductionType,
		PD.Outstanding_Amount AS DeductionAmount,
		PH.ChekTotl,
		PD.ApFvchNm,
		PD.DocNumbr,
		PD.AmntPaid
FROM	PM10300 PH
		INNER JOIN PM10201 PD ON PH.PmntNmbr = PD.PmntNmbr
WHERE	PH.DocDate = @WeekEnd AND
		PH.VendorId = @DriverId
ORDER BY
		PH.VendorId, 7, 8

-- SELECT * FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = 'AIS'
-- EXECUTE GPCustom.dbo.USP_DRA_Report 'AIS', '2008-05-24', 'A0164'

-- SELECT * FROM PM10201 WHERE	VendorId = 'A0164'
-- SELECT * FROM PM10300 WHERE	VendorId = 'A0031'

