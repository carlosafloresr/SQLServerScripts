/*
EXECUTE USP_CollectionsManagerNotesInsert 'ATEST', '8400E', '6-107377', GETDATE(), 'This is a test!', 'CLOSED SHORT PAY', 'EBE TEST'
*/
CREATE PROCEDURE USP_CollectionsManagerNotesInsert
		@Company		Varchar(5),
		@CustomerNumber	Varchar(15),
		@DocumentNumber	Varchar(30),
		@NoteDate		Datetime,
		@NoteText		Varchar(2000),
		@Action			Varchar(17),
		@UserId			Varchar(15)
AS
DECLARE	@NoteIndex		Int,
		@RevisionNumber	Int

DELETE	GPCustom.dbo.GPCollectionsNotes
WHERE	Company = @Company
		AND CustNmbr = @CustomerNumber
		AND DocNumbr = @DocumentNumber

SELECT	@NoteIndex = MAX(NOTEINDX) + 1
FROM	DYNAMICS.dbo.SY01500
WHERE	INTERID = @Company

INSERT INTO GPCustom.dbo.GPCollectionsNotes
SELECT	RTRIM(@Company) AS Company,
		CUSTNMBR,
		CPRCSTNM,
		RMDTYPAL,
		DOCNUMBR,
		@NoteIndex AS NoteIndx,
		1 AS ActionType,
		ORTRXAMT AS ActionAmount,
		CURTRXAM,
		ADRSCODE,
		CONVERT(Varchar(10), @NoteDate, 101) AS Date1,
		CAST('01/01/1900 ' + CONVERT(Varchar(8), @NoteDate, 108) AS Datetime) AS Time1,
		RTRIM(@NoteText) AS NoteString,
		RTRIM(@UserId) AS UserId
FROM	RM20101
WHERE	CUSTNMBR = RTRIM(@CustomerNumber)
		AND DOCNUMBR = RTRIM(@DocumentNumber)

BEGIN TRANSACTION

INSERT INTO CN00100 (CUSTNMBR, CPRCSTNM, DATE1, TIME1, Contact_Date, Contact_Time, NOTEINDX, Note_Display_String, USERID, Action_Promised, ActionType, PRIORT, RevisionNumber, ADRSCODE)
	SELECT	CUSTNMBR, CPRCSTNM, DATE1, TIME1, DATE1, TIME1, NOTEINDX, RTRIM(LEFT(NoteString, 70)), UserId, UPPER(@Action), 1, 2, 1, AdrsCode
	FROM	GPCustom.dbo.GPCollectionsNotes 
	WHERE	Company = RTRIM(@Company)
			AND CUSTNMBR = RTRIM(@CustomerNumber)
			AND DOCNUMBR = RTRIM(@DocumentNumber)

INSERT INTO CN00300 (NOTEINDX, TXTFIELD)
	SELECT	NOTEINDX, NoteString
	FROM	GPCustom.dbo.GPCollectionsNotes 
	WHERE	Company = RTRIM(@Company)
			AND CUSTNMBR = RTRIM(@CustomerNumber)
			AND DOCNUMBR = RTRIM(@DocumentNumber)

IF @@ERROR = 0
BEGIN
	UPDATE	DYNAMICS.dbo.SY01500
	SET		NOTEINDX = @NoteIndex
	WHERE	INTERID = @Company

	COMMIT TRANSACTION
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
END

GO