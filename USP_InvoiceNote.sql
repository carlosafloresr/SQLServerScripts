/*
EXECUTE USP_InvoiceNote 'AIS', '12-58084-A', 'EBE Short Pay Note', 'This is a test!'
*/
CREATE PROCEDURE USP_InvoiceNote
		@CompanyId		Varchar(5),
		@InvoiceNum		Varchar(25),
		@Subject		Varchar(100),
		@Note			Varchar(2000)
AS
DECLARE	@InvoiceId		Int,
		@EnterpriseId	Int,
		@NoteId			Int

SELECT	@EnterpriseId = EnterpriseId
FROM	CS_Enterprise
WHERE	EnterpriseNumber = @CompanyId

SELECT	@InvoiceId = InvoiceId
FROM	CS_Invoice
WHERE	EnterpriseId = @EnterpriseId
		AND InvoiceNum = @InvoiceNum

INSERT INTO CS_Note 
		(Subject, 
		Text, 
		Date, 
		UserId)
VALUES	
		(@Subject,
		@Note,
		GETDATE(),
		2)

IF @@ERROR = 0
BEGIN
	SET @NoteId = @@IDENTITY

	INSERT INTO CS_InvoiceNote (NoteId, InvoiceId) VALUES (@NoteId, @InvoiceId)
END
