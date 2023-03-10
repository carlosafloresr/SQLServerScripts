USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_InsertCollectionsNote]    Script Date: 12/20/2016 3:54:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_InsertCollectionsNote 'ATEST', '8400E', '6-107377', '10/31/2014 10:15:00 AM', 'This is a test!', 'CLOSED SHORT PAY', 'EBE TEST'
*/
ALTER PROCEDURE [dbo].[USP_InsertCollectionsNote]
		@Company		Varchar(5),
		@CustomerNumber	Varchar(15),
		@DocumentNumber	Varchar(30),
		@NoteDate		Datetime,
		@NoteText		Varchar(2000),
		@Action			Varchar(17),
		@UserId			Varchar(15)
AS
DECLARE	@Query			Varchar(Max)

SET		@Query = N'EXECUTE ' + RTRIM(@Company) + '.dbo.USP_CollectionsManagerNotesInsert ''' + RTRIM(@Company) + ''','''
					+ RTRIM(@CustomerNumber) + ''','''
					+ RTRIM(@DocumentNumber) + ''','''
					+ CAST(@NoteDate AS Varchar) + ''','''
					+ RTRIM(@NoteText) + ''','''
					+ RTRIM(@Action) + ''','''
					+ RTRIM(@UserId) + ''''

EXECUTE(@Query)

IF @@ERROR = 0
BEGIN
	PRINT 'Insert note on Collect-IT'

	SET @NoteText = 'Entered by ' + UPPER(RTRIM(@UserId)) + CHAR(13) + CHAR(10) + @NoteText

	--EXECUTE CollectIT.dbo.USP_InvoiceNote @Company, @DocumentNumber, @Action, @NoteText
END