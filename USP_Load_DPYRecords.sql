ALTER PROCEDURE USP_Load_DPYRecords
AS
DECLARE	@BatchId	Varchar(15),
		@Company	Varchar(5),
		@WEDate		Datetime

SELECT	TOP 1 @BatchId = RTRIM(Company) + '_DPY_' + dbo.FormatDateYMD(WeekEndingDate,0,1,1)
		,@Company = Company
		,@WEDate = WeekEndingDate
FROM	SWS_DPY
WHERE	Driver_Type = 'O'
		AND Processed = 0

IF NOT EXISTS(SELECT TOP 1 Company FROM Integration_APHeader WHERE BatchId = @BatchId AND Company = @Company)
BEGIN
	BEGIN TRANSACTION
	
	INSERT INTO Integration_APHeader
		(BatchId
		,Company
		,WeekEndDate
		,ReceivedOn
		,TotalDrayage
		,TotalMiles
		,TotalFuelRebate
		,TotalAccrud
		,TotalTransactions
		,TransactionType
		,Creation
		,Status
		,Division)
	SELECT	RTRIM(Company) + '_DPY_' + dbo.FormatDateYMD(WeekEndingDate,0,1,1) AS BatchId
			,Company
			,WeekEndingDate
			,RunTime
			,SUM(Driver_Total - FuelCredit_Amount) AS TotalDrayage
			,SUM(Pay_Miles) AS TotalMiles
			,SUM(FuelCredit_Amount) AS TotalFuelRebate
			,SUM(Truck_Amount) AS TotalAccrud
			,COUNT(Sws_DpyId) AS TotalTransactions
			,'DPY'
			,GETDATE()
			,2
			,MAX(Division_Code) AS Division
	FROM	SWS_DPY
	WHERE	Driver_Type = 'O'
			AND Processed = 0
			AND Company = @Company
			AND WeekEndingDate = @WEDate
	GROUP BY
			Company
			,WeekEndingDate
			,RunTime

	IF @@ERROR = 0
	BEGIN
		INSERT INTO Integration_APDetails
				(BatchId
			   ,VendorId
			   ,DriverId
			   ,Drayage
			   ,Miles
			   ,DriverFuelRebate
			   ,Accrud
			   ,Verification
			   ,Processed)
		SELECT	RTRIM(Company) + '_DPY_' + dbo.FormatDateYMD(WeekEndingDate,0,1,1) AS BatchId
				,Driver_Code
				,Driver_Code
				,Driver_Total - FuelCredit_Amount
				,Pay_Miles
				,FuelCredit_Amount
				,Truck_Amount
				,''
				,1
		FROM	SWS_DPY
		WHERE	Driver_Type = 'O'
				AND Processed = 0
				AND Company = @cOMPANY
				AND WeekEndingDate = @WEDate

		IF @@ERROR = 0
		BEGIN
			COMMIT TRANSACTION
			RETURN 1
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			RETURN 0
		END
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END

/*
UPDATE SWS_DPY SET Processed = 2 WHERE WeekEndingDate < '2008-10-04'

DELETE SWS_DPY WHERE Runtime = '2008-10-09 08:48:00.000' AND Company = 'IMC'

EXECUTE USP_Load_DPYRecords
*/