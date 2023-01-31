/****** Object:  View [dbo].[GTM20002V]    Script Date: 1/12/2016 9:50:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER  VIEW [dbo].[GTM20002V]  AS select GrantMstr.aaTrxDim,  GrantMstr.aaTrxDimCode,  BudgetMstr.aaBudgetID,  BudgetMstr.aaBudget,   BudgetMstr.YEAR1,   BudgetBalance.aaFiscalPeriod,   GrantMstr.STRTDATE,   GrantMstr.ENDDATE,   BudgetBalance.Balance,  BudgetBalance.PERIODDT, BudgetBalance.DEX_ROW_ID from AAG00903 as BudgetMstr   inner join AAG00902 as BudgetTree   on BudgetMstr.aaBudgetTreeID = BudgetTree.aaBudgetTreeID   inner join AAG00904 as BudgetBalance   on BudgetMstr.aaBudgetID = BudgetBalance.aaBudgetID   and BudgetTree.aaCodeSequence = BudgetBalance.aaCodeSequence  inner join AAG00401 as DimCode   on BudgetTree.aaTrxDimCodeID = DimCode.aaTrxDimCodeID  inner join AAG00400 as TrxDim   on DimCode.aaTrxDimID = TrxDim.aaTrxDimID  inner join GTM01100 as GrantMstr   on DimCode.aaTrxDimCode = GrantMstr.aaTrxDimCode  and TrxDim.aaTrxDim = GrantMstr.aaTrxDim where Balance <> 0   
GO