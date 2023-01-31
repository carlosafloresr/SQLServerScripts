/*
EXECUTE USP_Update_FIResults
*/

ALTER PROCEDURE USP_Update_FIResults
AS
DECLARE	@Inv_No				Varchar(20),
		@Query				Varchar(MAX),
		@SWS_Hours			Numeric(12,2),
		@SWS_Labor			Numeric(12,2),
		@SWS_Parts			Numeric(12,2),
		@SWS_Tax			Numeric(12,2),
		@SWS_Total			Numeric(12,2),
		@SWSInv_Date		Date,
		@SWSManifets_Date	Date,
		@SWSPosting_Date	Date
		
DECLARE curInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT RTRIM(CAST(INV_NO AS Varchar(10))) AS InvoiceNumber
FROM	Results
WHERE	SWSInv_Date IS NULL

OPEN curInvoices
FETCH FROM curInvoices INTO @Inv_No

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT LaborHours, Labor, Parts, SalesTax, InvTotal, InvDate, PostDate, WeekEnding FROM public.mrinv WHERE InvNo = ''I' + @Inv_No + ''' AND mrcompany_code = ''55'''
	
	EXECUTE Integrations.dbo.USP_QuerySWS @Query, '##tmpInvoice'
	
	SELECT	@SWS_Hours			= LaborHours,
			@SWS_Labor			= Labor,
			@SWS_Parts			= Parts,
			@SWS_Tax			= SalesTax,
			@SWS_Total			= InvTotal,
			@SWSInv_Date		= InvDate,
			@SWSManifets_Date	= WeekEnding,
			@SWSPosting_Date	= PostDate
	FROM	##tmpInvoice
	
	IF @@ROWCOUNT > 0
	BEGIN
		UPDATE	Results 
		SET		SWS_Hours			= @SWS_Hours,
				SWS_Labor			= @SWS_Labor,
				SWS_Parts			= @SWS_Parts,
				SWS_Tax				= @SWS_Tax,
				SWS_Total			= @SWS_Total,
				SWSInv_Date			= @SWSInv_Date, 
				SWSManifets_Date	= @SWSManifets_Date, 
				SWSPosting_Date		= @SWSPosting_Date 
		WHERE	INV_NO				= @Inv_No
	END
	
	DROP TABLE ##tmpInvoice
	
	FETCH FROM curInvoices INTO @Inv_No
END

CLOSE curInvoices
DEALLOCATE curInvoices