alter FUNCTION CashReceiptStatus (@Status Int)
RETURNS Varchar(30)
AS
BEGIN
	DECLARE @ReturnValue	Varchar(30)
	SET		@ReturnValue =	CASE	WHEN @Status = 1 THEN '1 - Unmatched in FI'
									WHEN @Status = 2 THEN '2 - Unmatched in GP'
									WHEN @Status = 3 THEN '3 - Already Paid'
									WHEN @Status = 4 THEN '4 - Matched'
									WHEN @Status = 5 THEN '5 - Overpaid'
									WHEN @Status = 6 THEN '6 - Underpaid'
									WHEN @Status = 7 THEN '7 - Write-off'
									WHEN @Status = 8 THEN '8 - Other Customer'
									ELSE Null END
	RETURN @ReturnValue
END