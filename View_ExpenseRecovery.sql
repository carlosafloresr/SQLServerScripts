USE [GPCustom]
GO

/****** Object:  View [dbo].[View_ExpenseRecovery]    Script Date: 09/22/2010 10:32:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_ExpenseRecovery]
AS
SELECT	ERE.ExpenseRecoveryId
		,ERE.Company
		,CASE WHEN LEFT(ISNULL(ERE.RepairType, ERA.RepairType), 1) = 'M' THEN 'M&R' WHEN LEFT(ISNULL(ERE.RepairType, ERA.RepairType), 1) = 'T' THEN 'Tire Rpl' WHEN LEFT(ISNULL(ERE.RepairType, ERA.RepairType), 1) = 'F' THEN 'Flat' ELSE 'Other' END AS RepairType
		,ERE.Vendor
		,ERE.Reference AS Description
		,ERE.Expense
		,ERE.Recovery
		,ERE.FailureReason
		,CASE WHEN ISNULL(ERE.DriverType, ERA.DriverType) = 1 THEN 'Company' WHEN ISNULL(ERE.DriverType, ERA.DriverType) = 2 THEN 'OO' ELSE Null END AS DriverType
		,ERE.DriverId
		,CASE WHEN ERE.ProNumber = '' OR ERE.ProNumber IS Null THEN 'No Defined' ELSE ProNumber END AS ProNumber
		,ERE.Chassis
		,ERE.Trailer
		,ERE.EffDate
		,ERE.InvDate
		,CASE WHEN LEFT(ISNULL(ERA.Recovery, ERE.Recoverable), 1) = 'N' THEN 'NO' WHEN LEFT(ISNULL(ERA.Recovery, ERE.Recoverable), 1) = 'Y' THEN 'YES' ELSE 'OPPTIONAL' END AS Recoverable
		,SUBSTRING(ERE.GLAccount, dbo.AT('-', ERE.GLAccount, 1) + 1, 2) AS Division
		,ERE.DocNumber
		,ERE.RecoveryAction
		,ERE.VoucherNo
		,ERE.GLAccount
		,ERE.Status
		,ERE.Notes
		,'' AS DriverName
FROM	ExpenseRecovery ERE
		LEFT JOIN ExpenseRecoveryAccounts ERA ON RIGHT(RTRIM(ERE.GLAccount), 4) = ERA.Account

-- SELECT * FROM ExpenseRecoveryAccounts
-- SELECT * FROM View_ExpenseRecovery ORDER BY EffDate DESC
-- UPDATE ExpenseRecovery SET Company = 'IMC'
-- UPDATE ExpenseRecovery SET Status = 'Open'

GO