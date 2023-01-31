/*
EXECUTE USP_UpdateEstimateDates

SELECT	*
FROM	Estimates 
WHERE	Inv_Date IS not NULL
*/
ALTER PROCEDURE USP_UpdateEstimateDates
AS
DECLARE	@Inv_No		Int,
		@Query		Varchar(MAX),
		@InvDate	Date,
		@ManDate	Date

DECLARE curInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Inv_No 
FROM	Estimates 
WHERE	Inv_Date IS NULL

OPEN curInvoices 
FETCH FROM curInvoices INTO @Inv_No

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT InvDate, PostDate FROM public.mrinv WHERE mrcompany_code = ''55'' AND InvNo = ''I' + CAST(@Inv_No AS Varchar(10)) + ''''
	
	EXECUTE Integrations.dbo.USP_QuerySWS @Query, '##tmpInvoice'
	
	SELECT	@InvDate = InvDate,
			@ManDate = PostDate
	FROM	##tmpInvoice
	
	IF @@ROWCOUNT > 0
	BEGIN
		UPDATE Estimates SET Inv_Date = @InvDate, Manifest_Date = @ManDate WHERE Inv_No = @Inv_No
	END
	
	DROP TABLE ##tmpInvoice
	
	FETCH FROM curInvoices INTO @Inv_No
END

CLOSE curInvoices
DEALLOCATE curInvoices