/*
EXECUTE USP_AP_Historical_Trial_Balance_New @Company='AIS', @CutoffDate='07/02/2022', @VendorId=Null, @Summary=0, @SortByName=1, @ForReporting=0
EXECUTE USP_AP_Historical_Trial_Balance_New @Company='AIS', @CutoffDate='07/02/2022', @VendorId=Null, @Summary=1, @SortByName=1, @ForReporting=1
*/
ALTER PROCEDURE USP_AP_Historical_Trial_Balance_New
	@Company			Varchar(5),
	@CutoffDate			Date,
	@VendorId			Varchar(15) = Null,
	@Summary			Bit = 0,
	@SortByName			Bit = 1,
	@ForReporting		Bit = 0,
	@VendorClass		Varchar(200) = Null
AS
SET NOCOUNT ON

DECLARE @Query			Varchar(MAX)

IF @VendorId IN ('','ALL')
	SET @VendorId = Null

IF @VendorClass = ''
	SET @VendorClass = Null

DECLARE @tblTrialData	Table (
		VCHRNMBR		Varchar(20),
		VENDORID		Varchar(15),
		VENDNAME		Varchar(100),
		VNDCLASS		Varchar(15),
		DOCTYPE			Smallint,
		DOCDATE			Date, 
		POSTEDDT		Date, 
		DOCNUMBR		Varchar(30),
		DOCAMNT			Numeric(12,2),
		CURRAMT			Numeric(12,2),
		DUEDATE			Date, 
		PYMTRMID		Varchar(30), 
		DATASOURCE		Varchar(10),
		DaysDue			Int)

SET @Query = N'SELECT * FROM (
		SELECT	TRX.VCHRNMBR,
				RTRIM(TRX.VENDORID) AS VENDORID,
				UPPER(RTRIM(VND.VENDNAME)) AS VENDNAME,
				RTRIM(TRX.VNDCLSID) AS VNDCLSID,
				TRX.DOCTYPE,
				TRX.DOCDATE, 
				TRX.POSTEDDT, 
				RTRIM(TRX.DOCNUMBR) AS DOCNUMBR,
				ABS(TRX.DOCAMNT) * IIF(TRX.DOCTYPE < 4, 1, -1) AS DOCAMNT,
				CASE WHEN TRX.DOCTYPE < 4 THEN IIF(ABS(ISNULL(APT.APPLDAMT, 0)) > ABS(TRX.DOCAMNT), 0, ABS(TRX.DOCAMNT) - ABS(ISNULL(APT.APPLDAMT, 0)))
						WHEN TRX.DOCTYPE > 3 THEN IIF(ABS(ISNULL(APF.APPLDAMT, 0)) > ABS(TRX.DOCAMNT), 0, ABS(TRX.DOCAMNT) - ABS(ISNULL(APF.APPLDAMT, 0)))
					END * IIF(TRX.DOCTYPE < 4, 1, -1) AS CURRAMT,
				TRX.DUEDATE, 
				TRX.PYMTRMID, 
				DATASOURCE,
				IIF(TRX.DOCTYPE > 3, 10, DATEDIFF(dd, TRX.DOCDATE, ''' + CONVERT(Char(10), @CutoffDate, 101) + ''')) AS DaysDue
		FROM	(
				SELECT	VCHRNMBR,
						TRA.VENDORID,
						VNDCLSID,
						DOCTYPE,
						DOCDATE, 
						POSTEDDT, 
						DOCNUMBR,
						DOCAMNT,
						TRA.DEX_ROW_ID,
						DISCAMNT, 
						DUEDATE, 
						TRA.PYMTRMID, 
						VOIDED,
						''HISTORY'' AS DATASOURCE
				FROM	' + @Company + '.dbo.PM30200 TRA
						INNER JOIN ' + @Company + '.dbo.PM00200 VND ON TRA.VENDORID = VND.VENDORID
				WHERE	((IIF(PSTGDATE = ''01/01/1900'', POSTEDDT,  PSTGDATE) <= ''' + CONVERT(Char(10), @CutoffDate, 101) + ''' AND VOIDED = 0) 
						OR (IIF(PSTGDATE = ''01/01/1900'', POSTEDDT,  PSTGDATE) <= ''' + CONVERT(Char(10), @CutoffDate, 101) + ''' AND VOIDPDATE > ''' + CONVERT(Char(10), @CutoffDate, 101) + ''' AND VOIDED = 1))'

IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND TRA.VENDORID = ''' + @VendorId + ''' '

IF @VendorClass IS NOT Null
	SET @Query = @Query + 'AND VND.VNDCLSID IN (''' + REPLACE(@VendorClass, ',', ''',''') + ''')'

SET @Query = @Query + '	UNION
				SELECT	VCHRNMBR,
						TRA.VENDORID,
						VNDCLSID,
						DOCTYPE,
						DOCDATE, 
						POSTEDDT, 
						DOCNUMBR,
						DOCAMNT,
						TRA.DEX_ROW_ID,
						DISCAMNT, 
						DUEDATE, 
						TRA.PYMTRMID, 
						VOIDED,
						''OPEN'' AS DATASOURCE
				FROM	' + @Company + '.dbo.PM20000 TRA
						INNER JOIN ' + @Company + '.dbo.PM00200 VND ON TRA.VENDORID = VND.VENDORID
				WHERE	PSTGDATE <= ''' + CONVERT(Char(10), @CutoffDate, 101) + ''' AND VOIDED = 0 '
IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND TRA.VENDORID = ''' + @VendorId + ''''

IF @VendorClass IS NOT Null
	SET @Query = @Query + 'AND VND.VNDCLSID IN (''' + REPLACE(@VendorClass, ',', ''',''') + ''')'


SET @Query = @Query + ') TRX
				INNER JOIN ' + @Company + '.dbo.PM00200 VND ON TRX.VENDORID = VND.VENDORID
				LEFT JOIN (
							SELECT	VENDORID,
									APTODCNM,
									SUM(APPLDAMT) AS APPLDAMT
							FROM	(
									SELECT	VENDORID,
											APTODCNM,
											VCHRNMBR,
											APPLDAMT
									FROM	' + @Company + '.dbo.PM30300 
									WHERE	GLPOSTDT <= ''' + CONVERT(Char(10), @CutoffDate, 101) + '''
											AND ApplyFromGLPostDate <= ''' + CONVERT(Char(10), @CutoffDate, 101) + '''
											AND ApplyFromGLPostDate <> ''1900-01-01'''
IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND VENDORID = ''' + @VendorId + ''''

SET @Query = @Query + '				UNION
									SELECT	VENDORID,
											APTODCNM,
											VCHRNMBR,
											APPLDAMT
									FROM	' + @Company + '.dbo.PM10200
									WHERE	POSTED = 1
											AND GLPOSTDT <= ''' + CONVERT(Char(10), @CutoffDate, 101) + '''
											AND ApplyFromGLPostDate <= ''' + CONVERT(Char(10), @CutoffDate, 101) + '''
											AND ApplyFromGLPostDate <> ''1900-01-01'''
IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND VENDORID = ''' + @VendorId + ''''

SET @Query = @Query + '	) DATA
							GROUP BY VENDORID, APTODCNM
							) APT ON TRX.VENDORID = APT.VENDORID AND TRX.DOCNUMBR = APT.APTODCNM 
				LEFT JOIN (
							SELECT	VENDORID,
									APFRDCNM,
									VCHRNMBR,
									SUM(APPLDAMT) AS APPLDAMT
							FROM	(
									SELECT	VENDORID,
											APFRDCNM,
											APTVCHNM,
											VCHRNMBR,
											APPLDAMT
									FROM	' + @Company + '.dbo.PM30300 
									WHERE	GLPOSTDT <= ''' + CONVERT(Char(10), @CutoffDate, 101) + '''
											AND ApplyFromGLPostDate <= ''' + CONVERT(Char(10), @CutoffDate, 101) + '''
											AND ApplyFromGLPostDate <> ''1900-01-01'''
IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND VENDORID = ''' + @VendorId + ''''

SET @Query = @Query + '				UNION
									SELECT	VENDORID,
											APFRDCNM,
											APTVCHNM,
											VCHRNMBR,
											APPLDAMT
									FROM	' + @Company + '.dbo.PM20100
									WHERE	DOCDATE <= ''' + CONVERT(Char(10), @CutoffDate, 101) + ''' 
											AND POSTED = 0 '
IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND VENDORID = ''' + @VendorId + ''''

SET @Query = @Query + '				UNION
									SELECT	VENDORID,
											APFRDCNM,
											APTVCHNM,
											VCHRNMBR,
											APPLDAMT
									FROM	' + @Company + '.dbo.PM10200
									WHERE	POSTED = 1
											AND GLPOSTDT <= ''' + CONVERT(Char(10), @CutoffDate, 101) + '''
											AND ApplyFromGLPostDate <= ''' + CONVERT(Char(10), @CutoffDate, 101) + '''
											AND ApplyFromGLPostDate <> ''1900-01-01'''
IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND VENDORID = ''' + @VendorId + ''''

	SET @Query = @Query + '	) DATA
							GROUP BY VENDORID, APFRDCNM, VCHRNMBR
							) APF ON TRX.VENDORID = APF.VENDORID AND TRX.VCHRNMBR = APF.VCHRNMBR AND TRX.DOCNUMBR = APF.APFRDCNM 
	) AP
	WHERE	CURRAMT <> 0 '

IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND VENDORID = ''' + @VendorId + ''''
print @Query
INSERT INTO @tblTrialData
EXECUTE(@Query)

IF @Summary = 0
BEGIN
	IF @ForReporting = 0
	BEGIN
		SELECT	CPY.CompanyName,
				DAT.VENDORID,
				DAT.VENDNAME,
				DAT.VNDCLASS,
				DAT.DOCDATE,
				DAT.DOCNUMBR,
				CASE DAT.DOCTYPE WHEN 1 THEN 'Invoice'
								 WHEN 4 THEN 'Return'
								 WHEN 5 THEN 'Credit Memo'
								 ELSE 'Payment' END AS DOCTYPE,
				DAT.DOCAMNT AS [Document_Amount],
				DAT.CURRAMT AS Due,
				CASE WHEN DAT.DaysDue <= 30 THEN DAT.CURRAMT ELSE 0 END [0_to_30_Days],
				CASE WHEN DAT.DaysDue BETWEEN 31 AND 60 THEN DAT.CURRAMT ELSE 0 END [31_to_60_Days],
				CASE WHEN DAT.DaysDue BETWEEN 61 AND 90 THEN DAT.CURRAMT ELSE 0 END [61_to_90_Days],
				CASE WHEN DAT.DaysDue > 90 THEN DAT.CURRAMT ELSE 0 END [91_and_Over],
				DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP WHERE TMP.VENDORID = DAT.VENDORID),
				0 AS Summary
		FROM	@tblTrialData DAT
				INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
				INNER JOIN (
							SELECT	VENDORID, SUM(CURRAMT) AS TOTALAMNT 
							FROM	@tblTrialData 
							GROUP BY VENDORID
							) TOT ON DAT.VENDORID = TOT.VENDORID
		WHERE	TOT.TOTALAMNT <> 0
		ORDER BY IIF(@SortByName = 0, DAT.VENDORID, DAT.VENDNAME)
	END
	ELSE
	BEGIN
		SELECT	*
		FROM	(
				SELECT	CPY.CompanyName,
						DAT.VENDORID,
						IIF(@SortByName = 1, RTRIM(DAT.VENDNAME) + ' [' + RTRIM(DAT.VENDORID) + ']', RTRIM(DAT.VENDORID) + ' - ' + RTRIM(DAT.VENDNAME)) AS VENDNAME,
						DAT.VNDCLASS,
						DAT.DOCDATE,
						DAT.DOCNUMBR,
						DAT.DOCTYPE,
						DAT.DOCAMNT AS [Document Amount],
						DAT.CURRAMT AS Due,
						CASE WHEN DAT.DaysDue <= 30 THEN DAT.CURRAMT ELSE 0 END [0_to_30_Days],
						CASE WHEN DAT.DaysDue BETWEEN 31 AND 60 THEN DAT.CURRAMT ELSE 0 END [31_to_60_Days],
						CASE WHEN DAT.DaysDue BETWEEN 61 AND 90 THEN DAT.CURRAMT ELSE 0 END [61_to_90_Days],
						CASE WHEN DAT.DaysDue > 90 THEN DAT.CURRAMT ELSE 0 END [91_and_Over],
						DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP WHERE TMP.VENDORID = DAT.VENDORID),
						0 AS Summary
				FROM	@tblTrialData DAT
						INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
						INNER JOIN (
									SELECT	VENDORID, SUM(CURRAMT) AS TOTALAMNT 
									FROM	@tblTrialData 
									GROUP BY VENDORID
									) TOT ON DAT.VENDORID = TOT.VENDORID
				WHERE	TOT.TOTALAMNT <> 0
				UNION
				SELECT	CPY.CompanyName,
						DAT.VENDORID,
						IIF(@SortByName = 1, RTRIM(DAT.VENDNAME) + ' [' + RTRIM(DAT.VENDORID) + ']', RTRIM(DAT.VENDORID) + ' - ' + RTRIM(DAT.VENDNAME)) AS VENDNAME,
						DAT.VNDCLASS,
						MAX(DOCDATE) AS DOCDATE,
						MAX(DOCNUMBR) AS DOCNUMBR,
						Null AS DOCTYPE,
						0 AS [Document Amount],
						SUM(DAT.CURRAMT) AS Due,
						SUM(CASE WHEN DAT.DaysDue <= 30 THEN DAT.CURRAMT ELSE 0 END) [0_to_30_Days],
						SUM(CASE WHEN DAT.DaysDue BETWEEN 31 AND 60 THEN DAT.CURRAMT ELSE 0 END) [31_to_60_Days],
						SUM(CASE WHEN DAT.DaysDue BETWEEN 61 AND 90 THEN DAT.CURRAMT ELSE 0 END) [61_to_90_Days],
						SUM(CASE WHEN DAT.DaysDue > 90 THEN DAT.CURRAMT ELSE 0 END) [91_and_Over],
						DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP WHERE TMP.VENDORID = DAT.VENDORID),
						1 AS Summary
				FROM	@tblTrialData DAT
						INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
						INNER JOIN (
									SELECT	VENDORID, SUM(CURRAMT) AS TOTALAMNT 
									FROM	@tblTrialData 
									GROUP BY VENDORID
									) TOT ON DAT.VENDORID = TOT.VENDORID
				WHERE	TOT.TOTALAMNT <> 0
				GROUP BY CPY.CompanyName, DAT.VENDORID, DAT.VENDNAME, DAT.VNDCLASS
				UNION
				SELECT	CPY.CompanyName,
						'ZZZZZZZZ' AS VENDORID,
						'ZZZZZZZZ' AS VENDNAME,
						'ZZZZZZZZ' AS VNDCLASS,
						Null AS DOCDATE,
						Null AS DOCNUMBR,
						Null AS DOCTYPE,
						0 AS [Document Amount],
						SUM(DAT.CURRAMT) AS Due,
						SUM(CASE WHEN DAT.DaysDue <= 30 THEN DAT.CURRAMT ELSE 0 END) [0_to_30_Days],
						SUM(CASE WHEN DAT.DaysDue BETWEEN 31 AND 60 THEN DAT.CURRAMT ELSE 0 END) [31_to_60_Days],
						SUM(CASE WHEN DAT.DaysDue BETWEEN 61 AND 90 THEN DAT.CURRAMT ELSE 0 END) [61_to_90_Days],
						SUM(CASE WHEN DAT.DaysDue > 90 THEN DAT.CURRAMT ELSE 0 END) [91_and_Over],
						DataCounter = (SELECT COUNT(*) FROM @tblTrialData),
						-1 AS Summary
				FROM	@tblTrialData DAT
						INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
						INNER JOIN (
									SELECT	VENDORID, SUM(CURRAMT) AS TOTALAMNT 
									FROM	@tblTrialData 
									GROUP BY VENDORID
									) TOT ON DAT.VENDORID = TOT.VENDORID
				WHERE	TOT.TOTALAMNT <> 0
				GROUP BY CPY.CompanyName
				) DATA
		ORDER BY VENDNAME, Summary DESC, DOCNUMBR
	END
END
ELSE
BEGIN
	IF @ForReporting = 0
	BEGIN
		SELECT	CPY.CompanyName,
				VENDORID,
				IIF(@SortByName = 1, RTRIM(VENDNAME) + ' [' + RTRIM(VENDORID) + ']', RTRIM(VENDORID) + ' - ' + RTRIM(VENDNAME)) AS VENDNAME,
				VNDCLASS,
				Null AS DOCDATE,
				Null AS DOCNUMBR,
				Null AS DOCTYPE,
				0 AS [Document_Amount],
				SUM(CURRAMT) AS Due,
				SUM(CASE WHEN DaysDue <= 30 THEN CURRAMT ELSE 0 END) AS [Current],
				SUM(CASE WHEN DaysDue <= 30 THEN CURRAMT ELSE 0 END) AS [0_to_30_Days],
				SUM(CASE WHEN DaysDue BETWEEN 31 AND 60 THEN CURRAMT ELSE 0 END) AS [31_to_60_Days],
				SUM(CASE WHEN DaysDue BETWEEN 61 AND 90 THEN CURRAMT ELSE 0 END) AS [61_to_90_Days],
				SUM(CASE WHEN DaysDue > 90 THEN CURRAMT ELSE 0 END) AS [91_and_Over],
				DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP WHERE TMP.VENDORID = DAT.VENDORID),
				1 AS Summary
		FROM	@tblTrialData DAT
				INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
		GROUP BY CPY.CompanyName, VENDORID, VENDNAME, VNDCLASS
		HAVING SUM(CURRAMT) <> 0
		ORDER BY IIF(@SortByName = 0, VENDORID, VENDNAME)
	END
	ELSE
	BEGIN
		SELECT	*
		FROM	(
				SELECT	CPY.CompanyName,
						VENDORID,
						IIF(@SortByName = 1, RTRIM(VENDNAME) + ' [' + RTRIM(VENDORID) + ']', RTRIM(VENDORID) + ' - ' + RTRIM(VENDNAME)) AS VENDNAME,
						VNDCLASS,
						Null AS DOCDATE,
						'' AS DOCNUMBR,
						Null AS DOCTYPE,
						0 AS [Document Amount],
						SUM(CURRAMT) AS Due,
						SUM(CASE WHEN DaysDue <= 30 THEN CURRAMT ELSE 0 END) AS [Current],
						SUM(CASE WHEN DaysDue <= 30 THEN DAT.CURRAMT ELSE 0 END) [0_to_30_Days],
						SUM(CASE WHEN DaysDue BETWEEN 31 AND 60 THEN CURRAMT ELSE 0 END) AS [31_to_60_Days],
						SUM(CASE WHEN DaysDue BETWEEN 61 AND 90 THEN CURRAMT ELSE 0 END) AS [61_to_90_Days],
						SUM(CASE WHEN DaysDue > 90 THEN CURRAMT ELSE 0 END) AS [91_and_Over],
						DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP WHERE TMP.VENDORID = DAT.VENDORID),
						1 AS Summary
				FROM	@tblTrialData DAT
						INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
				GROUP BY CPY.CompanyName, VENDORID, VENDNAME,VNDCLASS
				HAVING SUM(CURRAMT) <> 0
				UNION
				SELECT	CPY.CompanyName,
						'ZZZZZZZZ' AS VENDORID,
						'ZZZZZZZZ' AS VENDNAME,
						'ZZZZZZZZ' AS VNDCLASS,
						Null AS DOCDATE,
						'' AS DOCNUMBR,
						Null AS DOCTYPE,
						0 AS [Document Amount],
						SUM(CURRAMT) AS Due,
						SUM(CASE WHEN DaysDue <= 30 THEN CURRAMT ELSE 0 END) AS [Current],
						SUM(CASE WHEN DaysDue <= 30 THEN DAT.CURRAMT ELSE 0 END) [0_to_30_Days],
						SUM(CASE WHEN DaysDue BETWEEN 31 AND 60 THEN CURRAMT ELSE 0 END) AS [31_to_60_Days],
						SUM(CASE WHEN DaysDue BETWEEN 61 AND 90 THEN CURRAMT ELSE 0 END) AS [61_to_90_Days],
						SUM(CASE WHEN DaysDue > 90 THEN CURRAMT ELSE 0 END) AS [91_and_Over],
						DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP),
						-1 AS Summary
				FROM	@tblTrialData DAT
						INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
				GROUP BY CPY.CompanyName
				HAVING SUM(CURRAMT) <> 0
				) DATA
		ORDER BY VENDNAME, Summary DESC
	END
END