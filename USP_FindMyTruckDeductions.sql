ALTER PROCEDURE USP_FindMyTruckDeductions
		@Company	Varchar(5),
		@PayDate	DateTime,
		@VendorId	Varchar(12) = Null
AS
DECLARE	@ReturnDate	DateTime,
		@BatchId	Varchar(25)

IF DATENAME(weekday, @PayDate) = 'Monday'
	SET @ReturnDate = DATEADD(Day, 3, @PayDate)
ELSE
BEGIN
	IF DATENAME(weekday, @PayDate) = 'Tuesday'
		SET @ReturnDate = DATEADD(Day, 2, @PayDate)
	ELSE
	BEGIN
		IF DATENAME(weekday, @PayDate) = 'Wednesday'
			SET @ReturnDate = DATEADD(Day, 1, @PayDate)
		ELSE
		BEGIN
			IF DATENAME(weekday, @PayDate) = 'Thursday'
				SET @ReturnDate = @PayDate
			ELSE
			BEGIN
				IF DATENAME(weekday, @PayDate) = 'Friday'
					SET @ReturnDate = DATEADD(Day, -1, @PayDate)
				ELSE
				BEGIN
					IF DATENAME(weekday, @PayDate) = 'Saturday'
						SET @ReturnDate = DATEADD(Day, -2, @PayDate)
					ELSE
					BEGIN
						IF DATENAME(weekday, @PayDate) = 'Sunday'
							SET @ReturnDate = DATEADD(Day, -3, @PayDate)
					END
				END
			END
		END
	END
END

SET		@BatchId = RTRIM(@Company) + '_CSH_' + REPLACE(CONVERT(Char(10), @ReturnDate, 101), '/', '')

DELETE CashReceiptRCCL WHERE BatchId = @BatchId

INSERT INTO CashReceiptRCCL
		(Company
		,BatchId
		,VendorId
		,DriverName
		,WeekEndDate
		,Amount)
SELECT	TR.Company
		,@BatchId
		,TR.VendorId
		,dbo.GetVendorName(TR.Company, TR.VendorId) AS DriverName
		,TR.WeekEndDate
		,TR.DeductionAmount
FROM	View_OOS_Transactions TR
		INNER JOIN VendorMaster VM ON TR.Company = VM.Company AND TR.VendorId = VM.VendorId AND VM.SubType = 2
WHERE	TR.Company = @Company 
		AND TR.WeekEndDate = @ReturnDate
		AND TR.DeductionCode = 'TRK'
		AND VM.TerminationDate IS Null
		AND ((@VendorId IS Null) OR (@VendorId IS NOT Null AND TR.VendorId = @VendorId))
ORDER BY 1,3

SELECT TOP 1 Processed FROM CashReceiptRCCL WHERE BatchId = @BatchId

/*

Company,BatchId,VendorId,DriverName,WeekEndDate,Amount
TRUNCATE TABLE CashReceiptRCCL
EXECUTE USP_FindMyTruckDeductions 'AIS', '9/24/2009', Null
*/