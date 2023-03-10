USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_ReceivedSubDetails]    Script Date: 1/25/2023 3:52:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_FSI_ReceivedSubDetails]
		@BatchId			varchar(25),
		@DetailId			varchar(10),
		@RecordType			char(3),
		@RecordCode			varchar(12),
		@Reference			varchar(60),
		@ChargeAmount1		money,
		@ChargeAmount2		money,
		@ReferenceCode		varchar(10),
		@Verification		varchar(50),
		@Processed			bit,
		@VndIntercompany	bit,
		@VendorDocument		varchar(30),
		@VendorReference	varchar(25) = Null,
		@PrePay				bit = 0,
		@AccCode			varchar(5) = Null,
		@ICB				bit = 0,
		@CheckDigit			char(1) = Null,
		@PrePayType			char(1) = Null,
		@FileRowNumber		int = 0,
		@PerDiemType		bit = 0,
		@AdminFee			numeric(10,2) = 0,
		@ExternalId			varchar(20) = Null,
		@SWSRecordId		bigint = 0
AS
SET NOCOUNT ON

DECLARE	@PerDiemCodes		Varchar(50),
		@PerDiemVendor		Varchar(12),
		@Company			Varchar(5)

IF @ICB IS Null
	SET @ICB = 0

IF @PrePayType IS NOT Null AND @PrePayType NOT IN ('A','P')
	SET @PrePayType = Null

IF @ExternalId = ''
	SET @ExternalId = Null

IF NOT EXISTS(SELECT	TOP 1 BatchId
				FROM	dbo.FSI_ReceivedSubDetails
				WHERE	BatchId	= @BatchId
						AND DetailId = @DetailId
						AND FileRowNumber = @FileRowNumber)
BEGIN
	IF @RecordType = 'VND'
	BEGIN
		SET @Company = (SELECT TOP 1 Company FROM FSI_ReceivedHeader WHERE BatchId = @BatchId)

		SELECT	@PerDiemVendor = VarC
		FROM	PRISQL01P.GPCustom.dbo.Parameters
		WHERE	Company = @Company
				AND ParameterCode = 'PRD_VENDORCODE'

		SELECT	@PerDiemCodes = VarC
		FROM	PRISQL01P.GPCustom.dbo.Parameters
		WHERE	ParameterCode = 'PRD_ACCESSORAILCODE'

		IF @RecordCode = @PerDiemVendor AND @PerDiemCodes LIKE ('%' + @AccCode + '%')
			SET @PerDiemType = 1
	END

	IF @RecordType = 'EQP'
	BEGIN
		BEGIN TRY
			DECLARE	@Query			Varchar(500),
					@ProNumber		Varchar(15),
					@CompanyNum		Varchar(2)

			DECLARE	@tblEquipment	Table (CheckDigit Char(1))

			SET @CompanyNum = LEFT(@BatchId, IIF(SUBSTRING(@BatchId, 2, 1) = 'F', 1, 2))
			SET @ProNumber = (SELECT InvoiceNumber FROM FSI_ReceivedDetails WHERE BatchId = @BatchId AND DetailId = @DetailId)
			SET @Query = N'SELECT EqChkDig FROM TRK.Invoice WHERE Cmpy_No = ' + @CompanyNum + ' AND Code = ''' + RTRIM(@ProNumber) + ''''

			INSERT INTO @tblEquipment
			EXECUTE USP_QuerySWS @Query

			SET @CheckDigit = (SELECT CheckDigit FROM @tblEquipment)
		END TRY
		BEGIN CATCH  
			PRINT ERROR_MESSAGE()
		END CATCH  
	END

	BEGIN TRANSACTION

	INSERT INTO dbo.FSI_ReceivedSubDetails
				(BatchId
				,DetailId
				,RecordType
				,RecordCode
				,Reference
				,ChargeAmount1
				,ChargeAmount2
				,ReferenceCode
				,Verification
				,Processed
				,VndIntercompany
				,VendorDocument
				,VendorReference
				,PrePay
				,AccCode
				,ICB
				,CheckDigit
				,PrePayType
				,FileRowNumber
				,PerDiemType
				,DemurrageAdminFee
				,ExternalId
				,SWSRecordId)
			VALUES
				(@BatchId
				,@DetailId
				,@RecordType
				,@RecordCode
				,@Reference
				,@ChargeAmount1
				,@ChargeAmount2
				,@ReferenceCode
				,@Verification
				,@Processed
				,@VndIntercompany
				,@VendorDocument
				,@VendorReference
				,@PrePay
				,@AccCode
				,@ICB
				,@CheckDigit
				,@PrePayType
				,@FileRowNumber
				,@PerDiemType
				,@AdminFee
				,@ExternalId
				,@SWSRecordId)

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @@IDENTITY
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN 0
	END
END
ELSE
	RETURN 0
