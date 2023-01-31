CREATE PROCEDURE USP_InsertExpiredOpenEstimateCredits
AS
DECLARE	@TransactionId			bigint,
		@Fk_ManifestTypeId		int,
		@Fk_TransactionTypeId	int,
		@Company				varchar(5),
		@Location				varchar(25),
		@TransactionDate		datetime = GETDATE(),
		@EffectiveDate			date = CAST(GETDATE() AS date),
		@WeekEndingDate			date,
		@CustomerNumber			varchar(25),
		@DocumentNumber			varchar(30),
		@ReferenceNumber		varchar(30),
		@Amount					numeric(12,2),
		@CreatedOn				datetime,
		@CurrentRecord			bit,
		@RelatedRecord			bigint,
		@ManifestTypeId			int,
		@WeekendingDay			varchar(10),
		@WeekPeriod				char(7),
		@MonthPeriod			char(7)

DECLARE CurTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	TransactionId
		,Fk_ManifestTypeId
		,Fk_TransactionTypeId
		,Company
		,Location
		,EffectiveDate
		,WeekEndingDate
		,CustomerNumber
		,DocumentNumber
		,ReferenceNumber
		,Amount * -1 AS Amount
		,CreatedOn
		,CurrentRecord
		,RelatedRecord
FROM	Transactions
WHERE	Fk_TransactionTypeId = 2
		AND DATEDIFF(dd, TransactionDate, @EffectiveDate) = 90

SET @WeekendingDate = CAST(CASE WHEN DATENAME(Weekday, @EffectiveDate) = @WeekendingDay THEN @EffectiveDate ELSE dbo.DayFwdBack(@EffectiveDate, 'N', @WeekendingDay) END AS Date)
SET @WeekPeriod		= CAST(YEAR(@WeekendingDate) AS Varchar) + '-' + dbo.PADL(dbo.WeekNumber(@WeekendingDate), 2, '0')
SET @MonthPeriod	= dbo.GetFiscalMonth(@WeekendingDate)

OPEN CurTransactions 
FETCH FROM CurTransactions INTO @TransactionId, @Fk_ManifestTypeId, @Fk_TransactionTypeId, @Company, @Location, @EffectiveDate, 
								@WeekEndingDate, @CustomerNumber, @DocumentNumber, @ReferenceNumber,
								@Amount, @CreatedOn, @CurrentRecord, @RelatedRecord

WHILE @@FETCH_STATUS = 0 
BEGIN
	BEGIN TRANSACTION

	INSERT INTO dbo.Transactions
			   (Fk_ManifestTypeId
			   ,Fk_TransactionTypeId
			   ,Company
			   ,Location
			   ,TransactionDate
			   ,EffectiveDate
			   ,WeekEndingDate
			   ,Week
			   ,FiscalMonth
			   ,CustomerNumber
			   ,DocumentNumber
			   ,ReferenceNumber
			   ,Amount
			   ,CreatedOn
			   ,CurrentRecord
			   ,RelatedRecord)
		 VALUES
			   (@Fk_ManifestTypeId
			   ,@Fk_TransactionTypeId
			   ,@Company
			   ,@Location
			   ,@TransactionDate
			   ,@EffectiveDate
			   ,@WeekEndingDate
			   ,@WeekPeriod
			   ,@MonthPeriod
			   ,@CustomerNumber
			   ,@DocumentNumber
			   ,@ReferenceNumber
			   ,@Amount
			   ,@CreatedOn
			   ,1
			   ,@TransactionId)

	IF @@ERROR = 0
	BEGIN
		UPDATE	Transactions
		SET		CurrentRecord = 0
		WHERE	TransactionId = @TransactionId

		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END

	FETCH FROM CurTransactions INTO @TransactionId, @Fk_ManifestTypeId, @Fk_TransactionTypeId, @Company, @Location, @EffectiveDate, 
									@WeekEndingDate, @CustomerNumber, @DocumentNumber, @ReferenceNumber,
									@Amount, @CreatedOn, @CurrentRecord, @RelatedRecord
END

CLOSE CurTransactions
DEALLOCATE CurTransactions


