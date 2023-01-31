SET NOCOUNT ON

--EXECUTE USP_OOS_Deductions_Create 'AIS', 'A1693', 'FUELTAX', '8/22/2017', 500, 4

/*
="INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',"&IF(B2 = "","NULL","'"&TEXT(B2,"mm/dd/yyyy")&"'")&",'"&A2&"',"&D2&")"
*/
DECLARE	@Company		Varchar(5),
		@TermDate		Date,
		@VendorId		Varchar(20),
		@TotDeduction	Numeric(10,2),
		@NumDeductions	Int,
		@DeductionCode	Varchar(10) = 'DUPL_PYMNT',
		@Query			Varchar(1000)

DECLARE	@tblDeductions Table (
		Company			Varchar(5),
		TermDate		Date Null,
		VendorId		Varchar(20),
		TotDeduction	Numeric(10,2))

INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'7989',289.76)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'8863',514.44)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'9989',433.08)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'10035',433.4)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'10209',74.28)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'10211',85.6)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'10362',52.12)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'10536',250.16)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'10860',616.5)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'10971',104.48)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'12278',42.8)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'12296',100.36)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','04/19/2021','12320',238.08)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'12393',106.36)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'12396',1373.32)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'12426',339.6)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','05/04/2021','12524',115.96)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'12540',893.96)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'12718',1065.5)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'12980',219.1)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','04/02/2021','13264',338.39)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'13350',244.36)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'13398',232.96)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'13432',63.36)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'13467',946.68)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50212',239.72)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50299',469.24)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50446',285.42)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50483',69.84)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50561',285.77)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','05/24/2021','I50631',381.36)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50685',540.38)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50687',57.76)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50689',223.28)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50692',69.36)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50788',100.32)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50795',144.78)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50797',300.96)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I50927',69.36)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','05/07/2021','I50977',57.88)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51072',298.15)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51250',51.86)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51355',317)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51440',213.92)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51448',235.76)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51470',184.44)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51474',401.21)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51535',69.36)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','05/24/2021','I51537',185.24)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51582',79.38)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51593',64.04)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51635',58.02)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51641',277.26)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51699',515.24)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','03/01/2021','I51738',139.68)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51793',389.56)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51823',373.84)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51828',243.08)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51833',1120.05)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51853',64.04)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51869',104.48)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51924',281.96)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51970',476.28)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I51999',442.69)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','03/10/2021','I52003',177.86)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','05/24/2021','I52005',126.72)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52060',873.83)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52071',263.12)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52075',214)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52117',324.98)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52126',46.96)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52142',150.72)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52167',75.8)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','04/26/2021','I52170',282.96)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52171',133.04)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52188',64.04)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52217',110.52)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52243',201.73)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','04/15/2021','I52259',79.38)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52260',81.28)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52269',110.64)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52278',47.44)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52287',63.52)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52289',331.54)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52298',291.27)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52333',191.64)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52379',110.64)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','04/14/2021','I52383',110.64)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','05/10/2021','I52385',46.32)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC','03/10/2021','I52387',112)
INSERT INTO @tblDeductions (Company, TermDate, VendorId, TotDeduction) VALUES ('IMC',NULL,'I52398',121.62)

DECLARE curDeductions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	@tblDeductions
WHERE	@TermDate IS Null

OPEN curDeductions 
FETCH FROM curDeductions INTO @Company, @TermDate, @VendorId, @TotDeduction

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @NumDeductions = IIF(@TotDeduction <= 101, 1, IIF(ROUND(@TotDeduction/100, 2) > CAST(@TotDeduction/100 AS Int), CAST(@TotDeduction/100 AS Int) + 1, CAST(@TotDeduction/100 AS Int)))

	SET @Query = 'EXECUTE USP_OOS_Deductions_Create ''' + @Company + ''',''' + @VendorId + ''',''' + @DeductionCode + ''',''06/03/2021'',' + CAST(@TotDeduction AS Varchar) + ',' + CAST(@NumDeductions AS Varchar)

	PRINT @Query
	EXECUTE(@Query)

	FETCH FROM curDeductions INTO @Company, @TermDate, @VendorId, @TotDeduction
END

CLOSE curDeductions
DEALLOCATE curDeductions

/*
UPDATE	OOS_Deductions
SET		OOS_Deductions.DeductionAmount = IIF(DATA.NumberOfDeductions = 1, DATA.MaxDeduction, 100)
FROM	(
SELECT	Company,
		Vendorid,
		DeductionCode,
		DeductionType,
		CreditAccount,
		DebitAccount,
		AmountToDeduct,
		MaxDeduction,
		NumberOfDeductions,
		DeductionId
FROM	View_OOS_Deductions
WHERE	Company = 'IMC'
		AND DeductionCode = 'DUPL_PYMNT'
		) DATA
WHERE	OOS_Deductions.OOS_DeductionId = DATA.DeductionId

SELECT	Company,
		Vendorid,
		DeductionCode,
		DeductionType,
		CreditAccount,
		DebitAccount,
		AmountToDeduct,
		MaxDeduction,
		NumberOfDeductions,
		DeductionId
FROM	View_OOS_Deductions
WHERE	Company = 'IMC'
		AND DeductionCode = 'DUPL_PYMNT'
ORDER BY Vendorid
*/