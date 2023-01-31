CREATE PROCEDURE USP_DeletePopUpRecord
		@RecordId		Int,
		@Company		Varchar(5),
		@GLAccount		Varchar(15)
AS
DECLARE	@ReturnValue	Int
EXECUTE @ReturnValue	= USP_FindPopUpType @Company, @GLAccount, NULL, NULL

IF @ReturnValue = 20
	DELETE DEX_ER_PopUps WHERE DEX_ER_PopUpsId = @RecordId
ELSE
	DELETE DEX_ET_PopUps WHERE DEX_ET_PopUpsId = @RecordId
	
GO