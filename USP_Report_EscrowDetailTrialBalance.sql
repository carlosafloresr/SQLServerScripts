USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_Report_EscrowDetailTrialBalance]    Script Date: 2/14/2022 3:34:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Report_EscrowDetailTrialBalance 'AIS', 1, '0-00-2790', '09/15/2021', '11/02/2021', NULL, 'CFLORES', 1, 0, NULL
EXECUTE USP_Report_EscrowDetailTrialBalance 'GIS', 1, '0-00-2790', '09/15/2021', '11/02/2021', NULL, 'CFLORES', 1, 0, NULL
EXECUTE USP_Report_EscrowDetailTrialBalance 'OIS', 1, '0-00-2790', '01/05/2022', '01/12/2022', NULL, 'JCROCKER', 1, 1, NULL
*/
ALTER PROCEDURE [dbo].[USP_Report_EscrowDetailTrialBalance]
		@CompanyId		Varchar(6), 
		@EscrowModule	Int,
		@Account		Varchar(15) = Null,
		@DateIni		DateTime,
		@DateEnd		DateTime,
		@VendorId		Varchar(10) = Null,
		@UserId			Varchar(25),
		@ReportId		Int = 1,
		@HideZeros		Bit = 1,
		@BatchId		Varchar(20) = Null
AS
SET NOCOUNT ON
DECLARE	@IniDate		Char(10),
		@EndDate		Char(22),
		@Query			Varchar(5000),
		@Query2			Varchar(1000),
		@Query3			Varchar(3000),
		@QryVendor		Varchar(500),
		@CompanyName	Varchar(50)

DELETE tmpEscrowTransactions WHERE UserId = @UserId AND CompanyId = @CompanyId

SET	@CompanyId		= RTRIM(@CompanyId)
SET	@CompanyName	= (SELECT CmpnyNam FROM Dynamics.dbo.View_AllCompanies WHERE InterID = @CompanyId)

DELETE	EscrowBalancesReport 
WHERE	UserId = @UserId

SET	@IniDate = CONVERT(Char(10), @DateIni, 101)
SET	@EndDate = CONVERT(Char(10), @DateEnd, 101) + ' 11:59:59 PM'

IF @BatchId IS NOT Null AND @EscrowModule = 15
BEGIN
	EXECUTE USP_DriverEscrowBalance @CompanyId, @BatchId, @VendorId, @UserId
END
ELSE
BEGIN
	IF @EscrowModule = 5
	BEGIN
		SET @Query = RTRIM(@CompanyId) + '.dbo.USP_Report_ExpenseRecovery ''' + RTRIM(@CompanyId) + ''''
		IF @Account IS Null
			SET @Query = @Query + ',Null'
		ELSE
			SET @Query = @Query + ',''' + @Account + ''''
		SET @Query = @Query + ',''' + CONVERT(Varchar, @IniDate, 101) + ''''
		SET @Query = @Query + ',''' + CONVERT(Varchar, @EndDate, 101) + ''''
		SET @Query = @Query + ',' + CAST(@HideZeros AS Char(1))

		EXECUTE(@Query)
	END
	ELSE
	BEGIN
		IF @Account IS Null
			SET	@Query2 = ''
		ELSE
			SET	@Query2 = 'E1.AccountNumber = ''' + RTRIM(@Account) + ''' AND '

		IF @VendorId IS Null
			SET	@QryVendor = ''
		ELSE
			SET @QryVendor = 'ET.VendorId = ''' + RTRIM(@VendorId) + ''' AND '

		-- Calculate Balances
		IF @EscrowModule = 5
		BEGIN
			SET @Query3	= 'SELECT E1.AccountNumber, ISNULL(E1.ProNumber, ''BLANK'') AS ProNumber, SUM(E1.Amount) AS Balance 
					FROM View_EscrowTransactions E1
					INNER JOIN #TempProNumbers PN ON E1.ProNumber = PN.ProNumber 
					WHERE ' + @Query2 + 'E1.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND E1.DeletedOn IS Null AND E1.Fk_EscrowModuleId = 5 AND E1.DeletedBy IS Null' + 
					' AND E1.PostingDate < ''' + @IniDate + ''' GROUP BY E1.AccountNumber, ISNULL(E1.ProNumber, ''BLANK'')'
		
			SELECT	ProNumber, 
					SUM(Amount) AS Amount
			INTO	#TempProNumbers
			FROM	View_EscrowTransactions
			WHERE	CompanyId = @CompanyId
					AND AccountNumber = @Account
					AND Fk_EscrowModuleId = @EscrowModule
			GROUP BY 
					ProNumber
		END
		ELSE
		BEGIN
			IF @EscrowModule = 6
			BEGIN
				SET @Query3	= 'SELECT E1.AccountNumber, E1.ClaimNumber, SUM(E1.Amount) AS Balance 
						FROM View_EscrowTransactions E1 WHERE ' + @Query2 + 'CompanyId = ''' + RTRIM(@CompanyId) + ''' AND E1.DeletedOn IS Null AND Fk_EscrowModuleId = ' + 
						RTRIM(CAST(@EscrowModule AS Char(10))) + ' AND E1.PostingDate < ''' + @IniDate + ''' AND E1.DeletedBy IS Null GROUP BY E1.AccountNumber, E1.ClaimNumber'
			END
			ELSE
			BEGIN
				SET @Query3	= 'SELECT E1.AccountNumber, E1.VendorId, SUM(E1.Amount) AS Balance 
						FROM View_EscrowTransactions E1 WHERE ' + @Query2 + 'CompanyId = ''' + RTRIM(@CompanyId) + ''' AND E1.DeletedOn IS Null AND Fk_EscrowModuleId = ' + 
						RTRIM(CAST(@EscrowModule AS Char(10))) + ' AND E1.PostingDate < ''' + @IniDate + ''' AND E1.DeletedBy IS Null GROUP BY E1.AccountNumber, E1.VendorId'
			END
		END

		SET	@Query2 = REPLACE(@Query2, 'E1', 'ET')
		
		SET @Query = N'INSERT INTO tmpEscrowTransactions
						SELECT	DISTINCT ET.*, 
								ET.ProNumber AS ProNumberMain, 
								''' + RTRIM(@UserId) + ''' AS UserId,
								0 AS EndBalance
						FROM	View_EscrowTransactions ET
						WHERE	ET.CompanyId = ''' + RTRIM(@CompanyId) + '''
								AND ET.DeletedOn IS Null 
								AND ET.Fk_EscrowModuleId = ' + CAST(@EscrowModule AS Varchar) + ' 
								AND ET.PostingDate BETWEEN ''' + @IniDate + ''' AND ''' + @EndDate + ''' 
								AND ET.PostingDate IS NOT Null '
		IF @VendorId IS NOT Null
			SET @Query = @Query + 'AND ET.VendorId = ''' + RTRIM(@VendorId) + ''''

		IF @Account IS NOT Null
			SET @Query = @Query + 'AND ET.AccountNumber = ''' + RTRIM(@Account) + ''''

		SET @Query = @Query + ' ORDER BY ET.AccountNumber, ET.VendorId, ET.PostingDate, ET.VoucherNumber'
		
		EXECUTE (@Query)

		SET @Query 	= 'INSERT INTO EscrowBalancesReport 
			SELECT	DISTINCT ET.EscrowTransactionId
					,ET.Source
					,ET.VoucherNumber
					,ET.ItemNumber
					,ET.CompanyId
					,ET.Fk_EscrowModuleId
					,ET.AccountNumber
					,ET.AccountType
					,ET.VendorId
					,ET.DriverId
					,ET.Division
					,ET.Amount
					,ET.ClaimNumber
					,ET.DriverClass
					,ET.AccidentType
					,ET.Status
					,ET.DMSubmitted
					,ET.DeductionPlan
					,ET.Comments
					,ET.ProNumber
					,ET.TransactionDate
					,ET.PostingDate
					,ET.EnteredBy
					,ET.EnteredOn
					,ET.ChangedBy
					,ET.ChangedOn
					,ET.Void
					,ET.InvoiceNumber
					,ET.OtherStatus
					,ET.DeletedBy
					,ET.DeletedOn
					,ET.BatchId
					,ET.SOPDocumentNumber
					,ET.RecordType
					,ET.TrailerNumber
					,ET.ChassisNumber
					,LEFT(COALESCE(ET.Comments, G0.Refrence, G1.Refrence, P0.DistRef, P3.DistRef, P1.TrxDscrn, P2.TrxDscrn, '' ''), 500) AS TransDescription
					,LEFT(CmpnyNam, 50) AS CompanyName
					,LEFT(VendName, 50)
					,ISNULL(BA.Balance, 0.00) AS Balance
					,UPPER(LEFT(GL.ActDescr, 75)) AS ActDescr
					,ET.ProNumberMain
					,LEFT(COALESCE(P1.DocNumbr, P2.DocNumbr, ET.InvoiceNumber, '' ''), 20) AS DocNumber
					,ET.PostingDate AS PostDate
					,ET.UserId
					,LEFT(EM.ModuleDescription, 50) AS Module
					,ISNULL(ET.EndBalance , 0) AS EndBalance
			FROM tmpEscrowTransactions ET
			INNER JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
			INNER JOIN EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
			INNER JOIN Dynamics.dbo.View_AllCompanies CO ON ET.CompanyID = CO.InterID 
			LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM10100 P0 ON ET.VoucherNumber = P0.Vchrnmbr AND ET.AccountType = P0.DistType AND ET.ItemNumber = P0.DstSqNum AND EA.AccountIndex = P0.DstIndx
			LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM20000 P1 ON P0.Vchrnmbr = P1.Vchrnmbr AND (P0.VendorId = P1.VendorId OR ET.VendorId = P1.VendorId)
			LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM30600 P3 ON ET.VoucherNumber = P3.Vchrnmbr AND ET.AccountType = P3.DistType AND ET.ItemNumber = P3.DstSqNum
			LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM30200 P2 ON P3.Vchrnmbr = P2.Vchrnmbr AND (P3.VendorId = P2.VendorId OR ET.VendorId = P2.VendorId) AND P3.TrxSorce = P2.TrxSorce
			LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.GL20000 G0 ON ET.VoucherNumber = CAST(G0.JrnEntry AS Varchar(20)) AND G0.SourcDoc <> ''PMTRX'' AND EA.AccountIndex = G0.ActIndx AND ET.ItemNumber = G0.SeqNumbr
			LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.GL30000 G1 ON ET.VoucherNumber = CAST(G1.JrnEntry AS Varchar(20)) AND G1.SourcDoc <> ''PMTRX'' AND EA.AccountIndex = G1.ActIndx AND ET.ItemNumber = G1.SeqNumbr
			LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM00200 VE ON ET.VendorId = VE.VendorId
			LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx '

		IF @EscrowModule = 5
			SET @Query = @Query + 'FULL OUTER JOIN (' + @Query3 + ') BA ON ET.AccountNumber = BA.AccountNumber AND ISNULL(ET.ProNumber, ''BLANK'') = BA.ProNumber INNER JOIN #TempProNumbers PN ON ET.ProNumber = PN.ProNumber '
		ELSE
			IF @EscrowModule = 6
				SET @Query = @Query + 'FULL OUTER JOIN (' + @Query3 + ') BA ON ET.AccountNumber = BA.AccountNumber AND ET.ClaimNumber = BA.ClaimNumber '
			ELSE
				SET @Query = @Query + 'FULL OUTER JOIN (' + @Query3 + ') BA ON ET.AccountNumber = BA.AccountNumber AND ET.VendorId = BA.VendorId '

		SET @Query = @Query + ' WHERE ET.UserId = ''' + RTRIM(@UserId) + ''' AND ET.CompanyId = ''' + @CompanyId + ''' AND ' + @Query2 + @QryVendor + ' ET.PostingDate IS NOT Null ORDER BY ET.AccountNumber, ET.VendorId, ET.PostingDate, ET.VoucherNumber'
		
		EXECUTE (@Query)

		IF @EscrowModule = 5 AND @ReportId = 2
		BEGIN
			SET	@Query3	= 'INSERT INTO EscrowBalancesReport (TransDescription, CompanyId, AccountNumber, Balance, ProNumber, UserId)
				SELECT DISTINCT ''BALANCE'', ''' + RTRIM(@CompanyId) + ''', ET.AccountNumber, SUM(ET.Amount) AS Balance, ET.ProNumber, ''' + RTRIM(@UserId) + '''
				FROM View_EscrowTransactions ET
				LEFT JOIN EscrowBalancesReport EB ON ET.AccountNumber = EB.AccountNumber AND ET.ProNumber = EB.ProNumber AND EB.UserId = ''' + RTRIM(@UserId) + '''
				WHERE ' + @QryVendor + @Query2 + 'ET.CompanyId = ''' + RTRIM(@CompanyId) + '''AND ET.DeletedOn IS Null AND ET.PostingDate IS NOT Null AND ET.Fk_EscrowModuleId = 5 ' + 
				'AND ET.PostingDate < ''' + @IniDate + ''' AND EB.AccountNumber IS NULL GROUP BY ET.AccountNumber, ET.ProNumber'
		END
		ELSE
		BEGIN
			IF @EscrowModule = 6
			BEGIN
				SET	@Query3	= 'INSERT INTO EscrowBalancesReport (TransDescription, CompanyId, CompanyName, AccountNumber, ActDescr, Balance, ClaimNumber, UserId)
					SELECT DISTINCT ''BALANCE'', ''' + RTRIM(@CompanyId) + ''', ''' + RTRIM(@CompanyName) + ''', ET.AccountNumber, GL.ActDescr, SUM(ET.Amount) AS Balance, ET.ClaimNumber, ''' + RTRIM(@UserId) + '''
					FROM View_EscrowTransactions ET
					INNER JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
					LEFT JOIN EscrowBalancesReport EB ON ET.AccountNumber = EB.AccountNumber AND ET.ClaimNumber = EB.ClaimNumber AND EB.UserId = ''' + RTRIM(@UserId) + '''
					LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx 
					WHERE ' + @QryVendor + @Query2 + 'ET.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND ET.DeletedOn IS Null AND ET.PostingDate IS NOT Null AND ET.Fk_EscrowModuleId = 6 ' + 
					'AND ET.PostingDate < ''' + @IniDate + ''' AND EB.ClaimNumber IS NULL
					GROUP BY ET.AccountNumber, GL.ActDescr, ET.ClaimNumber'
			END
			ELSE
			BEGIN
				SET	@Query3	= 'INSERT INTO EscrowBalancesReport (TransDescription, CompanyId, ClaimNumber, AccountNumber, VendorId, VendName, UserId, Balance, Module, CompanyName)
				SELECT DISTINCT ''BALANCE'', ''' + RTRIM(@CompanyId) + ''', ''BALANCE'' + ET.VendorId, ET.AccountNumber, ET.VendorId, VE.VendName, ''' + RTRIM(@UserId) + ''', SUM(ET.Amount) AS Balance, EM.ModuleDescription, ''' + RTRIM(@CompanyName) + '''
				FROM View_EscrowTransactions ET
				LEFT JOIN EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId
				LEFT JOIN EscrowBalancesReport EB ON ET.AccountNumber = EB.AccountNumber AND ET.VendorId = EB.VendorId AND EB.UserId = ''' + RTRIM(@UserId) + '''
				LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM20000 P1 ON ET.VoucherNumber = P1.Vchrnmbr 
				LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM10000 P2 ON ET.VoucherNumber = P2.VchnumWk 
				LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM00200 VE ON ET.VendorId = VE.VendorId
				WHERE ' + @QryVendor + @Query2 + 'ET.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND ET.DeletedOn IS Null AND ET.PostingDate IS NOT Null AND ET.Fk_EscrowModuleId = ' + 
				RTRIM(CAST(@EscrowModule AS Char(10))) + ' AND ET.PostingDate < ''' + @IniDate + ''' AND EB.AccountNumber IS NULL 
				GROUP BY ET.AccountNumber, ET.VendorId, VE.VendName, EM.ModuleDescription'
			END
		END

		EXECUTE (@Query3)

		DELETE tmpEscrowTransactions WHERE UserId = @UserId AND CompanyId = @CompanyId

		UPDATE	EscrowBalancesReport
		SET		ProNumber = ProNumberMain
		WHERE	(ProNumber IS Null OR ProNumber = '') AND
				UserId = @UserId

		IF @ReportId = 5
			DROP TABLE #TempProNumbers
		
		SELECT 	DISTINCT *
				,CAST(Null AS Int) AS VendorNumber
		INTO	#tmpReportData
		FROM 	EscrowBalancesReport
		WHERE 	UserId = '*NOTHING*'

		IF @ReportId = 2 AND @HideZeros = 1
		BEGIN
			IF @Account IS Null
			BEGIN
				INSERT INTO #tmpReportData
				SELECT 	DISTINCT *
						,CAST(dbo.ExtractInteger(VendorId) AS Int) AS VendorNumber
				FROM 	EscrowBalancesReport 
				WHERE 	UserId = @UserId AND
						CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END IN (
						SELECT	CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END
						FROM	EscrowBalancesReport ES
								INNER JOIN (SELECT CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END AS Pro_Number, 
								Balance AS IniBalance,
								SUM(Amount) AS SumAmount
						FROM 	EscrowBalancesReport WHERE UserId = @UserId AND DeletedOn IS Null
						GROUP BY CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END, Balance
						HAVING	Balance + SUM(Amount) <> 0) SM ON CASE WHEN ES.ProNumber IS Null OR RTRIM(ES.ProNumber) = '' THEN ES.VendorId ELSE ES.ProNumber END = SM.Pro_Number
						WHERE	UserId = @UserId)
				ORDER BY 
						AccountNumber
						,VendorId
						,TransactionDate
						,EscrowTransactionId
				END
			ELSE
				INSERT INTO #tmpReportData
				SELECT 	DISTINCT *
						,CAST(dbo.ExtractInteger(VendorId) AS Int) AS VendorNumber
				FROM 	EscrowBalancesReport 
				WHERE 	UserId = @UserId AND 
						AccountNumber = @Account AND
						CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END IN (
							SELECT	CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END
							FROM	EscrowBalancesReport ES
								INNER JOIN (SELECT CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END AS Pro_Number, 
								Balance AS IniBalance,
								SUM(Amount) AS SumAmount
							FROM 	EscrowBalancesReport WHERE UserId = @UserId AND DeletedOn IS Null
							GROUP BY CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END, Balance
							HAVING	Balance + SUM(Amount) <> 0) SM ON CASE WHEN ES.ProNumber IS Null OR RTRIM(ES.ProNumber) = '' THEN ES.VendorId ELSE ES.ProNumber END = SM.Pro_Number
							WHERE	UserId = @UserId)
				ORDER BY 
						VendorId
						,TransactionDate
						,EscrowTransactionId
		END
		ELSE
		BEGIN
			IF @EscrowModule = 6
			BEGIN
				IF @Account IS Null
					INSERT INTO #tmpReportData
					SELECT	DISTINCT *
							,CAST(dbo.ExtractInteger(VendorId) AS Int) AS VendorNumber 
					FROM	EscrowBalancesReport 
					WHERE	UserId = @UserId 
							AND DeletedOn IS Null 
					ORDER BY 
							AccountNumber
							,ClaimNumber
							,PostingDate
				ELSE
					INSERT INTO #tmpReportData
					SELECT	DISTINCT *
							,CAST(dbo.ExtractInteger(VendorId) AS Int) AS VendorNumber 
					FROM	EscrowBalancesReport 
					WHERE	UserId = @UserId 
							AND AccountNumber = @Account 
							AND DeletedOn IS Null 
					ORDER BY 
							ClaimNumber
							,PostingDate
			END
			ELSE
			BEGIN
				IF @ReportId = 1 AND @HideZeros = 1
				BEGIN
					IF @Account IS Null
					BEGIN
						INSERT INTO #tmpReportData
						SELECT 	DISTINCT *
								,CAST(dbo.ExtractInteger(VendorId) AS Int) AS VendorNumber
						FROM 	EscrowBalancesReport ER
						WHERE 	UserId = @UserId AND
								ER.AccountNumber + ER.VendorId IN (
										SELECT	AccountNumber + ES.VendorId AS VendorId
										FROM	EscrowBalancesReport ES
												INNER JOIN (SELECT	AccountNumber + VendorID AS VendorId, 
																	Balance AS IniBalance,
																	SUM(Amount) AS SumAmount
															FROM 	EscrowBalancesReport WHERE UserId = @UserId AND DeletedOn IS Null
															GROUP BY AccountNumber + VendorID, Balance
															HAVING	Balance + SUM(Amount) <> 0) SM ON ER.AccountNumber + ER.VendorId = SM.VendorId
										WHERE	UserId = @UserId)
						ORDER BY AccountNumber, ER.VendorId, PostingDate, EscrowTransactionId
					END
					ELSE
					BEGIN
						INSERT INTO #tmpReportData
						SELECT 	DISTINCT *
								,CAST(dbo.ExtractInteger(VendorId) AS Int) AS VendorNumber 
						FROM 	EscrowBalancesReport ER
						WHERE 	UserId = @UserId AND 
								AccountNumber = @Account AND
								ER.AccountNumber + ER.VendorId IN (
												SELECT	AccountNumber + ES.VendorId AS VendorId
												FROM	EscrowBalancesReport ES
														INNER JOIN (SELECT AccountNumber + VendorID AS VendorId, 
														Balance AS IniBalance,
														SUM(Amount) AS SumAmount
												FROM 	EscrowBalancesReport WHERE UserId = @UserId AND DeletedOn IS Null
												GROUP BY 
														AccountNumber + VendorID
														,Balance
												HAVING	Balance + SUM(Amount) <> 0) SM ON ER.AccountNumber + ER.VendorId = SM.VendorId
						WHERE	UserId = @UserId)
						ORDER BY 
								AccountNumber
								,ER.VendorId
								,PostingDate
								,EscrowTransactionId
					END
				END
				ELSE
				BEGIN
					IF @Account IS Null
						INSERT INTO #tmpReportData
						SELECT	DISTINCT *
								,CAST(dbo.ExtractInteger(VendorId) AS Int) AS VendorNumber 
						FROM	EscrowBalancesReport WHERE UserId = @UserId AND DeletedOn IS Null 
						ORDER BY 
								AccountNumber
								,VendorId
								,PostingDate
					ELSE
						INSERT INTO #tmpReportData
						SELECT	DISTINCT *
								,CAST(dbo.ExtractInteger(VendorId) AS Int) AS VendorNumber 
						FROM	EscrowBalancesReport 
						WHERE	UserId = @UserId AND AccountNumber = @Account AND DeletedOn IS Null 
						ORDER BY 
								AccountNumber
								,VendorId
								,PostingDate
				END
			END
		END

		SELECT	DISTINCT TMP.EscrowTransactionId
				,TMP.Source
				,TMP.VoucherNumber
				,TMP.ItemNumber
				,TMP.CompanyId
				,TMP.Fk_EscrowModuleId
				,TMP.AccountNumber
				,TMP.AccountType
				,TMP.VendorId
				,TMP.DriverId
				,TMP.Division
				,TMP.Amount
				,TMP.ClaimNumber
				,TMP.DriverClass
				,TMP.AccidentType
				,TMP.Status
				,TMP.DMSubmitted
				,TMP.DeductionPlan
				,TMP.Comments
				,TMP.ProNumber
				,TMP.TransactionDate
				,TMP.PostingDate
				,TMP.EnteredBy
				,TMP.EnteredOn
				,TMP.ChangedBy
				,TMP.ChangedOn
				,TMP.Void
				,TMP.InvoiceNumber
				,TMP.OtherStatus
				,TMP.DeletedBy
				,TMP.DeletedOn
				,TMP.BatchId
				,TMP.SOPDocumentNumber
				,TMP.RecordType
				,TMP.TrailerNumber
				,TMP.ChassisNumber
				,TMP.TransDescription
				,TMP.CompanyName
				,TMP.VendName
				,TMP.Balance
				,TMP.ActDescr
				,TMP.ProNumberMain
				,TMP.DocNumber
				,TMP.PostDate
				,TMP.UserId
				,TMP.Module
				,EndBalance = (TMP.Balance + ISNULL((SELECT SUM(DAT.Amount) FROM #tmpReportData DAT WHERE DAT.AccountNumber = TMP.AccountNumber AND CASE WHEN @EscrowModule <> 6 THEN DAT.VendorId ELSE DAT.ClaimNumber END = CASE WHEN @EscrowModule <> 6 THEN TMP.VendorId ELSE TMP.ClaimNumber END),0))
				,TMP.VendorNumber
				,VEM.HireDate
				,VEM.TerminationDate
				,CASE WHEN VEM.SubType = 1 THEN 'CO' ELSE 'MYT' END AS DriverType
				,ROW_NUMBER() OVER(PARTITION BY CASE WHEN @EscrowModule <> 6 THEN TMP.VendorId ELSE TMP.ClaimNumber END ORDER BY CASE WHEN @EscrowModule <> 6 THEN TMP.VendorId ELSE TMP.ClaimNumber END, TMP.PostingDate, TMP.EnteredOn) AS RowNumber
		INTO	#tmpFinalReportData
		FROM	#tmpReportData TMP
				LEFT JOIN VendorMaster VEM ON TMP.CompanyId = VEM.Company AND TMP.VendorId = VEM.VendorId
		
		IF @EscrowModule = 6
		BEGIN
			SELECT	DATA.*
					,AccountStartBalance = (SELECT SUM(TMP.Balance) FROM #tmpFinalReportData TMP WHERE TMP.RowNumber = 1 AND TMP.EndBalance <> 0)
					,AccountEndingBalance = (SELECT SUM(TMP.EndBalance) FROM #tmpFinalReportData TMP WHERE TMP.RowNumber = 1 AND TMP.EndBalance <> 0)
					,ReportEndingBalance = (SELECT SUM(TMP.RowNumber) FROM #tmpFinalReportData TMP WHERE TMP.RowNumber = 1 AND TMP.EndBalance <> 0)
			FROM	#tmpFinalReportData DATA
			WHERE	@HideZeros = 0
					OR (@HideZeros = 1 AND DATA.EndBalance <> 0)
			ORDER BY
					DATA.AccountNumber,
					DATA.ClaimNumber,
					DATA.RowNumber
		END
		ELSE
		BEGIN
			SELECT	DATA.*
					,AccountStartBalance = (SELECT SUM(CASE WHEN TMP.RowNumber = 1 THEN TMP.Balance ELSE 0 END) FROM #tmpFinalReportData TMP WHERE TMP.AccountNumber = DATA.AccountNumber)
					,AccountEndingBalance = (SELECT SUM(CASE WHEN TMP.RowNumber = 1 THEN TMP.EndBalance ELSE 0 END) FROM #tmpFinalReportData TMP WHERE TMP.AccountNumber = DATA.AccountNumber)
					,ReportEndingBalance = (SELECT SUM(CASE WHEN TMP.RowNumber = 1 THEN TMP.EndBalance ELSE 0 END) FROM #tmpFinalReportData TMP)
			FROM	#tmpFinalReportData DATA
			ORDER BY
					DATA.AccountNumber,
					DATA.VendorId,
					DATA.RowNumber
		END

		DROP TABLE #tmpReportData
		DROP TABLE #tmpFinalReportData
	END
END