DECLARE	@HeaderId	Int = 23

DECLARE	@Company		varchar(5),
		@VendorId		varchar(20),
		@VendorName		varchar(50),
		@File_Invoice	varchar(30),
		@File_InvDate	date,
		@File_Container	varchar(50),
		@File_Reference	varchar(50),
		@File_Amount	numeric(12, 2),
		@Invoice		varchar(35),
		@InvDate		date,
		@Amount			numeric(12, 2),
		@Balance		numeric(12, 2),
		@Inv_Difference	numeric(12, 2),
		@Container		varchar(25),
		@Reference		varchar(50),
		@DataSource		varchar(50),
		@DataStatus		varchar(70),
		@KeyField		varchar(70),
		@DocType		varchar(12),
		@DocumentNumber	varchar(30),
		@Applied_Paid	numeric(10,2),
		@PostingDate	date

DECLARE	@tblDetails Table
		(DocType	Varchar(15) Null,
		Document	Varchar(30) Null,
		Applied		Numeric(10,2) Null,
		DatePosted	Date Null)

DECLARE	@tblResult Table (
		Company			varchar(5) NOT NULL,
		VendorId		varchar(20) NOT NULL,
		VendorName		varchar(50) NOT NULL,
		File_Invoice	varchar(30) NULL,
		File_InvDate	date NULL,
		File_Container	varchar(50) NULL,
		File_Reference	varchar(50) NULL,
		File_Amount		numeric(12, 2) NOT NULL,
		Invoice			varchar(35) NULL,
		InvDate			date NULL,
		Amount			numeric(12, 2) NULL,
		Balance			numeric(12, 2) NULL,
		Inv_Difference	numeric(12, 2) NOT NULL,
		Container		varchar(25) NULL,
		Reference		varchar(50) NULL,
		DataSource		varchar(50) NULL,
		DataStatus		varchar(70) NULL,
		KeyField		varchar(70) NULL,
		DocType			varchar(12) NULL,
		DocumentNumber	varchar(30) NULL,
		Applied_Paid	numeric(10,2) NULL,
		PostingDate		date NULL)

INSERT INTO @tblResult
SELECT	Company
		,VendorId
		,VendorName
		,File_Invoice
		,File_InvDate
		,File_Container
		,ISNULL(File_Reference,'') AS File_Reference
		,File_Amount
		,Invoice AS Sys_Invoice
		,InvDate AS Sys_InvDate
		,Amount AS Sys_Amount
		,Balance AS Sys_Balance
		,Inv_Difference
		,ISNULL(Container,'') AS Container
		,ISNULL(Reference,'') AS Reference
		,ISNULL(DataSource,'') AS DataSource
		,DataStatus
		,KeyField
		,Null
		,Null
		,Null
		,Null
FROM	VendorInvoiceStatusResult
WHERE	HeaderId = @HeaderId
		AND KeyField IS Null
ORDER BY
		File_InvDate,
		File_Invoice

DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company
		,VendorId
		,VendorName
		,File_Invoice
		,File_InvDate
		,File_Container
		,ISNULL(File_Reference,'') AS File_Reference
		,File_Amount
		,Invoice AS Sys_Invoice
		,InvDate AS Sys_InvDate
		,Amount AS Sys_Amount
		,Balance AS Sys_Balance
		,Inv_Difference
		,ISNULL(Container,'') AS Container
		,ISNULL(Reference,'') AS Reference
		,ISNULL(DataSource,'') AS DataSource
		,DataStatus
		,KeyField
FROM	VendorInvoiceStatusResult
WHERE	HeaderId = @HeaderId
		AND KeyField IS NOT Null
ORDER BY
		File_InvDate,
		File_Invoice

OPEN curTransactions 
FETCH FROM curTransactions INTO @Company, @VendorId, @VendorName, @File_Invoice, @File_InvDate, @File_Container,
								@File_Reference, @File_Amount, @Invoice, @InvDate, @Amount, @Balance, @Inv_Difference,
								@Container, @Reference, @DataSource, @DataStatus, @KeyField

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblDetails

	INSERT INTO @tblDetails
	EXECUTE USP_VendorInvoiceStatus_Details @KeyField

	INSERT INTO @tblResult
	SELECT	Company
			,VendorId
			,VendorName
			,File_Invoice
			,File_InvDate
			,File_Container
			,ISNULL(File_Reference,'') AS File_Reference
			,File_Amount
			,Invoice AS Sys_Invoice
			,InvDate AS Sys_InvDate
			,Amount AS Sys_Amount
			,Balance AS Sys_Balance
			,Inv_Difference
			,ISNULL(Container,'') AS Container
			,ISNULL(Reference,'') AS Reference
			,ISNULL(DataSource,'') AS DataSource
			,DataStatus
			,KeyField
			,DET.DocType
			,DET.Document
			,DET.Applied
			,DET.DatePosted
	FROM	VendorInvoiceStatusResult VIS
			LEFT JOIN @tblDetails DET ON DET.DocType IS NOT NULL
	WHERE	VIS.HeaderId = @HeaderId
			AND VIS.KeyField = @KeyField

	FETCH FROM curTransactions INTO @Company, @VendorId, @VendorName, @File_Invoice, @File_InvDate, @File_Container,
									@File_Reference, @File_Amount, @Invoice, @InvDate, @Amount, @Balance, @Inv_Difference,
									@Container, @Reference, @DataSource, @DataStatus, @KeyField
END

CLOSE curTransactions
DEALLOCATE curTransactions

SELECT	Company
		,VendorId
		,VendorName
		,File_Invoice
		,File_InvDate
		,File_Container
		,File_Reference
		,File_Amount
		,Invoice
		,InvDate
		,Amount
		,Balance
		,Inv_Difference
		,Container
		,Reference
		,DataSource
		,DataStatus
		,KeyField
		,ISNULL(DocType,'') AS DocType
		,ISNULL(DocumentNumber, '') AS DocumentNumber
		,ISNULL(CAST(Applied_Paid AS Varchar), '') AS Applied_Paid
		,ISNULL(CAST(PostingDate AS Varchar), '') AS PostingDate
FROM	@tblResult
ORDER BY
		File_InvDate,
		File_Invoice