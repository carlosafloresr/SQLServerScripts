USE GPCustom
GO

CREATE PROCEDURE USP_VendorInvoiceStatusDet
		@VendorInvoiceStatusHdrId	int,
		@InvoiceNumber				varchar(30) = Null,
		@InvoiceDate				date = Null,
		@ContainerNumber			varchar(15) = Null,
		@Reference					varchar(30) = Null,
		@Amount						numeric(10,2)
AS
INSERT INTO dbo.VendorInvoiceStatusDet
		(VendorInvoiceStatusHdrId
		,InvoiceNumber
		,InvoiceDate
		,ContainerNumber
		,Reference
		,Amount)
VALUES
		(@VendorInvoiceStatusHdrId
		,@InvoiceNumber
		,@InvoiceDate
		,@ContainerNumber
		,@Reference
		,@Amount)
GO


