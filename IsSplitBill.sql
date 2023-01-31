CREATE FUNCTION IsSplitBill (@InvoiceNumber Varchar(25))
RETURNS Bit
BEGIN
	DECLARE @ReturnValue Bit = 0

	SET @ReturnValue =	CASE WHEN @InvoiceNumber LIKE '%-A%' THEN 1
							 WHEN @InvoiceNumber LIKE '%-B%' THEN 1
							 WHEN @InvoiceNumber LIKE '%-C%' THEN 1
							 WHEN @InvoiceNumber LIKE '%-D%' THEN 1
							 WHEN @InvoiceNumber LIKE '%-E%' THEN 1
						ELSE 0 END

	RETURN @ReturnValue
END