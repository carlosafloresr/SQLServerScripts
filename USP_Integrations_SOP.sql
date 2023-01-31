ALTER PROCEDURE USP_Integrations_SOP
		@Integration	varchar(6),
		@Company		varchar(5),
		@BACHNUMB		varchar(15),
		@SOPTYPE		int,
		@DOCID			varchar(15),
		@SOPNUMBE		varchar(21),
		@DOCDATE		date,
		@CUSTNMBR		varchar(15),
		@DOCAMNT		numeric(12,2),
		@SUBTOTAL		numeric(12,2),
		@ITEMNMBR		varchar(30),
		@QUANTITY		numeric(12,2),
		@UNITPRICE		numeric(12,2),
		@DISTTYPE		int,
		@ACTNUMST		varchar(75),
		@DEBITAMT		numeric(12,2),
		@CRDTAMNT		numeric(12,2),
		@DistRef		varchar(30),
		@PostingDate	date,
		@IsFee			bit = 0,
		@ProNumber		varchar(15) = Null,
		@Chassis		varchar(12) = Null,
		@Container		varchar(12) = Null,
		@VendorId		varchar(15) = Null,
		@DriverId		varchar(15) = Null,
		@VendorName		varchar(200) = Null,
		@InvoiceNumber	varchar(30) = Null,
		@Reference		varchar(100) = Null,
		@InDate			date = Null,
		@OutDate		date = Null
AS
INSERT INTO dbo.Integrations_SOP
		(Integration
		,Company
		,BACHNUMB
		,SOPTYPE
		,DOCID
		,SOPNUMBE
		,DOCDATE
		,CUSTNMBR
		,DOCAMNT
		,SUBTOTAL
		,ITEMNMBR
		,QUANTITY
		,UNITPRICE
		,DISTTYPE
		,ACTNUMST
		,DEBITAMT
		,CRDTAMNT
		,DistRef
		,PostingDate
		,IsFee
		,ProNumber
		,Chassis
		,Container
		,VendorId
		,DriverId
		,VendorName
		,InvoiceNumber
		,Reference
		,InDate
		,OutDate)
VALUES
		(@Integration
		,@Company
		,@BACHNUMB
		,@SOPTYPE
		,@DOCID
		,@SOPNUMBE
		,@DOCDATE
		,@CUSTNMBR
		,@DOCAMNT
		,@SUBTOTAL
		,@ITEMNMBR
		,@QUANTITY
		,@UNITPRICE
		,@DISTTYPE
		,@ACTNUMST
		,@DEBITAMT
		,@CRDTAMNT
		,@DistRef
		,@PostingDate
		,@IsFee
		,@ProNumber
		,@Chassis
		,@Container
		,@VendorId
		,@DriverId
		,@VendorName
		,@InvoiceNumber
		,@Reference
		,@InDate
		,@OutDate)
GO


