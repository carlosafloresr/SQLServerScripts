CREATE VIEW View_VendorInvoiceStatus
AS
SELECT	HDR.VendorInvoiceStatusHdrId
		,HDR.Company
		,HDR.VendorId
		,HDR.VendorName
		,HDR.FileName
		,HDR.UploadedOn
		,DET.VendorInvoiceStatusDetId
		,DET.InvoiceNumber
		,DET.InvoiceDate
		,DET.ContainerNumber
		,DET.Reference
		,DET.Amount
FROM	VendorInvoiceStatusHdr HDR
		INNER JOIN VendorInvoiceStatusDet DET ON HDR.VendorInvoiceStatusHdrId = DET.VendorInvoiceStatusHdrId