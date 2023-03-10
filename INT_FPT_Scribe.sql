/*
=============================================================
Author:		Jeff Crumbley
Create date: 2011-01-27
Description:	Format the data for Scribe to load into GP
EXECUTE INT_FPT_Scribe @BATCHID = '1_FPT_20110122'
SELECT * FROM View_Integration_FPT_Summary WHERE BatchId = '1_FPT_20110122' AND (TotalFuel + Cash) <> 0
=============================================================
*/
ALTER PROCEDURE [dbo].[INT_FPT_Scribe]
	@BATCHID varchar(15)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @COMPANY varchar(5)
			,@INTEGRATION varchar(3)
			,@FPTFULECRDACCOUNT varchar(25)
			,@FPTFULEDEBACCOUNT varchar(25)
			,@FPTCASHCRDACCOUNT varchar(25)
			,@FPTCASHFEEACCT varchar(25)

	SET @COMPANY = (Select Company From dbo.ReceivedIntegrations where BatchID = @BATCHID)
	SET	@INTEGRATION = 'FPT'

	SELECT [ParameterId]
		,CASE WHEN [Company] = 'ALL' THEN @COMPANY ELSE [Company] END AS [Company]
		,[ParameterCode]
		,[Description]
		,[VarType]
		,[VarN]
		,[VarI]
		,[VarD]
		,[VarB]
		,[VarM]
		,[VarC]
	INTO [#TempParms]
	From ILSGP01.GPCustom.dbo.Parameters
	WHERE COMPANY IN ('ALL', @COMPANY) 
			AND LEFT(ParameterCode, 3) = @INTEGRATION

	SET @FPTFULECRDACCOUNT	= (Select VarC FROM #TempParms WHERE ParameterCode = 'FPTFULECRDACCOUNT')
	SET @FPTFULEDEBACCOUNT	= (Select VarC FROM #TempParms WHERE ParameterCode = 'FPTDEBITACCOUNT')
	SET @FPTCASHCRDACCOUNT	= (Select VarC FROM #TempParms WHERE ParameterCode = 'FPTCASHCRDACCOUNT')
	SET @FPTCASHFEEACCT		=  (Select VarC FROM #TempParms WHERE ParameterCode = 'FPTCASHFEEACCT')

	SELECT C.PubAgent
		 , C.PubDivision
		 , C.BatchID
		 , C.WeekEndDate
		 , C.VendorID
		 , C.Account
		 , C.TotalAmount
		 , C.Credit
		 , C.Debit
		 , C.TransId + dbo.PADL(E.RowNum, 3, '0') AS [TransId]
		 , C.[Description]
		 , C.Voucher + dbo.PADL(E.RowNum, 3, '0') AS [Voucher]
		 , C.TransType
		 , C.DistType
		 , C.RowNum --ROW_NUMBER() OVER (PARTITION BY C.VendorId ORDER BY C.BatchId) AS [RowNum]
		 , C.Counter
	FROM (
		-- FUEL
		SELECT	CASE WHEN A.Agent IS NULL THEN '' 
					 WHEN A.Agent = '19' THEN '22' 
					 WHEN A.Agent = '22' THEN '22' ELSE ''
				END AS [PubAgent]
				, CASE WHEN A.Agent IS NULL THEN '' 
  					 WHEN A.Agent = '10' THEN '16' 
					 WHEN A.Agent = '11' THEN '05' 
					 WHEN A.Agent = '12' THEN '04' 
					 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
					 WHEN A.Agent = '15' THEN '09' 
					 WHEN A.Agent = '16' THEN '06' 
					 WHEN A.Agent = '17' THEN '12' 
					 WHEN A.Agent = '21' THEN '05' 
					 WHEN A.Agent = '18' THEN '27' 
					 WHEN A.Agent = '20' THEN '03' 
					 WHEN A.Agent = '19' THEN '11' 
					 WHEN A.Agent = '22' THEN '11' ELSE ''
				END AS [PubDivision]
				, 'FPT_' + CAST(YEAR(A.WeekEndDate) AS Varchar(4)) + dbo.PADL(CAST(MONTH(A.WeekEndDate) AS Varchar(2)), 2, '0') + dbo.PADL(CAST(DAY(A.WeekEndDate) AS Varchar(2)), 2, '0') AS [BatchId]
				, A.VendorID AS [VendorID]
				, @FPTFULECRDACCOUNT AS [Account]
				, CASE WHEN A.TotalFuel > 0 THEN 5 ELSE 1 END AS [TransType]
				, 6 AS [DistType]
				, CASE WHEN A.TotalFuel > 0 THEN A.TotalFuel ELSE 0 END AS [Credit]
				, CASE WHEN A.TotalFuel < 0 THEN ABS(A.TotalFuel) ELSE 0 END AS [Debit]
				, 'FPT' 
				   + CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END)
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)), 3, 2) + CAST(MONTH(A.WeekEndDate) AS Varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					+ 'F'
					AS [TransId]
				, 'Fuel Card ' + CONVERT(varchar(10), A.WeekEndDate, 101) + ' [' + (CASE WHEN A.TotalFuel <> 0 THEN 'FUEL' ELSE 'CASH' END) + ']' AS [Description]
				, 'FPT' + CASE WHEN A.Agent IS NULL OR A.Agent = '' THEN '_' ELSE 
				   + (CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END)
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END) END
					+ 'F'
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)),3,2) + CAST(MONTH(A.WeekEndDate) AS varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					AS [Voucher]
				, 1 AS RowNum
				, 2 AS Counter
				, A.WeekEndDate
				, A.TotalFuel AS TotalAmount
		FROM	View_Integration_FPT_Summary A
		WHERE	A.BatchId = @BATCHID
				AND A.TotalFuel <> 0
			-- CASH
		UNION
		SELECT
				CASE WHEN A.Agent IS NULL THEN '' 
					 WHEN A.Agent = '19' THEN '22' 
					 WHEN A.Agent = '22' THEN '22' ELSE ''
				END AS [PubAgent]
				, CASE WHEN A.Agent IS NULL THEN '' 
					 WHEN A.Agent = '10' THEN '16' 
					 WHEN A.Agent = '11' THEN '05' 
					 WHEN A.Agent = '12' THEN '04' 
					 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
					 WHEN A.Agent = '15' THEN '09' 
					 WHEN A.Agent = '16' THEN '06' 
					 WHEN A.Agent = '17' THEN '12' 
					 WHEN A.Agent = '21' THEN '05' 
					 WHEN A.Agent = '18' THEN '27' 
					 WHEN A.Agent = '20' THEN '03' 
					 WHEN A.Agent = '19' THEN '11' 
					 WHEN A.Agent = '22' THEN '11' ELSE ''
				END AS [PubDivision]
				, 'FPT_' + CAST(YEAR(A.WeekEndDate) AS Varchar(4)) + dbo.PADL(CAST(MONTH(A.WeekEndDate) AS Varchar(2)), 2, '0') + dbo.PADL(CAST(DAY(A.WeekEndDate) AS Varchar(2)), 2, '0') AS [BatchId]
				, A.VendorID AS [VendorID]
				, @FPTCASHCRDACCOUNT AS [Account]
				, 5 AS [TransType]
				, 6 AS [DistType]
				, A.Cash AS [Credit]
				, 0 AS [Debit]
				, 'FPT' 
				   + CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END)
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)),3,2) + CAST(MONTH(A.WeekEndDate) AS varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					+ 'C'
					AS [TransId]
				, 'Fuel Card ' + CONVERT(varchar(10), A.WeekEndDate, 101) + ' [CASH]' AS [Description]
				, 'FPT' + CASE WHEN A.Agent IS NULL OR A.Agent = '' THEN '_' ELSE 
				   + (CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END)
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END)END
					+ 'C'
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)),3,2) + CAST(MONTH(A.WeekEndDate) AS varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					AS [Voucher]
				, 1 AS RowNum
				, 3 AS Counter
				, A.WeekEndDate
				, A.Cash + A.CashFee AS TotalAmount
		FROM	View_Integration_FPT_Summary A
		WHERE	A.BatchId = @BATCHID
				AND A.Cash <> 0
		-- CASH FEE
		UNION
		SELECT	CASE WHEN A.Agent IS NULL THEN '' 
					 WHEN A.Agent = '19' THEN '22' 
					 WHEN A.Agent = '22' THEN '22' ELSE ''
				END AS [PubAgent]
				, CASE WHEN A.Agent IS NULL THEN '' 
					 WHEN A.Agent = '10' THEN '16' 
					 WHEN A.Agent = '11' THEN '05' 
					 WHEN A.Agent = '12' THEN '04' 
					 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
					 WHEN A.Agent = '15' THEN '09' 
					 WHEN A.Agent = '16' THEN '06' 
					 WHEN A.Agent = '17' THEN '12' 
					 WHEN A.Agent = '21' THEN '05' 
					 WHEN A.Agent = '18' THEN '27' 
					 WHEN A.Agent = '20' THEN '03' 
					 WHEN A.Agent = '19' THEN '11' 
					 WHEN A.Agent = '22' THEN '11' ELSE ''
				END AS [PubDivision]
				, 'FPT_' + CAST(YEAR(A.WeekEndDate) AS Varchar(4)) + dbo.PADL(CAST(MONTH(A.WeekEndDate) AS Varchar(2)), 2, '0') + dbo.PADL(CAST(DAY(A.WeekEndDate) AS Varchar(2)), 2, '0') AS [BatchId]
				, A.VendorID AS [VendorID]
				, @FPTCASHFEEACCT AS [Account]
				, 5 AS [TransType]
				, 6 AS [DistType]
				, A.CashFee AS [Credit]
				, 0 AS [Debit]
				, 'FPT' 
				   + CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END)
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)),3,2) + CAST(MONTH(A.WeekEndDate) AS varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					+ 'C'
					AS [TransId]
				, 'Fuel Card ' + CONVERT(varchar(10), A.WeekEndDate, 101) + ' [CASH]' AS [Description]
				, 'FPT' + CASE WHEN A.Agent IS NULL OR A.Agent = '' THEN '_' ELSE 
				   + (CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END)
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END)END
					+ 'C'
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)),3,2) + CAST(MONTH(A.WeekEndDate) AS varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					AS [Voucher]
				, 2 AS RowNum
				, 3 AS Counter
				, A.WeekEndDate
				, A.Cash + A.CashFee AS TotalAmount
		FROM	View_Integration_FPT_Summary A
		WHERE	A.BatchId = @BATCHID
				AND A.Cash <> 0
		UNION
		-- FUEL DEBIT
		SELECT	CASE WHEN A.Agent IS NULL THEN '' 
					WHEN A.Agent = '19' THEN '22' 
					WHEN A.Agent = '22' THEN '22' ELSE ''
				END AS [PubAgent]
				, CASE WHEN A.Agent IS NULL THEN '' 
					 WHEN A.Agent = '10' THEN '16' 
					 WHEN A.Agent = '11' THEN '05' 
					 WHEN A.Agent = '12' THEN '04' 
					 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
					 WHEN A.Agent = '15' THEN '09' 
					 WHEN A.Agent = '16' THEN '06' 
					 WHEN A.Agent = '17' THEN '12' 
					 WHEN A.Agent = '21' THEN '05' 
					 WHEN A.Agent = '18' THEN '27' 
					 WHEN A.Agent = '20' THEN '03' 
					 WHEN A.Agent = '19' THEN '11' 
					 WHEN A.Agent = '22' THEN '11' ELSE ''
				END AS [PubDivision]
				, 'FPT_' + CAST(YEAR(A.WeekEndDate) AS Varchar(4)) + dbo.PADL(CAST(MONTH(A.WeekEndDate) AS Varchar(2)), 2, '0') + dbo.PADL(CAST(DAY(A.WeekEndDate) AS Varchar(2)), 2, '0') AS [BatchId]
				, A.VendorID AS [VendorID]
				, @FPTFULEDEBACCOUNT AS [Account]
				, CASE WHEN A.TotalFuel > 0 THEN 5 ELSE 1 END AS [TransType]
				, 2 AS [DistType]
				, CASE WHEN A.TotalFuel < 0 THEN ABS(A.TotalFuel) ELSE 0 END AS [Credit]
				, CASE WHEN A.TotalFuel > 0 THEN A.TotalFuel ELSE 0 END AS [Debit]
				, 'FPT' 
				   + CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END)
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)),3,2) + CAST(MONTH(A.WeekEndDate) AS varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					+ 'F'
					AS [TransId]
				, 'Fuel Card ' + CONVERT(varchar(10), A.WeekEndDate, 101) + ' [' + (CASE WHEN A.TotalFuel <> 0 THEN 'FUEL' ELSE 'CASH' END) + ']' AS [Description]
				, 'FPT' + CASE WHEN A.Agent IS NULL OR A.Agent = '' THEN '_' ELSE 
				   + (CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END)
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END) END
					+ 'F'
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)),3,2) + CAST(MONTH(A.WeekEndDate) AS varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					AS [Voucher]
				, 2 AS RowNum
				, 2 AS Counter
				, A.WeekEndDate
				, A.TotalFuel AS TotalAmount
		FROM	View_Integration_FPT_Summary A
		WHERE	A.BatchId = @BATCHID
				AND A.TotalFuel <> 0
		UNION
		-- CASH AND CASH FEE DEBIT
		SELECT	CASE WHEN A.Agent IS NULL THEN '' 
					WHEN A.Agent = '19' THEN '22' 
					WHEN A.Agent = '22' THEN '22' ELSE ''
				END AS [PubAgent]
				, CASE WHEN A.Agent IS NULL THEN '' 
					 WHEN A.Agent = '10' THEN '16' 
					 WHEN A.Agent = '11' THEN '05' 
					 WHEN A.Agent = '12' THEN '04' 
					 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
					 WHEN A.Agent = '15' THEN '09' 
					 WHEN A.Agent = '16' THEN '06' 
					 WHEN A.Agent = '17' THEN '12' 
					 WHEN A.Agent = '21' THEN '05' 
					 WHEN A.Agent = '18' THEN '27' 
					 WHEN A.Agent = '20' THEN '03' 
					 WHEN A.Agent = '19' THEN '11' 
					 WHEN A.Agent = '22' THEN '11' ELSE ''
				END AS [PubDivision]
				, 'FPT_' + CAST(YEAR(A.WeekEndDate) AS Varchar(4)) + dbo.PADL(CAST(MONTH(A.WeekEndDate) AS Varchar(2)), 2, '0') + dbo.PADL(CAST(DAY(A.WeekEndDate) AS Varchar(2)), 2, '0') AS [BatchId]
				, A.VendorID AS [VendorID]
				, @FPTFULEDEBACCOUNT AS [Account]
				, 5 AS [TransType]
				, 2 AS [DistType]
				, 0 AS [Credit]
				, A.Cash + A.CashFee AS [Debit]
				, 'FPT' 
				   + CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END)
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)),3,2) + CAST(MONTH(A.WeekEndDate) AS varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					+ 'C'
					AS [TransId]
				, 'Fuel Card ' + CONVERT(varchar(10), A.WeekEndDate, 101) + ' [CASH]' AS [Description]
				, 'FPT' + CASE WHEN A.Agent IS NULL OR A.Agent = '' THEN '_' ELSE 
				   + (CASE WHEN A.Agent IS NULL THEN '' WHEN A.Agent = '19' THEN '22' WHEN A.Agent = '22' THEN '22' ELSE '' END)
				   + RTRIM(CASE WHEN @COMPANY = 'NDS' THEN 
							CASE WHEN A.Agent IS NULL THEN '' 
								 WHEN A.Agent = '10' THEN '16' 
								 WHEN A.Agent = '11' THEN '05' 
								 WHEN A.Agent = '12' THEN '04' 
								 WHEN A.Agent = '14' THEN dbo.PADL(A.Division,2,'0')
								 WHEN A.Agent = '15' THEN '09' 
								 WHEN A.Agent = '16' THEN '06' 
								 WHEN A.Agent = '17' THEN '12' 
								 WHEN A.Agent = '21' THEN '05' 
								 WHEN A.Agent = '18' THEN '27' 
								 WHEN A.Agent = '20' THEN '03' 
								 WHEN A.Agent = '19' THEN '11' 
								 WHEN A.Agent = '22' THEN '11' ELSE '' END
						ELSE A.VendorID END)END
					+ 'C'
					+ SUBSTRING(CAST(Year(A.WeekEndDate) AS varchar(4)),3,2) + CAST(MONTH(A.WeekEndDate) AS varchar(2)) + CAST(DAY(A.WeekEndDate) AS varchar(2))
					AS [Voucher]
				, 3 AS RowNum
				, 3 AS Counter
				, A.WeekEndDate
				, A.Cash + A.CashFee AS TotalAmount
		FROM	View_Integration_FPT_Summary A
		WHERE	A.BatchId = @BATCHID
				AND A.Cash <> 0
		) C
		LEFT OUTER JOIN (SELECT F.VENDORID, ROW_NUMBER() OVER (ORDER BY VendorId) AS [RowNum] FROM (SELECT DISTINCT(VendorID) From View_Integration_FPT_Summary WHERE BatchId = @BATCHID) F) E ON (C.VendorID = E.VendorID)
	ORDER BY VendorID, Description, RowNum

	DROP TABLE #TempParms
END