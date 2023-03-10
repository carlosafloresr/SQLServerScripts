ALTER PROCEDURE [dbo].[USP_DEX_ER_PopUps]
		@DEX_ER_PopUpsId	Int
		,@Company			varchar(5)
		,@VoucherNo			varchar(20) = Null
		,@Vendor			varchar(30)
		,@Pronumber			varchar(15)
		,@Reference			varchar(50) = Null
		,@Expense			decimal(9,2)
		,@Recovery			decimal(9,2)
		,@DocNumber			varchar(25)
		,@EffDate			datetime = Null
		,@InvDate			datetime = Null
		,@Trailer			varchar(20)
		,@Chassis			varchar(20)
		,@FailureReason		varchar(50)
		,@Recoverable		Char(1)
		,@DriverId			varchar(12)
		,@DriverType		Int
		,@RepairType		varchar(20) = Null
		,@GLAccount			varchar(12)
		,@RecoveryAction	varchar(25) = Null
		,@Status			Varchar(10) = 'Open'
		,@Notes				Varchar(250) = Null
		,@ItemNumber		Int = 0
		,@Closed			Bit = 0
		,@Source			Char(2) = 'AP'
		,@ATPAmount			decimal(9,2) = 0
		,@ATPDeductions		Int = 1
		,@StartingDate		Datetime = Null
AS
DECLARE	@RecordId			Int

IF @RepairType IS Null
BEGIN
	SET @RepairType = (SELECT LEFT(RepairType, 1) FROM ExpenseRecoveryAccounts WHERE Account = RIGHT(RTRIM(@GLAccount), 4))
	
	IF @RepairType IS Null
		SET @RepairType = 'O'
END

SET @DocNumber = REPLACE(@DocNumber, '|', '')

IF @Closed = 1
	SET @Status = 'Closed'

BEGIN TRANSACTION

IF @DEX_ER_PopUpsId IS Null OR @DEX_ER_PopUpsId = 0
BEGIN
	IF @Recovery < 0
		SET @Closed = 1
		
	INSERT INTO DEX_ER_PopUps
		(Company
		,voucherno
		,vendor
		,pronumber
		,reference
		,expense
		,recovery
		,docnumber
		,effdate
		,invdate
		,trailer
		,chassis
		,FailureReason
		,Recoverable
		,DriverId
		,DriverType
		,repairtype
		,glaccount
		,RecoveryAction
		,Status
		,Notes
		,ItemNumber
		,Closed
		,Source
		,ATPAmount
		,ATPDeductions
		,StartingDate)
	VALUES
		(@Company
		,@voucherno
		,@vendor
		,@pronumber
		,@reference
		,ISNULL(ABS(@expense),0.00)
		,ISNULL(ABS(@recovery) * -1, 0.00)
		,@docnumber
		,@effdate
		,@invdate
		,@trailer
		,@chassis
		,@FailureReason
		,@Recoverable
		,@driverid
		,@DriverType
		,@repairtype
		,@glaccount
		,@RecoveryAction
		,@Status
		,@Notes
		,@ItemNumber
		,@Closed
		,@Source
		,@ATPAmount
		,@ATPDeductions
		,@StartingDate)

	SET	@RecordId = @@IDENTITY
END
ELSE
BEGIN
	UPDATE	DEX_ER_PopUps
	SET		Company				= @Company
			,voucherno			= @voucherno
			,vendor				= @vendor
			,pronumber			= @pronumber
			,reference			= @reference
			,expense			= ISNULL(ABS(@expense),0.00)
			,[recovery]			= ISNULL(ABS(@recovery) * -1,0.00)
			,docnumber			= @docnumber
			,effdate			= @effdate
			,invdate			= @invdate
			,trailer			= @trailer
			,chassis			= @chassis
			,FailureReason		= @FailureReason
			,Recoverable		= @Recoverable
			,driverid			= @driverid
			,DriverType			= @DriverType
			,repairtype			= @repairtype
			,glaccount			= @glaccount
			,RecoveryAction		= @RecoveryAction
			,[Status]			= @Status
			,Notes				= @Notes
			,ItemNumber			= @ItemNumber
			,Closed				= @Closed
			,[Source]			= @Source
			,ATPAmount			= @ATPAmount
			,ATPDeductions		= @ATPDeductions
			,StartingDate		= @StartingDate
	WHERE	DEX_ER_PopUpsId		= @DEX_ER_PopUpsId
	
	SET		@RecordId = @DEX_ER_PopUpsId
END

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	--EXECUTE USP_ExpenseRecovery_Update @Company, @RecordId
	RETURN @RecordId
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	RETURN -1
END