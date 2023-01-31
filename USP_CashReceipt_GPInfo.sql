/*
EXECUTE USP_CashReceipt_GPInfo ' GIS', '31-130891'
*/
ALTER PROCEDURE USP_CashReceipt_GPInfo
		@Company		Varchar(5),
		@InvoiceNumber	Varchar(25)
AS
DECLARE	@Query			Varchar(Max)
DECLARE	@tblData		Table (CustomerId Varchar(15), Description Varchar(35), DocumentAmount Numeric(10,2), DocumentBalance Numeric(10,2))

SET @Query = N'SELECT RTRIM(CUSTNMBR), TRXDSCRN, ORTRXAMT, CURTRXAM FROM ' + RTRIM(@Company) + '.dbo.RM20101 WHERE DOCNUMBR = ''' + RTRIM(@InvoiceNumber) + ''' 
			UNION
			SELECT RTRIM(CUSTNMBR), TRXDSCRN, ORTRXAMT, CURTRXAM FROM ' + RTRIM(@Company) + '.dbo.RM30101 WHERE DOCNUMBR = ''' + RTRIM(@InvoiceNumber) + ''''

INSERT INTO @tblData
EXECUTE(@Query)

SELECT	*
FROM	@tblData