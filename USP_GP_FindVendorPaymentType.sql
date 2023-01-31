/*
EXECUTE USP_GP_FindVendorPaymentType 'AIS','A0061'
*/
ALTER PROCEDURE USP_GP_FindVendorPaymentType
		@Company	Varchar(5),
		@VendorId	Varchar(15)
AS
DECLARE	@Query		Varchar(MAX)

DECLARE @tblData	Table (PaymentType	Varchar(30))

SET @Query = N'SELECT PYMTRMID FROM ' + @Company + '.dbo.PM00200 WHERE VENDORID = ''' + @VendorId + ''''

INSERT INTO @tblData
EXECUTE(@Query)

SELECT * FROM @tblData