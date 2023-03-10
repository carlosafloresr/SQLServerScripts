USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_Integrations_GL]    Script Date: 2/2/2017 12:53:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_Integrations_GL]
		@Integration	varchar(6),
        @Company		varchar(5),
        @BatchId		varchar(15),
		@PstgDate		date,
		@Refrence		varchar(30),
		@TrxDate		date,
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@VendorId		varchar(12) = Null,
		@ProNumber		varchar(15) = Null,
		@InvoiceNumber	varchar(30) = Null,
		@Division		varchar(3) = Null,
		@ETADate		date = Null,
		@RepairDate		date = Null,
		@UnitNumber		varchar(90) = Null
AS
DECLARE	@PopUpId		int,
		@EscrowType		int,
		@FormType		int,
		@Amount			numeric(12,2),
		@AcctSign		Char(1)
PRINT @ETADate
EXECUTE @EscrowType = LENSASQL001.[GPCustom].dbo.USP_FindPopUpType @Company, @ActNumSt, @FormType OUTPUT, NULL

IF @EscrowType > 0
BEGIN
	SELECT	@AcctSign = Increase
	FROM	ILSGP01.GPCustom.dbo.EscrowAccounts 
	WHERE	AccountNumber = @ActNumSt 
			AND CompanyId = @Company

	IF @CrdtAmnt > 0
		SET @Amount = @CrdtAmnt * CASE WHEN @AcctSign = 'C' THEN 1 ELSE -1 END
	ELSE
		SET @Amount = @DebitAmt * CASE WHEN @AcctSign = 'D' THEN 1 ELSE -1 END

	IF @FormType = 1
	BEGIN
		EXECUTE @PopUpId = LENSASQL001.[GPCustom].dbo.USP_DEX_ET_PopUps @InvoiceNumber, 
																		@Company, 
																		@EscrowType,
																		@ActNumSt,
																		99,
																		@VendorId,
																		Null,
																		@Division,
																		@Amount,
																		Null,
																		Null,
																		Null,
																		@Dscriptn,
																		@UserId,
																		1,
																		1,
																		'GL',
																		@PstgDate,
																		Null,
																		0,	-- Item
																		@ProNumber,
																		@PstgDate,
																		Null,
																		Null,
																		@BatchId,
																		@InvoiceNumber
	END

	IF @FormType = 2 AND @EscrowType <> 5
	BEGIN
		EXECUTE @PopUpId = LENSASQL001.[GPCustom].dbo.USP_DEX_ET_PopUps @InvoiceNumber, 
																		@Company, 
																		@EscrowType, 
																		@ActNumSt,
																		99,
																		@VendorId,
																		Null,
																		@Division,
																		@Amount,
																		Null,
																		Null,
																		Null,
																		@Dscriptn,
																		@UserId,
																		Null,
																		Null,
																		'GL',
																		@PstgDate,
																		Null,
																		0,	-- Item
																		@ProNumber,
																		@PstgDate,
																		Null,
																		Null,
																		@BatchId,
																		@InvoiceNumber
	END

	IF @EscrowType = 5
	BEGIN
		EXECUTE @PopUpId = LENSASQL001.[GPCustom].dbo.USP_DEX_ET_PopUps @InvoiceNumber, 
																		@Company, 
																		@EscrowType, 
																		@ActNumSt,
																		99,
																		@VendorId,
																		Null,
																		@Division,
																		@Amount,
																		Null,
																		Null,
																		Null,
																		@Dscriptn,
																		@UserId,
																		1,
																		0,
																		'GL',
																		@PstgDate,
																		Null,
																		0,
																		@ProNumber,
																		@PstgDate,
																		Null,
																		Null,
																		@BatchId,
																		@InvoiceNumber,
																		Null,
																		@ETADate,
																		@RepairDate,
																		@UnitNumber
	END
END

INSERT INTO [dbo].[Integrations_GL]
           ([Integration]
           ,[Company]
           ,[BatchId]
           ,[Refrence]
           ,[TrxDate]
           ,[Series]
           ,[UserId]
           ,[ActNumSt]
           ,[CrdtAmnt]
           ,[DebitAmt]
           ,[Dscriptn]
		   ,[VendorId]
		   ,[ProNumber]
		   ,[InvoiceNumber]
           ,[PopUpId])
     VALUES
           (@Integration
           ,@Company
           ,@BatchId
           ,@Refrence
           ,@PstgDate
           ,@Series
           ,@UserId
           ,@ActNumSt
           ,@CrdtAmnt
           ,@DebitAmt
           ,@Dscriptn
		   ,@VendorId
		   ,@ProNumber
		   ,@InvoiceNumber
           ,ISNULL(@PopUpId,0))

IF @@ERROR = 0
	RETURN @@IDENTITY
ELSE
	RETURN 0