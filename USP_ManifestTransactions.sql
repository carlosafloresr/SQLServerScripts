USE [Manifest]
GO
/****** Object:  StoredProcedure [dbo].[USP_ManifestTransactions]    Script Date: 1/14/2015 1:42:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ManifestTransactions
	@ManifestTypeId = 1
	,@Company = 'FI'
	,@Location = 'TN'
	,@TransactionDate = '11/13/2014'
	,@EffectiveDate = Null
	,@CustomerNumber = '125'
	,@DocumentNumber = '235'
	,@ReferenceNumber = 'A125'
	,@TransactionType = 'EST'
	,@Amount = 2525.15
*/
ALTER PROCEDURE [dbo].[USP_ManifestTransactions]
		@ManifestTypeId			int,
		@Company				varchar(5),
		@Location				varchar(25) = Null,
		@TransactionDate		datetime,
		@EffectiveDate			date = Null,
		@CustomerNumber			varchar(25),
		@DocumentNumber			varchar(30),
		@ReferenceNumber		varchar(30) = Null,
		@TransactionType		varchar(3),
		@Amount					numeric(12,2)
AS
BEGIN
	DECLARE	@Fk_TransactionTypeId	int,
			@WeekendingDay			varchar(10),
			@WeekendingDate			date,
			@OldRecordAmount		numeric(12,2),
			@OldRecordId			bigint = Null,
			@NewRecordId			bigint,
			@WeekPeriod				char(7),
			@MonthPeriod			char(7),
			@DataGroupId			int,
			@DataGroup				varchar(25)

	-- Retrieve the Weekending Day of the week for the Manifest Type
	SELECT	@WeekendingDay = RTRIM(WeekendingDay)
	FROM	ManifestTypes
	WHERE	ManifestTypeId = @ManifestTypeId

	-- Retrieve the identity value of the related Amount Type
	SELECT	@Fk_TransactionTypeId	= TransactionTypeId,
			@DataGroupId		= Fk_DataGroupId
	FROM	TransactionTypes
	WHERE	Fk_ManifestTypeId = @ManifestTypeId
			AND [Type] = @TransactionType

	-- Retrieve the Data Group related to the transactio type received to see if this affect previous transactions
	SELECT	@DataGroup = GroupCode
	FROM	DataGroups
	WHERE	Fk_ManifestTypeId = @ManifestTypeId
			AND DataGroupId = @DataGroupId

	-- Define the correct Weekending Date according with the defined day of the week
	IF @EffectiveDate IS NOT Null
		SET @WeekendingDate = CAST(CASE WHEN DATENAME(Weekday, @EffectiveDate) = @WeekendingDay THEN @EffectiveDate ELSE dbo.DayFwdBack(@EffectiveDate, 'N', @WeekendingDay) END AS Date)

	IF @WeekendingDate IS NOT Null
	BEGIN
		SET @WeekPeriod		= CAST(YEAR(@WeekendingDate) AS Varchar) + '-' + dbo.PADL(dbo.WeekNumber(@WeekendingDate), 2, '0')
		SET @MonthPeriod	= dbo.GetFiscalMonth(@WeekendingDate)
	END

	-- Check if the current document number already exists
	SELECT	@OldRecordId		= TransactionId,
			@OldRecordAmount	= Amount
	FROM	Transactions
	WHERE	Fk_ManifestTypeId = @ManifestTypeId
			AND Company = @Company
			AND Location = @Location
			AND CustomerNumber = @CustomerNumber
			AND DocumentNumber = @DocumentNumber
			AND CurrentRecord = 1
			AND @DataGroup IN ('PRE-INVOICE','INVOICE')

	BEGIN TRANSACTION

	INSERT INTO Transactions
				(Fk_ManifestTypeId
				,Company
				,Location
				,WeekendingDate
				,TransactionDate
				,EffectiveDate
				,[Week]
				,[FiscalMonth]
				,CustomerNumber
				,DocumentNumber
				,ReferenceNumber
				,Amount
				,Fk_TransactionTypeId)
	VALUES
				(@ManifestTypeId
				,@Company
				,@Location
				,@WeekendingDate
				,@TransactionDate
				,@EffectiveDate
				,@WeekPeriod
				,@MonthPeriod
				,@CustomerNumber
				,@DocumentNumber
				,@ReferenceNumber
				,@Amount
				,@Fk_TransactionTypeId)

	SET @NewRecordId = @@IDENTITY

	IF @OldRecordId IS NOT Null
	BEGIN
		INSERT INTO Transactions
				(Fk_ManifestTypeId
				,Company
				,Location
				,WeekendingDate
				,TransactionDate
				,EffectiveDate
				,[Week]
				,[FiscalMonth]
				,CustomerNumber
				,DocumentNumber
				,ReferenceNumber
				,Amount
				,Fk_TransactionTypeId
				,CurrentRecord
				,RelatedRecord)
		SELECT	Fk_ManifestTypeId
				,Company
				,Location
				,@WeekendingDate
				,TransactionDate
				,@EffectiveDate
				,@WeekPeriod
				,@MonthPeriod
				,CustomerNumber
				,DocumentNumber
				,ReferenceNumber
				,Amount * -1
				,Fk_TransactionTypeId
				,0
				,@NewRecordId
		FROM	Transactions
		WHERE	TransactionId = @OldRecordId
	END

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END
END