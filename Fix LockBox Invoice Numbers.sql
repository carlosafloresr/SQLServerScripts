USE [AIS]
GO

DECLARE	@Integration	Varchar(8) = 'CASHAR',
		@Company		Varchar(5) = 'AIS',
		@BatchId		Varchar(25) = 'LB062119120000',
		@PostingDate	Date

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
		@Document		Varchar(25),
		@Customer		Varchar(15),
		@Parent			Varchar(15)

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CustomerVendor) AS CustomerVendor,
		RTRIM(ApplyFrom) AS ApplyFrom,
		RTRIM(ApplyTo) AS ApplyTo,
		ApplyAmount
FROM	IntegrationsDB.Integrations.dbo.Integrations_ApplyTo 
WHERE	Integration = @Integration 
		AND Company = @Company 
		AND BatchId = @BatchId

OPEN curData 
FETCH FROM curData INTO @CustVndId, @ApplyFrom, @ApplyTo, @Amount

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @ApplyTo

	SELECT	@Document	= RTRIM(DOCNUMBR),
			@Customer	= RTRIM(CUSTNMBR),
			@Parent		= RTRIM(CPRCSTNM)
	FROM	RM20101
	WHERE	(DOCNUMBR = @ApplyTo
			OR REPLACE(DOCNUMBR, '-', '') = @ApplyTo)

	IF @@ROWCOUNT > 0
	BEGIN
		UPDATE	IntegrationsDB.Integrations.dbo.Integrations_ApplyTo
		SET		ApplyTo			= @Document,
				CustomerVendor	= IIF(@Parent = '', @Customer, @Parent)
		WHERE	Integration = @Integration 
				AND Company = @Company 
				AND BatchId = @BatchId
				AND ApplyFrom = @ApplyFrom
				AND ApplyTo = @ApplyTo
	END

	FETCH FROM curData INTO @CustVndId, @ApplyFrom, @ApplyTo, @Amount
END

CLOSE curData
DEALLOCATE curData

SELECT	RTRIM(CustomerVendor) AS CustomerVendor,
		RTRIM(ApplyFrom) AS ApplyFrom,
		RTRIM(ApplyTo) AS ApplyTo,
		ApplyAmount
FROM	IntegrationsDB.Integrations.dbo.Integrations_ApplyTo 
WHERE	Integration = @Integration 
		AND Company = @Company 
		AND BatchId = @BatchId