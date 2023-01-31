/*
EXECUTE USP_UpdateIntegrationCustomerandVendors 'FSI','DNJ','7FSI20141014_1007'
*/
CREATE PROCEDURE [dbo].[USP_UpdateIntegrationCustomerandVendors]
		@Integration	Varchar(5),
		@Company		Varchar(5),
		@BatchId		Varchar(25),
		@Type			Char(1),
		@UpdateType		Char(1),
		@OldValue		Varchar(30) = Null,
		@NewValue		Varchar(30) = Null
AS
DECLARE	@Query		Varchar(Max)

IF @UpdateType = 'A' -- **** ACTIVATE CUSTOMER/VENDOR ***
BEGIN
	IF @Type = 'C'
		-- FOR CUSTOMERS
		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.RM00101 SET INACTIVE = 0 WHERE CUSTNMBR = ''' + RTRIM(@OldValue) + ''''
	ELSE
		-- FOR VENDORS
		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM00200 SET VENDSTTS = 1 WHERE VENDORID = ''' + RTRIM(@OldValue) + ''''

	EXECUTE(@Query)
END

IF @UpdateType = 'R' -- **** REPLACE VALUES ***
BEGIN
	IF @Integration = 'DPY'
	BEGIN
		-- ONLY VENDOR APPLY
		UPDATE	Integration_APDetails
		SET		VendorId = @NewValue
		WHERE	BatchId = @BatchId
				AND VendorId = @OldValue
	END

	IF @Integration = 'FSI'
	BEGIN
		IF @Type = 'C'
			-- FOR CUSTOMERS
			UPDATE	ILSINT02.Integrations.dbo.FSI_ReceivedDetails
			SET		CustomerNumber = @NewValue
			WHERE	BatchId = @BatchId
					AND CustomerNumber = @OldValue
		ELSE
			-- FOR VENDORS
			UPDATE	ILSINT02.Integrations.dbo.FSI_ReceivedSubDetails
			SET		RecordCode = @NewValue
			WHERE	BatchId = @BatchId
					AND RecordType = 'VND'
					AND RecordCode = @OldValue
	END

	IF @Integration = 'FPT'
	BEGIN
		-- ONLY VENDOR APPLY
		UPDATE	ILSINT02.Integrations.dbo.FPT_ReceivedDetails
		SET		VendorId = @NewValue
		WHERE	BatchId = @BatchId
				AND VendorId = @OldValue
	END

	IF @Integration = 'MSR'
	BEGIN
		-- ONLY CUSTOMER APPLY
		UPDATE	ILSINT02.Integrations.dbo.MSR_ReceviedTransactions
		SET		Customer = @NewValue
		WHERE	BatchId = @BatchId
				AND Customer = @OldValue
	END
END

IF @UpdateType = 'U' -- **** UNHOLD CUSTOMER/VENDOR ***
BEGIN
	IF @Type = 'C'
		-- FOR CUSTOMERS
		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.RM00101 SET HOLD = 0 WHERE CUSTNMBR = ''' + RTRIM(@OldValue) + ''''
	ELSE
		-- FOR VENDORS
		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM00200 SET HOLD = 0 WHERE VENDORID = ''' + RTRIM(@OldValue) + ''''

	EXECUTE(@Query)
END

IF @@ROWCOUNT > 0 AND @@ERROR = 0
BEGIN
	UPDATE	ILSINT02.Integrations.dbo.IntegrationExceptions
	SET		Applied = 1
	WHERE	Integration = @Integration
			AND Company = @Company
			AND BatchId = @BatchId
			AND ValueType = @Type
			AND Value = @OldValue
END