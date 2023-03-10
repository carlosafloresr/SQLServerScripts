USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_Integrations_Bank]    Script Date: 7/10/2018 1:27:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_Integrations_Bank]
		@Integration	varchar(6),
		@Company		varchar(5),
		@BatchId		varchar(15),
		@Option			smallint = 1,
		@CMTrxType		smallint = 3,
		@RcpType		smallint = Null,
		@TrxDate		date,
		@ChekBkId		varchar(15),
		@CMTrxNum		varchar(20),
		@CardName		varchar(15) = Null,
		@PaidToCrvFrom	varchar(30) = Null,
		@Dscrptn		varchar(30),
		@TrxAmnt		numeric(10,2),
		@GLPostDate		date,
		@ActNumSt		varchar(15),
		@DebitAmt		numeric(10,2),
		@CrdtAmnt		numeric(10,2),
		@DistRef		varchar(30),
		@Division		char(2) = Null,
		@DriverId		varchar(15) = Null,
		@ClaimNumber	varchar(15) = Null,
		@DriverClass	smallint = Null,
		@AccidentType	smallint = Null,
		@InvoiceNumber	varchar(30) = Null,
		@UserId			varchar(25)
AS
DECLARE	@PopUpId		int = 0,
		@EscrowType		int,
		@FormType		int,
		@AcctSign		char(1),
		@Amount			numeric(10,2)

SET	@ActNumSt = RTRIM(REPLACE(@ActNumSt, '.', '-'))

EXECUTE @EscrowType = LENSASQL001.GPCustom.dbo.USP_FindPopUpType @Company, @ActNumSt, @FormType OUTPUT, NULL

BEGIN TRY
	IF @EscrowType = 6 AND @DriverId IS NOT Null
	BEGIN
		-- ESCROW
		SELECT	@AcctSign = Increase
		FROM	LENSASQL001.GPCustom.dbo.EscrowAccounts 
		WHERE	AccountNumber = @ActNumSt 
				AND CompanyId = @Company

		IF @CrdtAmnt > 0
			SET @Amount = @CrdtAmnt * CASE WHEN @AcctSign = 'C' THEN 1 ELSE -1 END
		ELSE
			SET @Amount = @DebitAmt * CASE WHEN @AcctSign = 'D' THEN 1 ELSE -1 END

		EXECUTE @PopUpId = LENSASQL001.GPCustom.dbo.USP_DEX_ET_PopUps @InvoiceNumber, 
																		@Company, 
																		@EscrowType,
																		@ActNumSt,
																		99,
																		@DriverId,
																		@DriverId,
																		@Division,
																		@Amount,
																		@ClaimNumber,
																		@DriverClass,
																		@AccidentType,
																		@DISTREF,
																		@UserId,
																		Null,
																		Null,
																		'BK',
																		@GLPostDate,
																		Null,
																		0,	-- Item
																		Null,
																		@GLPostDate,
																		Null,
																		Null,
																		@BatchId,
																		@InvoiceNumber,
																		Null
	END

	INSERT INTO dbo.Integrations_Bank
           (Integration
           ,Company
           ,BatchId
           ,[Option]
           ,CMTrxType
           ,RcpType
           ,TrxDate
           ,ChekBkId
           ,CMTrxNum
           ,CardName
           ,PaidToCrvFrom
           ,Dscrptn
           ,TrxAmnt
           ,GLPostDate
           ,ActNumSt
           ,DebitAmt
           ,CrdtAmnt
           ,DistRef
		   ,Division
		   ,DriverId
		   ,ClaimNumber
		   ,DriverClass
		   ,AccidentType
		   ,InvoiceNumber
		   ,PopUpId)
     VALUES
           (@Integration,
           @Company,
           @BatchId,
           @Option,
           @CMTrxType,
           @RcpType,
           @TrxDate,
           @ChekBkId,
           @CMTrxNum,
           @CardName,
           @PaidToCrvFrom,
           @Dscrptn,
           @TrxAmnt,
           @GLPostDate,
           @ActNumSt,
           @DebitAmt,
           @CrdtAmnt,
           @DistRef,
		   @Division,
		   @DriverId,
		   @ClaimNumber,
		   @DriverClass,
		   @AccidentType,
		   @InvoiceNumber,
		   @PopUpId)
END TRY  
BEGIN CATCH  
	SELECT	ERROR_NUMBER() AS ErrorNumber,
			ERROR_MESSAGE() AS ErrorMessage 
END CATCH  
