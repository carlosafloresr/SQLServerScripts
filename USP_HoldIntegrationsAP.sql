/*
EXECUTE USP_HoldIntegrationsAP 'GIS', 'DEX140612080000'
*/
ALTER PROCEDURE USP_HoldIntegrationsAP
		@Company	Varchar(5),
		@BatchId	Varchar(25)
AS
DECLARE	@Query		Varchar(MAX),
		@VendorId	Varchar(20),
		@DocNumbr	Varchar(30),
		@Counter	Int

DECLARE @tblData	Table (VendorId Varchar(20), DocNumbr Varchar(30))

SET @Query = N'SELECT DISTINCT AP.VendorId, AP.DocNumbr FROM ILSINT02.Integrations.dbo.Integrations_AP AP
	INNER JOIN ' + RTRIM(@Company) + '.dbo.PM10000 PM ON AP.VendorId = PM.VENDORID AND AP.DocNumbr = PM.DOCNUMBR 
	WHERE AP.BatchId = ''' + @BatchId + ''' AND Hold_AP = 1'

INSERT INTO @tblData
EXECUTE(@Query)

SET @Counter = @@ROWCOUNT

IF @Counter > 0
BEGIN
	DECLARE Transactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	*
	FROM	@tblData

	OPEN Transactions 
	FETCH FROM Transactions INTO @VendorId, @DocNumbr

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Query = 'UPDATE ' + @Company + '.dbo.PM20000 SET Hold = 1 WHERE VendorId = ''' + @VendorId + ''' AND DocNumbr = ''' + @DocNumbr + ''''

		EXECUTE(@Query)

		FETCH FROM Transactions INTO @VendorId, @DocNumbr
	END

	CLOSE Transactions
	DEALLOCATE Transactions

	SELECT CAST(1 AS Bit) AS Updated
END
ELSE
	SELECT CAST(0 AS Bit) AS Updated