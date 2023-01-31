-- EXECUTE DURING THE STEP: Load Post Conversion Objects. After the creation of objects AAGXXXXX

USE RCMR
GO

SET DATEFORMAT YMD 
GO 
 
/*Begin_GTM20001V*/
IF EXISTS(SELECT id FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[GTM20001V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20001V]
	GO

CREATE VIEW GTM20001V 
AS 
SELECT	HDR.aaSubLedgerHdrID, 
		LINE.aaSubLedgerDistID, 
		LINE.aaSubLedgerAssignID, 
		HDR.SERIES,
		HDR.DOCTYPE,
		HDR.DOCNUMBR,
		HDR.Master_ID,
		LINE.aaTrxDimID,
		LINE.aaTrxCodeID,
		LINE.aaTrxDimCode,
		LINE.INTERID,
		LINE.ACTINDX,
		LINE.ACCTTYPE,
		LINE.DISTTYPE,
		LINE.DEBITAMT,
		LINE.CRDTAMNT,
		LINE.CURNCYID,
		LINE.SEQNUMBR,
		LINE.GLPOSTDT,
		LINE.POSTED,
		LINE.HISTORY,
		LINE.DEX_ROW_ID
FROM	AAG20000 AS HDR
		INNER JOIN (	SELECT	T1.*,
								T3.aaTrxDimCode,
								T2.INTERID,
								T2.ACTINDX,
								T2.DISTTYPE,
								T2.ACCTTYPE,
								T2.DEBITAMT,
								T2.CRDTAMNT,
								T2.ORDBTAMT,
								T2.ORCRDAMT,
								T2.CURNCYID,
								T2.CURRNIDX,
								T2.RATETPID,
								T2.EXGTBLID,
								T2.XCHGRATE,
								T2.EXCHDATE,
								T2.SEQNUMBR,
								T2.GLPOSTDT,
								T2.POSTED,
								T2.HISTORY
						FROM	AAG20003 AS T1
								LEFT JOIN AAG20001 AS T2 ON T1.aaSubLedgerHdrID = T2.aaSubLedgerHdrID AND T1.aaSubLedgerDistID = T2.aaSubLedgerDistID
								LEFT JOIN AAG00401 AS T3 ON T1.aaTrxDimID = T3.aaTrxDimID AND T1.aaTrxCodeID = T3.aaTrxDimCodeID
						WHERE	T1.aaTrxCodeID <> 0
					) AS LINE ON HDR.aaSubLedgerHdrID = LINE.aaSubLedgerHdrID
GO
GRANT SELECT ON [dbo].[GTM20001V] TO [DYNGRP]
GO

/*End_GTM20001V*/
/*Begin_GTM20002V*/
IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20002V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20002V]
	GO

CREATE VIEW GTM20002V 
AS
SELECT	GrantMstr.aaTrxDim,
		GrantMstr.aaTrxDimCode,
		BudgetMstr.aaBudgetID,
		BudgetMstr.aaBudget, 
		BudgetMstr.YEAR1, 
		BudgetBalance.aaFiscalPeriod, 
		GrantMstr.STRTDATE, 
		GrantMstr.ENDDATE, 
		BudgetBalance.Balance,
		BudgetBalance.PERIODDT,
		BudgetBalance.DEX_ROW_ID
FROM	AAG00903 AS BudgetMstr 
		INNER JOIN AAG00902 AS BudgetTree ON BudgetMstr.aaBudgetTreeID = BudgetTree.aaBudgetTreeID 
		INNER JOIN AAG00904 AS BudgetBalance ON BudgetMstr.aaBudgetID = BudgetBalance.aaBudgetID AND BudgetTree.aaCodeSequence = BudgetBalance.aaCodeSequence
		INNER JOIN AAG00401 AS DimCode ON BudgetTree.aaTrxDimCodeID = DimCode.aaTrxDimCodeID
		INNER JOIN AAG00400 AS TrxDim ON DimCode.aaTrxDimID = TrxDim.aaTrxDimID
		INNER JOIN GTM01100 AS GrantMstr ON DimCode.aaTrxDimCode = GrantMstr.aaTrxDimCode AND TrxDim.aaTrxDim = GrantMstr.aaTrxDim
WHERE	Balance <> 0
GO

GRANT SELECT ON [dbo].[GTM20002V] TO [DYNGRP]
GO

/*End_GTM20002V*/
/*Begin_GTM20003V*/
IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20003V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20003V]
	GO

CREATE VIEW GTM20003V 
AS 
SELECT	GrantMstr.aaTrxDim,
		GrantMstr.aaTrxDimCode,
		BudgetMstr.aaBudgetID,
		BudgetMstr.aaBudget, 
		BudgetMstr.YEAR1, 
		BudgetActBalance.aaFiscalPeriod,
		BudgetActBalance.ACTINDX, 
		GrantMstr.STRTDATE, 
		GrantMstr.ENDDATE, 
		BudgetActBalance.Balance,
		BudgetActBalance.PERIODDT,
		BudgetActBalance.DEX_ROW_ID
FROM	AAG00903 AS BudgetMstr 
		INNER JOIN AAG00902 AS BudgetTree ON BudgetMstr.aaBudgetTreeID = BudgetTree.aaBudgetTreeID 
		INNER JOIN AAG00905 AS BudgetActBalance ON BudgetMstr.aaBudgetID = BudgetActBalance.aaBudgetID AND BudgetTree.aaCodeSequence = BudgetActBalance.aaCodeSequence
		INNER JOIN AAG00401 AS DimCode ON BudgetTree.aaTrxDimCodeID = DimCode.aaTrxDimCodeID
		INNER JOIN AAG00400 AS TrxDim ON DimCode.aaTrxDimID = TrxDim.aaTrxDimID
		INNER JOIN GTM01100 AS GrantMstr ON DimCode.aaTrxDimCode = GrantMstr.aaTrxDimCode AND TrxDim.aaTrxDim = GrantMstr.aaTrxDim
WHERE	Balance <> 0
GO

GRANT SELECT ON [dbo].[GTM20003V] TO [DYNGRP]
GO

/*End_GTM20003V*/

-- DROP ALL ADDITIONAL AA VIEWS
IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20004V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20004V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20005V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20005V]
	GO
 
IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20006V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20006V]
	GO
 
IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20007V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20007V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20008V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20008V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20009V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20009V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20010V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20010V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20011V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20011V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20012V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20012V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20013V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20013V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20014V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20014V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20015V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20015V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20016V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20016V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20017V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20017V]
	GO

IF EXISTS(SELECT id FROM sysobjects WHERE id = object_id(N'[dbo].[GTM20018V]') AND OBJECTPROPERTY(id, N'IsView') = 1)
	DROP VIEW [dbo].[GTM20018V]
	GO