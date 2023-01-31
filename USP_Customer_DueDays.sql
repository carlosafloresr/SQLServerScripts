CREATE PROCEDURE USP_Customer_DueDays
		@Company		Varchar(5),
		@Customer		Varchar(20)
AS
/*
***************************************************************************
  PURPOSE: Return the customer due days based on the assigned payment terms
  USED ON: This will be called from GP SOP_Blank_Invoice report on each 
	       invoice.
CRATED BY: CARLOS A. FLORES
		   09/13/2021 11:37 AM
***************************************************************************
EXECUTE USP_Customer_DueDays 'DNJ','10313'
***************************************************************************
*/
SET NOCOUNT ON

DECLARE	@Query			Varchar(1000),
		@ReturnValue	Int = 15

DECLARE @tblDueDays		Table (DueDays Int)

SET @Query = N'SELECT DUEDTDS FROM ' + @Company + '.dbo.SY03300 WHERE PYMTRMID IN (SELECT PYMTRMID FROM ' + @Company + '.dbo.RM00101 WHERE CUSTNMBR = ''' + @Customer + ''')'

INSERT INTO @tblDueDays
EXECUTE(@Query)

IF @@ROWCOUNT > 0
	SET @ReturnValue = (SELECT DueDays FROM @tblDueDays)

SELECT	@ReturnValue AS DueDays
GO