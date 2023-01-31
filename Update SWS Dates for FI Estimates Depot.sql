DECLARE	@Inv_No		Varchar(20),
		@Query		Varchar(MAX),
		@InvDate	Date,
		@ManDate	Date,
		@PosDate	Date
		
DECLARE curInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(InvNo) AS InvoiceNumber
FROM	FI_Oct_Estimates
WHERE	Inv_Date IS NULL

OPEN curInvoices 
FETCH FROM curInvoices INTO @Inv_No

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT InvDate, PostDate, ManifestDate FROM public.mrinv WHERE mrcompany_code = ''55'' AND InvNo = ''I' + @Inv_No + ''''
	
	EXECUTE USP_QuerySWS @Query, '##tmpInvoice'
	
	SELECT	@InvDate = InvDate,
			@ManDate = ManifestDate,
			@PosDate = PostDate
	FROM	##tmpInvoice
	
	IF @@ROWCOUNT > 0
	BEGIN
		UPDATE FI_Oct_Estimates SET Inv_Date = @InvDate, Manifest_Date = @ManDate, SWSPosting_Date = @PosDate WHERE InvNo = @Inv_No
	END
	
	DROP TABLE ##tmpInvoice
	
	FETCH FROM curInvoices INTO @Inv_No
END

CLOSE curInvoices
DEALLOCATE curInvoices