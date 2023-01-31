/*
EXECUTE USP_RSR_CreatePopUps 2686
*/
ALTER PROCEDURE USP_RSR_CreatePopUps (@RepairId Int)
AS
DECLARE	@DEX_ER_PopUpsId	Int,
		@Company			varchar(5),
		@VoucherNo			varchar(20) = Null,
		@Vendor				varchar(30),
		@Pronumber			varchar(15),
		@Reference			varchar(50) = Null,
		@Expense			decimal(9,2),
		@Recovery			decimal(9,2),
		@DocNumber			varchar(25),
		@EffDate			datetime = Null,
		@InvDate			datetime = Null,
		@Trailer			varchar(20),
		@Chassis			varchar(20),
		@FailureReason		varchar(50),
		@Recoverable		Char(1),
		@DriverId			varchar(12),
		@DriverType			Int,
		@RepairType			varchar(20) = Null,
		@GLAccount			varchar(12),
		@RecoveryAction		varchar(25) = Null,
		@Status				Varchar(10) = 'Open',
		@Notes				Varchar(250) = Null,
		@ItemNumber			Int = 0,
		@Closed				Bit = 0,
		@Source				Char(2) = 'AP',
		@ATPAmount			decimal(9,2) = 0,
		@ATPDeductions		Int = 1,
		@StartingDate		Datetime = Null,
		@DetailId			Int,
		@PopUpId			Int

-- *** SELECT THE REPAIR DATA REQUIRED FOR THE POP UPS ***
DECLARE curPopUps CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	REPA.PopUpId
		,REPA.Company
		,REPA.VoucherNumber
		,REPA.Vendor
		,REPA.ProNumber
		,REPA.GLDescription
		,REPA.LineTotal
		,0
		,REPA.InvoiceNumber
		,REPA.EffectiveDate
		,REPA.InvoiceDate
		,REPA.Container
		,REPA.Chassis
		,UPPER(REPA.Repair) AS FailureReason
		,CASE WHEN ACCT.Recovery = 'Y' THEN 'YES' ELSE 'NO' END AS Recoverable
		,REPA.DriverId
		,CASE WHEN VNDM.VendorId IS Null THEN 1 ELSE 2 END AS DriverType
		,CASE WHEN REPA.Repair = 'RPL' THEN 'Tire RPL' WHEN REPA.Repair = 'RPR' THEN 'Flat' ELSE 'M&R' END AS RepairType
		,REPA.GLCode
		,Null AS RecoveryAction
		,'Open' AS Status
		,Null AS Notes
		,16384 * ROW_NUMBER() OVER (ORDER BY REPA.InvoiceNumber) AS ItemNumber
		,0 AS Closed
		,'AP' AS Source
		,0 AS ATPAmount
		,1 AS ATPDeductions
		,Null AS StartingDate
		,REPA.RSA_InvoiceDetailId
FROM	View_RSA_Invoices REPA
		INNER JOIN ExpenseRecoveryAccounts ACCT ON RIGHT(RTRIM(REPA.GLCode), 4) = ACCT.Account
		LEFT JOIN VendorMaster VNDM ON REPA.Company = VNDM.Company AND REPA.DriverId = VNDM.VendorId
WHERE	REPA.RepairNumber = @RepairId

OPEN curPopUps
FETCH FROM curPopUps INTO @DEX_ER_PopUpsId, @Company, @VoucherNo, @Vendor, @Pronumber, @Reference, @Expense, @Recovery, @DocNumber, @EffDate,
						  @InvDate, @Trailer, @Chassis, @FailureReason, @Recoverable, @DriverId, @DriverType, @RepairType, @GLAccount, 
						  @RecoveryAction, @Status, @Notes, @ItemNumber, @Closed, @Source, @ATPAmount, @ATPDeductions, @StartingDate, @DetailId

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE @PopUpId = USP_DEX_ER_PopUps @DEX_ER_PopUpsId, @Company, @VoucherNo, @Vendor, @Pronumber, @Reference, @Expense, @Recovery, @DocNumber, @EffDate,
						  @InvDate, @Trailer, @Chassis, @FailureReason, @Recoverable, @DriverId, @DriverType, @RepairType, @GLAccount, 
						  @RecoveryAction, @Status, @Notes, @ItemNumber, @Closed, @Source, @ATPAmount, @ATPDeductions, @StartingDate

	-- *** IF THE POP UP RECORD WAS CREATED THE REPAIR INVOICE DETAIL LINE POPUPID FIELD IS UPDATED
	IF @PopUpId > 0
	BEGIN
		UPDATE RSA_InvoiceDetail SET PopUpId = @PopUpId WHERE Id = @DetailId
	END

	FETCH FROM curPopUps INTO @DEX_ER_PopUpsId, @Company, @VoucherNo, @Vendor, @Pronumber, @Reference, @Expense, @Recovery, @DocNumber, @EffDate,
						  @InvDate, @Trailer, @Chassis, @FailureReason, @Recoverable, @DriverId, @DriverType, @RepairType, @GLAccount, 
						  @RecoveryAction, @Status, @Notes, @ItemNumber, @Closed, @Source, @ATPAmount, @ATPDeductions, @StartingDate, @DetailId
END

CLOSE curPopUps
DEALLOCATE curPopUps

-- SELECT * FROM View_RSA_Invoices WHERE RepairNumber = 2686
-- EXECUTE sp_RSA_Invoice_SendTransactionToGP 2686
-- SELECT * FROM DEX_ER_PopUps WHERE DEX_ER_PopUpsId IN (SELECT PopUpId FROM View_RSA_Invoices WHERE RepairNumber = 2686)