/*
EXECUTE USP_FindKarmakSalesOrders '10/21/2009', '5601', '5629'
*/

ALTER PROCEDURE USP_FindKarmakSalesOrders
		@WeekEndDate	DateTime,
		@Range1			Varchar(10),
		@Range2			Varchar(10)
AS
DECLARE	@WEndDate		DateTime,
		@BatchId		Varchar(25)

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

SET		@BatchId = 'KARMAK_' + CAST(YEAR(@WeekEndDate) AS Char(4)) + '_W' + RTRIM(CAST(DATEPART(week, @WEndDate) AS Varchar(2)))

DELETE	KarmakIntegration WHERE BatchId = @BatchId

INSERT INTO KarmakIntegration
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
		Fees_Price, 
		OrderTax, 
		InvoiceTotal, 
		Labor + Tires_Price + Parts_Price + Shop_Price + Fees_Price + OrderTax + Misc_Price + Fuel_Price AS Total,
		0 AS Processed
FROM	[RCCLSRV01\SQLEXPRESS].ILS_Data.dbo.View_SalesOrders 
WHERE	InvoiceTotal <> 0 
		AND Voided = 0 
		AND InvoiceNumber BETWEEN @Range1 AND @Range2

SELECT * FROM KarmakIntegration WHERE BatchId = @BatchId ORDER BY InvoiceNumber