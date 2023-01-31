ALTER PROCEDURE USP_CreateMyTruckRecords
		@ParDate	Datetime
AS
DECLARE	@EndWeek	Datetime,
		@WeekIni	DateTime,
		@ThisWeek	DateTime

IF DATEPART(weekday, @ParDate) = 5
BEGIN
	SET	@ThisWeek	= @ParDate
END
ELSE
BEGIN
	IF (DATEPART(weekday, @ParDate) = 1 AND @ParDate < GETDATE()) OR DATEPART(weekday, @ParDate) < 5
	BEGIN
		SET	@ThisWeek	= dbo.DayFwdBack(@ThisWeek, 'N', 'Thursday')
	END
	ELSE
	BEGIN
		SET	@ThisWeek	= dbo.DayFwdBack(@ThisWeek, 'P', 'Thursday')
	END
END

SET		@EndWeek	= dbo.DayFwdBack(@ThisWeek, 'P', 'Saturday')
SET		@WeekIni	= dbo.DayFwdBack(@ThisWeek, 'P', 'Friday')

DELETE ILS_Datawarehouse.dbo.MyTruck WHERE PayDate = @ThisWeek

INSERT INTO ILS_Datawarehouse.dbo.MyTruck (CompanyId, VendorId, PayDate, Description, Balance)
SELECT	ET.CompanyId
		,ET.VendorId
		,@ThisWeek AS PayDate
		,CASE WHEN EA.AccountAlias IS Null OR EA.AccountAlias = '' THEN dbo.GetAccountName(ET.CompanyId, EA.AccountIndex) ELSE EA.AccountAlias END AS Description
		,SUM(ET.Amount) AS Balance
FROM	EscrowTransactions ET
		INNER JOIN EscrowAccounts EA ON ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId AND ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId
WHERE	ET.VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
		AND ET.Fk_EscrowModuleId <> 10
		AND ET.PostingDate <= @ThisWeek
GROUP BY
		ET.CompanyId
		,ET.VendorId
		,EA.AccountAlias
		,CASE WHEN EA.AccountAlias IS Null OR EA.AccountAlias = '' THEN dbo.GetAccountName(ET.CompanyId, EA.AccountIndex) ELSE EA.AccountAlias END
UNION
SELECT	*
FROM	(
		SELECT	'AIS' AS Company
				,VendorId
				,DocDate
				,'Pay' AS Description
				,DocAmnt 
		FROM	AIS.dbo.PM30200 
		WHERE	BchSourc = 'XPM_Cchecks' 
				AND VoidPDate < '1/1/1901'
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND DocDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'GIS'
				,VendorId
				,DocDate
				,'Pay' AS Description
				,DocAmnt 
		FROM	GIS.dbo.PM30200 
		WHERE	BchSourc = 'XPM_Cchecks' 
				AND VoidPDate < '1/1/1901'
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND DocDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'IMC'
				,VendorId
				,DocDate
				,'Pay' AS Description
				,DocAmnt 
		FROM	IMC.dbo.PM30200 
		WHERE	BchSourc = 'XPM_Cchecks' 
				AND VoidPDate < '1/1/1901'
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND DocDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'NDS'
				,VendorId
				,DocDate
				,'Pay' AS Description
				,DocAmnt 
		FROM	NDS.dbo.PM30200 
		WHERE	BchSourc = 'XPM_Cchecks' 
				AND VoidPDate < '1/1/1901'
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND DocDate BETWEEN @WeekIni AND @ThisWeek) P1
UNION
SELECT	HE.Company
		,DE.VendorId
		,@ThisWeek
		,'Drayage' AS Description
		,Drayage + DriverFuelRebate AS Balance
FROM	Integration_APDetails DE
		INNER JOIN Integration_APHeader HE ON DE.BatchId = HE.BatchId
WHERE	HE.WeekEndDate = @EndWeek
		AND DE.VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
UNION
SELECT	HE.Company
		,DE.VendorId
		,@ThisWeek
		,'Miles' AS Description
		,Miles AS Balance
FROM	Integration_APDetails DE
		INNER JOIN Integration_APHeader HE ON DE.BatchId = HE.BatchId
WHERE	HE.WeekEndDate = @EndWeek
		AND DE.VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
UNION
SELECT	HE.Company
		,DE.VendorId
		,@ThisWeek
		,'Cash on Card' AS Description
		,Cash AS Balance
FROM	ILSINT01.Integrations.dbo.FPT_ReceivedHeader HE
		INNER JOIN ILSINT01.Integrations.dbo.FPT_ReceivedDetails DE ON HE.BatchId = DE.BatchId
WHERE	HE.WeekEndDate = @EndWeek
		AND DE.Cash <> 0
		AND DE.VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
UNION
SELECT	Company
		,VendorId
		,@ThisWeek
		,'HUT' AS Description
		,SUM(Amount) AS Balance
FROM	(
		SELECT	'AIS' AS Company
				,VendorId
				,CrdtAmnt + DebitAmt AS Amount
		FROM	AIS.dbo.PM30600 
		WHERE	DstIndx IN (SELECT ActIndx FROM AIS.dbo.GL00105 WHERE ActNumSt = '0-01-2785')
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND PstgDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'AIS' AS Company
				,VendorId
				,CrdtAmnt + DebitAmt AS Amount
		FROM	AIS.dbo.PM10100 
		WHERE	DstIndx IN (SELECT ActIndx FROM AIS.dbo.GL00105 WHERE ActNumSt = '0-01-2785')
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND PstgDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'GIS' AS Company
				,VendorId
				,CrdtAmnt + DebitAmt AS Amount
		FROM	GIS.dbo.PM30600 
		WHERE	DstIndx IN (SELECT ActIndx FROM GIS.dbo.GL00105 WHERE ActNumSt = '0-01-2785')
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND PstgDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'GIS' AS Company
				,VendorId
				,CrdtAmnt + DebitAmt AS Amount
		FROM	GIS.dbo.PM10100 
		WHERE	DstIndx IN (SELECT ActIndx FROM GIS.dbo.GL00105 WHERE ActNumSt = '0-01-2785')
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND PstgDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'IMC' AS Company
				,VendorId
				,CrdtAmnt + DebitAmt AS Amount
		FROM	IMC.dbo.PM30600 
		WHERE	DstIndx IN (SELECT ActIndx FROM IMC.dbo.GL00105 WHERE ActNumSt = '0-01-2785')
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND PstgDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'IMC' AS Company
				,VendorId
				,CrdtAmnt + DebitAmt AS Amount
		FROM	IMC.dbo.PM10100 
		WHERE	DstIndx IN (SELECT ActIndx FROM IMC.dbo.GL00105 WHERE ActNumSt = '0-01-2785')
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND PstgDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'NDS' AS Company
				,VendorId
				,CrdtAmnt + DebitAmt AS Amount
		FROM	NDS.dbo.PM30600 
		WHERE	DstIndx IN (SELECT ActIndx FROM NDS.dbo.GL00105 WHERE ActNumSt = '00-01-2785')
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND PstgDate BETWEEN @WeekIni AND @ThisWeek
		UNION
		SELECT	'NDS' AS Company
				,VendorId
				,CrdtAmnt + DebitAmt AS Amount
		FROM	NDS.dbo.PM10100 
		WHERE	DstIndx IN (SELECT ActIndx FROM NDS.dbo.GL00105 WHERE ActNumSt = '00-01-2785')
				AND VendorId IN (SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null)
				AND PstgDate BETWEEN @WeekIni AND @ThisWeek) HUT
GROUP BY Company, VendorId
UNION
SELECT	Company
		,VendorId
		,@ThisWeek
		,'EFS Pay Advance Ded'
		,DeductionAmount 
FROM	View_OOS_Transactions 
WHERE	DeductionDate = @ThisWeek
		AND DeductionCode = 'ESCA'
UNION
SELECT	Company
		,VendorId
		,@ThisWeek
		,'Funding Maint. Escrow'
		,DeductionAmount 
FROM	View_OOS_Transactions 
WHERE	DeductionDate = @ThisWeek
		AND DeductionCode = 'MANT'
UNION
SELECT	VM.Company
		,VM.VendorId
		,@ThisWeek
		,'Total Lease Payment'
		,DebitAmt
FROM	RCCL.dbo.RM10101 RM
		INNER JOIN VendorMaster VM ON RM.CustNmbr = VM.VendorId AND VM.SubType = 2 AND VM.TerminationDate IS Null
WHERE	DstIndx = 1
		AND PostEddt BETWEEN @WeekIni - 7 AND @ThisWeek - 6
ORDER BY 1,2,3

/*
-- LEASE BALANCE --
SELECT CustNmbr, SUM(CurTrxAm) AS Balance FROM RCCL.dbo.RM20101 GROUP BY CustNmbr ORDER BY CustNmbr

SELECT VendorId FROM VendorMaster WHERE SubType = 2 AND TerminationDate IS Null ORDER BY VendorId

TRUNCATE TABLE ILS_Datawarehouse.dbo.MyTruck
SELECT * FROM AIS.dbo.PM30200 WHERE VendorId = 'A0086' AND BchSourc = 'XPM_Cchecks' AND VoidPDate < '1/1/1901' ORDER BY DocDate
SELECT * FROM ILS_Datawarehouse.dbo.MyTruck WHERE VendorId = 'A0086'

SELECT Company, VendorId, DocDate, ChekTotl FROM PM10300 WHERE VendorId = 'A0086' ORDER BY DocDate
SELECT * FROM PM10300 WHERE DocDate = '2009-05-07'
SELECT DISTINCT DocDate FROM PM10300  ORDER BY DocDate
*/