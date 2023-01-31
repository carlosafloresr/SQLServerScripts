/*
PRINT dbo.FindSalesInvoiceContainers('DNJ','96-00392')
-- IN ('96-00382','96-00383','96-00392')
*/
ALTER FUNCTION dbo.FindSalesInvoiceContainers (@Company Varchar(5), @InvoiceNumber Varchar(30))
RETURNS	Varchar(200)
AS
BEGIN
	DECLARE	@Container		Varchar(20),
			@ReturnValue	Varchar(200)
			
	SET		@ReturnValue	= ''
	
	DECLARE Containers CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	TrailerNumber
	FROM	SalesInvoices
	WHERE	InvoiceNumber = @InvoiceNumber
	
	OPEN Containers 
	FETCH FROM Containers INTO @Container

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @ReturnValue = @ReturnValue + CASE WHEN @ReturnValue = '' THEN '' ELSE ',' END + RTRIM(@Container)
		
		FETCH FROM Containers INTO @Container
	END
	
	CLOSE Containers
	DEALLOCATE Containers
	
	RETURN @ReturnValue
END