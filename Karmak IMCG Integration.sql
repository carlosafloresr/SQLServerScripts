DECLARE	@WeekEndDate	DateTime,
		@Range1			Varchar(10),
		@Range2			Varchar(10),
		@BatchId		Varchar(25)

DECLARE	@WEndDate		DateTime

SET		@WeekEndDate	= '11/10/2009'
SET		@Range1			= '5795'
SET		@Range2			= '5799'

IF DATENAME(weekday, @WeekEndDate) = 'Saturday'
	SET @WEndDate = @WeekEndDate
ELSE
BEGIN
	IF DATENAME(weekday, @WeekEndDate) = 'Monday'
		SET @WEndDate = DATEADD(Day, 5, @WeekEndDate)
	ELSE
	BEGIN
		IF DATENAME(weekday, @WeekEndDate) = 'Tuesday'
			SET @WEndDate = DATEADD(Day, 4, @WeekEndDate)
		ELSE
		BEGIN
			IF DATENAME(weekday, @WeekEndDate) = 'Wednesday'
				SET @WEndDate = DATEADD(Day, 3, @WeekEndDate)
			ELSE
			BEGIN
				IF DATENAME(weekday, @WeekEndDate) = 'Thursday'
					SET @WEndDate = DATEADD(Day, 2, @WeekEndDate)
				ELSE
				BEGIN
					IF DATENAME(weekday, @WeekEndDate) = 'Friday'
						SET @WEndDate = DATEADD(Day, 1, @WeekEndDate)
					ELSE
					BEGIN
						IF DATENAME(weekday, @WeekEndDate) = 'Sunday'
							SET @WEndDate = DATEADD(Day, 6, @WeekEndDate)
					END
				END
			END
		END
	END
END

--DELETE	KarmakIntegration WHERE BatchId = @BatchId

--INSERT INTO KarmakIntegration
SELECT	@BatchId AS BatchId,
		@WEndDate AS WeekEndDate,
		InvoiceNumber, 
		InvoicedDate, 
		CustomerNumber, 
		UnitNumber, 
		Labor, 
		Fuel_Price, 
		Tires_Price, 
		Misc_Price, 
		Parts_Price, 
		Shop_Price, 

		CASE WHEN Misc_Price + Tires_Price + Shop_Price + Fuel_Price <> 0 THEN 0 ELSE Fees_Price_All END AS Fees_Price,
		OrderTax, 
		InvoiceTotal, 
		Labor + Tires_Price + Parts_Price + Shop_Price + Fees_Price + OrderTax + Misc_Price + Fuel_Price AS Total,
		0 AS Processed
FROM	[RCCLSRV01\SQLEXPRESS].ILS_Data.dbo.View_SalesOrders 
WHERE	InvoiceTotal <> 0 
		AND Voided = 0 
		AND InvoiceNumber BETWEEN @Range1 AND @Range2

--SELECT * FROM KarmakIntegration WHERE BatchId = @BatchId ORDER BY InvoiceNumber