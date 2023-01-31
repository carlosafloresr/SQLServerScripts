SET NOCOUNT ON

DECLARE	@Company		Varchar(5),
		@BatchId		Varchar(25),
		@Customer		Varchar(15), 
		@ApplyFrom		Varchar(30), 
		@ApplyTo		Varchar(30), 
		@ApplyAmount	Numeric(10,2), 
		@WriteoffAmount	Numeric(10,2),
		@FromBalance	Numeric(10,2),
		@ToBalance		Numeric(10,2),
		@Note			Varchar(500),
		@RecordId		Int,
		@Query			Varchar(MAX)

DECLARE	@tblLckBoxRecs	Table (
		Company			Varchar(5),
		BatchId			Varchar(25),
		Customer		Varchar(15),
		ApplyFrom		Varchar(30),
		ApplyTo			Varchar(30),
		ApplyAmount		Numeric(10,2),
		Writeoff		Numeric(10,2),
		FromBalance		Numeric(10,2),
		ToBalance		Numeric(10,2),
		Note			Varchar(500),
		ApplyRecordId	Int)

DECLARE @tblCustomer	Table (Customer Varchar(15))
DECLARE @tblBalance		Table (Balance Numeric(10,2))

DECLARE curLockBoxBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company, BatchId
FROM	(
		SELECT	DISTINCT Company, BatchId, Integration
		FROM	PRISQL004P.Integrations.dbo.Integrations_ApplyTo
		WHERE	BatchId LIKE 'LB10%'
				AND BatchId LIKE '%102521IREC'
				AND Company IN ('GIS','GLSO','PDS')
				--AND Integration = 'CASHAR'
				AND RecordId NOT IN (SELECT ApplyRecordId FROM Lockbox_ApplyTo)
				--AND Processed = 0
		) DATA
ORDER BY 1,2

OPEN curLockBoxBatches 
FETCH FROM curLockBoxBatches INTO @Company, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	DECLARE curLockBoxRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	Company, BatchId, CustomerVendor, ApplyFrom, ApplyTo, ApplyAmount, WriteOffAmnt, RecordId
	FROM	PRISQL004P.Integrations.dbo.Integrations_ApplyTo
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND RecordId NOT IN (SELECT ApplyRecordId FROM Lockbox_ApplyTo)
	
	OPEN curLockBoxRecords 
	FETCH FROM curLockBoxRecords INTO @Company, @BatchId, @Customer, @ApplyFrom, @ApplyTo, @ApplyAmount, @WriteoffAmount, @RecordId

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Note = ''

		DELETE @tblCustomer
		DELETE @tblBalance

		SET @Query = N'SELECT CUSTNMBR FROM ' + @Company + '.dbo.RM00401 WHERE DOCNUMBR = ''' + @ApplyFrom + ''''

		INSERT INTO @tblCustomer
		EXECUTE(@Query)

		IF (SELECT COUNT(*) FROM @tblCustomer) = 0
			SET @Note = @ApplyFrom + ' does not exists'

		DELETE @tblCustomer

		SET @Query = N'SELECT CUSTNMBR FROM ' + @Company + '.dbo.RM00401 WHERE DOCNUMBR = ''' + @ApplyTo + ''''

		INSERT INTO @tblCustomer
		EXECUTE(@Query)

		IF (SELECT COUNT(*) FROM @tblCustomer) = 0
			SET @Note = IIF(@Note = '', '', ' / ') + @ApplyTo + ' does not exists'

		SET @Query = N'SELECT CURTRXAM FROM ' + @Company + '.dbo.RM20101 WHERE DOCNUMBR = ''' + @ApplyFrom + ''' UNION SELECT CURTRXAM FROM ' + @Company + '.dbo.RM30101 WHERE DOCNUMBR = ''' + @ApplyFrom + ''''

		INSERT INTO @tblBalance
		EXECUTE(@Query)

		SET @FromBalance = (SELECT Balance FROM @tblBalance)

		DELETE @tblBalance

		SET @Query = N'SELECT CURTRXAM FROM ' + @Company + '.dbo.RM20101 WHERE DOCNUMBR = ''' + @ApplyTo + ''' UNION SELECT CURTRXAM FROM ' + @Company + '.dbo.RM30101 WHERE DOCNUMBR = ''' + @ApplyTo + ''''

		INSERT INTO @tblBalance
		EXECUTE(@Query)

		SET @ToBalance = (SELECT Balance FROM @tblBalance)

		DELETE @tblCustomer

		SET @Query = N'SELECT CUSTNMBR FROM ' + @Company + '.dbo.RM20201 WHERE APFRDCNM = ''' + @ApplyFrom + ''' AND APTODCNM = ''' + @ApplyTo + ''' UNION ' 
		SET @Query =  + N'SELECT CUSTNMBR FROM ' + @Company + '.dbo.RM30201 WHERE APFRDCNM = ''' + @ApplyFrom + ''' AND APTODCNM = ''' + @ApplyTo + '''' 

		INSERT INTO @tblCustomer
		EXECUTE(@Query)

		IF (SELECT COUNT(*) FROM @tblCustomer) = 0
		BEGIN
			IF @ToBalance = 0
				SET @Note = IIF(@Note = '', '', ' / ') + @ApplyTo + ' already applied'

			INSERT INTO @tblLckBoxRecs
			SELECT @Company, @BatchId, @Customer, @ApplyFrom, @ApplyTo, @ApplyAmount, @WriteoffAmount, @FromBalance, @ToBalance, @Note, @RecordId
		END
		
		FETCH FROM curLockBoxRecords INTO @Company, @BatchId, @Customer, @ApplyFrom, @ApplyTo, @ApplyAmount, @WriteoffAmount, @RecordId
	END

	CLOSE curLockBoxRecords
	DEALLOCATE curLockBoxRecords

	FETCH FROM curLockBoxBatches INTO @Company, @BatchId
END

CLOSE curLockBoxBatches
DEALLOCATE curLockBoxBatches

INSERT INTO Lockbox_ApplyTo
		(Company,
		BatchId,
		Customer,
		ApplyFrom,
		ApplyTo,
		ApplyAmount,
		Writeoff,
		FromBalance,
		ToBalance,
		Note,
		ApplyRecordId)
SELECT	Company,
		BatchId,
		Customer,
		ApplyFrom,
		ApplyTo,
		ApplyAmount,
		Writeoff,
		FromBalance,
		ToBalance,
		Note,
		ApplyRecordId
FROM	@tblLckBoxRecs

UPDATE Lockbox_ApplyTo SET Submitted = 1 WHERE Note <> '' AND Submitted = 0

SELECT	*
FROM	Lockbox_ApplyTo
WHERE	CreatedOn > '10/28/2021'

-- EXECUTE USP_Lockbox_ApplyTo_Export

-- TRUNCATE TABLE Lockbox_ApplyTo

/*
PD-P02685 CH102621IR_01002 
*/