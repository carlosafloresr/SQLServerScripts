USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AgentsSettlements_WeeklyBatch]    Script Date: 4/11/2018 11:44:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AgentsSettlements_WeeklyBatch 'NDS20180317'
EXECUTE USP_AgentsSettlements_WeeklyBatch 'NDS20180317', 1
EXECUTE USP_AgentsSettlements_WeeklyBatch 'NONE'
*/
ALTER PROCEDURE [dbo].[USP_AgentsSettlements_WeeklyBatch]
		@BatchId	Varchar(20),
		@NonStd		Bit = 0
AS
DECLARE	@tblData Table (
		TransactionId			Int,
		Vendor					Varchar(100),
		ProNumber				Varchar(30),
		DeductionDescription	Varchar(75),
		StartBalance			Numeric(10,2),
		DeductionAmount			Numeric(10,2),
		EndBalance				Numeric(10,2),
		Hold					Bit,
		Commission				Numeric(10,2),
		RecordType				Varchar(10),
		Agent					Varchar(3),
		ChassisUsage			Numeric(10,2),
		EmptyColumn				Varchar(10))

IF @NonStd = 1
BEGIN
	INSERT INTO @tblData
	SELECT	*
	FROM	(
			SELECT	AST.AgentsSettlementsTransactionsId,
					RTRIM(ASD.VendorId) + ' - ' + dbo.GetDriverName(AST.Company, ASD.VendorId, 'O') + ' [Agent:' + AST.Agent + ']' AS VendorName,
					AST.ProNumber,
					AST.Description,
					AST.BalanceIni AS StartBalance,
					AST.Amount,
					AST.BalanceEnd AS EndBalance,
					AST.Hold,
					0 AS Commission,
					'NON' AS RecordType,
					AST.Agent,
					ACO.ChassisUsage,
					'' AS EmptyColumn
			FROM	AgentsSettlementsTransactions AST
					INNER JOIN AgentsSettlementsBatches ASB ON AST.Company = ASB.Company AND AST.WeekendDate = ASB.WeekendDate
					INNER JOIN AgentsSettlementsCommisions ACO ON AST.Agent = ACO.Agent AND ASB.BatchId = ACO.BatchId
					LEFT JOIN (SELECT DISTINCT Agent, VendorId FROM Agents WHERE VendorId IS NOT Null) ASD ON AST.Agent = ASD.Agent
			WHERE	ASB.BatchId = @BatchId
					AND AST.BalanceEnd > 0
			) DATA
END
ELSE
BEGIN
	INSERT INTO @tblData
	SELECT	*
	FROM	(
			SELECT	TransactionId,
					Vendor,
					'' AS ProNumber,
					DeductionDescription,
					0 AS StartBalance,
					DeductionAmount,
					0 AS EndBalance,
					Hold,
					Commission,
					'STD' AS RecordType,
					Agent,
					ChassisUsage,
					' ' AS EmptyColumn
			FROM	View_AgentsSettlements_WeeklyBatch 
			WHERE	BatchId = @BatchId
			) DATA
END

SELECT	*
FROM	@tblData
ORDER BY Vendor, DeductionDescription

