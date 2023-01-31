DECLARE	@Query				Varchar(MAX),
		@DocumentId			Int,
		@Document			Varchar(250),
		@DoesFileExists		Bit

DECLARE @tblERData			Table (
		ExpenseRecoveryId	Int,
		Company				Varchar(5),
		DocNumber			Varchar(30),
		Vendor				Varchar(100),
		Amount				numeric(12,2), 
		VendorId			Varchar(15))

INSERT INTO @tblERData
SELECT	ExpenseRecoveryId,
		Company,
		DocNumber,
		Vendor,
		Amount, 
		VendorId
FROM	View_ExpenseRecovery
WHERE	VoucherNo LIKE 'IDV%'
		AND InvDate > '01/10/2022'
		AND Closed = 0
		AND Attachments > 0

/*
SELECT	ERY.*,
		DOC.DocumentFile,
		DOC.DocumentId
FROM	@tblERData ERY
		LEFT JOIN LENSASQL002.ILS_Documents.dbo.View_Documents DOC ON DOC.CategoryId = 6 AND ERY.Company = DOC.Company AND ERY.DocNumber = DOC.RecordId
*/

DECLARE curEXRData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DOC.DocumentId, DOC.DocumentFile
FROM	@tblERData ERY
		LEFT JOIN LENSASQL002.ILS_Documents.dbo.View_Documents DOC ON DOC.CategoryId = 6 AND ERY.Company = DOC.Company AND ERY.DocNumber = DOC.RecordId

OPEN curEXRData 
FETCH FROM curEXRData INTO @DocumentId, @Document

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @DoesFileExists = dbo.CheckIfFileExists(@Document)

	IF @DoesFileExists = 0
	BEGIN
		PRINT @Document + ' Exists: ' + IIF(@DoesFileExists = 1, 'Y', 'N')

		DELETE LENSASQL002.ILS_Documents.dbo.Documents WHERE DocumentId = @DocumentId
	END

	FETCH FROM curEXRData INTO @DocumentId, @Document
END

CLOSE curEXRData
DEALLOCATE curEXRData