USE GPCustom
GO

CREATE PROCEDURE USP_VendorInvoiceStatusHdr
		@Company	varchar(5),
		@VendorId	varchar(20),
		@VendorName	varchar(50),
		@FileName	varchar(50),
		@UploadedOn	datetime
AS
INSERT INTO dbo.VendorInvoiceStatusHdr
		(Company
		,VendorId
		,VendorName
		,FileName
		,UploadedOn)
VALUES
		(@Company
		,@VendorId
		,@VendorName
		,@FileName
		,@UploadedOn)

IF @@ERROR = 0
	RETURN @@IDENTITY
ELSE
	RETURN 0

GO


