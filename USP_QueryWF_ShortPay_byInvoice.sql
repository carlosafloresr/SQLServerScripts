/*
EXECUTE USP_QueryWF_ShortPay_byInvoice 'IMC', '10-109596'
*/
ALTER PROCEDURE USP_QueryWF_ShortPay_byInvoice
	@Company	Varchar(5),
	@DocNumber	Varchar(30)
AS
EXECUTE LENSASQL002.Tributary.dbo.usp_QueryWF_ShortPay_byInvoice @DocNumber, @Company
GO