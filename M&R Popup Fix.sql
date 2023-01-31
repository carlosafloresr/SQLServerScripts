DECLARE @Query		Varchar(MAX),
		@Invoice	Varchar(12),
		@Chassis	Varchar(15),
		@Container	Varchar(15),
		@Companion	Varchar(15) = '',
		@RepDate	Datetime,
		@RepDate2	Datetime,
		@ProNumber	Varchar(15) = '',
		@DriverId	Varchar(12) = '',
		@DriverType	Varchar(20) = 'N/A',
		@DriverDiv	Char(2) = '',
		@EqType		Varchar(20),
		@EqOwner	Varchar(20),
		@CompanyEq	Bit = 0,
		@UserId		Varchar(25) = 'Auto-Generate',
		@VendorId	Varchar(30) = '1000331 - Imcg Maintenance & R',
		@VendorName	Varchar(100),
		@Customer	Varchar(12),
		@IsDepot	Bit = 0,
		@DepotError	Varchar(2) = '',
		@EIRI		Varchar(12),
		@DEP_LOC	Varchar(15),
		@TotalAmnt	Numeric(10,2) = 0,
		@TmpDesc	Varchar(100) = '',
		@PartsTax	Numeric(10,2) = 0,
		@LaborTax	Numeric(10,2) = 0,
		@TotParts	Numeric(10,2) = 0,
		@TotLabor	Numeric(10,2) = 0,
		@InvParts	Numeric(10,2) = 0,
		@InvLabor	Numeric(10,2) = 0,
		@FleetEq	Varchar(15) = '',
		@OrderNum	Int,
		@tmpProNum	Varchar(15) = '',
		@OverRoad	bit = 0,
		@tmpString	Varchar(50) = '',
		@DistId		Int = 0,
		@DistAcct	Varchar(15) = '',
		@DistDesc	Varchar(30) = '',
		@DistAmnt	Numeric(10,2) = 0.0,
		@DistDept	Char(2) = '',
		@PopupId	int = 0,
		@EffDate	Date = GETDATE(),
		@DrvType	Char(1) = '',
		@RepType	Char(1)

DECLARE @tblExpAccounts Table (Account Char(4), RepType Varchar(30), DrvType Char(1), Recovery Char(1))

INSERT INTO @tblExpAccounts
SELECT	[Account]
		,[RepairType]
		,[DriverType]
		,[Recovery]
FROM	PRISQL01P.GPCustom.dbo.ExpenseRecoveryAccounts

DECLARE curDistribution CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DET.InvoiceNumber,
		DET.MRInvoices_DistributionId,
		DET.GLAccount,
		DET.Description,
		DET.Amount,
		HDR.Field11,
		HDR.Field10,
		HDR.Field14,
		HDR.Field3
FROM	[DepotSystemsViews].[dbo].[MRInvoices_AP] HDR
		INNER JOIN MRInvoices_Distribution DET ON HDR.InvoiceNumber = DET.InvoiceNumber
		INNER JOIN @tblExpAccounts ACC ON RIGHT(DET.GLAccount, 4) = ACC.Account
WHERE	HDR.InvoiceNumber BETWEEN '1785372' AND '1785871'
		AND HDR.Accepted = 1
		AND DET.PopUpId = 0

OPEN curDistribution 
FETCH FROM curDistribution INTO @Invoice, @DistId, @DistAcct, @DistDesc, @DistAmnt, @ProNumber,
							@invoice_date, @Container, @Chassis

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF RIGHT(@DistAcct, 4) IN (SELECT Account FROM @tblExpAccounts)
	BEGIN
		SET @DrvType = IIF(LEFT(@DriverType, 1) = 'C', '1', '2')
		SET @DistDept = IIF(SUBSTRING(@DistAcct, 3, 2) IN ('','XX'), '', SUBSTRING(@DistAcct, 3, 2))

		SELECT	@RepType = LEFT(RepType, 1)
		FROM	@tblExpAccounts
		WHERE	Account = RIGHT(@DistAcct, 4)

		EXECUTE @PopupId = PRISQL01P.GPCustom.dbo.USP_DEX_ER_PopUps 0, 'IMC', @Invoice,
							@VendorId, @ProNumber, @DistDesc, 0, @DistAmnt, @Invoice,
							@EffDate, @invoice_date, @Container, @Chassis, @DistDesc, 'N',
							@DriverId, @DrvType, @RepType, @DistAcct, Null, 'Open', Null, 
							0, 0, 'AP', 0, 1, Null, @DistDept

		IF ISNULL(@PopupId, 0) > 0
			UPDATE MRInvoices_Distribution SET PopUpId = @PopupId WHERE MRInvoices_DistributionId = @DistId
	END

	FETCH FROM curDistribution INTO @Invoice, @DistId, @DistAcct, @DistDesc, @DistAmnt
END

CLOSE curDistribution
DEALLOCATE curDistribution