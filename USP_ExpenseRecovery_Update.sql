USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_ExpenseRecovery_Update]    Script Date: 02/18/2011 08:22:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_ExpenseRecovery_Update]
		@Company			Varchar(5),
		@RecordId			Int
AS
DECLARE	@RepairTypeText		Varchar(15),
		@DriverTypeText		Char(10),
		@DriverName			Varchar(50),
		@RecoverableText	Char(10),
		@Division			Char(2),
		@StatusText			Char(6),
		@DriverId			Varchar(12),
		@ProNumber			Varchar(15),
		@Chassis			Varchar(20),
		@Trailer			Varchar(20),
		@Emails				Bit
		
SET		@Emails				= CAST(CASE WHEN (SELECT COUNT(ExpenseRecoveryEmailId) FROM ExpenseRecoveryEmails WHERE Fk_ExpenseRecoveryId = @RecordId) > 0 THEN 1 ELSE 0 END AS Bit)
		
SELECT	@RepairTypeText = CASE WHEN LEFT(ISNULL(ERE.RepairType, ERA.RepairType), 1) = 'M' THEN 'M&R' WHEN LEFT(ISNULL(ERE.RepairType, ERA.RepairType), 1) = 'T' THEN 'Tire Rpl' WHEN LEFT(ISNULL(ERE.RepairType, ERA.RepairType), 1) = 'F' THEN 'Flat' ELSE 'Other' END
		,@DriverTypeText = CASE WHEN ISNULL(ERE.DriverType, ERA.DriverType) = 1 AND ISNULL(PUV.DriverId,ERE.DriverId) IS NOT Null THEN 'Company' 
			WHEN ISNULL(ERE.DriverType, ERA.DriverType) = 2 AND ISNULL(PUV.DriverId,ERE.DriverId) IS NOT Null THEN 'OO' 
			WHEN ISNULL(ERE.DriverType, ERA.DriverType) = 3 AND ISNULL(PUV.DriverId,ERE.DriverId) IS NOT Null THEN 'MyTruck'
			ELSE Null END
		,@DriverId = ISNULL(PUV.DriverId,ERE.DriverId)
		,@DriverName = CASE WHEN ISNULL(PUV.DriverId,ERE.DriverId) IS Null THEN Null ELSE dbo.GetVendorName(ERE.Company,ISNULL(PUV.DriverId,ERE.DriverId)) END
		,@ProNumber = CASE WHEN ISNULL(ERE.ProNumber,PUV.ProNumber) = '' OR ISNULL(ERE.ProNumber,PUV.ProNumber) IS Null THEN Null ELSE ISNULL(ERE.ProNumber,PUV.ProNumber) END
		,@Chassis = ISNULL(PUV.ChassisNumber,ERE.Chassis)
		,@Trailer = ISNULL(PUV.TrailerNumber,ERE.Trailer)
		,@RecoverableText = CASE WHEN LEFT(ISNULL(ERA.Recovery, ERE.Recoverable), 1) = 'N' THEN 'NO' WHEN LEFT(ISNULL(ERA.Recovery, ERE.Recoverable), 1) = 'Y' THEN 'YES' ELSE 'OPTIONAL' END
		,@Division = SUBSTRING(ERE.GLAccount, dbo.AT('-', ERE.GLAccount, 1) + 1, 2)
		,@StatusText = CASE WHEN Closed = 1 THEN 'Closed' WHEN Closed = 0 AND ERE.ATPAmount > 0 AND @Emails = 1 THEN 'Pending ATP' ELSE 'Open' END
FROM	ExpenseRecovery ERE
		LEFT JOIN ExpenseRecoveryAccounts ERA ON RIGHT(RTRIM(ERE.GLAccount), 4) = ERA.Account
		LEFT JOIN Purchasing_Vouchers PUV ON ERE.Company = PUV.CompanyId AND ERE.Source = PUV.Source AND ERE.VoucherNo = PUV.VoucherNumber
WHERE	ERE.Company = @Company
		AND ERE.ExpenseRecoveryId = @RecordId
		
UPDATE	ExpenseRecovery
SET		RepairTypeText		= @RepairTypeText,
		DriverTypeText		= @DriverTypeText,
		DriverName			= @DriverName,
		RecoverableText		= @RecoverableText,
		Division			= @Division,
		StatusText			= @StatusText,
		DriverId			= @DriverId,
		ProNumber			= @ProNumber,
		Chassis				= @Chassis,
		Trailer				= @Trailer
WHERE	ExpenseRecoveryId	= @RecordId

--UPDATE	ExpenseRecovery 
--SET		Recovery = Expense * -1,
--		Expense = 0
--WHERE	ExpenseRecoveryId	= @RecordId
--		AND PATINDEX('%ATP%', DocNumber) > 0
--		AND Expense <> 0

UPDATE	ExpenseRecovery 
SET		Recovery = Recovery * -1,
		Expense = 0
WHERE	ExpenseRecoveryId	= @RecordId
		AND Recovery > 0

