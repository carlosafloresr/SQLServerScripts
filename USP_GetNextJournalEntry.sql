ALTER PROCEDURE USP_GetNextJournalEntry
AS
DECLARE @l_tINCheckWORKFiles	tinyint = 1,
		@I_iSQLSessionID		int = USER_SID(),
		@O_tOUTOK				tinyint,
		@IO_iOUTJournalEntry	int = 1,
		@O_iErrorState			int

EXECUTE glGetNextJournalEntry
		@l_tINCheckWORKFiles,
		@I_iSQLSessionID,
		@IO_iOUTJournalEntry OUTPUT,
		@O_tOUTOK OUTPUT,
		@O_iErrorState OUTPUT

RETURN @IO_iOUTJournalEntry

/*
CREATE PROCEDURE USP_GetNextJournalEntry
AS
DECLARE	@IO_iOUTJournalEntry	Int, 
		@O_tOUTOK				Tinyint, 
		@O_iErrorState			Int
  
SELECT	@IO_iOUTJournalEntry = 0, 
		@O_tOUTOK = 0, 
		@O_iErrorState = 0  
  
--EXECUTE dbo.glGetNextJournalEntry 0, 0, @IO_iOUTJournalEntry OUT, @O_tOUTOK OUT, @O_iErrorState OUT
EXECUTE dbo.USP_GetNextJournalNumber 1, @IO_iOUTJournalEntry OUT, @O_iErrorState OUT
  
PRINT @IO_iOUTJournalEntry
RETURN @IO_iOUTJournalEntry

/*
EXECUTE dbo.USP_GetNextJournalEntry
*/
*/