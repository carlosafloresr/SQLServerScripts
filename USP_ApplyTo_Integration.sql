USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_ApplyTo_Integration]    Script Date: 5/15/2020 12:10:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ApplyTo_Integration 'CASHAR', 'AIS', 'LB071019120000', '07/10/2019'
EXECUTE USP_ApplyTo_Integration 'TIPAP', 'GLSO', 'TIPAP0919181109', '09/19/2018'
*/
ALTER PROCEDURE [dbo].[USP_ApplyTo_Integration]
		@Integration	Varchar(8),
		@Company		Varchar(5),
		@BatchId		Varchar(25),
		@PostingDate	Date
AS
SET NOCOUNT ON

DECLARE	@ApplyType		Char(2),
		@CustVndId		Varchar(20),
		@ApplyFrom		Varchar(30),
		@ApplyTo		Varchar(30),
		@Amount			Numeric(10,2),
		@Query			Varchar(1000),
		@InOpen			Bit = 0,
		@Success		Smallint = 0,
		@DocType		Smallint,
		@Balance		Numeric(10,2),
		@TempDocument	Varchar(30),
		@TempCustomer	Varchar(25),
		@NatAccount		Varchar(25),
		@WriteOffAmnt	Numeric(10,2) = 0

DECLARE	@tblData		Table (DocumentNumber Varchar(30), Balance Numeric(10,2), CustomerId Varchar(25), NatAccount Varchar(25) Null)
DECLARE @tblAPData		Table (DocType Smallint, Balance Numeric(10,2))

SET @ApplyType = (SELECT TOP 1 RecordType FROM [SECSQL04T].Integrations.dbo.Integrations_ApplyTo WHERE Integration = @Integration AND Company = @Company AND BatchId = @BatchId)

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CustomerVendor) AS CustomerVendor,
		RTRIM(ApplyFrom) AS ApplyFrom,
		RTRIM(ApplyTo) AS ApplyTo,
		ApplyAmount,
		WriteOffAmnt
FROM	[SECSQL04T].Integrations.dbo.Integrations_ApplyTo 
WHERE	Integration = @Integration 
		AND Company = @Company 
		AND BatchId = @BatchId
		AND Processed = 0

OPEN curData 
FETCH FROM curData INTO @CustVndId, @ApplyFrom, @ApplyTo, @Amount, @WriteOffAmnt

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblData

	IF @Amount < 0
	BEGIN
		SET @Amount			= ABS(@Amount)
		SET @TempDocument	= @ApplyTo
		SET @ApplyTo		= @ApplyFrom
		SET @ApplyFrom		= @TempDocument
	END

	IF @ApplyType = 'AR'
		SET @Query = N'SELECT TOP 1 DOCNUMBR, CURTRXAM, CUSTNMBR, CPRCSTNM FROM ' + RTRIM(@Company) + '.dbo.RM20101 WHERE CUSTNMBR = ''' + @CustVndId + ''' AND DOCNUMBR = ''' + @ApplyFrom + ''''
	ELSE
		SET @Query = N'SELECT TOP 1 DOCNUMBR, CURTRXAM, VENDORID, Null FROM ' + RTRIM(@Company) + '.dbo.PM20000 WHERE VENDORID = ''' + @CustVndId + ''' AND DOCNUMBR = ''' + @ApplyFrom + ''''

	INSERT INTO @tblData
	EXECUTE(@Query)

	IF @ApplyType = 'AR'
		SET @Query = N'SELECT TOP 1 DOCNUMBR, CURTRXAM, CUSTNMBR, CPRCSTNM FROM ' + RTRIM(@Company) + '.dbo.RM20101 WHERE (CUSTNMBR = ''' + @CustVndId + ''' OR CPRCSTNM = ''' + @CustVndId + ''') AND DOCNUMBR = ''' + @ApplyTo + ''''
	ELSE
		SET @Query = N'SELECT TOP 1 DOCNUMBR, CURTRXAM, VENDORID, Null FROM ' + RTRIM(@Company) + '.dbo.PM20000 WHERE VENDORID = ''' + @CustVndId + ''' AND DOCNUMBR = ''' + @ApplyTo + ''''

	INSERT INTO @tblData
	EXECUTE(@Query)
	
	IF @@ROWCOUNT > 0
	BEGIN
		SET @Balance = (SELECT SUM(Balance) FROM @tblData WHERE DocumentNumber = @ApplyFrom)
		IF @Balance > 0 AND EXISTS(SELECT DocumentNumber FROM @tblData WHERE DocumentNumber = @ApplyTo)
		BEGIN
			-- PRINT 'ApplyFrom ' + @ApplyFrom + ' = ' + CAST(@Balance AS Varchar) + ' Apply To ' + @ApplyTo
			SET @Success = 1

			BEGIN TRY
				IF @ApplyType = 'AR'
				BEGIN
					SET @TempCustomer = (SELECT CustomerId FROM @tblData WHERE DocumentNumber = @ApplyTo)

					IF RTRIM(@TempCustomer) <> RTRIM(@CustVndId)
					BEGIN
						SET @NatAccount = RTRIM(@CustVndId)
						SET @CustVndId	= RTRIM(@TempCustomer)
					END
					
					--BEGIN TRANSACTION
					BEGIN TRY
						EXECUTE USP_ApplyTo_ReceivablesIntegration @Company, @CustVndId, @ApplyFrom, @ApplyTo, @Amount, @PostingDate, @NatAccount, @WriteOffAmnt
					END TRY
					BEGIN CATCH
						SET @Success = 0
						PRINT CAST(ERROR_NUMBER() AS Varchar) + ' - ' + ERROR_MESSAGE()
						PRINT 'on EXECUTE USP_ApplyTo_ReceivablesIntegration ' + @Company + ',' + @CustVndId + ',' + @ApplyFrom + ',' + @ApplyTo + ',' + CAST(@Amount AS Varchar) + ',' + CAST(@PostingDate AS Varchar) + ',' + ISNULL(@NatAccount, 'Null') + ',' + CAST(@WriteOffAmnt AS Varchar)
					END CATCH

					--IF @@ERROR = 0
					--	COMMIT TRANSACTION
					--ELSE
					--	ROLLBACK TRANSACTION
				END
				ELSE
				BEGIN
					DELETE @tblAPData

					EXECUTE USP_ApplyTo_PayablesIntegration @Company, @CustVndId, @ApplyFrom, @ApplyTo, @Amount, @PostingDate

					SET @Query = N'SELECT TOP 1 DOCTYPE, CURTRXAM FROM ' + RTRIM(@Company) + '.dbo.PM20000 WHERE VENDORID = ''' + @CustVndId + ''' AND DOCNUMBR = ''' + @ApplyTo + ''''

					INSERT INTO @tblAPData
					EXECUTE(@Query)

					IF @@ROWCOUNT > 0
					BEGIN
						SELECT	@DOCTYPE	= DOCTYPE,
								@BALANCE	= Balance
						FROM	@tblAPData

						IF @Balance = 0
						BEGIN
							SET @Query = N'EXECUTE ' + RTRIM(@Company) + '.dbo.USP_AP_MoveOpenToHistory ''' +  RTRIM(@ApplyTo) + ''',''' + CAST(@DOCTYPE AS Varchar) + ''''
							EXECUTE(@Query)
						END
					END
				END
			END TRY
			BEGIN CATCH
				SET @Success = 0
			END CATCH
		END
		ELSE
			SET @Success = 1
	END

	FETCH FROM curData INTO @CustVndId, @ApplyFrom, @ApplyTo, @Amount, @WriteOffAmnt
END

CLOSE curData
DEALLOCATE curData

RETURN @Success

-- ROLLBACK TRANSACTION